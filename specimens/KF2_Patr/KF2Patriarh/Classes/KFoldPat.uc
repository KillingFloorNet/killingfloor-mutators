Class KFoldPat extends Mutator;

function PreBeginPlay()
{
	AddToPackageMap();
}
function MatchStarting()
{
	SetTimer(1,false);
}
function Timer()
{
	KFGameType(Level.Game).EndGameBossClass = string(Class'KF2Patriarh.ZombieKf2Boss_STANDARD');
	if( KFGameType(Level.Game).MonsterCollection!=None )
		KFGameType(Level.Game).MonsterCollection.Default.EndGameBossClass = string(Class'KF2Patriarh.ZombieKf2Boss_STANDARD');
	Destroy();
}

defaultproperties
{
     GroupName="KF2-BossMut"
     FriendlyName="KF2-Boss"
     Description="Make the Patriarch boss kf2."
}
