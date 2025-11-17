class KFRangedPounds extends Mutator;

var int LastSetWave;

function PostBeginPlay()
{
	SetTimer(0.1,False);
}
function Timer()
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
		KF.EndGameBossClass = string(Class'ZombieBoss');
	}
	Destroy();
}
final function Class<KFMonster> GetReplaceClass( Class<KFMonster> MC )
{
	switch( MC )
	{
	case Class'ZombieFleshPound':
		return Class'ZombieFleshPoundRange';
	default:
		return MC;
	}
}
final function ReplaceMonsterStr( out string MC )
{
	if( MC~="KFChar.ZombieFleshPound" )
		MC = "KFChar.ZombieFleshPoundRange";
}

function tick(float delta)
{

local kfmonster law;

foreach allactors(class'kfmonster', law)
{

if(law!=none)
{

if(law.isa('ZombieFleshPound'))
{law.RagDollOverride="ClotRag";
		}
	}

	}
}

defaultproperties
{
     GroupName="KF-RangedPounds"
     FriendlyName="Fleshpound Chaingunners"
     Description="Gives chainguns to Fleshpounds."
}
