//============================================================
// TTeamFixStatsBalance.uc		- Specialised balancing which relies on a MySQL stats database
//============================================================
//	TitanTeamFix
//		+ Coded by Shambler (Shambler@OldUnreal.com or Shambler__@Hotmail.com)
//		- A modular team balancing mutator initially coded for the Titan servers
//			http://ut2004.titaninternet.co.uk/
//
//============================================================
Class TTeamFixStatsBalance extends TTeamFixGeneric
	config(TitanTeamFix);

// Steps:
/*
99%	- Gather as much incoming player data as possible up until a second before the match starts
	done	- Connect to the SQL server
	done	- As players join, cache their GUID's and 5 seconds before the match starts query the SQL server for the cached GUID's
	done	- Past those 5 seconds, only cache GUID's over the course of a tick...then at the end of the tick, send the query
		done	- As queries are sent, cache the guid in a guid+float struct in this class and initialize the float to -1.0
		done	- If a players guid is not in the database, add it immediatly
	done	- As query results are received from the SQL server, cache them in the guid+float struct
		done	- Also, after the query results are received check for any missing query results and set PlayerValue to a default value


90%	- Use the remaining second to iteratively call the player sorting algorithm over the course of many ticks
	done	- Initialize (and maintain by verifying each tick before match start) a struct containing each players PRI and his/her index into QueryCache
	test	- Start the first tick by initialising the two team lists, sort the main list by PlayerValue and then put every second element on the list to one side
	test	- Limit it to 'x' amount of iterations per tick to avoid infinite loops


test	- Upon match start, sort the teams based upon the sorting results
	test	- Use the shuffle code but try to cut down on switch messages...just have one message "TitanTeamFix: Finished balancing team stats"



test	- If a new player joins when the teams are balanced, query for his stats and recalculate each teams combined 'value' and put the player on the appropriate team
	done	- If his stats don't exist then create them immediatly

test	- When a player leaves (or becomes a spectator) after being in the game for more than 5 minutes, gather his stats from the game and cache them


75%	- When the game ends calculate the updated stats for all players and average the new values into the database
	test	- First of all, start reconnecting to the SQL server
	test	- Add everyone to the UpdateCache list if they aren't already there and set the exit timestamps
	test	- Process the player stats and construct the SQL update query
	50%	- Send the query and close the SQL server connection, perhaps add a way to prevent the game from ending (like in Wormbo's IRC tool) if this takes a while



	MAJOR TODO:
	done	- You haven't yet replaced PPH in the tables with PPPG!!!!
	test	- You screwed up the WinRatio calculations in the SQL query, fix that and rename WinRatio to GamesWon or something
	test	- You aren't closing the SQL server connection yet, get that done
		- Retest the automatic stat database creation....might have broken it while merging with TTF, because of how the query result delegate is different
	done	- Add a way of differentiating between gametypes...you really should expand the code to work with the more flexible config system
		- At some stage in the future (when everything is working) add some code to monitor team switches, and make it so a player has to be on team x for 5 minutes
			before he can be considered as a contribution to that team winning
		- Go over the code and try to find problems related to multiple people joining with same GUID
		- Make sure the exiting players score can be otained from 'PlayerExitingGame', test with both exiting server and spectating
		- Tweak the player join code so that it doesn't modify any lists once the game has ended
		- Modify the database layout so you can keep the stats accurate independant of playercount (4 players on a 32 player server will fuck up stats)
		- Index that database
		- Integrate fnenu's stat system, i.e. total points / games played (which is reset if the player isn't around for x amount of days)
		- Rewrite this class, there is a lot of messed up code
*/



// Struct used for handling outgoing query requests and incoming query results
struct PlayerQueryCache
{
	var string GUID;
	var float PlayerValue;
	var float JoinTimeStamp;	// Used for determining when this player last joined the current game
};

// Struct which is used for keeping a local playerlist
struct PlayerSortData
{
	var PlayerReplicationInfo PRI;	// For verifying players existence aswel as checking other things
	var int QCIndex;		// Index of this player into the query cache
};

// Struct used to represent a new team
struct SortList
{
	var array<byte> PDIndex;	// Index into the PlayerData array..IMPORTANT: THIS IS VOLATILE, every time you check the value of this check it's valid first
	var float TeamValue;
};

// Struct for storing player data until the game ends, contains all required player stats
struct PlayerUpdateCache
{
	var int QCIndex;
	var int PlayerScore;
	var byte MainTeam;		// The team which the player was on the most (currently this is just the players 'last' team, I need to tweak this later)
	var array<Range> PlayTime;	// Min = Timestamp of players entry into game, Max = Timestamp of players exit (or game end), this is an array because the player can leave and come back
};


var byte StartStage;
var TTeamFixSQLHandle SQLHandle;


// Lists for keeping track of sent queries and the query results
var array<PlayerQueryCache> QueryCache;
var array<int> OutgoingQueryIndex;	// Used to cache multiple GUID's which are used to query the SQL server (the more guids you query at the same time the more efficient)
var array<int> IncomingQueryIndex;	// Used to speed up sorting of incoming query result aswel as detect player entries which are not yet in the database
var bool bPendingQueryFlush;


// Lists/variables for maintaining the team balancers local player list
var array<PlayerSortData> PlayerData;
var array<int> UninitializedQueries;	// Index of players that have not yet received query results
var bool bInitialSorting;		// If true, the games initial sorting is currently taking place


// The main team balancing list
var SortList SortedTeam[2];
var bool bSortListInitialized;		// Used to determine if it's ok the modify the SortedTeam lists


// List containing player stats from the current game, the results of which are fed to the stats database when the game ends
var array<PlayerUpdateCache> UpdateList;
var array<string> EndGameQueries;


// Config variables
var config string SQLBalanceQuery;	// The actual SQL query which gathers and formulates various player data, returning a single value representing the players 'worth'
					//	%g is replaced with a string of guids, like so: "GUID='blah'||GUID='blah2'"
var config string	SQLServerIP;
var config bool		bResolveIPString;
var config int		SQLServerPort;
var config string	SQLUser;
var config string	SQLPassword;
var config string	SQLDatabase;

var config int		SQLLinkPort;

var config string	SQLTableName;
var config bool		bPrefixGameToTable;
var config bool		bPrefixProfileToTable;


// Wether or not to automaticly create a new database, if the current one doesn't exist...this should only ever happen ONCE if at all
var config bool		bAutoCreateDatabase;
var config bool		bAutoCreateTable;
var config bool		bCurrentDatabaseExists;
var config string	LastDatabase;


var string FinalTableName;
var string FinalBalanceQuery;

var bool bPreEndGameQuery;
var bool bEndGameTimer;
var bool bTTFGameEnded;

// test stuff
var bool bDebugLog;
var bool bNewResultCode;

//var bool bDebugDisable;

var deprecated int RemoveThisDebugCode;	// Handy for making compile-time warnings which point you to specific code....great for making sure you don't forget something! (just do 'var = blah;')
var deprecated int TODO;



var bool bBotTest;
var string TestGUIDS[32];
//var string TestNames[32];
var float JoinTimes[32];
var float ExitTimes[32];

struct DelayedBotJoin
{
	var bool bJoined;
	var int idx;
	var Controller c;
	var string GUID;
};

var array<DelayedBotJoin> DelayedBotList;

var string CurTestGUID;




