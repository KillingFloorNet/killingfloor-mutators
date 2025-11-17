class DamTypeRPG extends DamTypeFrag;

static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed );

defaultproperties
{
	WeaponClass=Class'RPG7DT_v2.RPG'
	KDeathUpKick=300.000000
	HumanObliterationThreshhold=350
	DeathOverlayMaterial=Material'Effects_Tex.PlayerDeathOverlay'
	DeathOverlayTime=999
	bIsPowerWeapon=False
	bIsExplosive=True
}