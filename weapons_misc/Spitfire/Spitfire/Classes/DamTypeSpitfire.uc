class DamTypeSpitfire extends KFWeaponDamageType
	abstract;

static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount)
{
	KFStatsAndAchievements.AddFlameThrowerDamage(Amount);
}

defaultproperties
{
     bDealBurningDamage=True
     bCheckForHeadShots=False
     WeaponClass=Class'Spitfire.Spitfire'
     DeathString="%k incinerated %o (Spitfire)."
     FemaleSuicide="%o roasted herself alive."
     MaleSuicide="%o roasted himself alive."
}
