class DamTypeTau extends DamTypeTCProjectile
	abstract;

static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount)
{
	if( SRStatsBase(KFStatsAndAchievements)!=None && SRStatsBase(KFStatsAndAchievements).Rep!=None )
		SRStatsBase(KFStatsAndAchievements).Rep.ProgressCustomValue(Class'EngineerDam',Amount);
}

defaultproperties
{
}


