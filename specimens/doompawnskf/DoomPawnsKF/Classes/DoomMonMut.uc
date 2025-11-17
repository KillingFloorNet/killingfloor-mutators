//-----------------------------------------------------------
// Written by Marco
//-----------------------------------------------------------
class DoomMonMut extends Mutator
	Config(DoomPawnsKF);

var() config bool bFastMonsters,bSpawnSuperMonsters,bMonstersDropWeps;
var() config int MaxLostSouls;
var bool bHasInit;
var int SuperMonWave,LastScannedWave;
var array< class<Pickup> > DropsWhenDie;

function PostBeginPlay()
{
	SetTimer(0.1,False);
}
function Timer()
{
	if( !bHasInit )
	{
		bHasInit = true;
		InitMut();
	}
	else if( LastScannedWave!=KFGameType(Level.Game).WaveNum )
	{
		if( !KFGameType(Level.Game).bWaveInProgress )
			return;
		LastScannedWave = KFGameType(Level.Game).WaveNum;
		if( FRand()<0.45 && KFGameType(Level.Game).WaveNum>=SuperMonWave && KFGameType(Level.Game).WaveNum<KFGameType(Level.Game).FinalWave )
			TryToAddBoss();
	}
}
final function InitMut()
{
	local KFGameType KF;
	local int i,j;

	KF = KFGameType(Level.Game);
	if ( KF!=None )
	{
		for( i=0; i<KF.InitSquads.Length; i++ )
		{
			for( j=0; j<KF.InitSquads[i].MSquad.Length; j++ )
				KF.InitSquads[i].MSquad[j] = GetReplaceClass(KF.InitSquads[i].MSquad[j]);
		}
		for( i=0; i<KF.SpecialSquads.Length; i++ )
		{
			for( j=0; j<KF.SpecialSquads[i].ZedClass.Length; j++ )
				ReplaceMonsterStr(KF.SpecialSquads[i].ZedClass[j]);
		}
		for( i=0; i<KF.FinalSquads.Length; i++ )
		{
			for( j=0; j<KF.FinalSquads[i].ZedClass.Length; j++ )
				ReplaceMonsterStr(KF.FinalSquads[i].ZedClass[j]);
		}
		KF.FallbackMonster = GetReplaceClass( Class<KFMonster>(KF.FallbackMonster) );
		if( bSpawnSuperMonsters )
		{
			SuperMonWave = (KF.FinalWave*0.75);
			SetTimer(3,true);
		}
	}
}
final function TryToAddBoss()
{
	local NavigationPoint N;
	local array<NavigationPoint> Candinates;
	local byte i;
	local int j;
	local class<Monster> TryMonster;
	local Monster M;

	for( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
	{
		if( FRand()<0.5 && PathNode(N)!=None )
			Candinates[Candinates.Length] = N;
	}
	if( Candinates.Length==0 )
		return;
	if( FRand()<0.5 )
		TryMonster = Class'Cyber';
	else TryMonster = Class'SpiderMM';
	for( i=0; i<30; i++ ) // Give it 30 tries
	{
		j = Rand(Candinates.Length);
		N = Candinates[j];

		// Try spawn twice..
		M = Spawn(TryMonster,,,N.Location);
		if( M==None )
			M = Spawn(TryMonster,,,N.Location+vect(0,0,1)*(M.CollisionHeight-N.CollisionHeight));
		if( M!=None )
			return;

		// Remove candinate entry, and try random next...
		Candinates.Remove(j,1);
		if( Candinates.Length==0 )
			return;
	}
}
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if( DoomController(Other)!=None )
	{
		DoomController(Other).bActLikeInv = true;
		DoomController(Other).bFastMonster = bFastMonsters;
	}
	else if( PainHead(Other)!=None )
		PainHead(Other).MaxLostSouls = MaxLostSouls;
	else if( bMonstersDropWeps && DoomPawns(Other)!=None && DoomPawns(Other).DropWhenKilled==None && FRand()<0.05 )
		DoomPawns(Other).DropWhenKilled = DropsWhenDie[Rand(DropsWhenDie.Length)];
	return true;
}
final function Class<KFMonster> GetReplaceClass( Class<KFMonster> MC )
{
	switch( MC )
	{
	case Class'ZombieClot':
		if( FRand()<0.4 )
			return Class'LightTrooper';
		else if( FRand()<0.1 )
			return Class'MediumTrooper';
		return Class'Imp';
	case Class'ZombieBloat':
		if( FRand()<0.1 )
			return Class'Spectre';
		return Class'Demon';
	case Class'ZombieCrawler':
		return Class'Skull';
	case Class'ZombieHusk':
	case Class'ZombieStalker':
		if( FRand()<0.3 )
			return Class'Knight';
		else if( FRand()<0.2 )
			return Class'PlasmaTrooper';
		return Class'Caco';
	case Class'ZombieSiren':
		if( FRand()<0.3 )
			return Class'D64Baron';
		else if( FRand()<0.2 )
			return Class'PainHead';
		else if( FRand()<0.1 )
			return Class'Spider';
		return Class'Baron';
	case Class'ZombieScrake':
		if( FRand()<0.33 )
			return Class'Mancub';
		else if( FRand()<0.33 )
			return Class'Spider';
		return Class'Skeleton';
	case Class'ZombieFleshPound':
		return Class'Vile';
	case Class'ZombieGorefast':
		if( FRand()<0.25 )
			return Class'WolfSS';
		return Class'HeavyTrooper';
	default:
		return MC;
	}
}
final function ReplaceMonsterStr( out string MC )
{
	MC = string(GetReplaceClass(Class<KFMonster>(DynamicLoadObject(MC,Class'Class'))));
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.RulesGroup, "bFastMonsters", "Fast monsters", 0, 0, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "bSpawnSuperMonsters", "Super monsters", 0, 0, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "MaxLostSouls", "Max Lost Souls", 0, 1, "Text", "1;1:50");
	PlayInfo.AddSetting(default.RulesGroup, "bMonstersDropWeps", "Monsters drop weps", 0, 0, "Check");
}
static event string GetDescriptionText(string PropName)
{
	switch(PropName)
	{
		case "bFastMonsters":
			return "If checked, all monsters are about 1.5 X faster.";
		case "MaxLostSouls":
			return "Maximum number of 'Lost Souls' Pain Elementals can spit out.";
		case "bSpawnSuperMonsters":
			return "In later waves, add sometimes a super monster (such as Spider MasterMind or Cyberdemon).";
		case "bMonstersDropWeps":
			return "Monsters should randomly drop random doom weapons.";
		default:
			return Super.GetDescriptionText(PropName);
	}
}

