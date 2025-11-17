class KFBrutesOnlyMut extends Mutator
	Config(Brute);
	
var config string BrutePkgName;

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.RulesGroup, "BrutePkgName", "Brute package name", 0, 0, "text");
}

function PostBeginPlay()
{
	if (Level.NetMode != NM_Standalone)
		AddToPackageMap(BrutePkgName);
    SetTimer(0.1, false);
}

function ModifyPlayer(Pawn P)
{
	P.GiveWeapon("KFMod.Crossbow");
	Super.ModifyPlayer(P);
}

function Timer()
{
    local KFGameType KF;
    local byte i;
    local class<KFMonster> MC;

    KF = KFGameType(Level.Game);
    MC = Class<KFMonster>(DynamicLoadObject(BrutePkgName$".ZombieBrute", Class'Class'));
    if (KF!=None && MC!=None)
    {
        KF.InitSquads.Length = 1;
        KF.InitSquads[0].MSquad.Length = 1;
        for( i=0; i<1; i++ )
            KF.InitSquads[0].MSquad[i] = MC;
    }
	Destroy();
}

defaultproperties
{
     GroupName="KF-MonsterMut"
     FriendlyName="Brutes Only"
     Description="Only Brutes will appear during the game."
	 BrutePkgName="KFBruteFinal_013"
}
