class AA12DWBullet extends ShotgunBullet;

defaultproperties
{
     DamageAtten=5
     MaxPenetrations=2
     PenDamageReduction=0.750000
     HeadShotDamageMult=1.500000
     Speed=3500
     MaxSpeed=4000
     bSwitchToZeroCollision=True
     Damage=30
     DamageRadius=0
     MomentumTransfer=60000
     MyDamageType=Class'KFMod.DamTypeAA12Shotgun'
     ExplosionDecal=Class'KFMod.ShotgunDecal'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'kf_generic_sm.Shotgun_Pellet'
     CullDistance=3000
     LifeSpan=3
     DrawScale=1.5
     Style=STY_Alpha
     ImpactEffect=class'ROBulletHitEffect'
}
