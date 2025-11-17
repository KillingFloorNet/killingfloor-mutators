class DamTypeTCProjectile extends KFProjectileWeaponDamageType;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth)
{
	HitEffects[0] = class'HitSmoke';
	if( VictimHealth <= 0 )
		HitEffects[1] = class'KFHitFlame';
	else if ( FRand() < 0.8 )
		HitEffects[1] = class'KFHitFlame';
}

defaultproperties
{
    WeaponClass=Class'TauC.TauCannon'
    DeathString="%o overcharged their Tau Cannon"
    FemaleSuicide="%o overcharged her Tau Cannon."
    MaleSuicide="%o overcharged his Tau Cannon"
    bRagdollBullet=True
    bBulletHit=True
    KDamageImpulse=10000.000000
    KDeathVel=300.000000
    KDeathUpKick=100.000000
    bIsPowerWeapon=false
	DeathOverlayMaterial=Material'Effects_Tex.PlayerDeathOverlay'
	DeathOverlayTime=999
	HumanObliterationThreshhold=150
    HeadShotDamageMult=1.4
}
