Class ControllerBoss extends BossZombieController;

function bool FindNewEnemy()
{
	return Class'ControllerAIBase'.Static.StaticFindNewEnemy(KFM,Self);
}
function bool SetEnemy( Pawn NewEnemy, optional bool bHateMonster, optional float MonsterHateChanceOverride )
{
	return Class'ControllerAIBase'.Static.StaticSetEnemy(KFM,Self,NewEnemy,bHateMonster);
}
function AvoidThisMonster(KFMonster Feared);

defaultproperties
{
}
