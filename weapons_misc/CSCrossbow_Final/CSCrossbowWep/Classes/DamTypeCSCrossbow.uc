class DamTypeCSCrossbow extends KFProjectileWeaponDamageType;

static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed )
{
	if( KFStatsAndAchievements!=None && Killed.BurnDown>0 )
		KFStatsAndAchievements.AddBurningCrossbowKill();
}

defaultproperties
{
    WeaponClass=Class'CSCrossbowWep.CSCrossbow'

    HeadShotDamageMult=1.000000 // Decreased in Balance Round 2
    bKUseOwnDeathVel=True
    bThrowRagdoll=True
    bFlaming=False
    DamageThreshold=1
    KDamageImpulse=2000.000000
	bSniperWeapon=True

    // Make this bullet move the ragdoll when its shot
    bRagdollBullet=true
    KDeathVel=110.000000
    KDeathUpKick=10
}
