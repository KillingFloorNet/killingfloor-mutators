class DamTypeAssaultRifle extends KFProjectileWeaponDamageType
	abstract;

static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed )
{
	if( Killed.IsA('ZombieStalker') )
		KFStatsAndAchievements.AddStalkerKill();
}

static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount)
{
	KFStatsAndAchievements.AddBullpupDamage(Amount);
}

defaultproperties
{
    WeaponClass=Class'AssaultRifleUnreal2k4.AssaultRifle'
    DeathString="%k killed %o (AssaultRifle)."
    FemaleSuicide="%o shot herself in the foot."
    MaleSuicide="%o shot himself in the foot."
    bBulletHit=True
    FlashFog=(X=600.000000)
    //KDamageImpulse=11500.000000
    VehicleDamageScaling=0.800000
    bIsPowerWeapon=false
    bSniperWeapon=false

	// Make this bullet move the ragdoll when its shot
	bRagdollBullet=true
	KDamageImpulse=11500
	KDeathVel=200.000000
	KDeathUpKick=40
}