function PostBeginPlay()
{
	local int i;

	Super.PostBeginPlay();

	Tag = 'EndGame';

	Enable('Tick');


	// Before anything, construct the final table name and balance query
	if (bPrefixGameToTable)
	{
		FinalTableName = String(Level.Game.Class);
		FinalTableName = Mid(FinalTableName, InStr(FinalTableName, ".") + 1)$"_";
	}

	if (bPrefixProfileToTable && bLoadConfigProfile)
		FinalTableName $= class'TTeamFixConfigLoader'.default.ActiveConfiguration$"_";

	FinalTableName $= SQLTableName;

	Log("Final database table name is:"@FinalTableName, 'TitanTeamFix');

	i = InStr(SQLBalanceQuery, "%t");

	FinalBalanceQuery = Left(SQLBalanceQuery, i)$FinalTableName$Mid(SQLBalanceQuery, i+2);


	// Now setup the SQLHandle, which interfaces with an SQLLink object
	CreateSQLHandle();
	SQLHandle.ResultDel = InitialQueryResult;
	SQLHandle.InitializeHandle();


	if (bBotTest)
	{
		TestGUIDs[0] = "813d9838b8656926e3259da6ad05fb39";
		TestGUIDS[1] = "19d9f7192232d32cc0500f262c382847";
		TestGUIDS[2] = "d8fae9bf6ee33711c89b326d09eb65ba";
		TestGUIDS[3] = "5469096c89bbaeb8dfac50cc4e660531";
		TestGUIDS[4] = "33b7870ac38f713fc880af8a01f61830";
		TestGUIDS[5] = "1e32af0b7989edcdc9e4031315431337";
		TestGUIDS[6] = "6418fab4f42296c046a26cae77d8e248";
		TestGUIDS[7] = "b4e454debb93b7d23bda5844f1c00457";
		TestGUIDS[8] = "c6e1dba01dd6c6b6c4c2c530e7449f41";
		TestGUIDS[9] = "cc032fc7ea3bc7cb3d445d1081f42033";
		TestGUIDS[10] = "38b8008b15c8631b436325c7fd3015bb";
		TestGUIDS[11] = "efbd0abc68d4985ec01d25969f5e70a2";
		TestGUIDS[12] = "50901bfc9eb23174651089c2f7657ccb";
		TestGUIDS[13] = "dd07b85a4e230709fe343eb12896c780";
		TestGUIDS[14] = "957f7f9aa6c3f4c21222f923d6d3ef23";
		TestGUIDS[15] = "fbfe6d78aa122d5f574f7fb0f7a473f6";
		TestGUIDS[16] = "e0c8ab2947b32f1ee3e6cdb03c4df739";
		TestGUIDS[17] = "a8781d601c5027a2d5909efc003359b2";
		TestGUIDS[18] = "0907d84ff49b481a0c0e3a9402022f96";
		TestGUIDS[19] = "8bac3e36df65be37ae6c580defba097d";
		TestGUIDS[20] = "17a4651b3c6e7c7a443f61315435aa61";
		TestGUIDS[21] = "6c65cae701bc1194c3bd3595d4ca11dd";
		TestGUIDS[22] = "b28d500a9c5129d537407a4b357426c6";
		TestGUIDS[23] = "6e5bc5e16a406ec1e792845536c83714";
		TestGUIDS[24] = "9c5997dfda810903533b6dc329561063";
		TestGUIDS[25] = "9198cbe723d3d3defc278e4efafbad05";
		TestGUIDS[26] = "8ef012497c4e64f0b65ab47050d66111";
		TestGUIDS[27] = "36f6e8608ed87cc226ebaee0b3293bae";
		TestGUIDS[28] = "96fa80211e30e86340ef1114f75721dc";
		TestGUIDS[29] = "91202cda57210864ddcb8d9a0825af04";
		TestGUIDS[30] = "d408d368e07c58eb280d364037a8b234";
		TestGUIDS[31] = "85087fd03b188c3d8c85c69a89043a48";

	/*
		TestNames[0] = "A";
		TestNames[1] = "B";
		TestNames[2] = "C";
		TestNames[3] = "D";
		TestNames[4] = "E";
		TestNames[5] = "F";
		TestNames[6] = "G";
		TestNames[7] = "H";
	*/

	
		JoinTimes[0] = 8.295923;
		JoinTimes[1] = 8.295923;
		JoinTimes[2] = 8.295923;
		JoinTimes[3] = 8.295923;
		JoinTimes[4] = 8.295923;
		JoinTimes[5] = 8.295923;
		JoinTimes[6] = 8.295923;
		JoinTimes[7] = 8.295923;
	/*
		JoinTimes[8] = 8.295923;
		JoinTimes[9] = 8.295923;
		JoinTimes[10] = 8.295923;
		JoinTimes[11] = 8.295923;
		JoinTimes[12] = 8.295923;
		JoinTimes[13] = 8.295923;
		JoinTimes[14] = 8.295923;
		JoinTimes[15] = 8.295923;
		JoinTimes[16] = 8.295923;
		JoinTimes[17] = 8.295923;
		JoinTimes[18] = 8.295923;
		JoinTimes[19] = 8.295923;
		JoinTimes[20] = 8.295923;
		JoinTimes[21] = 8.295923;
		JoinTimes[22] = 8.295923;
		JoinTimes[23] = 8.295923;
		JoinTimes[24] = 8.295923;
		JoinTimes[25] = 8.295923;
		JoinTimes[26] = 8.295923;
		JoinTimes[27] = 8.295923;
		JoinTimes[28] = 8.295923;
		JoinTimes[29] = 8.295923;
		JoinTimes[30] = 8.295923;
		JoinTimes[31] = 8.295923;
	*/

		for (i=8; i<ArrayCount(JoinTimes); ++i)
		{
			JoinTimes[i] = float(Level.Game.TimeLimit) * RandRange(1.0, 34.0);

			if (bDebugLog)
				Log("JoinTime("$i$") is:"@JoinTimes[i], 'TitanTeamFix');
		}

		for (i=0; i<ArrayCount(ExitTimes)-8; ++i)
			ExitTimes[i] = float(Level.Game.TimeLimit) * RandRange(35.0, 60.0);
	}
}

function CreateSQLHandle(optional bool bForceDisableAutoCreate)
{
	if (SQLHandle != none)
		return;

	SQLHandle = Spawn(Class'TTeamFixSQLHandle');

	SQLHandle.UpdateSQLConfig = UpdateSQLConfig;
	SQLHandle.CreateTableQuery = "create table"@FinalTableName$"(GUID char(32),PPPG int,GamesPlayed int,GamesWon int,RecentPPPG int,LastGame datetime)";

	SQLHandle.SQLServerIP			= SQLServerIP;
	SQLHandle.bResolveIPString		= bResolveIPString;
	SQLHandle.SQLServerPort			= SQLServerPort;
	SQLHandle.SQLUser			= SQLUser;
	SQLHandle.SQLPassword			= SQLPassword;
	SQLHandle.SQLDatabase			= SQLDatabase;
	SQLHandle.SQLLinkPort			= SQLLinkPort;
	SQLHandle.bAutoCreateDatabase		= bAutoCreateDatabase;
	SQLHandle.bAutoCreateTable		= bAutoCreateTable;

	// On a multi-gametype server, the table name is liable to change a lot with bPrefixGameToTable set to True. So make sure the SQLHandle checks the table all the time
	if (bForceDisableAutoCreate)
	{
		SQLHandle.bCurrentDatabaseExists = True;
		SQLHandle.LastDatabase = SQLDatabase;
	}
	else if (bPrefixGameToTable)
	{
		SQLHandle.bCurrentDatabaseExists = False;
		SQLHandle.LastDatabase = "";
		SQLHandle.bCheckTableExists = True;
	}
	else
	{
		SQLHandle.bCurrentDatabaseExists	= bCurrentDatabaseExists;
		SQLHandle.LastDatabase			= LastDatabase;
	}

}

