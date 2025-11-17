Class ZEDSoldier extends ZEDSoldierBase;

function bool ReadyToFire( Pawn Enemy )
{
	return (FRand() < 0.5f && Super.ReadyToFire(Enemy));
}

defaultproperties
{
	WeaponMissRate=0.057500
	WeaponFireTime=0.800000
	ScoringValue=15
}