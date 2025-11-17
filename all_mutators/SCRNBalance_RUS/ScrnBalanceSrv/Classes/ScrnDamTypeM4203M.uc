class ScrnDamTypeM4203M extends ScrnDamTypeMedicBase
	abstract;
    
// Award also Shiver kills with 2x Stalker progress 
// v4.59 - count only 1 kill from now on, because new version of Shiver.se calls 
// AwardKill() twice: for the decapitator and for the killer
static function AwardKill(KFSteamStatsAndAchievements KFStatsAndAchievements, KFPlayerController Killer, KFMonster Killed )
{
	if( Killed.IsA('ZombieShiver') || Killed.IsA('ZombieStalker') )
		KFStatsAndAchievements.AddStalkerKill();
}

defaultproperties
{
     WeaponClass=Class'ScrnBalanceSrv.ScrnM4203MMedicGun'
     DeathString="%k killed %o (M4 203)."
     KDamageImpulse=1500.000000
     KDeathVel=110.000000
}
