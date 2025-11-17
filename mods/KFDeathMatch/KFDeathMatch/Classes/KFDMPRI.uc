Class KFDMPRI extends KFPlayerReplicationInfo;

simulated function SetGRI(GameReplicationInfo GRI);

function Reset()
{
	Super.Reset();
	bReadyToPlay = true;
}

defaultproperties
{
}
