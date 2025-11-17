class VSBaseMut extends Mutator
	CacheExempt;

// Try to replace as many unsafe controllers as possible.
final function CheckControllerClass( out class<AIController> CC )
{
	switch( CC )
	{
	case class'KFMonsterController':
		CC = Class'ControllerAIBase';
		break;
	case class'BossZombieController':
		CC = Class'ControllerBoss';
		break;
	case class'CrawlerController':
		CC = Class'ControllerCrawler';
		break;
	case class'FleshpoundZombieController':
		CC = Class'ControllerFP';
		break;
	case class'GorefastController':
		CC = Class'ControllerGoreFast';
		break;
	case class'HuskZombieController':
		CC = Class'ControllerHusk';
		break;
	case class'SawZombieController':
		CC = Class'ControllerScrake';
		break;
	case class'SirenZombieController':
		CC = Class'ControllerSiren';
		break;
	}
}
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if( Controller(Other)!=None )
		Controller(Other).PlayerReplicationInfoClass = Class'VSPRI';
	else if( Monster(Other)!=None )
		CheckControllerClass(Monster(Other).ControllerClass);
	return true;
}

defaultproperties
{
}