function UpdateSQLConfig()
{
	bCurrentDatabaseExists = SQLHandle.bCurrentDatabaseExists;
	LastDatabase = SQLHandle.LastDatabase;

	if (bLoadConfigProfile && ConfigObject != none)
		ConfigObject.SaveProperties(Self);
	else
		SaveConfig();
}


function Tick(float DeltaTime)
{
	local Controller c;
	local int iTempInt, i, j, k, l;
	local byte idx;
	local PlayerReplicationInfo TempPRI;
	local float ValueDiff, BestValue, TempValue;
	local byte SwitchList[2];

/*
	for (i=0; i<ArrayCount(TestGUIDS); ++i)
	{
		if (TestGUIDS[i] == "")
			break;

		if (JoinTimes[i] > 0 && JoinTimes[i] - Level.TimeSeconds < 0)
		{
			JoinTimes[i] = -1.0;

			CurTestGUID = TestGUIDS[i];

			// Prevent an accessed none
			Class'PlayerReplicationInfo'.default.bBot = True;

			TempPRI = Spawn(Class'PlayerReplicationInfo');
			TempPRI.PlayerName = TestNames[i];

			Class'PlayerReplicationInfo'.default.bBot = False;


			PlayerJoinedGame(TempPRI);
		}
	}
*/

	if (bBotTest)
	{
		for (i=0; i<DelayedBotList.Length; ++i)
		{
			if (DelayedBotList[i].bJoined)
				continue;

			DelayedBotList[i].bJoined = True;
			CurTestGUID = DelayedBotList[i].GUID;
			PlayerJoinedGame(DelayedBotList[i].c.PlayerReplicationInfo);
		}


		for (i=0; i<ArrayCount(TestGUIDS); ++i)
		{
			if (JoinTimes[i] > 0 && JoinTimes[i] - Level.TimeSeconds < 0)
			{
				TeamGame(Level.Game).AddBots(1);

				JoinTimes[i] = -1.0;

				DelayedBotList.Length = DelayedBotList.Length + 1;

				for (c=Level.ControllerList; c!=none; c=c.NextController)
					if (c.NextController == none)
						DelayedBotList[DelayedBotList.Length-1].c = c;

				DelayedBotList[DelayedBotList.Length-1].GUID = TestGUIDS[i];
				DelayedBotList[DelayedBotList.Length-1].idx = i;
			}
		}

		for (i=0; i<ArrayCount(ExitTimes); ++i)
		{
			if (ExitTimes[i] > 0 && ExitTimes[i] - Level.TimeSeconds < 0)
			{
				ExitTimes[i] = -1.0;

				for (j=0; j<DelayedBotList.Length; ++j)
				{
					if (DelayedBotList[j].idx == i)
					{
						PlayerExitingGame(DelayedBotList[j].c);
						DelayedBotList[j].c.Destroy();

						break;
					}
				}
			}
		}
	}

	if (Level.Game.IsInState('PendingMatch') && DeathMatch(Level.Game).bStartedCountDown)
	{
		// If a previous query flush failed while awaiting authentication, see if it can be done now
		if (bPendingQueryFlush && SQLHandle.bConnected)
		{
			bPendingQueryFlush = False;
			FlushQueries();
		}

		if (StartStage == 0)	// Stage 0: Query the SQL server for the current player data
		{
			FlushQueries();
			StartStage++;
		}
		else if (StartStage == 1) // Stage 1: Initialize the player balancing lists one second before the match starts
		{
			if (DeathMatch(Level.Game).CountDown <= 1)
			{
				bInitialSorting = True;
				StartStage++;

				// Initialize player balancing list
				for (c=Level.ControllerList; c!=none; c=c.NextController)
					if (AIController(c) == none && c.PlayerReplicationInfo != none && !c.PlayerReplicationInfo.bOnlySpectator)
						AddToBalanceList(c.PlayerReplicationInfo, PlayerController(c).GetPlayerIDHash());

				if (bBotTest)
				{
					i = 0;

					for (c=Level.ControllerList; c!=none; c=c.NextController)
					{
						if (AIController(c) != none)
						{
							while (i<ArrayCount(JoinTimes))
							{
								++i;

								if (JoinTimes[i-1] < 0)
								{
									AddToBalanceList(c.PlayerReplicationInfo, TestGUIDS[i-1]);
									break;
								}
							}
						}
					}
				}
			}
		}
		else if (StartStage == 2) // Stage 2: Continuously rebalance the player data until the match starts
		{
			// Instantly query for any new players info
			if (OutgoingQueryIndex.Length > 0 && (SQLHandle.bConnected || !bPendingQueryFlush))
				FlushQueries();


			// If there are uninitialized cache queries, check if they have been initialized since the last tick
			for (i=0; i<UninitializedQueries.Length; ++i)
			{
				iTempInt = QueryCache[UninitializedQueries[i]].PlayerValue;

				// This query cache entry has been initialized, modify the pre-game balance calculations to suit
				if (iTempInt != -1.0)
				{
					// Reposition the entry within the PlayerData struct
					for (j=0; j<PlayerData.Length; ++j)
					{
						if (PlayerData[j].QCIndex == UninitializedQueries[i])
						{
							TempPRI = PlayerData[j].PRI;
							PlayerData.Remove(j, 1);

							break;
						}
					}


					// BEFORE the initial sort list is generated, PlayerData MUST be sorted in-order from highest player value to lowest...but after the initial
					//	sort list is generated, you MUST keep the SortedTeam lists PlayerData indicies correct! which means you must put the new entries at
					//	the end of the list at that stage
					if (bSortListInitialized)
						j = Max(PlayerData.Length - 1, 0);
					else
						j = FindPlayerDataPos(iTempInt);


					PlayerData.Insert(j, 1);
					PlayerData[j].PRI = TempPRI;
					PlayerData[j].QCIndex = UninitializedQueries[i];



					// If the code has begun the team-balancing calculations then add this player to one of the team lists
					if (bSortListInitialized)
					{
						// PDIndex.Length is the same as playercount
						if (SortedTeam[0].PDIndex.Length == SortedTeam[1].PDIndex.Length)
						{
							if (SortedTeam[0].TeamValue == SortedTeam[1].TeamValue)
								idx = Rand(1);
							else if (SortedTeam[0].TeamValue < SortedTeam[1].TeamValue)
								idx = 0;
							else
								idx = 1;
						}
						else if (SortedTeam[0].PDIndex.Length < SortedTeam[1].PDIndex.Length)
						{
							idx = 0;
						}
						else
						{
							idx = 1;
						}


						iTempInt = SortedTeam[idx].PDIndex.Length;

						SortedTeam[idx].PDIndex.Length = iTempInt + 1;
						SortedTeam[idx].PDIndex[iTempInt] = j;

						SortedTeam[idx].TeamValue += QueryCache[UninitializedQueries[i]].PlayerValue;
					}




					// Now remove the uninitialized queries value
					UninitializedQueries.Remove(i, 1);
					--i;
				}
			}


			// If the team lists haven't been initialized, initialize them (every even player on team 0, every odd player on team 1)
			if (!bSortListInitialized)
			{
				bSortListInitialized = True;

				for (i=0; i<PlayerData.Length; ++i)
				{
					// Obviously, don't add spectators
					if (PlayerData[i].PRI.bOnlySpectator)
						continue;


					j = (i + 1) % 2;

					SortedTeam[j].PDIndex.Length = SortedTeam[j].PDIndex.Length + 1;
					SortedTeam[j].PDIndex[SortedTeam[j].PDIndex.Length-1] = i;


					// Increase the teams total value relative to the current player
					if (QueryCache[PlayerData[i].QCIndex].PlayerValue != -1.0)
						SortedTeam[j].TeamValue += QueryCache[PlayerData[i].QCIndex].PlayerValue;
				}
			}



			// Pre-balance list checking (check for players that have left)
			for (k=0; k<2; ++k)
			{
				l = int(!bool(k));

				for (i=0; i<SortedTeam[k].PDIndex.Length; ++i)
				{
					if (PlayerData[SortedTeam[k].PDIndex[i]].PRI == none)
					{
						SortedTeam[k].TeamValue -= QueryCache[PlayerData[SortedTeam[k].PDIndex[i]].QCIndex].PlayerValue;
						SortedTeam[k].PDIndex.Remove(i, 1);

						// If the other team is already a player ahead then it is now two players ahead, you will have to switch a player here
						if (SortedTeam[l].PDIndex.Length > SortedTeam[k].PDIndex.Length)
						{
							// Try to find the most suitable player to switch
							ValueDiff = (SortedTeam[l].TeamValue - SortedTeam[k].TeamValue) * 0.5;
							BestValue = -1.0;
							idx = 255;

							for (j=0; j<SortedTeam[l].PDIndex.Length; ++j)
							{
								// Switch the player with lowest value if the bigger team has less value than the smaller, otherwise the most 'balanced' switch
								if (ValueDiff <= 0)
									TempValue = QueryCache[PlayerData[SortedTeam[l].PDIndex[j]].QCIndex].PlayerValue;
								else
									TempValue = Abs(QueryCache[PlayerData[SortedTeam[l].PDIndex[j]].QCIndex].PlayerValue - ValueDiff);

								if (TempValue < BestValue || BestValue < 0)
								{
									BestValue = TempValue;
									idx = j;
								}
							}


							// Switch the player between lists
							if (idx != 255)
							{
								SortedTeam[k].PDIndex.Length = SortedTeam[k].PDIndex.Length + 1;
								SortedTeam[k].PDIndex[SortedTeam[k].PDIndex.Length-1] = SortedTeam[l].PDIndex[idx];

								BestValue = QueryCache[PlayerData[SortedTeam[l].PDIndex[idx]].QCIndex].PlayerValue;

								if (BestValue != -1.0)
								{
									SortedTeam[k].TeamValue += BestValue;
									SortedTeam[l].TeamValue -= BestValue;
								}

								SortedTeam[l].PDIndex.Remove(idx, 1);
							}
						}
					}
				}
			}



			// Main balance calculation loop
			iTempInt = SortedTeam[0].PDIndex.Length * SortedTeam[1].PDIndex.Length;

			if (iTempInt != 0)
			{
				TempValue = SortedTeam[1].TeamValue - SortedTeam[0].TeamValue;
				BestValue = TempValue;

				for (i=0; iTempInt*i<1024; ++i)
				{
					for (j=0; j<SortedTeam[0].PDIndex.Length; ++j)
					{
						if (QueryCache[PlayerData[SortedTeam[0].PDIndex[j]].QCIndex].PlayerValue == -1.0)
							continue;

						for (k=0; k<SortedTeam[1].PDIndex.Length; ++k)
						{
							if (QueryCache[PlayerData[SortedTeam[1].PDIndex[k]].QCIndex].PlayerValue == -1.0)
								continue;

							ValueDiff = QueryCache[PlayerData[SortedTeam[1].PDIndex[k]].QCIndex].PlayerValue -
									QueryCache[PlayerData[SortedTeam[0].PDIndex[j]].QCIndex].PlayerValue;

							if (TempValue < 0.0 && ValueDiff > 0.0 || TempValue > 0.0 && ValueDiff < 0.0)
								continue;

							ValueDiff = Abs(TempValue - ValueDiff);

							if (ValueDiff < BestValue)
							{
								BestValue = ValueDiff;

								SwitchList[0] = j;
								SwitchList[1] = k;
							}
						}
					}

					if (BestValue != TempValue)
					{
						// First update the team values and Temp/Best Value
						ValueDiff = QueryCache[PlayerData[SortedTeam[0].PDIndex[SwitchList[0]]].QCIndex].PlayerValue
							- QueryCache[PlayerData[SortedTeam[1].PDIndex[SwitchList[1]]].QCIndex].PlayerValue;

						SortedTeam[0].TeamValue -= ValueDiff;
						SortedTeam[1].TeamValue += ValueDiff;

						TempValue = SortedTeam[1].TeamValue - SortedTeam[0].TeamValue;
						BestValue = TempValue;


						// Now re-arrange the team lists
						j = SortedTeam[0].PDIndex[SwitchList[0]];

						SortedTeam[0].PDIndex[SwitchList[0]] = SortedTeam[1].PDIndex[SwitchList[1]];
						SortedTeam[1].PDIndex[SwitchList[1]] = j;
					}
				}
			}
		}
	}
	else if (Level.Game.bGameEnded)
	{
		if (SQLHandle == none)
		{
			if (!bBotTest)
				Disable('Tick');

			return;
		}

		// The endgame stat updates have to be delayed while waiting to reconnect and authenticate with the SQL server
		if (SQLHandle.bConnected && EndGameQueries.Length > 0)
		{
			if (bPreEndGameQuery)
				SQLHandle.SQLObj.SetQueryFilter(0xfe, 0xfe, true, true, true);
			else
				SQLHandle.SQLObj.SetQueryFilter(-1);

			for (i=0; i<EndGameQueries.Length; ++i)
			{
				if (bDebugLog)
					Log("Endgame delayed query being sent:"@EndGameQueries[i], 'TitanTeamFix');

				SQLHandle.SQLObj.SendQuery(EndGameQueries[i]);
			}


			EndGameQueries.Length = 0;

			if (!bBotTest)
				Disable('Tick');
		}
	}
	else if (DeathMatch(Level.Game).bStartedCountDown && !bBotTest)
	{
		Disable('Tick');
	}
}

