class MutAddHellFire extends Mutator
	Config(HellFire);

var config string SpecPkgName;

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.RulesGroup, "SpecPkgName", "HellFire package name", 0, 0, "text");
}

function PostBeginPlay()
{
	local KFGameType KF;
	local string HellFireID;
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
		Destroy();
		return;
	}
	
	// Get new slot in monster list
	MonsterSlot = KF.StandardMonsterClasses.Length;
	KF.StandardMonsterClasses.Length = MonsterSlot + 1;
	HellFireID = Chr(65 + MonsterSlot);
	
	// Add monster to monster list
	KF.StandardMonsterClasses[MonsterSlot].MClassName = SpecPkgName$".ZombieHellFire";
	KF.StandardMonsterClasses[MonsterSlot].MID = HellFireID;
	
	for (SquadIndex = 0; SquadIndex < KF.StandardMonsterSquads.Length; SquadIndex++)
	{
		SquadStr = KF.StandardMonsterSquads[SquadIndex];

		for (i = 0; i < Len(SquadStr); i+=2)
		{
			ThisCount = int( Mid(SquadStr, i, 1) );
			ThisID = Mid(SquadStr, i + 1, 1);
			
			if (ThisID == "E")
			{
				SquadStr = Left(SquadStr, i);
				SquadStr $= string(int(ThisCount / 2 + ThisCount % 2));
				SquadStr $= ThisID;
				SquadStr $= "1";//string(ThisCount / 2);
				SquadStr $= HellFireID;
				SquadStr $= Right(KF.StandardMonsterSquads[SquadIndex], Len(KF.StandardMonsterSquads[SquadIndex]) - i - 2);
				KF.StandardMonsterSquads[SquadIndex] = SquadStr;
				break;
			}
		}
	}
	
	SetTimer(0.1, false);
}

function Timer()
{
	Destroy(); // Destroy here (after mut is loaded) otherwise it won't appear as set in webadmin
}

defaultproperties
{
     SpecPkgName="HellFire"
     GroupName="KF-AddHellFire"
     FriendlyName="Add HellFire"
     Description="Adds HellFire to spawn list."
}
