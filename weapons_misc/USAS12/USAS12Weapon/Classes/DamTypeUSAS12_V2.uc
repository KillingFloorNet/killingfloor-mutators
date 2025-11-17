class DamTypeUSAS12_V2 extends KFProjectileWeaponDamageType
	abstract;

defaultproperties
{
     bIsPowerWeapon=True
     WeaponClass=Class'USAS12_V2'
     DeathString="%k killed %o (USAS-12 Shotgun)."
     FemaleSuicide="%o shot herself in the foot."
     MaleSuicide="%o shot himself in the foot."
     bRagdollBullet=True
     bBulletHit=True
     FlashFog=(X=600.000000)
     KDamageImpulse=10000.000000
     KDeathVel=1100.000000
     KDeathUpKick=200.000000
     VehicleDamageScaling=0.700000
}
