class KFSurpriseBloatMut extends mutator;

//#exec obj load file=..\textures\Bobsponge.utx
//#exec obj load file=..\animations\Bobsponge.ukx

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
		KF.FallbackMonster = GetReplaceClass( Class<KFMonster>(KF.FallbackMonster) );		
	}
	
}

function Class<KFMonster> GetReplaceClass( Class<KFMonster> MC )
{
	switch( MC )
	{
	case Class'ZombieBloat':
		return Class'ZombieSurpriseBloat';
	default:
		return MC;
	}
}

defaultproperties
{
     GroupName="KF-SurpriseBloat"
     FriendlyName="SurpriseBloat-ed"
     Description="When a Bloat shoot it spawn a Baby Bloat..."
}
