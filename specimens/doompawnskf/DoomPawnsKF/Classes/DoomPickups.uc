Class DoomPickups extends TournamentPickUp
	Abstract
	Placeable;

function RespawnEffect()
{
	spawn(class'DRespawnEffect');
}

defaultproperties
{
     PickupSound=Sound'DoomPawnsKF.Generic.DSITEMUP'
     DrawType=DT_Sprite
}
