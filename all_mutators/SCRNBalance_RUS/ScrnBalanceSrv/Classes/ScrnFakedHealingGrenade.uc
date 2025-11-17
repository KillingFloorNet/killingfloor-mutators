class ScrnFakedHealingGrenade extends ScrnM79MGrenadeProjectile;


simulated function PostBeginPlay()
{
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
}

simulated function Disintegrate(vector HitLocation, vector HitNormal)
{
}

simulated function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
}

simulated function Tick( float DeltaTime )
{
	Disable('Tick');
}

/*

simulated function ProcessTouch( actor Other, vector HitLocation )
{
}

simulated function HitWall( vector HitNormal, actor Wall )
{
}
*/
/*
simulated function PostNetReceive()
{
}





*/

defaultproperties
{
     StaticMesh=StaticMesh'KF_pickups5_Trip.nades.MedicNade_Pickup'
     bReplicateMovement=False
     bSkipActorPropertyReplication=True
     bUpdateSimulatedPosition=False
     Physics=PHYS_None
     RemoteRole=ROLE_None
     LifeSpan=0.000000
     DrawScale=3.500000
     bCollideActors=False
     bCollideWorld=False
     bNetNotify=False
}
