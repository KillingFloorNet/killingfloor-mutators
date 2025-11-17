//=============================================================================
// RLRocket.
//=============================================================================
class RLRocket extends DoomRocket;

function BlowUp( vector HitLocation )
{
	HurtRadius(Damage-(Damage/2*FRand()),DamageRadius, Class'RLBlown', MomentumTransfer, HitLocation );
	MakeNoise(2.0);
}

defaultproperties
{
     Speed=1500.000000
     Damage=130.000000
     DamageRadius=300.000000
     SpawnSound=None
     CollisionRadius=10.000000
     CollisionHeight=10.000000
}
