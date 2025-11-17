class MutAddShivers extends Mutator
	Config(Shiver);

var config string SpecPkgName;
var array<int> NoSpawnSquads;
var KFGameType KF;

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.RulesGroup, "SpecPkgName", "Shiver package name", 0, 0, "text");
}

function PostBeginPlay()
{
	local string ShiverID;
	local int MonsterSlot;
	local int SquadIndex, i;
	local string SquadStr;
	local string ThisID;
	local int ThisCount;
	
	if (Level.NetMode != NM_Standalone)
		AddToPackageMap(SpecPkgName);
	
	KF = KFGameType(Level.Game);
	if (KF == none)
	{
		Log("ERROR: Wrong GameType (requires KFGameType)");
		Destroy();
		return;
	}
	
	// Get new slot in monster list
	MonsterSlot = KF.StandardMonsterClasses.Length;
	KF.StandardMonsterClasses.Length = MonsterSlot + 1;
	ShiverID = Chr(65 + MonsterSlot);
	
	// Add monster to monster list
	KF.StandardMonsterClasses[MonsterSlot].MClassName = SpecPkgName$".ZombieShiver";
	KF.StandardMonsterClasses[MonsterSlot].MID = ShiverID;
	/*
	MonsterSquad=4A
	MonsterSquad=4A1G
	MonsterSquad=2B
	MonsterSquad=4B
	MonsterSquad=3A1G
	MonsterSquad=2D
	MonsterSquad=3A1C
	MonsterSquad=2A2C
	8 MonsterSquad=2A3B1C
	MonsterSquad=1A3C
	MonsterSquad=3A1C1H
	MonsterSquad=3A1B2D1G1H
	MonsterSquad=3A1E
	MonsterSquad=2A1E
	MonsterSquad=2A3C1E
	MonsterSquad=2B3D1G2H
	MonsterSquad=4A1C
	MonsterSquad=4A
	MonsterSquad=4D
	MonsterSquad=4C
	MonsterSquad=6B
	MonsterSquad=2B2C2D1H
	MonsterSquad=2A2B2C2H
	MonsterSquad=1F
	MonsterSquad=1I
	MonsterSquad=2A1C1I
	MonsterSquad=2I
	*/

	AddShiverReplace(3, "B", 2, ShiverID); // Crawler
	AddShiverReplace(4, "A", 2, ShiverID); // Clot
	AddShiverReplace(6, "A", 2, ShiverID); // Clot
	AddShiverReplace(7, "A", 1, ShiverID); // Clot
	AddShiverReplace(8, "A", 1, ShiverID); AddShiverReplace(8, "B", 1, ShiverID); // Clot, crawler
	AddShiverReplace(9, "C", 1, ShiverID); // Gorefast
	AddShiverReplace(10, "A", 1, ShiverID); // Clot
	AddShiverReplace(11, "A", 2, ShiverID); // Clot
	// AddShiverReplace(16, "A", 2, ShiverID); // Clot
	// AddShiverReplace(17, "A", 2, ShiverID); // Clot
	AddShiverReplace(19, "C", 2, ShiverID); // Gorefast
	// AddShiverReplace(21, "B", 1, ShiverID); AddShiverReplace(21, "C", 1, ShiverID); // Crawler, gorefast
	AddShiverReplace(24, "", 1, ShiverID); // Add; don't replace
}

function AddShiverReplace(int SquadID, string SpecToReplace, int AmountToReplace, string ShiverID)
{
	if (SpecToReplace != "")
		KF.StandardMonsterSquads[SquadID] = AmountToReplace $ ShiverID
			$ RemoveFromSquad(KF.StandardMonsterSquads[SquadID], SpecToReplace, AmountToReplace);
	else
		KF.StandardMonsterSquads[SquadID] = AmountToReplace $ ShiverID
			$ KF.StandardMonsterSquads[SquadID];
}

function string RemoveFromSquad(string SquadStr, string ID, int NumToRemove)
{
	local int x;
	local string OutStr;
	local int OldNum;
	
	// Locate said specimen
	for (x = 0; x < Len(SquadStr); x += 2)
		if (Mid(SquadStr, x + 1, 1) == ID)
			break;
			
	if (x == Len(SquadStr))
		return SquadStr;
		
	OldNum = int(Mid(SquadStr, x, 1));
		
	// If we are removing all, remove completely
	if (OldNum - NumToRemove <= 0)
		return Left(SquadStr, x) $ Right(SquadStr, Len(SquadStr) - x - 2);

	return Left(SquadStr, x) $ (OldNum - NumToRemove) $ ID $ Right(SquadStr, Len(SquadStr) - x - 2);
}

function MatchStarting()
{
	Destroy();
}

defaultproperties
{
     SpecPkgName="Shiver"
     GroupName="KF-AddShivers"
     FriendlyName="Add Shivers"
     Description="Adds shivers to spawn list."
}
