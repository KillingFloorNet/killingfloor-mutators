class TauBulletOver extends Grenade;

defaultproperties
{
	TossZ=+0.0
    HitEffectClass=none
    DampenFactor=0.5
    DampenFactorParallel=0.8
    ExplosionDecal=class'RocketMark'
    MyDamageType=DamTypeTauExplode
    Speed=0
    MaxSpeed=10
    Damage=2000
    DamageRadius=500
    MomentumTransfer=75000
    ExplodeTimer=0.001
    ImpactSound=sound'Inf_Weapons_Foley.grenadeland'
    Physics=PHYS_Falling
    DrawType=DT_StaticMesh
    StaticMesh=StaticMesh'kf_generic_sm.Shotgun_Pellet' //C
    DrawScale=0.5
    AmbientGlow=100
    bBounce=True
    bFixedRotationDir=True
    DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
    FluidSurfaceShootStrengthMod=3.f
}
