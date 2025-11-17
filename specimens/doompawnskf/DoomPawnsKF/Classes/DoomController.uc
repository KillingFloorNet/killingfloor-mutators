//=============================================================================
// DoomController.				Coded by .:..:
//=============================================================================
class DoomController extends KFMonsterController;

var Actor Node;
var bool bIsAttacking,bCanBeAgressive,bFastMonster,bActLikeInv,bIsWandering;
var int NumFLeft;
var float LastRoamTime,ForbiddenHateTime,StartedStateTime,NoKillMeTimer,DoorAttackTime;
var vector DoorAimingPosition;

function ZombieMoan();

function BreakUpDoor( KFDoorMover Other, bool bTryDistanceAttack ) // I have came up to a door, break it!
{
	TargetDoor = Other;
	DoorAimingPosition = Pawn.Location+Normal(Pawn.Velocity)*800;
	GotoState('HateDoorz');
}
function PreBeginPlay()
{
	ForbiddenHateTime = Level.TimeSeconds+0.5;
	Super.PreBeginPlay();
}
function ExecuteWhatToDoNext()
{
	if( Enemy==None )
		GoToState('Idling');
	else if( LineOfSightTo(Enemy) )
		GoToState('AttackEnemy');
	else GoToState('HuntingEnemy');
}
function bool FindNewEnemy()
{
	local Controller C;
	local array<Controller> CC;

	For( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( C.Pawn!=None && C.Pawn.Health>0 && !C.Pawn.IsA('Monster') )
			CC[CC.Length] = C;
	}
	if( CC.Length==0 ) Return False;
	if( SetEnemy(CC[Rand(CC.Length)].Pawn,False) )
	{
		DoomPawns(Pawn).PlayAcquisitionSound();
		if( LineOfSightTo(Enemy) )
			GoToState('AttackEnemy');
		else GoToState('HuntingEnemy');
	}
	Return True;
}
final function FreezePawn( bool bFreezeNow )
{
	if( Pawn==None )
		return;
	if( bFreezeNow )
	{
		MoveTimer = -1;
		MoveTarget = None;
		if( Pawn.Physics==PHYS_Flying )
			Pawn.Velocity = vect(0,0,0);
		Pawn.Acceleration = vect(0,0,0);
		Pawn.GroundSpeed = 0.1;
		Pawn.AirSpeed = 0.1;
	}
	else if( bFastMonster )
	{
		Pawn.GroundSpeed = Pawn.Default.GroundSpeed*1.5;
		Pawn.AirSpeed = Pawn.Default.AirSpeed*1.5;
	}
	else
	{
		Pawn.GroundSpeed = Pawn.Default.GroundSpeed;
		Pawn.AirSpeed = Pawn.Default.AirSpeed;
	}
}
State InitUp
{
Ignores Tick,EnemyNotVisible,SeePlayer,HearNoise,DamageAttitudeTo;

	function EndState()
	{
		if( DoomPawns(Pawn).bFastMonster )
			bFastMonster = true;
		else DoomPawns(Pawn).bFastMonster = bFastMonster;
		FreezePawn(false);
		ResetSkill();
	}
Begin:
	FreezePawn(true);
	Sleep(0.1);
	if( Pawn.PhysicsVolume!=None && Pawn.PhysicsVolume.bWaterVolume )
		Pawn.SetPhysics(PHYS_Swimming);
	GoToState('Idling');
}
// Default, no behaviour...
function LongFall();
function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume);
function bool NotifyHeadVolumeChange(PhysicsVolume NewVolume);
function bool NotifyLanded(vector HitNormal);
function NotifyPostLanded();
function NotifyFallingHitWall(vector HitNormal, actor Wall); // only if bNotifyFallingHitWall is set
function NotifyHitMover(vector HitNormal, mover Wall);
function NotifyJumpApex();
function NotifyMissedJump();
function FearThisSpot(AvoidMarker aSpot);

