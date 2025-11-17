//============================================================
// TitanDatabase.uc	- Base class for other database storage classes
//============================================================
//	TitanDB
//		- A central database management package for the TitanAdminHax tool
//
//	Copyright (C) 2008 John "Shambler" Barrett (JBarrett847@Gmail.com or Shambler@OldUnreal.com)
//
//	This program is free software; you can redistribute and/or modify
//	it under the terms of the Open Unreal Mod License version 1.1.
//
//============================================================
//
// Stub class for basic database interfacing.
// Allows multiple tools to query the same database
//
// N.B. This database was originally designed to accomodate the
// aka/whois tool within TitanAdminHax, not as a complete
// database interface!
//
//============================================================
//
// HOW TO USE:
// 	- 1: In your class, to get a database reference call: Class'TitanDB.TitanDatabase'.static.GetDBRef(Self);
//	- 2: Create two functions in your class, each matching the format of the 'ReceivedPlayerData' and 'MissingPlayerData' delegates
//	- 3: When you need to make a query, add those two functions to the 'ReceiveSuccess' and 'ReceiveFail' delegate lists, and then call
//		'GetPlayerData'. When the query returns, make sure to remove those two functions from the delegate lists (in case multiple tools make
//		use of the database, you don't want to slow the system down by receiving unneccessary query returns)
//	- 4: When you need to store information in the database (for a particular player), use the 'SetPlayerData' function; if you want to store
//		arbitrary player data in the database, specificy the extra data in the 'ExtraData' parameter.
//
//============================================================
Class TitanDatabase extends Info
	dependson(TitanDBConfig);

// Used for storing extra data alongside general player data
struct PlayerProperty
{
	var string Key;
	var string Value;
};

/*
enum EMatchFlags
{
	MATCH_None,
	MATCH_IP,
	MATCH_GamespyID,
	MATCH_GUID,
	MATCH_Name,
	MATCH_ExtraData
};
*/

const MATCH_IP		= 1;
const MATCH_GamespyID	= 2;
const MATCH_GUID	= 4;
const MATCH_Name	= 8;
const MATCH_ExtraData	= 16;

const EDIT_Add		= 1;
const EDIT_Remove	= 2;
const EDIT_Overwrite	= 4;


// Important: Expect these delegates to return query results for players you did not query; in cases where multiple tools use the database, the code will
// return query results through ALL of the delegates, not just to the delegates owned by classes which performed the requested queries.
// Because of this, it is a good idea to test your code whilst the TitanAdminHax aka/whois tool is running; that way you can be more aware of potential
// incompatabilities between your code, and other tools using the database.


var array<delegate<ReceivedPlayerData> >	ReceiveSuccess;
var array<delegate<MissingPlayerData> >		ReceiveFail;

var deprecated bool bRemoveThisDebugCode;
var deprecated bool bTODO;

var bool bDebugInstance;	// Used for testing, allows you to specify raw player data in GetPlayerData, without using a controller
var string DebugIP;
var string DebugGamespyID;
var string DebugGUID;
var string DebugName;

var FileWriter DebugLog;


// N.B. It's possible for ExtraData to have multiple properties with the same key; if you want to be sure that this wont happen, only match with the GUID
delegate ReceivedPlayerData(PlayerController PC, int MatchFlags, string Names, string GUIDs, string GamespyIDs, string IPs,
				optional array<PlayerProperty> ExtraData, optional bool bGotExtraData)
{
	// ***
	bRemoveThisDebugCode = True;

	if (DebugLog != none)
		DebugLog.Logf("TitanDatabase::ReceivedPlayerData: Error, call to default delegate");
	// ***
}

delegate MissingPlayerData(PlayerController PC, int MatchFlags)
{
	// ***
	bRemoveThisDebugCode = True;

	if (DebugLog != none)
		DebugLog.Logf("TitanDatabase::MissingPlayerData: Error, call to default delegate");
	// ***
}



