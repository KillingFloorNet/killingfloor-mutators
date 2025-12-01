//================
//Code fixes and balancing by Skell*.
//Original content is by Alex Quick and David Hensley.
//================
//Toy Bomb (regular version)
//================
class ToyBombFix extends ToyBomb;

#exec obj load file="KFPuppetsFixV3_T.utx"
#exec obj load file="KFPuppetsFixV3_SM.usx"

static function PreloadAssets()
{
	UpdateDefaultStaticMesh(StaticMesh(DynamicLoadObject("KFPuppetsFixV3_SM.ToyBombProjectile", class'StaticMesh', true)));
}

//Slowed and a longer fuse time.

defaultproperties
{
     ExplodeTimer=4.000000
     Speed=1750.000000
     MaxSpeed=2000.000000
     Damage=200.000000
     DamageRadius=300.000000
     StaticMesh=StaticMesh'KFPuppetsFixV3_SM.ToyBombProjectile'
     DrawScale=1.500000
     CollisionRadius=33.000000
     CollisionHeight=33.000000
}
