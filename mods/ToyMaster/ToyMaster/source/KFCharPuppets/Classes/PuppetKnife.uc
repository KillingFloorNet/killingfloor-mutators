class PuppetKnife extends CrossbowArrow;

var() class<Actor> KnifeTrailClass;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
    if( Level.NetMode!=NM_DedicatedServer && (Level.NetMode!=NM_Client || Physics==PHYS_Projectile) )
	{
		if ( !PhysicsVolume.bWaterVolume )
		{
			Trail = xEmitter(Spawn(KnifeTrailClass,self));
			Trail.Lifespan = Lifespan;
		}
	}
	else if( Level.NetMode==NM_Client )
	{
		if( ImpactActor!=None )
			SetBase(ImpactActor);
		GoToState('OnWall');
	}
    if(Trail != none)
    {
         AttachToBone(Trail,'tip');
         LoopAnim('spin', 6.0);
    }
}


simulated function HitWall( vector HitNormal, actor Wall )
{
      super.HitWall (HitNormal, Wall);
      LoopAnim('idle', 1.0);
}

defaultproperties
{
     KnifeTrailClass=Class'KFCharPuppets.KnifeTrail'
     HeadShotDamageMult=2.000000
     MeshRef="KF_Puppets.Puppet_Knife"
     Speed=500.000000
     MaxSpeed=600.000000
     Damage=12.000000
     Mesh=SkeletalMesh'KF_Puppets.Puppet_Knife'
     DrawScale=1.000000
     AmbientGlow=15
}