defaultproperties
{
     bSpawnSuperMonsters=True
     bMonstersDropWeps=True
     MaxLostSouls=10
     DropsWhenDie(0)=Class'DoomPawnsKF.DoomSShotgunPickup'
     DropsWhenDie(1)=Class'DoomPawnsKF.DoomPistolPickup'
     DropsWhenDie(2)=Class'DoomPawnsKF.DoomRLPickup'
     DropsWhenDie(3)=Class'DoomPawnsKF.DoomBFGPickup'
     DropsWhenDie(4)=Class'DoomPawnsKF.MegaSphere'
     DropsWhenDie(5)=Class'DoomPawnsKF.SoulSphere'
     DropsWhenDie(6)=Class'DoomPawnsKF.InvulnSphere'
     DropsWhenDie(7)=Class'DoomPawnsKF.InvisSphere'
     DropsWhenDie(8)=Class'DoomPawnsKF.Backpack'
     DropsWhenDie(9)=Class'DoomPawnsKF.DoomArmor'
     DropsWhenDie(10)=Class'DoomPawnsKF.DoomSuperArmor'
     DropsWhenDie(11)=Class'DoomPawnsKF.DoomHealthPack'
     DropsWhenDie(12)=Class'DoomPawnsKF.DoomStimPack'
     bAddToServerPackages=True
     GroupName="KF-MonsterMut"
     FriendlyName="Doom Monsters Mode!"
     Description="Only do invasion of doom creatures."
}
