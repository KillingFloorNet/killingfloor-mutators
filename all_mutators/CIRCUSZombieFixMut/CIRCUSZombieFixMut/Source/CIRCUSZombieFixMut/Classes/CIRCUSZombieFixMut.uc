class CIRCUSZombieFixMut extends Mutator;

function PostBeginPlay()
{
	class'KFChar.ZombieStalker'.default.EventClasses[0]="KFChar.ZombieStalker_CIRCUS";
	class'KFChar.ZombieSiren'.default.EventClasses[0]="KFChar.ZombieSiren_CIRCUS";
	class'KFChar.ZombieScrake'.default.EventClasses[0]="KFChar.ZombieScrake_CIRCUS";
	class'KFChar.ZombieHusk'.default.EventClasses[0]="KFChar.ZombieHusk_CIRCUS";
	class'KFChar.ZombieGoreFast'.default.EventClasses[0]="KFChar.ZombieGoreFast_CIRCUS";
	class'KFChar.ZombieFleshPound'.default.EventClasses[0]="KFChar.ZombieFleshPound_CIRCUS";
	class'KFChar.ZombieCrawler'.default.EventClasses[0]="KFChar.ZombieCrawler_CIRCUS";
	class'KFChar.ZombieClot'.default.EventClasses[0]="KFChar.ZombieClot_CIRCUS";
	class'KFChar.ZombieBoss'.default.EventClasses[0]="KFChar.ZombieBoss_CIRCUS";
	class'KFChar.ZombieBloat'.default.EventClasses[0]="KFChar.ZombieBloat_CIRCUS";
}

defaultproperties
{
	GroupName="CIRCUSZombieFixMut"
	FriendlyName="CIRCUSZombieFixMut"
	Description="CIRCUSZombieFixMut"
	bAddToServerPackages=True
}