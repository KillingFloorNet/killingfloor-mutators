class DamTypeSV98SniperRifle extends KFProjectileWeaponDamageType
	abstract;

static function ScoredHeadshot(KFSteamStatsAndAchievements KFStatsAndAchievements, class<KFMonster> MonsterClass, bool bLaserSightedM14EBRKill)
{
	super.ScoredHeadshot( KFStatsAndAchievements, MonsterClass, bLaserSightedM14EBRKill );

	if ( KFStatsAndAchievements != none )
	{
     	KFStatsAndAchievements.AddHeadshotsWithSPSOrM14( MonsterClass );
	}
}

defaultproperties
{
    WeaponClass=Class'SV98SniperRifle'
    DeathString="%k killed %o (SV-98)."
    FemaleSuicide="%o shot herself in the foot."
    MaleSuicide="%o shot himself in the foot."

	bRagdollBullet=true
    KDeathVel=175.000000
    KDamageImpulse=7500
    KDeathUpKick=25
	bSniperWeapon=True
    HeadShotDamageMult=2.25
}