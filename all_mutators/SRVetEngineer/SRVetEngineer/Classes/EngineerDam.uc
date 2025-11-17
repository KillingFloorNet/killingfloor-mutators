class EngineerDam extends SRCustomProgressInt;

static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount)
{
	if( SRStatsBase(KFStatsAndAchievements)!=None && SRStatsBase(KFStatsAndAchievements).Rep!=None )
		SRStatsBase(KFStatsAndAchievements).Rep.ProgressCustomValue(Class'EngineerDam',Amount);
}

defaultproperties
{
     ProgressName="Engineer Weapons Damage"
}
