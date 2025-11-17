Class KF2HardPat extends Mutator;

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
	KFGameType(Level.Game).EndGameBossClass = string(Class'KF2Patriarh.HardPatKF2');
	if( KFGameType(Level.Game).MonsterCollection!=None )
		KFGameType(Level.Game).MonsterCollection.Default.EndGameBossClass = string(Class'KF2Patriarh.HardPatKF2');
	Destroy();
}

defaultproperties
{
     GroupName="KF2-HardBossMut"
     FriendlyName="KF2-HardBoss"
     Description="Make Hard the Patriarch Hard boss kf2."
}