function Restart()
{
	NoKillMeTimer = Level.TimeSeconds+30;
	KFM = KFMonster(Pawn);
	if( DoomPawns(Pawn).bFastMonster )
		bFastMonster = true;
	if( bFastMonster )
	{
		Pawn.GroundSpeed*=1.5;
		Pawn.AirSpeed*=1.5;
	}
	DoomPawns(Pawn).bFastMonster = bFastMonster;
	if( Physics==PHYS_None )
	{
		if( Pawn.bCanFly )
			Pawn.SetPhysics(PHYS_Flying);
		else if( Pawn.PhysicsVolume.bWaterVolume )
			Pawn.SetPhysics(PHYS_Swimming);
		else Pawn.SetPhysics(PHYS_Falling);
	}
	ReSetSkill();
	GoToState('InitUp');
}
function SetMaxDesiredSpeed()
{
	if ( Pawn != None )
		Pawn.MaxDesiredSpeed = 1;
}
function SetPeripheralVision()
{
	if ( Pawn == None )
		return;
	Pawn.PeripheralVision = Pawn.Default.PeripheralVision;
	Pawn.SightRadius = Pawn.Default.SightRadius;
}
function ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir);
function bool CanKillMeYet()
{
	return (NoKillMeTimer<Level.TimeSeconds);
}
final function CheckAttackDoors( vector MoveDes )
{
	local Actor A;
	local vector HL,HN;

	if( !DoomPawns(Pawn).bHasRangedAttack )
		return;
	A = Pawn.Trace(HL,HN,MoveDes,Pawn.Location,false);
	TargetDoor = KFDoorMover(A);
	if( TargetDoor!=None && !TargetDoor.bHidden && TargetDoor.bSealed && !TargetDoor.bZombiesIgnore )
	{
		DoorAimingPosition = HL;
		GotoState('HateDoorz');
	}
	else TargetDoor = None;
}

