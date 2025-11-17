class DamTypeFreezerDart extends DamTypeFreezerBase
	abstract;

static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed )
{
	if( Killed.IsA('ZombieStalker') )
		KFStatsAndAchievements.AddStalkerKill();
}

defaultproperties
{
     FreezeRatio=0.600000
     FoT_Duration=2
     FoT_Ratio=0.200000
}
