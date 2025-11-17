//============================================================
// TitanConfigDatabase.uc	- Database which works off of .ini files
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
// Implements the database interface to .ini files
//
//============================================================
Class TitanConfigDatabase extends TitanRuntimeDatabase
	config(TitanDatabase);

var config array<PlayerDatabaseEntry> LocalDatabase;



function bool GetPlayerData(PlayerController PC, int MatchFlags)
				//optional bool bMatchIP, optional bool bMatchGamespyID, optional bool bMatchGUID,
				//optional bool bMatchName, optional bool bGetExtraData)
{
	local int i, j;
	local UniqueNetID NullID;
	local PlayerDatabaseEntry MergedData;
	local bool bMergedDataInit;
	local delegate<ReceivedPlayerData> RecvDel;
	local delegate<MissingPlayerData> MissDel;
	local string PlayerIP, PlayerGamespyID, PlayerGUID, PlayerName;

	// I copy-paste the code here between two classes, so I need to set a variable like this
	bRuntimeDBRevision1 = True;


	// ***
	bRemoveThisDebugCode = True;

	if (bDebugInstance)
	{
		PlayerIP = DebugIP;
		PlayerGamespyID = DebugGamespyID;
		PlayerGUID = DebugGUID;
		PlayerName = DebugName;
	}
	else
	{
	// ***
		PlayerIP = PC.GetPlayerNetworkAddress();

		i = InStr(PlayerIP, ":");

		if (i != -1)
			PlayerIP = Left(PlayerIP, i);


		if (PC.PlayerReplicationInfo.UniqueID != NullID)
			PlayerGamespyID = Class'OnlineSubsystem'.static.UniqueNetIDToString(PC.PlayerReplicationInfo.UniqueID);

		PlayerGUID = PC.HashResponseCache;

		PlayerName = PC.PlayerReplicationInfo.GetPlayerAlias();
	}


	// ***
	bRemoveThisDebugCode = True;

	if (DebugLog != none)
	{
		DebugLog.Logf("TitanRuntimeDatabase::GetPlayerData: MatchFlags:"@MatchFlags);

		DebugLog.Logf("PlayerIP:"@PlayerIP$", PlayerGamespyID:"@PlayerGamespyID$", PlayerGUID:"@PlayerGUID$
				". PlayerName:"@PlayerName);
	}
	// ***


	// Iterate the database and check for matching entries
	for (i=0; i<LocalDatabase.Length; ++i)
	{
		if ((/*bMatchIP*/ bool(MatchFlags & MATCH_IP) && InStr(LocalDatabase[i].IPs, PlayerIP, True) != -1) ||
			(/*bMatchGamespyID*/ bool(MatchFlags & MATCH_GamespyID) && PlayerGamespyID != "" && SearchNameList(LocalDatabase[i].GamespyID, PlayerGamespyID)) ||
			(/*bMatchGUID*/ bool(MatchFlags & MATCH_GUID) && PlayerGUID != "" && PlayerGUID != "0" && LocalDatabase[i].GUID ~= StripString(PlayerGUID)) ||
			(/*bMatchName*/ bool(MatchFlags & MATCH_Name) && SearchNameList(LocalDatabase[i].Names, StripString(PlayerName))))
		{
			// ***
			bRemoveThisDebugCode = True;

			if (DebugLog != none)
			{
				DebugLog.Logf("TitanRuntimeDatabase::GetPlayerData:(loop) Found a matching entry with data:");

				DebugLog.Logf("PlayerIP:"@LocalDatabase[i].IPs$", PlayerGamespyID:"@LocalDatabase[i].GamespyID$
						", PlayerGUID:"@LocalDatabase[i].GUID$". PlayerName:"@LocalDatabase[i].Names);
			}
			// ***

			if (!bMergedDataInit)
			{
				//MergedData.PC =		PC;
				bMergedDataInit = True;

				MergedData.Names =	LocalDatabase[i].Names;
				MergedData.GUID =	UnStripString(LocalDatabase[i].GUID);
				MergedData.GamespyID =	LocalDatabase[i].GamespyID;
				MergedData.IPs =	LocalDatabase[i].IPs;

				if (/*bGetExtraData*/ bool(MatchFlags & MATCH_ExtraData))
					MergedData.ExtraData = LocalDatabase[i].ExtraData;
			}
			else
			{
				MergedData.Names =	MergeLists(MergedData.Names, LocalDatabase[i].Names);
				MergedData.GUID $=	","$UnStripString(LocalDatabase[i].GUID);
				MergedData.GamespyID =	MergeLists(MergedData.GamespyID, LocalDatabase[i].GamespyID);
				MergedData.IPs =	MergeLists(MergedData.IPs, LocalDatabase[i].IPs);

				if (/*bGetExtraData*/ bool(MatchFlags & MATCH_ExtraData) && LocalDatabase[i].ExtraData.Length > 0)
				{
					if (MergedData.ExtraData.Length == 0)
						MergedData.ExtraData = LocalDatabase[i].ExtraData;
					else
						for (j=0; j<LocalDatabase[i].ExtraData.Length; ++j)
							MergedData.ExtraData.AddItem(LocalDatabase[i].ExtraData[j]);
				}
			}
		}
	}

	// No matching entries
	if (!bMergedDataInit)
	{
		foreach ReceiveFail(MissDel)
			MissDel(PC, MatchFlags);
	}
	else
	{
		// ***
		bRemoveThisDebugCode = True;

		if (DebugLog != none)
		{
			DebugLog.Logf("TitanRuntimeDatabase::GetPlayerData: Final return data:");
			DebugLog.Logf("***");
			DebugLog.Logf("Names:"@MergedData.Names);
			DebugLog.Logf("GUID:"@MergedData.GUID);
			DebugLog.Logf("GamespyID:"@MergedData.GamespyID);
			DebugLog.Logf("IPs:"@MergedData.IPs);
			DebugLog.Logf("***");
		}
		// ***

		MergedData.Names = UnStripList(MergedData.Names);

		// Unstrip the extra data keys/values
		if (/*bGetExtraData*/ bool(MatchFlags & MATCH_ExtraData))
		{
			for (i=0; i<MergedData.ExtraData.Length; ++i)
			{
				MergedData.ExtraData[i].Key = UnStripString(MergedData.ExtraData[i].Key);
				MergedData.ExtraData[i].Value = UnStripString(MergedData.ExtraData[i].Value);
			}
		}

		foreach ReceiveSuccess(RecvDel)
		{
			if (/*bGetExtraData*/ bool(MatchFlags & MATCH_ExtraData))
				RecvDel(PC, MatchFlags, MergedData.Names, MergedData.GUID, MergedData.GamespyID, MergedData.IPs, MergedData.ExtraData, True);
			else
				RecvDel(PC, MatchFlags, MergedData.Names, MergedData.GUID, MergedData.GamespyID, MergedData.IPs);
		}
	}


	// This function always returns immediately
	return True;
}

