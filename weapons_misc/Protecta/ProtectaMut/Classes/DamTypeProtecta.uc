class DamTypeProtecta extends KFProjectileWeaponDamageType
	abstract;

defaultproperties
{
     bIsPowerWeapon=True
     WeaponClass=Class'ProtectaMut.Protecta'
     DeathString="%k killed %o (Protecta)."
     FemaleSuicide="%o shot herself in the foot."
     MaleSuicide="%o shot himself in the foot."
     bRagdollBullet=True
     bBulletHit=True
     FlashFog=(X=600.000000)
     KDamageImpulse=10000.000000
     KDeathVel=400.000000
     KDeathUpKick=120.000000
     VehicleDamageScaling=0.700000
}