// Results passed through the 'ReceiveSuccess' and 'ReceiveFail' delegate arrays; returns true if either were called instantly
function bool GetPlayerData(PlayerController PC, int MatchFlags);
				//optional bool bMatchIP, optional bool bMatchGamespyID, optional bool bMatchGUID,
				//optional bool bMatchName, optional bool bGetExtraData);

// TODO: Add a function which can search for player data without needing a reference to a controller.

// Updates a players info within the database ('ExtraData' allows other tools/mutators to utilize the database), returns True if successful
// If you make use of ExtraData, I recommend giving keys a special prefix that should be unique to your mod (i.e. "shamExtraData"), to avoid conflicts
// N.B. Usually only returns false if the players GUID (PC.HashResponseCache) is not set or is "0" (or if waiting to connect to an SQL server)
function bool UpdatePlayerData(PlayerController PC, optional array<PlayerProperty> ExtraData);


// TODO: Add an 'EditPlayerData' function, which allows existing player data to be modified (one which works off of a controller, and one which doesn't)



// ALWAYS use this function to reference a database from this package. It ensures that multiple tools will all be using one database
static final function TitanDatabase GetDBRef(Actor Sender, optional TitanDBConfig.EDatabaseType ForcedDBType, optional bool bForceDB)
{
	local TitanDatabase TDB;
	local class<TitanDatabase> DBClass;

	// Setup the required database class
	switch ((bForceDB ? ForcedDBType : Class'TitanDBConfig'.default.DatabaseType))
	{
	case DT_Runtime:
		DBClass = Class'TitanRuntimeDatabase';
		break;

	case DT_Config:
		DBClass = Class'TitanConfigDatabase';
		break;

		// ***
		if (default.bTODO) {}
		// Re-implement this
	/*
	case DT_MySQL:
		DBClass = Class'TitanMySQLDatabase';
		break;
	*/
		// ***
	}


	// Search for an existing database (only returns one of the default variety, unless another is specifically forced)
	foreach Sender.AllActors(Class'TitanDatabase', TDB)
		if (TDB.Class == DBClass)
			return TDB;


	// If none were found, create one
	TDB = Sender.Spawn(DBClass);

	if (TDB == none)
	{
		LogInternal("Failed to create database of class '"$DBClass$"', creating a config database as a fallback", 'TitanDB');
		TDB = Sender.Spawn(Class'TitanConfigDatabase');
	}

	TDB.InitializeDatabase();


	// Ensure that the .ini file exists and that 'TitanDBConfig' is written to it (so admins can reconfigure the database type)
	// Update: Modified to ensure that the MySQL database settings are also saved
	if (!Class'TitanDBConfig'.default.bINIExists)
	{
		TitanDBConfig(FindObject(Class'TitanDBConfig'.GetPackageName()$".Default__TitanDBConfig", Class'TitanDBConfig')).bINIExists = True;
		Class'TitanDBConfig'.static.StaticSaveConfig();

		// ***
		if (default.bTODO) {}
		// Add this back in when you restart development of the MySQL db
		//Class'TitanMySQLDatabase'.static.StaticSaveConfig();
		// ***
	}

	return TDB;
}


// Implemented in subclasses, not used outside of the TitanDB package
function InitializeDatabase()
{
	// ***
	bRemoveThisDebugCode = True;

	DebugLog = Spawn(Class'FileWriter');
	DebugLog.OpenFile("TitanDBDebug");
	// ***
}

// Make sure to call super in subclasses..
function GetPersistentActorList(out array<Actor> List)
{
	List[List.Length] = Self;

	// ***
	bRemoveThisDebugCode = True;

	if (DebugLog != none)
		List[List.Length] = DebugLog;
	// ***
}



