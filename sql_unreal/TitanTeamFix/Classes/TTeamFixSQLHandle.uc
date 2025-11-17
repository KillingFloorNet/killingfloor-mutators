//============================================================
// TTeamFixSQLHandle.uc		- Class for automating some tasks with an SQLLink
//============================================================
//	TitanTeamFix
//		+ Coded by Shambler (Shambler@OldUnreal.com or Shambler__@Hotmail.com)
//		- A modular team balancing mutator initially coded for the Titan servers
//			http://ut2004.titaninternet.co.uk/
//
//============================================================
//
// This class handles initializing the SQLLink, connecting to
// the SQL server, automatic database/table creation and
// notifying the owner object of query results using the
// ResultDel delegate
//
//============================================================
Class TTeamFixSQLHandle extends Info
	config(TitanTeamFix);

var SQLLink SQLObj;

var bool bConnected;
var byte SentDBQuery;

var string	SQLServerIP;
var bool	bResolveIPString;
var int		SQLServerPort;
var string	SQLUser;
var string	SQLPassword;
var string	SQLDatabase;

var int		SQLLinkPort;


// Wether or not to automaticly create a new database, if the current one doesn't exist...this should only ever happen ONCE if at all
var bool	bAutoCreateDatabase;
var bool	bAutoCreateTable;
var bool	bCheckDatabaseExists;
var bool	bCheckTableExists;

var bool	bCurrentDatabaseExists;
var string	LastDatabase;

var string CreateTableQuery;


delegate ResultDel();		// IMPORTANT, this delegate is ONLY VALID BEFORE CALLING INITIALIZE HANDLE
delegate UpdateSQLConfig();


function InitializeHandle()
{
	SQLObj = Spawn(Class'SQLLink');

	SQLObj.AuthSuccess = SQLConnected;
	SQLObj.Disconnected = SQLDisconnected;
	SQLObj.QueryResult = InternalResultDel;
	SQLObj.QueryError = SQLQueryError;


	// If we are not sure if the database exists, don't specify the database when connecting (instead, check if it exists after connecting)
	if ((bAutoCreateDatabase && (bCheckDatabaseExists || !bCurrentDatabaseExists || LastDatabase != SQLDatabase)))
	{
		GotoState('CreateDatabase');

		if (!SQLObj.SQLConnect(SQLServerIP, bResolveIPString, SQLServerPort, SQLUser, SQLPassword, "", SQLLinkPort))
			return;
	}
	else if (bAutoCreateTable && (bCheckTableExists || !bCurrentDatabaseExists || LastDatabase != SQLDatabase))
	{
		GotoState('CreateDatabase');

		if (SQLObj.SQLConnect(SQLServerIP, bResolveIPString, SQLServerPort, SQLUser, SQLPassword, SQLDatabase, SQLLinkPort))
			return;
	}
	else if (!SQLObj.SQLConnect(SQLServerIP, bResolveIPString, SQLServerPort, SQLUser, SQLPassword, SQLDatabase, SQLLinkPort))
	{
		return;
	}
}

function InternalResultDel()
{
	ResultDel();
}

function SQLConnected()
{
	bConnected = True;
}

function SQLDisconnected()
{
	SQLObj.Destroy();
	Destroy();
}

function SQLQueryResult();

function SQLQueryError(string Msg)
{
	Log("Received error while waiting for query result:"@Msg, 'TTF_SQL');
}


