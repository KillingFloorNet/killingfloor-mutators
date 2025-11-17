class KFBruteMut extends Mutator
	Config(Brute);

var config string BrutePkgName;

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.RulesGroup, "BrutePkgName", "Brute package name", 0, 0, "text");
}

function PostBeginPlay()
{
	local int i;
	local string MID;
	local KFGameType KF;
	
	if (Level.NetMode != NM_Standalone)
		AddToPackageMap(BrutePkgName);
	
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
	KFGameType(Level.Game).StandardMonsterClasses[i].MClassName = BrutePkgName$".ZombieBrute";
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
	GroupName="KF-AddBruteMut"
	FriendlyName="Add Brutes"
	Description="Adds brutes to spawn list."
	BrutePkgName="KFBruteFinal_013"
}
