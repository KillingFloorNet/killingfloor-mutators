class MadHuskMut extends Mutator
	Config(MadHusk);

var config string MDPkgName;

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.RulesGroup, "MDPkgName", "MadHusk package name", 0, 0, "text");
}

function PostBeginPlay()
{
	local int i;
	local string MID;
	local KFGameType KF;
	
	if (Level.NetMode != NM_Standalone)
		AddToPackageMap(MDPkgName);
	
	KF = KFGameType(Level.Game);
	if (KF == none)
	{
		Destroy();
		return;
	}
	
	// Get new slot in monster list
	i = KFGameType(Level.Game).StandardMonsterClasses.Length;
	KFGameType(Level.Game).StandardMonsterClasses.Length = i + 1;
	MID = Chr(65 + i);
	
	// Add monster to monster list
	KFGameType(Level.Game).StandardMonsterClasses[i].MClassName = MDPkgName$".MadHusk";
	KFGameType(Level.Game).StandardMonsterClasses[i].MID = MID;

	// Add monster to squads
	KFGameType(Level.Game).StandardMonsterSquads[24] $= "1" $ MID;
	KFGameType(Level.Game).StandardMonsterSquads[25] $= "2" $ MID;
	KFGameType(Level.Game).StandardMonsterSquads[26] $= "1" $ MID;
	
	SetTimer(0.1, false);
}

function Timer()
{
	Destroy(); // Destroy here (after mut is loaded) otherwise it won't appear as set in webadmin
}

defaultproperties
{
     MDPkgName="MadHusk"
     GroupName="KF-AddMDMut"
     FriendlyName="Add Mad Husk"
     Description="Adds Mad Husk to spawn list."
}