function bool UpdatePlayerData(PlayerController PC, optional array<PlayerProperty> ExtraData)
{
	local int idx, i, j;
	local UniqueNetID NullID;
	local string PlayerGUID;
	local string PlayerIP, PlayerGamespyID, PlayerName;

	// ***
	bRemoveThisDebugCode = True;

	if (bDebugInstance)
	{
		if (DebugGUID == "" || DebugGUID == "0")
			return False;

		PlayerGUID = StripString(DebugGUID);

		idx = LocalDatabase.Find('GUID', PlayerGUID);
	}
	else
	{
	// ***
		if (PC.HashResponseCache == "" || PC.HashResponseCache == "0")
		{
			return False;
		}
		else
		{
			PlayerGUID = StripString(PC.HashResponseCache);
			idx = LocalDatabase.Find('GUID', PlayerGUID);
		}
	}


	// ***
	bRemoveThisDebugCode = True;

	if (bDebugInstance)
	{
		PlayerIP = DebugIP;
		PlayerGamespyID = DebugGamespyID;
		PlayerName = DebugName;
	}
	else
	{
	// ***
		PlayerIP = PC.GetPlayerNetworkAddress();

		i = InStr(PlayerIP, ":");

		if (i != -1)
			PlayerIP = Left(PlayerIP, i);


		if (PC.PlayerReplicationInfo.UniqueID != NullID)
			PlayerGamespyID = Class'OnlineSubsystem'.static.UniqueNetIDToString(PC.PlayerReplicationInfo.UniqueID);

		PlayerName = PC.PlayerReplicationInfo.GetPlayerAlias();
	}


	// Check that there are no duplicate keys within extra data (and also strip the ExtraData values as you go)
	for (i=0; i<ExtraData.Length; ++i)
	{
		for (j=i+1; j<ExtraData.Length; ++j)
		{
			if (ExtraData[i].Key == ExtraData[j].Key)
			{
				LogInternal("TitanRuntimeDatabase::UpdatePlayerData: Duplicate key '"$ExtraData[i].Key$"' within ExtraData", 'TitanDB');

				ExtraData.Remove(j, 1);
				--j;
			}
		}

		ExtraData[i].Key = StripString(ExtraData[i].Key);
		ExtraData[i].Value = StripString(ExtraData[i].Value);
	}


	// New player entry
	if (idx == -1)
	{
		// ***
		bRemoveThisDebugCode = True;

		if (DebugLog != none)
		{
			DebugLog.Logf("TitanRuntimeDatabase::UpdatePlayerData: Adding new entry:");

			DebugLog.Logf("--- PlayerIP:"@PlayerIP$", PlayerGamespyID:"@PlayerGamespyID$", PlayerGUID:"@PlayerGUID$
					". PlayerName:"@PlayerName);
		}
		// ***

		idx = LocalDatabase.Length;
		LocalDatabase.Length = LocalDatabase.Length + 1;

		//LocalDatabase[idx].PC = PC;

		LocalDatabase[idx].Names = StripString(PlayerName);

		LocalDatabase[idx].GUID = PlayerGUID;

		if (PlayerGamespyID != "")
			LocalDatabase[idx].GamespyID = PlayerGamespyID;

		LocalDatabase[idx].IPs = PlayerIP;
		LocalDatabase[idx].ExtraData = ExtraData;
	}
	else
	{
		//LocalDatabase[idx].PC = PC;
		LocalDatabase[idx].Names = MergeLists(LocalDatabase[idx].Names, StripString(PlayerName));

		// No need to set the GUID, as it is already set

		if (PlayerGamespyID != "")
			LocalDatabase[idx].GamespyID = MergeLists(LocalDatabase[idx].GamespyID, PlayerGamespyID);

		LocalDatabase[idx].IPs = MergeLists(LocalDatabase[idx].IPs, PlayerIP);

		if (ExtraData.Length > 0)
		{
			// Overwrite existing ExtraData keys
			for (j=0; j<ExtraData.Length; ++j)
			{
				for (i=0; i<LocalDatabase[idx].ExtraData.Length; ++i)
				{
					if (LocalDatabase[idx].ExtraData[i].Key ~= ExtraData[j].Key)
					{
						LocalDatabase[idx].ExtraData[i].Value = ExtraData[j].Value;

						ExtraData.Remove(j, 1);
						--j;

						break;
					}
				}
			}

			// Add in remaining unused keys
			for (i=0; i<ExtraData.Length; ++i)
				LocalDatabase[idx].ExtraData.AddItem(ExtraData[i]);
		}
	}

	if (!bDisableAutoSave)
		SaveConfig();

	return True;
}

defaultproperties
{
	bDisableAutoSave=False
}