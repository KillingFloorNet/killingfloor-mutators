class DamTypeStunNade extends KFWeaponDamageType;

static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed )
{
	if(Killed.IsA('ZombieStalker'))
		KFStatsAndAchievements.AddStalkerKill();
}

static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount)
{
	KFStatsAndAchievements.AddBullpupDamage(Amount);
}

defaultproperties
{
     WeaponClass=Class'StunNade.StunNade'
     bCheckForHeadShots=False
     DeathString="%o filled %k's slowed down."
     FemaleSuicide="%o slowed down."
     MaleSuicide="%o slowed down."
     bLocationalHit=False
}