// Called on all actors through gameinfo
function MatchStarting()
{
	//local controller c;
	local int i, j;
	local FileLog SQLLog;
	local float DebugFloat;

	if (StartStage == 2)
	{
		//for (c=Level.ControllerList; c!=none; c=c.NextController)
		//	if (PlayerController(c) != none)
		//		PlayerController(c).ClientMessage(Class'GameInfo'.static.MakeColorCode(MessageColor)$"TitanTeamFix: Sorting teams");

		bInitialSorting = False;
		StartStage++;


		// Sorting done, now put players on appropriate teams
		for (i=0; i<2; ++i)
			for (j=0; j<SortedTeam[i].PDIndex.Length; ++j)
				if (PlayerData[SortedTeam[i].PDIndex[j]].PRI.Team.TeamIndex != i)
					SwitchPlayer(Controller(PlayerData[SortedTeam[i].PDIndex[j]].PRI.Owner));


		// temp
		if (bDebugLog)
		{
			SQLLog = Spawn(Class'FileLog');
			SQLLog.OpenLog("TitanTeamFix_Debug", "txt"); 


			SQLLog.Logf("QueryCache data:");

			for (i=0; i<QueryCache.Length; ++i)
				SQLLog.Logf("----- GUID:"@QueryCache[i].GUID$", PlayerValue:"@QueryCache[i].PlayerValue);

			SQLLog.Logf("");
			SQLLog.Logf("Player Balance data:");

			for (i=0; i<PlayerData.Length; ++i)
				SQLLog.Logf("----- Value:"@QueryCache[PlayerData[i].QCIndex].PlayerValue$"     Name:"@PlayerData[i].PRI.PlayerName);

			SQLLog.Logf("");
			SQLLog.Logf("Pre-balance team mismatch:");

			for (i=0; i<PlayerData.Length; ++i)
				if (PlayerData[i].PRI != none && PlayerData[i].PRI.Team != none)
					DebugFloat += (1.0 - (2.0 * PlayerData[i].PRI.Team.TeamIndex)) * QueryCache[PlayerData[i].QCIndex].PlayerValue;

			SQLLog.Logf("----- Value:"@Abs(DebugFloat));

			SQLLog.Logf("");
			SQLLog.Logf("Post-balance team mismatch:");
			SQLLog.Logf("----- Value:"@Abs(SortedTeam[0].TeamValue - SortedTeam[1].TeamValue));

			SQLLog.Logf("");
			SQLLog.Logf("");
			SQLLog.Logf("");


			SQLLog.CloseLog();
		}


		UninitializedQueries.Length = 0;
		PlayerData.Length = 0;

		SortedTeam[0].PDIndex.Length = 0;
		SortedTeam[1].PDIndex.Length = 0;

		if (SQLHandle != none)
			SQLHandle.SQLObj.Close();
	}
}