State Idling
{
Ignores Tick,EnemyNotVisible;

	function BeginState()
	{
		Enable('SeePlayer');
		Pawn.Enable('Bump');
		Enemy = None;
	}
	function EndState()
	{
		FreezePawn(false);
	}
Begin:
	FreezePawn(true);
	if( Pawn.Physics==PHYS_Falling )
	{
		DoomPawns(Pawn).PlayMyAnim('Fall');
		WaitForLanding();
	}
	DoomPawns(Pawn).PlayMyAnim('Still');
	if( bActLikeInv || bIsWandering )
	{
		Sleep(FRand()*2+0.5);
		FreezePawn(false);
		Pawn.PlaySound(DoomPawns(Pawn).Roam);
		DoomPawns(Pawn).PlayMyAnim('Walk');
		MoveTo(Pawn.Location+VRand()*700);
		if( bActLikeInv && FRand()<0.35 )
			FindNewEnemy();
		GoTo'Begin';
	}
	else
	{
		Sleep(0.1);
		Enemy = None;
	}
	Stop;
}
State HuntingEnemy
{
Ignores Tick,EnemyNotVisible,HearNoise;

	function BeginState()
	{
		Enable('SeePlayer');
	}
	function bool NotifyBump( Actor Other )
	{
		if( Other.IsA('Pawn') && (Pawn(Other)==None || SetEnemy(Pawn(Other),False)) )
			GoToState('AttackEnemy','DoAttack');
		Return False;
	}
	function Falling()
	{
		if( Pawn.bCanJump )
		{
			Pawn.Velocity = vect(0,0,1)*Pawn.JumpZ;
			Pawn.Acceleration = vect(0,0,0);
			Pawn.Velocity = EAdjustJump(Pawn.Velocity.Z,Pawn.GroundSpeed);
			DoomPawns(Pawn).PlayMyAnim('Fall');
		}
	}
	function SeePlayer( Pawn Seen )
	{
		if( bActLikeInv )
			Global.SeePlayer(Seen);
	}
Begin:
	CheckDeadEnemy();
	if( LineOfSightTo(Enemy) )
		GoToState('AttackEnemy');
	if( LastRoamTime<Level.TimeSeconds )
	{
		Pawn.PlaySound(DoomPawns(Pawn).Roam);
		LastRoamTime = Level.TimeSeconds+1.5;
	}
	DoomPawns(Pawn).PlayMyAnim('Walk');
	if( !bActLikeInv && VSize(Enemy.Location-Pawn.Location)>1500 )
		MoveTo(Pawn.Location+VRand()*700);
	else
	{
		Node = FindPathToward(Enemy);
		if( Node==None )
		{
			MoveTo(Pawn.Location+VRand()*700);
			if( bActLikeInv && FRand()<0.4 )
			{
				Enemy = None;
				GoToState('Idling');
			}
		}
		else
		{
			CheckAttackDoors(Node.Location);
			MoveToward(Node);
		}
	}
	GoTo'Begin';
}
State HateDoorz
{
Ignores Tick,EnemyNotVisible,SeePlayer,HearNoise;

	function BeginState()
	{
		Disable('SeePlayer');
	}
	function bool NotifyBump( Actor Other )
	{
		if( !bIsAttacking && Other.IsA('Pawn') && SetEnemy(Pawn(Other),false) )
			GoToState('AttackEnemy','DoAttack');
		Return False;
	}
	function EndState()
	{
		bCanBeAgressive = False;
		if( Pawn!=None && DoomPawns(Pawn).bConstFiring )
			Pawn.LightType = LT_None;
		FreezePawn(false);
	}
	function rotator GetEnemyRot()
	{
		local rotator R;

		R.Yaw = rotator(DoorAimingPosition-Pawn.Location).Yaw;
		Return R;
	}
	function bool CanKillMeYet()
	{
		return false;
	}

Begin:
	DoorAttackTime = Level.TimeSeconds+8.f;
	NoKillMeTimer = Level.TimeSeconds+30;
	FreezePawn(true);
	While( TargetDoor!=none && !TargetDoor.bHidden && TargetDoor.bSealed && !TargetDoor.bZombiesIgnore && Level.TimeSeconds<DoorAttackTime )
	{
		bCanBeAgressive = False;
		CheckDeadEnemy();
		FocalPoint = DoorAimingPosition;
		if( NeedToTurn(DoorAimingPosition) )
			Pawn.SetRotation(GetEnemyRot());
		Target = TargetDoor;
		if( DoomPawns(Pawn).CanAttackNow() )
		{
			if( DoomPawns(Pawn).bConstFiring )
				Pawn.LightType = LT_Strobe;
			bIsAttacking = True;
			CheckDeadEnemy();
			if( DoomPawns(Pawn).bHasRangedAttack )
			{
				if( bFastMonster )
					Sleep(DoomPawns(Pawn).PlayMyAnim('Fire')/1.5);
				else Sleep(DoomPawns(Pawn).PlayMyAnim('Fire'));
			}
			else if( DoomPawns(Pawn).bHasMelee )
			{
				if( bFastMonster )
					Sleep(DoomPawns(Pawn).PlayMyAnim('Melee')/2);
				else Sleep(DoomPawns(Pawn).PlayMyAnim('Melee'));
			}
			bIsAttacking = False;
		}
	}
	DoomPawns(Pawn).PlayMyAnim('Still');
	if( DoomPawns(Pawn).PauseAfterShooting>0 )
	{
		if( bFastMonster )
			Sleep(DoomPawns(Pawn).PauseAfterShooting/2);
		else Sleep(DoomPawns(Pawn).PauseAfterShooting);
	}
	GoToState('HuntingEnemy');
}
State AttackEnemy
{
Ignores Tick,EnemyNotVisible,SeePlayer,HearNoise;

	function BeginState()
	{
		StartedStateTime = Level.TimeSeconds+2+3*FRand(); // Randomized time before allowed to start firing at players
		Disable('SeePlayer');
	}
	function bool NotifyBump( Actor Other )
	{
		if( !bIsAttacking && Other.IsA('Pawn') && Pawn(Other)==Enemy )
			GoToState('AttackEnemy','DoAttack');
		Return False;
	}
	function Falling()
	{
		if( Pawn.bCanJump )
		{
			Pawn.Velocity = vect(0,0,1)*Pawn.JumpZ;
			Pawn.Acceleration = vect(0,0,0);
			Pawn.Velocity = EAdjustJump(Pawn.Velocity.Z,Pawn.GroundSpeed);
			DoomPawns(Pawn).PlayMyAnim('Fall');
		}
	}
	function EndState()
	{
		bCanBeAgressive = False;
		if( Pawn!=None && DoomPawns(Pawn).bConstFiring )
			Pawn.LightType = LT_None;
		FreezePawn(false);
	}
	function bool SetEnemy( Pawn E, bool bHateEnemy )
	{
		local Pawn OldE;
		local bool bResult;

		OldE = Enemy;
		bResult = Global.SetEnemy(E,bHateEnemy);
		if( bResult && FRand()<0.25 && NeedToTurn(E.Location) && VSize(E.Location-Pawn.Location)>250 ) // Dont attack enemys he cant see currently
		{
			Enemy = OldE;
			Return False;
		}
		Return bResult;
	}
	final function rotator GetEnemyRot()
	{
		local rotator R;

		R.Yaw = rotator(Enemy.Location-Pawn.Location).Yaw;
		Return R;
	}
	function damageAttitudeTo( pawn Other, float Damage )
	{
		if( (Damage*FRand())>FMin(Pawn.Mass*0.25*FRand(),50) && Pawn.Health<500 )
		{
			SetEnemy(Other,true);
			GoToState(,'TookDamage');
		}
		if( Damage>0 )
			SetEnemy(Other,true);
	}

TookDamage:
	DoomPawns(Pawn).PlayMyAnim('Still');
	DoomPawns(Pawn).CallTimer(0,False);
	if( DoomPawns(Pawn).bConstFiring )
		Pawn.LightType = LT_None;
	FreezePawn(true);
	bIsAttacking = False;
	Sleep(0.2);
Begin:
	NoKillMeTimer = Level.TimeSeconds+30;
	FreezePawn(false);
	bCanBeAgressive = False;
	CheckDeadEnemy();
	bIsAttacking = False;
	DoomPawns(Pawn).PlayMyAnim('Walk');
	if( !DoomPawns(Pawn).bHasRangedAttack || VSize(Enemy.Location-Pawn.Location)<DoomPawns(Pawn).StartMeleeRange || (bActLikeInv && StartedStateTime>Level.TimeSeconds && VSize(Enemy.Location-Pawn.Location)>500) )
	{
KeepOnSearching:
		CheckDeadEnemy();
		bCanBeAgressive = DoomPawns(Pawn).bHasRangedAttack;
		if( !ActorReachable(Enemy) )
		{
			Node = FindPathToward(Enemy);
			if( Node!=None )
			{
				CheckAttackDoors(Node.Location);
				MoveTo(Node.Location);
				Sleep(0.1);
				GoTo'Begin';
			}
		}
		if( VSize(Enemy.Location-Pawn.Location)<100 )
			MoveToward(Enemy);
		else MoveTo(Pawn.Location+Normal(Enemy.Location-Pawn.Location)*180+VRand()*80);
		if( bCanBeAgressive )
		{
			CheckDeadEnemy();
			if( VSize(Enemy.Location-Pawn.Location)<(Enemy.CollisionRadius+Pawn.CollisionRadius+DoomPawns(Pawn).MeleeRange) )
				GoTo'DoAttack';
			Sleep(0.1);
			if( !LineOfSightTo(Enemy) )
				GoToState('HuntingEnemy');
			GoTo'KeepOnSearching';
		}
	}
	else
	{
		CheckDeadEnemy();
		Target = Enemy;
		if( !DoomPawns(Pawn).bHasMelee && VSize(Enemy.Location-Pawn.Location)<(Enemy.CollisionRadius+Pawn.CollisionRadius+450) )
		{
			if( bFastMonster )
				MoveTo(Pawn.Location-Normal(Enemy.Location-Pawn.Location)*70+VRand()*30);
			else MoveTo(Pawn.Location-Normal(Enemy.Location-Pawn.Location)*200+VRand()*100);
		}
		else if( bFastMonster ) MoveTo(Pawn.Location+Normal(Enemy.Location-Pawn.Location)*70+VRand()*30);
		else MoveTo(Pawn.Location+Normal(Enemy.Location-Pawn.Location)*200+VRand()*100);
	}
	NumFLeft = DoomPawns(Pawn).PickNumFires();
DoAttack:
	NoKillMeTimer = Level.TimeSeconds+30;
	FreezePawn(true);
	bCanBeAgressive = False;
	CheckDeadEnemy();
	FocalPoint = Enemy.Location;
	Pawn.SetRotation(GetEnemyRot());
	if( DoomPawns(Pawn).CanAttackNow() )
	{
		if( DoomPawns(Pawn).bConstFiring )
			Pawn.LightType = LT_Strobe;
		bIsAttacking = True;
		CheckDeadEnemy();
		Target = Enemy;
		if( DoomPawns(Pawn).bHasMelee && VSize(Enemy.Location-Pawn.Location)<(Enemy.CollisionRadius+Pawn.CollisionRadius+DoomPawns(Pawn).MeleeRange) )
		{
			if( bFastMonster )
				Sleep(DoomPawns(Pawn).PlayMyAnim('Melee')/2);
			else Sleep(DoomPawns(Pawn).PlayMyAnim('Melee'));
		}
		else if( DoomPawns(Pawn).bHasRangedAttack )
		{
			if( bFastMonster )
				Sleep(DoomPawns(Pawn).PlayMyAnim('Fire')/1.5);
			else Sleep(DoomPawns(Pawn).PlayMyAnim('Fire'));
		}
		bIsAttacking = False;
	}
	CheckDeadEnemy();
	if( !LineOfSightTo(Enemy) )
		GoToState('HuntingEnemy');
	NumFLeft--;
	if( DoomPawns(Pawn).bConstFiring )
		GoTo'DoAttack';
	if( (NumFLeft>0) || (DoomPawns(Pawn).bHasMelee && VSize(Enemy.Location-Pawn.Location)<(Enemy.CollisionRadius+Pawn.CollisionRadius+DoomPawns(Pawn).MeleeRange)) )
		GoTo'DoAttack';
	DoomPawns(Pawn).PlayMyAnim('Still');
	if( DoomPawns(Pawn).PauseAfterShooting>0 )
	{
		if( bFastMonster )
			Sleep(DoomPawns(Pawn).PauseAfterShooting/2);
		else Sleep(DoomPawns(Pawn).PauseAfterShooting);
	}
	GoTo'Begin';
}
function bool NotifyBump( Actor Other )
{
	if( Other.IsA('Pawn') && SetEnemy(Pawn(Other),False) )
	{
		DoomPawns(Pawn).PlayAcquisitionSound();
		GoToState('AttackEnemy');
	}
	Return False;
}
function HearNoise( float Loudness, Actor NoiseMaker )
{
	if( NoiseMaker==None || NoiseMaker.Instigator==None )
		return;
	if( FastTrace(NoiseMaker.Location,Pawn.Location) && !NoiseMaker.Instigator.IsA('DoomPawns') && SetEnemy(NoiseMaker.Instigator,False) )
	{
		DoomPawns(Pawn).PlayAcquisitionSound();
		GoToState('AttackEnemy');
	}
}
function bool NotifyHitWall( vector HitNormal, actor HitWall )
{
	if( bActLikeInv )
		Return Super.NotifyHitWall(HitNormal,HitWall);
	if( Pawn.Physics==PHYS_Swimming )
		Pawn.Velocity.Z=Pawn.JumpZ*3;
	if( Pawn.Physics!=PHYS_Walking ) Return false;
		
	Destination = MirrorVectorByNormal(Destination-Pawn.Location,HitNormal);
	Destination+=Pawn.Location;
	Destination.Z = Pawn.Location.Z;
	FocalPoint = Destination;
	Focus = None;
	moveTarget = None;
	Return True;
}
function bool SetEnemy( Pawn E, bool bHateEnemy ) // Simply.
{
	if( E==None || E.Health<=0 || Enemy==E || (ForbiddenHateTime>Level.TimeSeconds) ) Return false;
	if( E.IsA('DoomPawns') )
	{
		if( !bHateEnemy || E.IsA('Vile') )
			Return false;
		else if( DoomPawns(Pawn).SameSpeciesAs(E) )
			Return false;
	}
	Enemy = E;
	Return True;
}
function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn)
{
	if( Enemy!=None && (Killed==Enemy.Controller || KilledPawn==Enemy) )
		Enemy = None;
}
function SeePlayer( Pawn Seen )
{
	if( SetEnemy(Seen,False) )
	{
		DoomPawns(Pawn).PlayAcquisitionSound();
		GoToState('AttackEnemy');
	}
}
function damageAttitudeTo( pawn Other, float Damage )
{
	if( Damage>0 && SetEnemy(Other,True) )
	{
		if( !IsInState('AttackEnemy') )
			GoToState('AttackEnemy');
		else if( bCanBeAgressive )
		{
			NumFLeft = DoomPawns(Pawn).PickNumFires();
			GoToState('AttackEnemy','DoAttack');
		}
	}
	else if( Enemy!=None && Other==Enemy && bCanBeAgressive )
	{
		NumFLeft = DoomPawns(Pawn).PickNumFires();
		GoToState('AttackEnemy','DoAttack');
	}
}
function Startle(Actor Feared);