// Strip a string of troublesome characters (make sure to replace them with less troublesome ones)
static final function string StripString(string InStr)
{
	local int StrLen, i, Char;
	local string ReturnStr;
	local bool bSetStart;

	StrLen = Len(InStr);


	for (i=0; i<StrLen; ++i)
	{
		Char = Asc(Mid(InStr, i, 1));


		// TODO: Check if Chr(31) is storable in a MySQL database
		// N.B. A lot of these are probably fine, but I'm removing them 'to be safe'
		// 34 = ", 37 = %, 38 = &, 40 = (, 41 = ), 44 = , , 47 = /, 59 = ;, 92 = \
		if (Char == 30 || Char == 31 || Char == 34 || Char == 37 || Char == 38 || Char == 40 || Char == 41 || Char == 44 || Char == 47 || Char == 59 || Char == 92)
		{
			ReturnStr $= Chr(31)$string(Char)$Chr(31);

			// All stripped strings start with Chr(30) (prevents wasted time going through unmodified strings when unstripping)
			if (!bSetStart)
			{
				ReturnStr = Chr(30)$ReturnStr;
				bSetStart = True;
			}
		}
		else if (Char >= 32 && Char <= 126)
		{
			ReturnStr $= Chr(Char);
		}
		else
		{
			// TODO: Rearrange these if/else conditions so that you don't repeat code
			ReturnStr $= Chr(31)$string(Char)$Chr(31);

			if (!bSetStart)
			{
				ReturnStr = Chr(30)$ReturnStr;
				bSetStart = True;
			}
		}
	}


	return ReturnStr;
}

// Decyphers a stored strings potentially troublesome characters
static final function string UnStripString(string InputStr)
{
	local int i, j;
	local string SChr, sTempStr;

	// If the string is not stripped, return immediately
	if (Left(InputStr, 1) != Chr(30))
		return InputStr;


	InputStr = Mid(InputStr, 1);

	SChr = Chr(31);

	i = InStr(InputStr, SChr);


	while (i != -1)
	{
		sTempStr = Mid(InputStr, i+1);
		j = InStr(sTempStr, SChr);

		// This shouldn't happen, so long as you use this function on a stripped string
		if (j == -1)
			break;

		InputStr = Left(InputStr, i)$Chr(int(Left(sTempStr, j)))$Mid(sTempStr, j+1);

		i = InStr(InputStr, SChr);
	}


	return InputStr;
}

// Make sure that both input strings stripped (and never strip anything twice!)
static final function bool SearchNameList(string List, string SearchName)
{
	local int iNameLen, iListLen;

	iNameLen = Len(SearchName);
	iListLen = Len(List);


	if (iListLen < iNameLen)
		return False;

	if (iListLen == iNameLen && List ~= SearchName)
		return True;


	if (Left(List, iNameLen+1) ~= Concat_StrStr(SearchName, ",") || Right(List, iNameLen+1) ~= Concat_StrStr(",", SearchName))
		return True;

	if (InStr(List, ","$SearchName$",") != -1)
		return True;

	return False;
}

// Parses the list and compares each list to make sure there are no duplicate entries in the final list
static final function string MergeLists(string ListA, string ListB)
{
	local array<string> SplitA, SplitB;
	local int i, ListALen;
	local bool bContinue;

	ParseStringIntoArray(ListA, SplitA, ",", True);
	ParseStringIntoArray(ListB, SplitB, ",", True);


	ListALen = SplitA.Length;

	foreach SplitB(ListB)
	{
		for (i=0; i<ListALen; ++i)
		{
			if (ListB ~= SplitA[i])
			{
				bContinue = True;
				break;
			}
		}


		if (bContinue)
		{
			bContinue = False;
			continue;
		}

		SplitA.AddItem(ListB);
	}


	JoinArray(SplitA, ListA);


	return ListA;
}

static final function string UnStripList(string List)
{
	local array<string> SplitList;
	local int i;


	// Quick return (Chr(30) exists in EVERY stripped string)
	if (InStr(List, Chr(30)) == -1)
		return List;


	ParseStringIntoArray(List, SplitList, ",", True);

	for (i=0; i<SplitList.Length; ++i)
		SplitList[i] = UnStripString(SplitList[i]);

	JoinArray(SplitList, List);

	return List;
}