function PlayerJoinedGame(PlayerReplicationInfo PRI)
{
	local string GUID;
	local int i;
	//local bool bSkipInOutIndex;

	Super.PlayerJoinedGame(PRI);


	//if (CurTestGUID != "" || PlayerController(PRI.Owner) != none)
	if (PlayerController(PRI.Owner) != none || (bBotTest && AIController(PRI.Owner) != none && CurTestGUID != ""))
	{
		// If the server has been waiting a long time for a player, it's likely that we have been disconnected from the SQL server
		if (Level.Game.IsInState('PendingMatch') && SQLHandle == none)
		{
			CreateSQLHandle(true);
			SQLHandle.ResultDel = InitialQueryResult;

			//if (bDebugLog)
			//	Log("PlayerJoinedGame, set ResultDel to InitialQueryResult");

			SQLHandle.InitializeHandle();
		}



		if (bBotTest && CurTestGUID != "")
		{
			if (bDebugLog)
				Log("Bot GUID:"@CurTestGUID$", ControllerType:"@string(PRI.Owner.Class), 'TitanTeamFix');

			GUID = CurTestGUID;
			CurTestGUID = "";
		}
		else
		{
			// ***
		/*
			if (Level.TimeSeconds > 60)
			{
				Log("Fake GUID");

				RemoveThisDebugCode = 0;
				GUID = TestGUIDs[Rand(31)];
			}
			else
			{
		*/
			// ***

				GUID = PlayerController(PRI.Owner).GetPlayerIDHash();
		//	}
		}

		// Shouldn't ever happen, but you never know
		if (GUID == "")
		{
			Log("ERROR: Players GUID not yet defined! TTF must be recoded to account for this", 'TitanTeamFix');
			return;
		}


		// Check that this players info isn't already in the QueryCache
		for (i=0; i<QueryCache.Length; ++i)
		{
			if (GUID == QueryCache[i].GUID)
			{
				QueryCache[i].JoinTimeStamp = Level.TimeSeconds;
				return;
			}
		}

		if (bDebugLog)
			Log("Player with GUID:"@GUID@"joined the game, adding player to outgoing query cache", 'TitanTeamFix');

			

		// Add incoming player to incoming/outgoing query cache (NOTE: These will be used at endgame aswel to check for GUID's which need to be added to db)
		OutgoingQueryIndex.Length = OutgoingQueryIndex.Length + 1;
		OutgoingQueryIndex[OutgoingQueryIndex.Length-1] = QueryCache.Length;
		IncomingQueryIndex.Length = IncomingQueryIndex.Length + 1;
		IncomingQueryIndex[IncomingQueryIndex.Length-1] = QueryCache.Length;

		QueryCache.Length = QueryCache.Length + 1;
		QueryCache[QueryCache.Length-1].GUID = GUID;
		QueryCache[QueryCache.Length-1].PlayerValue = -1.0;
		QueryCache[QueryCache.Length-1].JoinTimeStamp = Level.TimeSeconds;


		// If currently doing the initial player balance sorting, add this new players data to the respective variables
		if (bInitialSorting)
		{
			PlayerData.Length = PlayerData.Length + 1;
			PlayerData[PlayerData.Length-1].PRI = PRI;
			PlayerData[PlayerData.Length-1].QCIndex = QueryCache.Length - 1;

			UninitializedQueries.Length = UninitializedQueries.Length + 1;
			UninitializedQueries[UninitializedQueries.Length-1] = QueryCache.Length - 1;
		}
	}
}

function PlayerExitingGame(controller Player)
{
	local string CurGUID;
	local int i, j, k;

	Super.PlayerExitingGame(Player);

	if (PlayerController(Player) == none && !bBotTest)
		return;


	// Find this players entry in the QueryCache list
	if (bBotTest)
	{
		CurGUID = CurTestGUID;
		CurTestGUID = "";
	}
	else
	{
		CurGUID = PlayerController(Player).GetPlayerIDHash();
	}

	for (i=0; i<QueryCache.Length-1; ++i)
		if (QueryCache[i].GUID == CurGUID)
			break;

	// I can't see this ever happening, but just in case
	if (QueryCache[i].GUID != CurGUID)
	{
		Log("ERROR: Player not in cache list!", 'TitanTeamFix');
		return;
	}



	// Check if an UpdateList entry for the current player already exists and then add the entry
	for (j=0; j<UpdateList.Length-1; ++j)
		if (UpdateList[j].QCIndex == i)
			break;

	// Now add this player to the stat cache list
	UpdateList.Length = UpdateList.Length + 1;

	UpdateList[j].QCIndex = i;
	UpdateList[j].PlayerScore += Player.PlayerReplicationInfo.Score;

	if (bDebugLog && UpdateList[j].PlayerScore == 0)
		Log("Added player with no score to update list", 'TTF_Debug');

	UpdateList[j].MainTeam = Player.GetTeamNum();

	k = UpdateList[j].PlayTime.Length;
	UpdateList[j].PlayTime.Length = k + 1;

	UpdateList[j].PlayTime[k].Min = QueryCache[i].JoinTimeStamp;
	UpdateList[j].PlayTime[k].Max = Level.TimeSeconds;
}

//function GameEnded()