function CheckDeadEnemy()
{
	if( Enemy==None || Enemy.Health<=0 || Enemy.bDeleteMe )
	{
		Enemy = None;
		if( FRand()<0.3 )
			bIsWandering = true;
		GoToState('Idling');
	}
}
State Dead
{
ignores SeePlayer, HearNoise, KilledBy, Tick, NotifyHitWall;

	function BeginState()
	{
		Pawn.Controller = None;
		Destroy();
	}
}	
function rotator AdjustAim(FireProperties FiredAmmunition, vector projStart, int aimerror)
{
	local rotator R;
	local float S;

	if( KFDoorMover(Target)!=None )
		return rotator(DoorAimingPosition-projStart);
	if( Enemy!=None )
	{
		if( FastTrace(Enemy.Location,projStart) ) // Try middle
			R = rotator(Enemy.Location-projStart);
		else if( FastTrace(Enemy.Location+vect(0,0,0.9)*Enemy.CollisionHeight,projStart) ) // Try head
			R = rotator(Enemy.Location+vect(0,0,0.9)*Enemy.CollisionHeight-projStart);
		else if( FastTrace(Enemy.Location-vect(0,0,0.9)*Enemy.CollisionHeight,projStart) ) // Try feet
			R = rotator(Enemy.Location-vect(0,0,0.9)*Enemy.CollisionHeight-projStart);
		else R = rotator(Enemy.Location-projStart);
		if( Enemy.bHidden )
		{
			R.Yaw+=Rand(6000)-3000;
			R.Pitch+=Rand(6000)-3000;
		}
		else if( Enemy.Visibility<128 )
		{
			S = 1-(Enemy.Visibility/128);
			R.Yaw+=(Rand(6000)-3000)*S;
			R.Pitch+=(Rand(6000)-3000)*S;
		}
		Return R;
	}
	Return Super.AdjustAim(FiredAmmunition,projStart,aimerror);
}
function bool NeedToTurn(vector targ)
{
	local int YawErr;

	DesiredRotation = Rotator(targ - Pawn.Location);
	DesiredRotation.Yaw = DesiredRotation.Yaw & 65535;
	YawErr = (DesiredRotation.Yaw - (Pawn.Rotation.Yaw & 65535)) & 65535;
	if ( (YawErr < 4000) || (YawErr > 61535) )
		return false;

	return true;
}

defaultproperties
{
}
