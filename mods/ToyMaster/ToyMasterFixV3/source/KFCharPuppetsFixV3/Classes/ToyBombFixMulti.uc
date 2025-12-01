//================
//Code fixes and balancing by Skell*.
//Original content is by Alex Quick and David Hensley.
//================
//Toy Bomb (cluster version)
//================
class ToyBombFixMulti extends ToyBomb;

#exec obj load file="KFPuppetsFixV3_T.utx"
#exec obj load file="KFPuppetsFixV3_SM.usx"

static function PreloadAssets()
{
	UpdateDefaultStaticMesh(StaticMesh(DynamicLoadObject("KFPuppetsFixV3_SM.ToyBombProjectile", class'StaticMesh', true)));
}

//This bomb has higher damage but moves slowly in the air and has a very long fuse time.

defaultproperties
{
     ExplodeTimer=6.000000
     Speed=800.000000
     MaxSpeed=1000.000000
     Damage=200.000000
     DamageRadius=400.000000
     StaticMesh=StaticMesh'KFPuppetsFixV3_SM.ToyBombProjectile'
     CollisionRadius=44.000000
     CollisionHeight=44.000000
}
