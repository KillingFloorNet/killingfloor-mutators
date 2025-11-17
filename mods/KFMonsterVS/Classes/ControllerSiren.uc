Class ControllerSiren extends SirenZombieController;

function bool FindNewEnemy()
{
	return Class'ControllerAIBase'.Static.StaticFindNewEnemy(KFM,Self);
}
function bool SetEnemy( Pawn NewEnemy, optional bool bHateMonster, optional float MonsterHateChanceOverride )
{
	return Class'ControllerAIBase'.Static.StaticSetEnemy(KFM,Self,NewEnemy,bHateMonster);
}

defaultproperties
{
}
