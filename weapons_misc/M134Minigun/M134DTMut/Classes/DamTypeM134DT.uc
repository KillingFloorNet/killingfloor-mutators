class DamTypeM134DT extends KFProjectileWeaponDamageType
	abstract;

static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed)
{
	if (Killed.IsA('ZombieStalker'))
	{
		KFStatsAndAchievements.AddStalkerKill();
	}
}

static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount)
{
	KFStatsAndAchievements.AddBullpupDamage(Amount);
}

defaultproperties
{
     //bCheckForHeadShots=False
     WeaponClass=class'M134DT'
     DeathString="%k killed %o (M-134)."
     FemaleSuicide="%o shot herself in the foot."
     MaleSuicide="%o shot himself in the foot."
     bRagdollBullet=True
     KDamageImpulse=5500.000000
     KDeathVel=450.000000
     KDeathUpKick=45.000000
}