// Special state which checks if the specified database (SQLDatabase) or table exists before enabling queries, and will create the specified database if it doesn't already exist
state CreateDatabase
{
	function EndState()
	{
		Global.SQLConnected();
	}

	function SQLConnected()
	{
		// Send a query to see if the current database exists
		if (bAutoCreateDatabase)
		{
			SQLObj.SendQuery("USE"@SQLDatabase);
		}
		else if (bAutoCreateTable)
		{
			SentDBQuery = 3;
		}	SQLObj.SendQuery(CreateTableQuery);
	}

	function InternalResultDel()
	{
		if (SQLObj.ResultData.Length < 5)
		{
			Log("Received invalid packet, closing connection", 'TTF_SQL');
			SQLObj.Close();

			return;
		}


		// Check if an 'OK' packet (database exists) or an 'Error' packet (database doesn't exist) was received

		// OK packet
		if (SQLObj.ResultData[4] == 0)
		{
			if (SentDBQuery == 0)
			{
				Log("'"$SQLDatabase$"' database already exists", 'TTF_SQL');

				bCurrentDatabaseExists = True;
				LastDatabase = SQLDatabase;

				UpdateSQLConfig();


				// UPDATE: I want this to also check that the table exists anyway, even if the database already exists
				if (bAutoCreateTable)
				{
					Log("Requesting creation of table", 'TTF_SQL');

					SentDBQuery += 3;
					SQLObj.SendQuery(CreateTableQuery);
				}
				else
				{
					// Exit this state, now ready to send/receive queries
					GotoState('');
				}
			}
			else if (SentDBQuery == 1)
			{
				bCurrentDatabaseExists = True;
				LastDatabase = SQLDatabase;

				//SaveConfig();
				UpdateSQLConfig();

				Log("'"$SQLDatabase$"' database created, requesting use of that database", 'TTF_SQL');


				SentDBQuery++;
				SQLObj.SendQuery("USE"@SQLDatabase);
			}
			else if (SentDBQuery == 2)
			{
				SentDBQuery++;

				if (!bAutoCreateTable)
				{
					Log("Successfully set database", 'TTF_SQL');

					// Exit this state
					GotoState('');
					return;
				}


				Log("Successfully set database, now creating table for holding player data", 'TTF_SQL');

				// Not hardcoded anymore, allows more flexibility
				SQLObj.SendQuery(CreateTableQuery);
			}
			else// if (SentDBQuery == 3)
			{
				bCurrentDatabaseExists = True;
				LastDatabase = SQLDatabase;

				//SaveConfig();
				UpdateSQLConfig();


				Log("Successfully created player data table, database is now setup and ready to work with TitanTeamFix", 'TTF_SQL');

				// Exit this state, now ready to send/receive queries
				GotoState('');
			}
		}
		// Error packet
		else if (SQLObj.ResultData[4] == 255)
		{
			if (SentDBQuery == 0)
			{
				// Determine what the error ID was, if it was not 'database does not exist' then we can't handle the error and the connection must be closed
				if (SQLObj.ResultData[5] != 25 || SQLObj.ResultData[6] != 4)
				{
					Log("Expected a 'database does not exist' error but got:"@Class'SQLLink'.static.ParseErrorPacket(SQLObj.ResultData), 'TTF_SQL');
					SQLObj.Close();

					return;
				}

				// If the code reaches here, we have received the correct error type...now ask the SQL server to create a new database named after the value in SQLDatabase
				SentDBQuery++;
				Log("Requesting creation of '"$SQLDatabase$"' database", 'TTF_SQL');

				SQLObj.SendQuery("CREATE DATABASE"@SQLDatabase);
			}
			else if (SentDBQuery == 1)
			{
				Log("Error while attempting to create database, closing connection"@Class'SQLLink'.static.ParseErrorPacket(SQLObj.ResultData), 'TTF_SQL');
				SQLObj.Close();

				return;
			}
			else if (SentDBQuery == 2)
			{
				Log("Error selecting newly created database, closing connection"@Class'SQLLink'.static.ParseErrorPacket(SQLObj.ResultData), 'TTF_SQL');
				SQLObj.Close();

				return;
			}
			else// if (SentDBQuery == 3)
			{
				if ((SQLObj.ResultData[6] << 8) + SQLObj.ResultData[5] == 1050)
				{
					Log("Table already exists", 'TTF_SQL');
					GotoState('');
				}
				else
				{
					Log("Error while attempting to create table, closing connection"@Class'SQLLink'.static.ParseErrorPacket(SQLObj.ResultData), 'TTF_SQL');
					SQLObj.Close();
				}

				return;
			}
		}
		// Bad packet
		else
		{
			Log("Received invalid response packet, closing connection", 'TTF_SQL');
			SQLObj.Close();

			return;
		}
	}
}


defaultproperties
{
	bResolveIPString=False
	SQLDatabase="TitanTeamFix"

	SQLLinkPort=0

	bAutoCreateDatabase=True
	bAutoCreateTable=True
	bCurrentDatabaseExists=False
	LastDatabase=""
}