// Why the hell does this get called more than once?
function Trigger(Actor Other, Pawn EventInstigator)
{
	local FileLog SQLLog;
	local int i, j, k;
	local controller c;
	local string CurGUID, CurQuery;

	if (bTTFGameEnded || Other != Level.Game)
		return;

	bTTFGameEnded = True;

	if (bDebugLog)
		Log("TTF Game Ended event", 'TitanTeamFix');

	// temp
	if (bDebugLog)
	{
		SQLLog = Spawn(Class'FileLog');
		SQLLog.OpenLog("TitanTeamFix_Debug", "txt");

		SQLLog.Logf("QueryUpdate data:");

		for (i=0; i<UpdateList.Length; ++i)
		{
			SQLLog.Logf("+++++ Entry ("$i$"), GUID:"@QueryCache[UpdateList[i].QCIndex].GUID$":");
			SQLLog.Logf("----- Score:"@UpdateList[i].PlayerScore$", MainTeam:"@UpdateList[i].MainTeam);
			SQLLog.Logf("");

			for (j=0; j<UpdateList[i].PlayTime.Length; ++j)
				SQLLog.Logf("----- JoinTime:"@UpdateList[i].PlayTime[j].Min$", ExitTime:"@UpdateList[i].PlayTime[j].Max);

			SQLLog.Logf("");
			SQLLog.Logf("");
			SQLLog.Logf("");
		}

		SQLLog.CloseLog();
	}


	// Reconnect to the SQL server
	CreateSQLHandle(true);
	SQLHandle.InitializeHandle();


	// Iterate every present player, adding the players to UpdateList as you go
	for (c=Level.ControllerList; c!=none; c=c.NextController)
	{
		if ((AIController(c) == none || bBotTest) && c.PlayerReplicationInfo != none && !c.PlayerReplicationInfo.bOnlySpectator)
		{
			if (bBotTest && AIController(c) != none)
			{
				for (j=0; j<DelayedBotList.Length-1; ++j)
					if (DelayedBotList[j].c == c)
						break;

				CurGUID = DelayedBotList[j].GUID;
			}
			else
			{
				CurGUID = PlayerController(c).GetPlayerIDHash();
			}

			// This gets a little messy, first you must find the players entry into the QueryCache (by GUID) and then his entry into the UpdateList (if it exists)
			for (j=0; j<QueryCache.Length-1; ++j)
				if (QueryCache[j].GUID == CurGUID)
					break;

			for (k=0; k<UpdateList.Length-1; ++k)
				if (UpdateList[k].QCIndex == j)
					break;


			// Not yet in list
			if (UpdateList.Length == 0 || UpdateList[k].QCIndex != j)
			{
				k = UpdateList.Length;
				UpdateList.Length = k + 1;

				UpdateList[k].QCIndex = j;
				UpdateList[k].PlayerScore = c.PlayerReplicationInfo.Score;
				UpdateList[k].MainTeam = c.GetTeamNum();

				UpdateList[k].PlayTime.Length = 1;
				UpdateList[k].PlayTime[0].Min = QueryCache[j].JoinTimeStamp;
				UpdateList[k].PlayTime[0].Max = Level.TimeSeconds;
			}
			// Already in list (i.e. left and rejoined game at least once)
			else
			{
				UpdateList[k].PlayerScore += c.PlayerReplicationInfo.Score;
				UpdateList[k].PlayTime[UpdateList[k].PlayTime.Length-1].Max = Level.TimeSeconds;
			}
		}
	}

	if (UpdateList.Length < 1 || SQLHandle == none)
	{
		if (SQLHandle != none)
			SQLHandle.SQLObj.Close();

		return;
	}


	// If players joined midgame who weren't already in the query cache, check that they exist in the database before continuing. otherwise construct and send the final queries
	if (OutgoingQueryIndex.Length > 0)
	{
		bPreEndGameQuery = True;
		SQLHandle.ResultDel = PreEndGameQueryResult;

		if (bDebugLog)
		{
			Log("SQLHandle exists:"@(SQLHandle != none), 'TitanTeamFix');
			Log("GameEnded, ResultDel set to PreEndGameQueryResult", 'TitanTeamFix');
		}

		Enable('Tick');

		TODO = 0;
		// TODO: I don't want to leave this checking query as a hardcoded one
		CurQuery = "select GUID from"@FinalTableName@"where (";

		for (i=0; i<OutgoingQueryIndex.Length; ++i)
		{
			if (i > 0)
				CurQuery $= "||";

			CurQuery $= "GUID='"$QueryCache[OutgoingQueryIndex[i]].GUID$"'";
		}

		CurQuery $= ")";


		if (SQLHandle.bConnected)
		{
			SQLHandle.SQLObj.SetQueryFilter(0xfe, 0xfe, true, true, true);
			SQLHandle.SQLObj.SendQuery(CurQuery);
		}
		else
		{
			if (bDebugLog)
				Log("Delaying endgame GUID check query", 'TitanTeamFix');

			EndGameQueries.Length = 1;
			EndGameQueries[0] = CurQuery;
		}
	}
	else
	{
		SQLHandle.ResultDel = EndGameQueryResult;

		if (bDebugLog)
			Log("GameEnded, ResultDel set to EndGameQueryResult");

		SendUpdateQuery();
	}
}

function SendUpdateQuery()
{
	local int i, j, CurPP;
	local string CurQuery;
	local float TotalScore, TotalPlayTime;
	local bool bDelayClose;


	// Go through the update list and calculate the total combined score of all present players
	for (i=0; i<UpdateList.Length; ++i)
		TotalScore += UpdateList[i].PlayerScore;

	// The update list should now be complete, process the player stats and construct the final SQL query
	for (i=0; i<UpdateList.Length; ++i)
	{
		CurPP = int((float(UpdateList[i].PlayerScore) / TotalScore) * 100.0);

		// If the player has not been ingame for a total time of over 5 minutes then don't update his/her stats
		TotalPlayTime = 0;

		for (j=0; j<UpdateList[i].PlayTime.Length; ++j)
			TotalPlayTime += UpdateList[i].PlayTime[j].Max - UpdateList[i].PlayTime[j].Min;


		TODO = 0;

		// Quick test
		//if (TotalPlayTime < 300.0)
		//	continue;

		bDelayClose = True;


		if (TeamGame(Level.Game).Teams[0].Score == TeamGame(Level.Game).Teams[1].Score)
		{
			CurQuery = "update"@FinalTableName@"set PPPG=(((PPPG*least(GamesPlayed+3,3))+"$CurPP$
					")/4), RecentPPPG=if(to_days(now())-to_days(LastGame)>=2,PPPG,(RecentPPPG+"$CurPP$
					")/2), LastGame=now() where GUID='"$QueryCache[UpdateList[i].QCIndex].GUID$"'";
		}
		else if (TeamGame(Level.Game).Teams[byte(!bool(UpdateList[i].MainTeam))].Score > TeamGame(Level.Game).Teams[UpdateList[i].MainTeam].Score)
		{
			CurQuery = "update"@FinalTableName@"set PPPG=(((PPPG*least(GamesPlayed+3,3))+"$CurPP$
					")/4), GamesPlayed=GamesPlayed+1, RecentPPPG=if(to_days(now())-to_days(LastGame)>=2,PPPG,(RecentPPPG+"$CurPP$
					")/2), LastGame=now() where GUID='"$QueryCache[UpdateList[i].QCIndex].GUID$"'";
		}
		else
		{
			CurQuery = "update"@FinalTableName@"set PPPG=(((PPPG*least(GamesPlayed+3,3))+"$CurPP$
					")/4), GamesPlayed=GamesPlayed+1, GamesWon=GamesWon+1, RecentPPPG=if(to_days(now())-to_days(LastGame)>=2,PPPG,(RecentPPPG+"$CurPP$
					")/2), LastGame=now() where GUID='"$QueryCache[UpdateList[i].QCIndex].GUID$"'";
		}

		if (bDebugLog)
			Log("Endgame query:"@CurQuery, 'TitanTeamFix');


		// Now send the query
		if (SQLHandle.bConnected)
		{
			SQLHandle.SQLObj.SendQuery(CurQuery);
		}
		else
		{
			i = EndGameQueries.Length;
			EndGameQueries.Length = i + 1;

			EndGameQueries[i] = CurQuery;

			if (i == 0)
				Enable('Tick');
		}
	}

	if (!bDelayclose && SQLHandle != none)
		SQLHandle.SQLObj.Close();
}

