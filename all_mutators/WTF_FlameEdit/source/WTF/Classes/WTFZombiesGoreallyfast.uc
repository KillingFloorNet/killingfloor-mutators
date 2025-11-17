class WTFZombiesGoreallyFast extends ZombieGoreFast;



//charge from farther away
function RangedAttack(Actor A)
{
	Super.RangedAttack(A);
	if( !bShotAnim && !bDecapitated && VSize(A.Location-Location)<=1400 )
		GoToState('RunningState');
}

defaultproperties
{
     GroundSpeed=160.000000
     WaterSpeed=100.000000
     MenuName="Goreallyfast"
     Skins(0)=Texture'WTF_A.WTFZombies.Goreallyfast'
}
