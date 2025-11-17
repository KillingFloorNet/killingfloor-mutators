class zbot extends kfinvasionBot;

var Controller Leader;

function postbeginplay()
{
	PlayerReplicationInfoClass=class'awesomeclot2.zombiepri';
	pawnclass=class'zhuman';
	super.postbeginplay();
	//playerreplicationinfo.destroy();
	//playerreplicationinfo = spawn(PlayerReplicationInfoClass, Self,,vect(0,0,0),rot(0,0,0));
	//initplayerreplicationinfo();
}
function GoToTrader()
{
	if( ZombieGameType(level.game).Lure != none )
	GotoState('TraderHunt', 'Begin');
}
function Actor FaceActor(float StrafingModifier)
{
	return super(invasionbot).faceactor(strafingmodifier);
}
State TraderHunt extends MoveToGoalWithEnemy
{

	function BeginState()
	{
		MoveTarget = none;
		setcollision(false,false,false);
	}
	function Hunt()
	{
		MoveTarget = FindPathToward(ZombieGameType(level.game).Lure);
	}
	function EndState()
	{
		if( !pawn.ReachedDestination(MoveTarget) && zombiegametype(level.game).bwaveinprogress)
			gotostate('TraderHunt', 'Begin');
	}
	function Actor FaceActor(float StrafingModifier)
    {
		if( enemy==none )
		  return MoveTarget;
		else
		  return Enemy;
    }
	function bool FireWeaponAt(Actor A)
	{
		if ( (A == Enemy) && (Pawn.Weapon != None) && (Pawn.Weapon.AIRating < 0.5)
			&& (Level.TimeSeconds - Pawn.SpawnTime < DeathMatch(Level.Game).SpawnProtectionTime)
			&& (Squad.PriorityObjective(self) == 0)
			&& (InventorySpot(Routegoal) != None) )
		{
			// don't fire if still spawn protected, and no good weapon
			return false;
		}
		return Global.FireWeaponAt(A);
	}
Begin:
	Hunt();
	MoveTarget = FindPathToward(ZombieGameType(level.game).Lure);
	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));
	WhatToDoNext(14);
	pawn.bwantstocrouch=false;
	if( pawn.ReachedDestination(MoveTarget) && !zombiegametype(level.game).bwaveinprogress )
			gotostate('');
	
}

defaultproperties
{
     Aggressiveness=3.000000
     BaseAlertness=3.000000
     Accuracy=0.900000
     CombatStyle=1.000000
     FovAngle=180.000000
     PlayerReplicationInfoClass=Class'AwesomeClot2.ZombiePRI'
     PawnClass=Class'AwesomeClot2.ZHuman'
}