// For adding players to the balance list during pre-game stat balancing
function AddToBalanceList(PlayerReplicationInfo PRI, string GUID)
{
	local int i, j;
	local float TempVal;

	for (i=0; i<QueryCache.Length; ++i)
		if (GUID == QueryCache[i].GUID)
			break;

	if (GUID == "" || i >= QueryCache.Length || GUID != QueryCache[i].GUID)
	{
		Log("Error finding a players data within QueryCache, players GUID is:"@GUID, 'TitanTeamFix');
		return;
	}



	// This code will arrange the PlayerData list in order over highest player value to lowest, as it's being created
	TempVal = QueryCache[i].PlayerValue;

	if (TempVal == -1.0)
	{
		UninitializedQueries.Length = UninitializedQueries.Length + 1;
		UninitializedQueries[UninitializedQueries.Length-1] = i;

		// For the moment, add an 'average' value for this player...when removing from UninitializedQueries, remove this from TotalValue and then add the PROPER value
		TempVal = 100.0 / float(Level.Game.MaxPlayers);
	}


	j = FindPlayerDataPos(TempVal);


	// Add the player to the list
	PlayerData.Insert(j, 1);

	PlayerData[j].PRI = PRI;
	PlayerData[j].QCIndex = i;
}

// TODO: TEMPORARY FUNCTION! When you verify this code works properly and can remove the debug logs, REMOVE THIS FUNCTION and copy it's contents directly into the calling code
function int FindPlayerDataPos(float TempVal)
{
	local int j;

	// Find the best entry within PlayerData
	for (j=0; j<PlayerData.Length-1; ++j)
		if (QueryCache[PlayerData[j].QCIndex].PlayerValue <= TempVal)
			if (QueryCache[PlayerData[j].QCIndex].PlayerValue != -1.0 || (100.0 / float(Level.Game.MaxPlayers)) <= TempVal) // PlayerValue == -1.0 is treat as an avg. value
				break;


	// The above for loop looks potentially dodgy, might aswel add a debug log for the time bieng
	if (bDebugLog)
	{
		if (j > 0)
		{
			if (j+1 < PlayerData.Length)
			{
				Log("Initial player sort debug data: Prev List Val:"@QueryCache[PlayerData[j-1].QCIndex].PlayerValue$", This List Val:"@
					QueryCache[PlayerData[j].QCIndex].PlayerValue$", Next List Val:"@QueryCache[PlayerData[j+1].QCIndex].PlayerValue, 'TitanTeamFix');
			}
			else
			{
				Log("Initial player sort debug data: Prev List Val:"@QueryCache[PlayerData[j-1].QCIndex].PlayerValue$", This List Val:"@
					QueryCache[PlayerData[j].QCIndex].PlayerValue, 'TitanTeamFix');
			}
		}
		else
		{
			if (j+1 < PlayerData.Length)
			{
				Log("Initial player sort debug data: This List Val:"@QueryCache[PlayerData[j].QCIndex].PlayerValue$", Next List Val:"@
					QueryCache[PlayerData[j+1].QCIndex].PlayerValue, 'TitanTeamFix');
			}

			// No need to log if it's the only entry in the list
		}
	}

	return j;
}

function InitialQueryResult()
{
	local string GUID, ValueStr;
	local int i, j, k, l, iTempInt;
	local SQLLink SQLObj;

	// *** bNewResultCode
	local array<string> ResultList;

	if (bDebugLog)
		Log("InitialQueryResult", 'TitanTeamFix');

	SQLObj = SQLHandle.SQLObj;

	if (SQLObj.ResultData.Length < 38)
	{
		if (bDebugLog)
			Log("Received query result with no result data", 'TitanTeamFix');

		return;
	}


	TODO = 0;

	// TODO: After testing the new result code, get rid of the old code here AND CONVERT ALL OF THE OLD PARSING CODE TO WORK WITH THE NEW CODE
	if (bNewResultCode)
	{
		i = 0;

		while (i < SQLObj.ResultData.Length)
		{
			ResultList = SQLObj.ParseResultPacket(,, i, i, 2);

			if (ResultList.Length < 2)
			{
				Log("Bad result packet, length is"@ResultList.Length@"where it should be 2", 'TTF_SQL');
				break;
			}

			// Each result has two columns, thus ResultList's length will be two (element 0: GUID, element 1: Value)
			for (j=0; j<IncomingQueryIndex.Length; ++j)
			{
				if (QueryCache[IncomingQueryIndex[j]].GUID == ResultList[0])
				{
					//RemoveThisDebugCode = 0;
					QueryCache[IncomingQueryIndex[j]].PlayerValue = float(ResultList[1]);// /* DEBUG CODE PAST HERE */ * (FRand() * 2.0);

					if (bSortListInitialized)
					{
						for (k=0; k<2; ++k)
						{
							for (l=0; l<SortedTeam[k].PDIndex.Length; ++l)
							{
								if (PlayerData[SortedTeam[k].PDIndex[l]].QCIndex == IncomingQueryIndex[j])
								{
									SortedTeam[k].TeamValue += float(ResultList[1]);
									l = -1;

									break;
								}
							}

							if (l == -1)
								break;
						}
					}

					IncomingQueryIndex.Remove(j, 1);
					break;
				}
			}
		}
	}
	else
	{
		while (i < SQLObj.ResultData.Length)
		{
			ValueStr = "";
			GUID = "";


			iTempInt = i + 37;

			for (i=i+5; i<iTempInt; ++i)
				GUID $= Chr(SQLObj.ResultData[i]);

			++i;

			for (iTempInt=i+SQLObj.ResultData[i-1]; i<iTempInt; ++i)
				ValueStr $= Chr(SQLObj.ResultData[i]);

			for (j=0; j<IncomingQueryIndex.Length; ++j)
			{
				if (QueryCache[IncomingQueryIndex[j]].GUID == GUID)
				{
					//RemoveThisDebugCode = 0;
					QueryCache[IncomingQueryIndex[j]].PlayerValue = float(ValueStr);// /* DEBUG CODE PAST HERE */ * (FRand() * 2.0);

					// If the player is in one of the team lists, modify the total team value
					if (bSortListInitialized)
					{
						for (k=0; k<2; ++k)
						{
							for (l=0; l<SortedTeam[k].PDIndex.Length; ++l)
							{
								if (PlayerData[SortedTeam[k].PDIndex[l]].QCIndex == IncomingQueryIndex[j])
								{
									SortedTeam[k].TeamValue += float(ValueStr);
									l = -1;

									break;
								}
							}

							if (l == -1)
								break;
						}
					}


					IncomingQueryIndex.Remove(j, 1);
					break;
				}
			}
		}
	}


	// Assume at this point that ALL of the sent queries have returned, if there are any missing query results that means the player isn't in the database yet..add him

	if (IncomingQueryIndex.Length > 0)
	{
		// Any return by insert shouldn't matter, insert "shouldn't" return any row data or EOF packets
		ValueStr = "insert into"@FinalTableName@"values";

		// Construct the query
		for (i=0; i<IncomingQueryIndex.Length; ++i)
		{
			// Also set PlayerValue to a default value aswel, at the same time for conveniance
			iTempInt = 100 / Level.Game.MaxPlayers;
			QueryCache[IncomingQueryIndex[i]].PlayerValue = iTempInt;


			// If the player is in one of the team lists, modify the total team value
			if (bSortListInitialized)
			{
				for (k=0; k<2; ++k)
				{
					for (j=0; j<SortedTeam[k].PDIndex.Length; ++j)
					{
						if (PlayerData[SortedTeam[k].PDIndex[j]].QCIndex == IncomingQueryIndex[i])
						{
							SortedTeam[k].TeamValue += iTempInt;
							j = -1;

							break;
						}
					}

					if (j == -1)
						break;
				}
			}


			if (i > 0)
				ValueStr $= ",";

			ValueStr $= "('"$QueryCache[IncomingQueryIndex[i]].GUID$"',"$iTempInt$",0,0,"$iTempInt$",now())";
		}

		IncomingQueryIndex.Length = 0;

		//if (bDebugLog)
		//	Log("Final insert to players query:"@ValueStr, 'TitanTeamFix');


		// Now send the query
		SQLObj.SendQuery(ValueStr);
	}
}

// Used to check for GUID's which are missing from the db, from when an unencountered player joins midgame
function PreEndGameQueryResult()
{
	local int i, j, iTempInt;
	local string CurGUID, ValueStr;
	local SQLLink SQLObj;

	if (bDebugLog)
		Log("PreEndGameQueryResult", 'TitanTeamFix');

	if (bPreEndGameQuery)
	{
		bPreEndGameQuery = False;


		SQLObj = SQLHandle.SQLObj;

		for (i=5; i+32<=SQLObj.ResultData.Length; ++i)
		{
			CurGUID = "";

			for (j=0; j<32; ++j)
				CurGUID $= Chr(SQLObj.ResultData[i+j]);

			for (j=0; j<IncomingQueryIndex.Length; ++j)
			{
				if (QueryCache[IncomingQueryIndex[j]].GUID == CurGUID)
				{
					IncomingQueryIndex.Remove(j, 1);
					break;
				}
			}

			i += 36;
		}


		// If there are any remaining entries in the Incoming query list then those entries need to be added to the database. Otherwise, continue with update queries
		if (IncomingQueryIndex.Length > 0)
		{
			// Any return by insert shouldn't matter, insert "shouldn't" return any row data or EOF packets
			ValueStr = "insert into"@FinalTableName@"values";

			// Construct the query
			for (i=0; i<IncomingQueryIndex.Length; ++i)
			{
				iTempInt = 100 / Level.Game.MaxPlayers;

				if (i > 0)
					ValueStr $= ",";

				ValueStr $= "('"$QueryCache[IncomingQueryIndex[i]].GUID$"',"$iTempInt$",0,0,"$iTempInt$",now())";
			}

			IncomingQueryIndex.Length = 0;

			if (bDebugLog)
				Log("Final endgame insert to players query:"@ValueStr, 'TitanTeamFix');

			// Now send the query
			SQLObj.SendQuery(ValueStr);
		}
		else
		{
			SQLHandle.ResultDel = EndGameQueryResult;
			SQLHandle.SQLObj.SetQueryFilter(-1);
			SendUpdateQuery();
		}
	}
	else
	{
		// The new entries have successfully been inserted into the database, continue
		SQLHandle.ResultDel = EndGameQueryResult;
		SQLHandle.SQLObj.SetQueryFilter(-1);
		SendUpdateQuery();
	}
}

function EndGameQueryResult()
{
	Log("EndGameQueryResult", 'TitanTeamFix');

	TODO = 0;

	// This is still temporary but more flexible, what you need to do in the future is actually parse the 'ok' packets and count them.
	bEndGameTimer = True;
	SetTimer(10, false);
}

function Timer()
{
	if (bEndGameTimer)
	{
		bEndGameTimer = False;

		if (SQLHandle != none)
			SQLHandle.SQLObj.Close();
	}
	else
	{
		Super.Timer();
	}
}

function FlushQueries()
{
	local string GUIDString;
	local int i;


	if (OutgoingQueryIndex.Length <= 0)
		return;

	if (SQLHandle != none && !SQLHandle.bConnected)
	{
		if (bDebugLog)
			Log("SQL link is not yet connected or has not yet finished authentication", 'TitanTeamFix');

		bPendingQueryFlush = True;

		return;
	}

	if (SQLHandle == none || SQLHandle.SQLObj == none)
	{
		Log("Error sending query, either the SQLHandle or the SQLObj doesn't exist", 'TitanTeamFix');
		OutgoingQueryIndex.Length = 0;

		return;
	}


	// Special filter for maximising efficiency when parsing result data (cuts out lots of useless information)
	if (!SQLHandle.SQLObj.IsInState('QueryFilter') || SQLHandle.SQLObj.StartFilter != 0xfe || SQLHandle.SQLObj.EndFilter != 0xfe)
	{
		if (bNewResultCode)
			SQLHandle.SQLObj.SetQueryFilter(0xfe, 0xfe, true, true, false);
		else
			SQLHandle.SQLObj.SetQueryFilter(0xfe, 0xfe, true, true, true);
	}


	// Iterate the outgoing query list and generate the guid string
	for (i=0; i<OutgoingQueryIndex.Length; ++i)
	{
		if (i > 0)
			GUIDString $= "||";

		GUIDString $= "GUID='"$QueryCache[OutgoingQueryIndex[i]].GUID$"'";
	}

	OutgoingQueryIndex.Length = 0;



	i = InStr(FinalBalanceQuery, "%g");

	GUIDString = Left(FinalBalanceQuery, i)$GUIDString$Mid(FinalBalanceQuery, i+2);


	if (bDebugLog)
		Log("Final query string:"@GUIDString, 'TitanTeamFix');


	// Send the completed query string
	SQLHandle.SQLObj.SendQuery(GUIDString);
}


defaultproperties
{
	ConfigProfileClass=Class'TTeamFixStatConfigProfile'

	//bNeedGameEndedEvent=True
	bNeedJoinedEvent=True


	bDebugLog=False
	bBotTest=False
	bNewResultCode=True


	SQLBalanceQuery="select GUID,(PPPG+(RecentPPPG/PPPG)-1.0+(select if(GamesPlayed>10,((GamesWon/GamesPlayed)-0.5)*2.0,0.0))*0.5)from %t where(%g)"

	bResolveIPString=False
	SQLDatabase="TitanTeamFix"

	SQLLinkPort=0

	SQLTableName="Players"
	bPrefixGameToTable=True
	bPrefixProfileToTable=True

	bAutoCreateDatabase=True
	bAutoCreateTable=True
	bCurrentDatabaseExists=False
	LastDatabase=""
}