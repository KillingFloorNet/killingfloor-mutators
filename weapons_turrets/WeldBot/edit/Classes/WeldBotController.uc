class WeldBotController extends AIController;

var WeldBot WeldBot;
var bool bLostContactToPL;
var int HealDmg;
var float CriticalHP;
var bool bHealFull;
var bool bMovingCloser, bUseAcceleration;

var float tDist,tCoeff, float1, float2, float3;
var vector tLoc, vector1, vector2, vector3;
var rotator rotator1, rotator2, rotator3;
var int int1, int2, int3;
var KFDoorMover tDoor;
//var Actor MoveToActor;

var bool bDebug;

var enum EState
{
	Stay,
	Follow,
	WeldDoors,
} tempState;

enum EAnim
{
	Idle,
	Spawned,
	Left,
	Right,
	Twich,
	Walk,
	Fire,
	Stop,
	TurnLeft,
	TurnRight,
};
var vector repDot;
var vector F;

// Stuck variables
var array<vector> StuckA;
var float StuckALast;

var(DEBUG) float ZDiff;

//var(DEBUG) bool bIngoneZ;

//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
function bool Stuck(optional bool bReset)
{
	local int i;
	local float sumDist;

	if (bReset)
	{
		StuckA.Remove(0,StuckA.Length);
		return false;
	}
	if (StuckALast + 0.1 < Level.TimeSeconds)
	{
		StuckA.Insert(0,1);
		StuckA[0]=WeldBot.Location;
		StuckALast=Level.TimeSeconds;
	}
	if (StuckA.Length < 5)
	{
		//M("Stuck array not full"@StuckA.Length);
		return false;
	}
	else if (StuckA.Length > 5)
	{
		//M("Stuck array full"@StuckA.Length);
		StuckA.Remove(6,StuckA.Length-5);
	}
	
	for (i=0;i<StuckA.Length-1;i++)
		sumDist = VSizeSquared(StuckA[i]-StuckA[i+1]);
	
	//M("Stuck() sumDist"@sumDist);
	if (sumDist < 4000)
	{
		M("we stuck");
		return true;
	}
}
//--------------------------------------------------------------------------------------------------
function float DoorHP(Actor D)
{
	return WeldBot.DoorHP(D);
}
//--------------------------------------------------------------------------------------------------
function bool FindDoor()
{
	if (WeldBot.FindDoors()==false)
		return false;
	tDoor=WeldBot.DoorToRepairFirst();
	if (tDoor==none)
		return false;
	return true;
}
//--------------------------------------------------------------------------------------------------
function float CalcCoord(float x1, float x2, float coeff)
{
	local float t;
	t=abs((x1-x2)*coeff);
	if (x1<x2)
		return x1+t;
	else
		return x1-t;
}
//--------------------------------------------------------------------------------------------------
state WeldDoors
{
Ignores SeeMonster,SeePlayer,HearNoise;
	
	function BeginState()
	{
		Stuck(true);
		bMovingCloser=false;
		bUseAcceleration=false;
		SetTimer(3.0, true); // каждую секунду обновлять важность дверей вокруг
	}
	//--------------------------------------------------------
	function EndState()
	{
		Stuck(true);
		tDoor = none;
		MoveTarget = none;
		Focus = none;
		Target = none;
		Enemy = none;
		bUseAcceleration=false;
		bMovingCloser=false;
		if (WeldBot.bWelding)
			WeldBot.StopWeld();
			
		SetTimer(0.0, false);
	}
	//--------------------------------------------------------
	function SeeMonster(Pawn Seen);
	//--------------------------------------------------------
	function HearNoise(float Loudness, Actor NoiseMaker);
	//--------------------------------------------------------
	function SeePlayer (Pawn Seen);
	//--------------------------------------------------------
	function BadEnemy()
	{
		if (bDebug) M("BadDoor HP:"@DoorHP(Target));
		WeldBot.BadDoor(KFDoorMover(Target));
		bUseAcceleration=false;
		bMovingCloser=false;
		Target=none;
		Stuck(true);
	}
	//--------------------------------------------------------
	function bool SelectDoor()
	{
		local float curHP, newHP;
		tDoor=WeldBot.DoorToRepairFirst();
		if (tDoor==none /*|| WeldBot.TraceDoor(tDoor)==false*/)
			return false;
		// сравнение с текущей целью
		curHP=DoorHP(Target);
		newHP=DoorHP(tDoor);
		if (KFDoorMover(Target)==none || curHP-newHP > 30 || (newHP<25 && curHP > 30 ))
		{
			Stuck(true);
			Target=tDoor;
			bUseAcceleration=false;
			bMovingCloser=false;
			return true;
		}
		if( WeldBot.bDoorValid(KFDoorMover(Target)) == false )
		{
			BadEnemy();
			return false;
		}
	}
	//--------------------------------------------------------
	function Timer()
	{
		local float curHP, newHP;
		WeldBot.FindDoors();
		if (Target!=none)
		{
			curHP=DoorHP(Target);
			newHP=DoorHP(WeldBot.DoorToRepairFirst());
			if (curHP-newHP > 30 || (newHP<25 && curHP > 30 ) )
				BadEnemy(); // пора варить другую дверь
		}
	}
	//--------------------------------------------------------
	simulated function Tick (float dt)
	{
		if (bMovingCloser && bCanShoot(Target))
			GotoState(,'WeldDoor');
	}
	//--------------------------------------------------------
Begin:
	while (true)
	{
    	SelectDoor();
		if (KFDoorMover(Target)==none)
		{
			GotoState('FollowOwner','Begin');
			goto('Begin');
		}
		if (bCanShoot(Target))
			goto('WeldDoor');
		else
			goto('MoveCloser');
	}
goto('Begin');
MoveCloser:
	bMovingCloser=true;
	if (Stuck())
	{
		Destination = WeldBot.Location + vector(RotRand())*WeldBot.CollisionRadius*2.0;
		if (pointReachable(Destination))
		{
			WeldBot.SetAnim(Walk);
			MoveTo(Destination);
			Stuck(true);
			sleep(0.1);
		}
	}
	tDoor=KFDoorMover(Target);
	tLoc=WeldBot.GetDoorCenter(tDoor);
	if (abs(tLoc.Z-WeldBot.Location.Z) < 100)
		tLoc.Z = WeldBot.Location.Z;

	if (PointReachable(Target.Location) && (LineOfSightTo(Target) || bUseAcceleration || WeldBot.TraceDoor(tDoor)))
	{
		if (bDebug) M("Door pointReachable, use MoveTo Method");
		Pawn.Acceleration = vect(0.00,0.00,0.00);
		SetFocalPoint(Target.Location);
		WeldBot.SetAnim(TurnDirection(FocalPoint));
		while (TurnDirection(FocalPoint)!=TurnStop)
		{
			FinishRotation();
			sleep(0.1);
		}
		if (bDebug) M("WeldBotController: using MoveTo method");
		WeldBot.SetAnim(Walk);
		bUseAcceleration=true;
		
		if (Stuck())
		{
			Destination = WeldBot.Location + vector(RotRand())*WeldBot.CollisionRadius*4.0;
			if (pointReachable(Destination))
			{
				WeldBot.SetAnim(Walk);
				MoveTo(Destination);
				WeldBot.SetAnim(Idle);
				Stuck(true);
			}
		}
		else
			MoveTo(Target.Location);
		goto('Begin');
	}
	else
	{		
		MoveTarget = FindPathTo(tLoc);
		if (MoveTarget!=none)
			if (bDebug) M("move with FindPathTo(Door.Center)");
		
		if (MoveTarget==none)
		{
			tLoc = WeldBot.GetDoorBottomCenter(tDoor);
			tLoc.Z += Weldbot.CollisionHeight;
			MoveTarget = FindPathTo(tLoc);
		}
		if (MoveTarget!=none)
			if (bDebug) M("move with FindPathTo(Door bottom center)");
		
		if (MoveTarget==none)
			MoveTarget = FindPathToward(Target);
		if (MoveTarget!=none)
			if (bDebug) M("move with FindPathToward(Door)");
		
		if (MoveTarget==none)
			MoveTarget = FindPathTo(Target.Location);
		if (MoveTarget!=none)
			if (bDebug) M("move with FindPathTo(Door.Location)");

		if (MoveTarget==none && !bUseAcceleration && ActorReachable(tDoor.DoorPathNode))
		{
			tDist = VSize(tDoor.DoorPathNode.Location - WeldBot.Location);
			if (tDist>250)
			{
				if (bDebug)	M("Distance to DoorPathNode"@tDist@"moving");
				MoveTarget = FindPathToward(tDoor.DoorPathNode);
			}
			else
			{
				if (bDebug) M("Distance to DoorPathNode"@tDist@"stop moving");
				bUseAcceleration=true;
			}
		}
		if (MoveTarget!=none)
			if (bDebug) M("move with FindPathToward(Door.DoorPathNode)");
		
		if (MoveTarget==none)
			MoveTarget = FindPathTo(WeldBot.GetNearestDoorNavigationPoint(tDoor).Location);
			
		if (MoveTarget!=none)
			if (bDebug) M("move with FindPathToward(Nearest NavigationPoint)");
		
		if (MoveTarget==none && WeldBot.TraceDoor(tDoor))
		{
			bUseAcceleration=true;
			Pawn.Acceleration = vect(0.00,0.00,0.00);
			SetFocalPoint(tDoor.WeldIconLocation);
			WeldBot.SetAnim(TurnDirection(FocalPoint));
			while (TurnDirection(FocalPoint)!=TurnStop)
			{
				FinishRotation();
				sleep(0.1);
			}
			
			if (bDebug) M("WeldBotController: using SetAcceleration method");
			WeldBot.SetAnim(Walk);
			Pawn.Velocity = vector(Pawn.GetViewRotation())*150.0;
			Pawn.Acceleration = Pawn.Velocity;
			sleep(0.3);
			goto('Begin');
		}
		else if (MoveTarget!=none)
		{
			if (Stuck())
			{
				Destination = WeldBot.Location + vector(RotRand())*WeldBot.CollisionRadius*4.0;
				if (pointReachable(Destination))
				{
					WeldBot.SetAnim(Walk);
					MoveTo(Destination);
					WeldBot.SetAnim(Idle);
					Stuck(true);
				}
			}
			else
			{
				WeldBot.SetAnim(Walk);
				MoveToward(MoveTarget);
			}
			goto('Begin');
		}
	}
	if (bDebug) M("WeldBotController: Error: Door not reachable any way");
	BadEnemy();
	WeldBot.SetAnim(Idle);
	sleep(0.5);
goto('Begin');
WeldDoor:
	bMovingCloser=false;
	bUseAcceleration=false;
	Stuck(true);
	tDoor=KFDoorMover(Target);
	//DrawStayingDebugLine(Pawn.Location, tDoor.WeldIconLocation, 255, 10, 10);
	
	Pawn.Acceleration = vect(0.00,0.00,0.00);
	SetFocalPoint(tDoor.WeldIconLocation);
	WeldBot.SetAnim(TurnDirection(FocalPoint));
	while (TurnDirection(FocalPoint)!=TurnStop)
	{
		FinishRotation();
		sleep(0.1);
	}
	
	WeldBot.SetAnim(Fire);
	While( isValidTarget(Target,true) && bCanShoot(Target) )
	{
		// Лечим цель
		Pawn.Acceleration = vect(0.00,0.00,0.00);
		if (WeldBot.Weld(Target)==false)
		{
			BadEnemy();
			break;
		}
		Sleep(0.35);
	}
	WeldBot.StopWeld();
	WeldBot.SetAnim(Idle); //WeldBot.SetAnimationNum(0);
goto('Begin');
}
//--------------------------------------------------------------------------------------------------
function Restart()
{
	if (bDebug) log("WeldBotController: Restart()");
	Enemy = None;
	Target = None;
	WeldBot = WeldBot(Pawn);
	GotoState('WakeUp');
}
//--------------------------------------------------------------------------------------------------
state WakeUp
{
Ignores SeePlayer,HearNoise,SeeMonster;
Begin:
	if (bDebug) log("WeldBotController: State WakeUp");
	WeldBot.SetAnim(Stop);
	WaitForLanding();
	WeldBot.SetAnim(Twich);
	Sleep(1.0);
	GoNextOrders();
}
//--------------------------------------------------------------------------------------------------
function bool OwnerMustAndAbleToSeeMe()
{
	if (WeldBot.BotState==Follow && LineOfSightTo(WeldBot.HomeActor) || WeldBot.BotState!=Follow)
		return true;
	else return false;
}
//--------------------------------------------------------------------------------------------------
function vector NearestDoorPoint(KFDoorMover Door)
{
	//local vector IconLocation, MoverLocation;
	local float MinDist,tD;
	local vector MinLoc,tL;
	
	tL		= Door.WeldIconLocation;
	tL.Z	= WeldBot.Location.Z;
	tD		= DistanceFromBot(tL);
	MinDist	= tD;
	MinLoc	= tL;
	
	tL		= Door.Location;
	tL.Z	= WeldBot.Location.Z;
	tD	= DistanceFromBot(tL);
	if (tD < MinDist)
	{
		MinDist = tD;
		MinLoc = tL;
	}
		
	tL	= WeldBot.GetDoorCenter(Door);
	tD	= DistanceFromBot(tL);
	if (tD < MinDist)
	{
		MinDist = tD;
		MinLoc = tL;
	}
	
	
	tL	= WeldBot.GetDoorBottomCenter(Door);
	tD	= DistanceFromBot(tL);
	if (tD < MinDist)
	{
		MinDist = tD;
		MinLoc = tL;
	}
		if( Door.DoorPathNode!=None )
	{
	tL	= Door.DoorPathNode.Location;
	tD	= DistanceFromBot(tL);
	}

	if (tD < MinDist)
	{
		MinDist = tD;
		MinLoc = tL;
	}
		
	return MinLoc;
}
//--------------------------------------------------------------------------------------------------
function bool bCanShoot(Actor Enemy)
{
	local bool bRet;
	local float tD;
	
	if (Pawn(Enemy) != none)
	{
		if(isValidTarget(Enemy,true) && LineOfSightTo(Enemy) && VSizeSquared(WeldBot.Location-Enemy.Location) < WeldBot.MaxShootDistance)
			return true;
		else
			return false;
	}
	else if (KFDoorMover(Enemy)!=none)
	{
		if (WeldBot.TraceDoor(KFDoorMover(Enemy))==false)
			return false;
		tD = VSizeSquared(WeldBot.Location-NearestDoorPoint(KFDoorMover(Enemy)));
		bRet = tD < WeldBot.MaxShootDistance;
		if (bRet==false)
			if (bDebug) M("Distance to Door"@tD@"max"@WeldBot.MaxShootDistance@"too far, Cant shoot");
		return bRet;
	}
	
	return false;
}
//--------------------------------------------------------------------------------------------------
function vector BaseLocation()
{
	return WeldBot.HomeActor.Location;
}
//--------------------------------------------------------------------------------------------------
function float DistanceFromBot(Vector loc)
{
	return VSizeSquared(WeldBot.Location - loc);
}
//--------------------------------------------------------------------------------------------------
function float DistanceFromHome(Vector loc)
{
	if (WeldBot.HomeActor!=none)
		return VSizeSquared(WeldBot.HomeActor.Location - loc);
	else return 0.0;
}
//--------------------------------------------------------------------------------------------------
function bool bTooFar(Vector loc, optional bool toShoot)
{
	local Pawn tPawn;
	tPawn=Pawn(Target);
	// Если хозяин убит или у него критический уровень HP, бежим к нему
	if (tPawn!=none)
	{
		if ((tPawn==WeldBot.OwnerPawn && bCriticalHP(WeldBot.OwnerPawn)) || WeldBot.OwnerPawn == None)
		{
			if (bDebug) log("Owner is Critical, shure its not too far");
			return false;
		}
		if (bHealFull)
		{
			if (bDebug) log("I must heal this pawn to Full health, so distance no matter");
			return false;
		}
	}

	if (toShoot)
		return (DistanceFromHome(loc) > (WeldBot.MaxDistanceToOwner + WeldBot.MaxShootDistance));
	else
		return (DistanceFromHome(loc) > WeldBot.MaxDistanceToOwner);
}
//--------------------------------------------------------------------------------------------------
function SeeMonster(Pawn Seen)
{
	ChangeEnemy(Seen);
}
//--------------------------------------------------------------------------------------------------
function HearNoise(float Loudness, Actor NoiseMaker)
{
	if ( (NoiseMaker != None) && (NoiseMaker.Instigator != None) && FastTrace(NoiseMaker.Location,Pawn.Location) )
		ChangeEnemy(NoiseMaker.Instigator);
}
//--------------------------------------------------------------------------------------------------
function SeePlayer (Pawn Seen)
{
	ChangeEnemy(Seen);
}
//--------------------------------------------------------------------------------------------------
function damageAttitudeTo(Pawn Other, float Damage)
{
	ChangeEnemy(Other);
}
//--------------------------------------------------------------------------------------------------
function bool isValidTarget(Actor Other, optional bool IgnoreDistance)
{
	local KFPlayerReplicationInfo PRI;
	local KFHumanPawn tPawn;
	local KFDoorMover Door;
	if (Other==none) return false;
	tPawn=KFHumanPawn(Other);
	Door=KFDoorMover(Other);
	if (tPawn!=none)
	{
		if (tPawn.Controller==None)
			return false;

		PRI = KFPlayerReplicationInfo(tPawn.PlayerReplicationInfo);
		if (PRI==none)
			return false;

		///if (tPawn.ShieldStrength>=100 /*|| tPawn.ShieldStrength==0*/)  /// оригинал
		if(tPawn.ShieldStrength == tPawn.ShieldStrengthMax)  /// Если уровень брони игрока равен максимальному, то не считаем такого игрока целью. Sir Arthur
			return false;
		
		//if( tPawn.Health >= PRI.default.PlayerHealth )
		//	return false;
	}
	else if (Door!=none)
	{
		// валидность двери
	}
	else
		return false;
	if (!IgnoreDistance)
		if (bTooFar(Other.Location, true))
			return false;

	return true;
}
//--------------------------------------------------------------------------------------------------
function bool bNeedHealOwner()
{
	//local KFPlayerReplicationInfo PRI;
	//PRI = KFPlayerReplicationInfo(WeldBot.OwnerPawn.PlayerReplicationInfo);
	if (isValidTarget(WeldBot.OwnerPawn, true)) {
		///if ( WeldBot.OwnerPawn.ShieldStrength < 100.f*0.73f )  /// оригинал
		if(WeldBot.OwnerPawn.ShieldStrength < 76.0)  /// Бот будет варить броню хозяину, если её уровень падает до 75 единиц. Sir Arthur
		//if ( WeldBot.OwnerPawn.Health < WeldBot.OwnerPawn.HealthMax*0.73f )
			return true;
	}

	return false;

}
//--------------------------------------------------------------------------------------------------
function bool bCriticalHP(Pawn P)
{
	if (P==none) return false;

	//if ((float(P.Health)/P.HealthMax) < CriticalHP)
	if (P.ShieldStrength/100.f < CriticalHP)
		return true;
	else
		return false;
}
//--------------------------------------------------------------------------------------------------
function ChangeEnemy(Pawn Other, optional bool bForce)
{
	local float DistanceCur, DistanceNew;
	if (bHealFull && Enemy!=none) return;
	if (bNeedHealOwner() && (bCriticalHP(WeldBot.OwnerPawn) || !bCriticalHP(Enemy)))
	{
		if (Enemy!=WeldBot.OwnerPawn)
		{
			Enemy = WeldBot.OwnerPawn;
			EnemyChanged();
		}
		if (bCriticalHP(WeldBot.OwnerPawn))
			bHealFull=true;
		return;
	}

	if (!isValidTarget(Other,false))
		return;

	if (Enemy==Other) return;

	if (WeldBot.OwnerPawn == None)
	{
		WeldBot.SetOwningPlayer(Other, None, true); // true - означает, что предупреждаем нового хозяина, что бот теперь его (старый хозяин погиб)
		return;
	}

	if (isValidTarget(Enemy))
	{
		//if (Other.Health/Other.HealthMax > Enemy.Health/Enemy.HealthMax)
		if (Other.ShieldStrength/100.f > Enemy.ShieldStrength/100.f)
			return;
		DistanceCur=VSizeSquared(Enemy.Location - Pawn.Location);
		DistanceNew=VSizeSquared(Other.Location - Pawn.Location);
		if( LineOfSightTo(Enemy) &&  (!LineOfSightTo(Other) || DistanceNew > DistanceCur) )
			return;
	}
	else
		Enemy=none;

	Enemy = Other;
	EnemyChanged();
}
//--------------------------------------------------------------------------------------------------
function EnemyChanged()
{
	if (bDebug) log("Enemy changed:"@Enemy.PlayerReplicationInfo.PlayerName);
}
//--------------------------------------------------------------------------------------------------
final function GoNextOrders()
{
	bIsPlayer = True;
	
	WeldBot.SetAnim(Idle);
	
	if ( WeldBot.OwnerPawn == None || WeldBot.OwnerPawn.Health <= 0 )
	{
		WeldBot.OwnerPawn = None;
		WeldBot.PlayerReplicationInfo = None;
	}

	if (WeldBot.BotState==WeldDoors)
		if (FindDoor())
			GotoState('WeldDoors','Begin');

	if (isValidTarget(Enemy))
	{
		GotoState('FightEnemy','Begin');
		return;
	}
	else
		Enemy = None;
	GotoState('FollowOwner','Begin');
}
//--------------------------------------------------------------------------------------------------
function PawnDied(Pawn P)
{
	if (bDebug) log("WeldBotController: PawnDied()");
	if ( Pawn == P )
		Destroy();
}
//--------------------------------------------------------------------------------------------------
state FightEnemy
{
	function EnemyChanged()
	{
		Stuck(true);
		WeldBot.Speech(WeldBot.SndOther[2]);
		WeldBot.SetAnim(Idle);
		GotoState(,'Begin');
	}
	//--------------------------------------------------------
	function BeginState ()
	{
		Stuck(true);
		if (WeldBot.BotState==WeldDoors)
			SetTimer(1.0, true);
	}
	//--------------------------------------------------------
	function EndState()
	{
		Stuck(true);
		Enemy=none;
		Target=none;
		MoveTarget=none;
		Focus=none;
		WeldBot.StopWeld();
		WeldBot.Speech(WeldBot.SndOther[3]);
	}
	//--------------------------------------------------------
	function BadEnemy()
	{
		Stuck(true);
		if (bDebug) log("WeldBot: target is not valid 1");
		Enemy=none;
		GoNextOrders();
	}
	//--------------------------------------------------------
	event Tick( float DeltaTime )
	{
		if (bMovingCloser && bCanShoot(Enemy))
			GotoState(,'ShootEnemy');
	}
	//--------------------------------------------------------
	function Timer()
	{
		if (WeldBot.BotState==WeldDoors)
			if (FindDoor())
				GotoState('WeldDoors');
	}
	//--------------------------------------------------------
	simulated function bool TraceEnemy(Pawn P)
	{
		local vector	StartTrace, EndTrace, HitLocation, HitNormal;
		local Actor HitActor;
		StartTrace = WeldBot.Location;
		EndTrace = P.Location;
		HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
		if (Pawn(HitActor)!=none && Pawn(HitActor) == P)
		{
			if (bDebug) M("Trace pawn successfull");
			return true;
		}
		else
		{
			if (bDebug) M("Trace door unsuccessfull");
			return false;
		}
	}
	//--------------------------------------------------------
	/*function SetMoveToActor(vector loc)
	{
		if (MoveToActor==none)
			MoveToActor=Spawn(class'WeldBotHomeActor');
		MoveToActor.bHidden=true;

		MoveToActor.SetLocation(loc);
	}*/
	//--------------------------------------------------------
Begin:
	if (bDebug) log("FightEnemy: Begin");
	While (true)
	{
		if (bCanShoot(Enemy))
			goto ('ShootEnemy');
		else if (isValidTarget(Enemy))
		{
			if (bDebug) log("Target is Valid: DFromBLoc="$DistanceFromHome(Enemy.Location)@"MaxShootDist="$(WeldBot.MaxDistanceToOwner + WeldBot.MaxShootDistance));
			goto ('MoveCloser');
		}
		else
		{
			if (bDebug) log("FightEnemy: invalid target");
			BadEnemy();
		}
	}
MoveCloser:
	WeldBot.StopWeld();
	bMovingCloser=true;
	if (!isValidTarget(Enemy))
		BadEnemy();
	// Dont go exactly to Enemy location
	tLoc = WeldBot.Location 
		+ vector(rotator(Enemy.Location-WeldBot.Location))
		*(VSize(Enemy.Location-WeldBot.Location)
			-(WeldBot.MaxShootDistance)*0.80f);
	
	if (abs(WeldBot.Location.Z-Enemy.Location.Z)<100.0)
		tLoc.Z = FMax(WeldBot.Location.Z, Enemy.Location.Z-16.f);
	
	if (pointReachable(Enemy.Location))
	{
		Pawn.Acceleration = vect(0.00,0.00,0.00);
		SetFocalPoint(Enemy.Location);
		WeldBot.SetAnim(TurnDirection(FocalPoint));
		while (TurnDirection(FocalPoint)!=TurnStop)
		{
			FinishRotation();
			sleep(0.1);
		}
		if (bDebug) M("MoveTo method");
		Enable('NotifyBump');
		WeldBot.SetAnim(Walk);
		MoveTo(Enemy.Location);
		goto('Begin');
	}
	else
	{
		//MoveTarget = FindPathTo(tLoc);
		//if (MoveTarget==none)
		MoveTarget = FindPathToward(Enemy);
		
		if (MoveTarget==none && TraceEnemy(Enemy))
		{
			Pawn.Acceleration = vect(0.00,0.00,0.00);
			SetFocalPoint(Enemy.Location);
			WeldBot.SetAnim(TurnDirection(FocalPoint));
			while (TurnDirection(FocalPoint)!=TurnStop)
			{
				FinishRotation();
				sleep(0.1);
			}

			if (bDebug) M("Move with acceleration method");
			WeldBot.SetAnim(Walk);
			if (Stuck())
			{
				Destination = WeldBot.Location + vector(RotRand())*WeldBot.CollisionRadius*4.0;
				if (pointReachable(Destination))
				{
					WeldBot.SetAnim(Walk);
					MoveTo(Destination);
					WeldBot.SetAnim(Idle);
					Stuck(true);
				}
			}
			else
			{
				Pawn.Velocity = vector(Pawn.GetViewRotation())*150.0;
				Pawn.Acceleration = Pawn.Velocity;
			}
			sleep(0.2);
			goto('Begin');
		}
		else if (MoveTarget!=none)
		{
			if (Stuck())
			{
				Destination = WeldBot.Location + vector(RotRand())*WeldBot.CollisionRadius*4.0;
				if (pointReachable(Destination))
				{
					WeldBot.SetAnim(Walk);
					MoveTo(Destination);
					WeldBot.SetAnim(Idle);
					Stuck(true);
				}
			}
			else
			{
				WeldBot.SetAnim(Walk);
				MoveToward(MoveTarget);
			}
			sleep(0.2);
		}
		else 
			BadEnemy();

		goto('Begin');
	}
/*
	if (pointReachable(Enemy.Location))
		MoveTo(Enemy.Location);
	else
	{
		MoveTarget = FindPathToward(Enemy);
		if (MoveTarget != none)
		{
			WeldBot.SetAnim(Walk);
			MoveToward(MoveTarget);
		}
		else
		{
			if (bDebug) log("BadEnemy");
			BadEnemy();  // will exit to GoNextOrders
		}
	}
*/
	sleep(0.5);
goto ('Begin');
ShootEnemy:
	Stuck(true);
	if (bDebug) log("FightEnemy: ShootEnemy");
	bMovingCloser=false;
	Pawn.Acceleration = vect(0.00,0.00,0.00);
	SetFocalPoint(Enemy.Location);
	WeldBot.SetAnim(TurnDirection(FocalPoint));
	while (TurnDirection(FocalPoint)!=TurnStop)
	{
		FinishRotation();
		sleep(0.1);
	}
	WeldBot.SetAnim(Fire);
	While( isValidTarget(Enemy,true) && bCanShoot(Enemy) )
	{
		Pawn.Acceleration = vect(0.00,0.00,0.00);
		
		float1 = VSize(WeldBot.WeldBoneLocation-Enemy.Location);
		/*rotator1 = WeldBot.GetBoneRotation('tip');
		rotator2 = rotator(Normal(Enemy.Location - Location));
		int1 = abs(rotator1.Pitch - rotator2.Pitch);
		if (int1>7500)*/
		// player is too close
		if (float1 < 50.0)
		{
			WeldBot.StopWeld();
			rotator3 = rotator(Normal(Enemy.Location-Location)); //rotator2;
			rotator3.Pitch = 0;
			//rotator3.Yaw += 32768; // rotate 180 degrees
			vector1 = Enemy.Location + vector(rotator3) * 100.f; // отходим на 100 единиц
			if (pointReachable(vector1))
			{
				M("MoveAway");
				SetFocalPoint(vector1);
				WeldBot.SetAnim(TurnDirection(FocalPoint));
				while (TurnDirection(FocalPoint)!=TurnStop)
				{
					FinishRotation();
					sleep(0.1);
				}
				WeldBot.SetAnim(Walk);
				MoveTo(vector1);
				WeldBot.SetAnim(Idle);
			}
			else
			{
				MoveTarget = FindPathTo(Enemy.Location + vector(RotRand())*100.f);
				int1 = 0;
				while (MoveTarget==none && int1 < 15)
				{
					MoveTarget = FindPathTo(Enemy.Location + vector(RotRand())*100.f);
					int1++;
				}
				if (MoveTarget==none)
					BadEnemy();
				else
				{
					SetFocalPoint(MoveTarget.Location);
					WeldBot.SetAnim(TurnDirection(FocalPoint));
					while (TurnDirection(FocalPoint)!=TurnStop)
					{
						FinishRotation();
						sleep(0.1);
					}
					WeldBot.SetAnim(Walk);
					MoveToward(MoveTarget);
					WeldBot.SetAnim(Idle);
				}
			}
			sleep(0.1);
			continue;
		}
		
		SetFocalPoint(Enemy.Location);
		WeldBot.SetAnim(TurnDirection(FocalPoint));
		while (TurnDirection(FocalPoint)!=TurnStop)
		{
			WeldBot.StopWeld();
			FinishRotation();
			sleep(0.1);
		}
		
		WeldBot.SetAnim(Fire); //WeldBot.SetAnimationNum(2);
		if (WeldBot.Weld(Enemy)==false)
			BadEnemy();
		if (Enemy.ShieldStrength>=100.f)
			bHealFull=false;		
		Sleep(0.35);
	}
	WeldBot.StopWeld();
	WeldBot.SetAnim(Idle);
	if (bDebug)
	{
		if (!isValidTarget(Enemy))
			log("FightEnemy: ShootEnemyExit - ShootLoop Exit - isValidTarget(Enemy)==false");
		if (!bCanShoot(Enemy))
			log("FightEnemy: ShootEnemyExit - ShootLoop Exit - bCanShoot(Enemy)==false");
		if (bTooFar(WeldBot.Location))
			log("FightEnemy: ShootEnemyExit - ShootLoop Exit - bTooFar(WeldBot.Location)==true");
	}
goto ('Begin');
}
//--------------------------------------------------------------------------------------------------
state FollowOwner
{
	function bool NotifyBump(Actor Other)
	{
		if ( KFPawn(Other) != None )
		{
			Destination = (Normal(Pawn.Location - Other.Location) + VRand() * 0.34999999) * (Other.CollisionRadius + 45.0 + FRand() * 45.0) + Pawn.Location;
			GotoState(,'StepAside');
		}
		return false;
	}
	//--------------------------------------------------------
	function BeginState()
	{
		Stuck(true);
		if (WeldBot == none)
			WeldBot=WeldBot(Pawn);
		if (WeldBot.BotState==WeldDoors)
			SetTimer(1.5, true); // check new doors every second
	}
	//--------------------------------------------------------
	function EndState()
	{
		Stuck(true);
	}
	//--------------------------------------------------------
	final function CheckShopTeleport()
	{
		local ShopVolume S;
		foreach Pawn.TouchingActors(Class'ShopVolume',S)
		{
			if ( !S.bCurrentlyOpen && (S.TelList.Length > 0) )
				S.TelList[Rand(S.TelList.Length)].Accept(Pawn,S);
			return;
		}
	}
	//--------------------------------------------------------
	function bool bNeedToMove()
	{
		if (WeldBot.HomeActor==none)
			return false;
		return (DistanceFromHome(WeldBot.Location)>15000.0
				|| !OwnerMustAndAbleToSeeMe());
	}
	//--------------------------------------------------------
	function Timer()
	{
		if (WeldBot.BotState==WeldDoors)
		if (FindDoor())
			GotoState('WeldDoors','Begin');
	}
	//--------------------------------------------------------

	simulated function bool TraceEnemy(Pawn P)
	{
		local vector	StartTrace, EndTrace, HitLocation, HitNormal;
		local Actor HitActor;
		StartTrace = WeldBot.Location;
		EndTrace = P.Location;
		HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
		if (Pawn(HitActor)!=none && Pawn(HitActor) == P)
		{
			if (bDebug) M("Trace pawn successfull");
			return true;
		}
		else
		{
			if (bDebug) M("Trace pawn unsuccessfull");
			return false;
		}
	}
	//--------------------------------------------------------
Begin:
	while (true)
	{
		CheckShopTeleport();
		Disable('NotifyBump');
		if (bNeedToMove())
			goto ('MoveToBase');
		else
		{
			if ( bLostContactToPL )
			{
				if (bDebug) M("Found Player");
				WeldBot.Speech(WeldBot.SndOther[4]);
				bLostContactToPL = false;
			}
			goto ('Idle');
		}
	}
Idle:
		Stuck(true);
		Enable('NotifyBump');
		Pawn.Acceleration = vect(0.00,0.00,0.00);
		SetFocalPoint(VRand() * 20000.0 + Pawn.Location);
		WeldBot.SetAnim(TurnDirection(FocalPoint));
		while (TurnDirection(FocalPoint)!=TurnStop)
		{
			FinishRotation();
			sleep(0.1);
		}
		WeldBot.SetAnim(Idle);
		Sleep(1.0 + FRand()); //Sleep(0.21 + FRand());
		GoNextOrders();
goto ('Begin');
MoveToBase:
	if (WeldBot.HomeActor!=WeldBot.OwnerPawn)
		tLoc = WeldBot.HomeActor.Location;
	else // dont go exactly to Owner location
		tLoc = WeldBot.Location 
			+ vector(rotator(WeldBot.HomeActor.Location-WeldBot.Location))
			*(VSize(WeldBot.HomeActor.Location-WeldBot.Location)
				-(WeldBot.HomeActor.CollisionRadius+WeldBot.CollisionRadius)*1.2f);
				
	// if dont do it, pointReachable return false;
	if (abs(WeldBot.Location.Z-WeldBot.HomeActor.Location.Z)<100.0)
		tLoc.Z = FMax(WeldBot.Location.Z, WeldBot.HomeActor.Location.Z-16.f);

	repDot=tLoc; // for debugging
	
	if (pointReachable(tLoc))
	{
		Pawn.Acceleration = vect(0.00,0.00,0.00);
		SetFocalPoint(tLoc);
		WeldBot.SetAnim(TurnDirection(FocalPoint));
		while (TurnDirection(FocalPoint)!=TurnStop)
		{
			FinishRotation();
			sleep(0.1);
		}
		WeldBot.SetAnim(Walk);
		if (bDebug) M("MoveTo "@tLoc);
		Enable('NotifyBump');
		
		if (Stuck())
		{
			MoveTarget = FindRandomDest();
			WeldBot.SetAnim(Walk);
			MoveToward(MoveTarget);
			WeldBot.SetAnim(Idle);
			Stuck(true);
		}
		else
			MoveTo(tLoc);
		goto('Begin');
	}
	else
	{
		MoveTarget = FindPathTo(tLoc);
		if (MoveTarget==none)
			MoveTarget = FindPathToward(WeldBot.HomeActor);
		
		if (MoveTarget==none)
			MoveTarget = FindPathToward(WeldBot.HomeActor);
		if (MoveTarget==none && PointReachable(WeldBot.HomeActor.Location) && TraceEnemy(Pawn(WeldBot.HomeActor)))
		{
			Pawn.Acceleration = vect(0.00,0.00,0.00);
			SetFocalPoint(WeldBot.HomeActor.Location);
			WeldBot.SetAnim(TurnDirection(FocalPoint));
			while (TurnDirection(FocalPoint)!=TurnStop)
			{
				FinishRotation();
				sleep(0.1);
			}
			if (bDebug) M("Moving with acceleration method");
			WeldBot.SetAnim(Walk);
			
			if (Stuck())
			{
				MoveTarget = FindRandomDest();
				WeldBot.SetAnim(Walk);
				MoveToward(MoveTarget);
				WeldBot.SetAnim(Idle);
				Stuck(true);
			}
			else
			{
				Pawn.Velocity = vector(Pawn.GetViewRotation())*150.0;
				Pawn.Acceleration = Pawn.Velocity;
			}
			sleep(0.3);
			goto('Begin');
		}
		else
		{
			if (Stuck())
			{
				MoveTarget = FindRandomDest();
				WeldBot.SetAnim(Walk);
				MoveToward(MoveTarget);
				WeldBot.SetAnim(Idle);
				Stuck(true);
			}
			else
			{
				WeldBot.SetAnim(Walk);
				MoveToward(MoveTarget);
			}
			sleep(0.2);
			goto('Begin');
		}
	}
LostContact:
	if (!bLostContactToPL )
	{
		if (bDebug) M("Lost contact to player");
		WeldBot.Speech(WeldBot.SndOther[5]);
		bLostContactToPL = true;
	}
goto ('Idle');
StepAside:
	WeldBot.SetAnim(Walk);
	MoveTo(Destination);
goto ('Begin');
}
//--------------------------------------------------------------------------------------------------
function SetFocalPoint(vector loc)
{
	Focus = none;
	FocalPoint = loc;
	FocalPoint.Z = Pawn.Location.Z;
}
//--------------------------------------------------------------------------------------------------
function M(string in)
{
	PlayerController(WeldBot.OwnerPawn.Controller).ClientMessage(in);
}
//--------------------------------------------------------------------------------------------------
function WeldBot.EAnim TurnDirection(vector newLoc)
{
	local vector curLoc;
	local rotator curRot, newRot;
	local int rotUnitsLeft, rotUnitsRight;
	
	curLoc = WeldBot.Location;
	curRot = WeldBot.Rotation; // GetViewRotation();

	newRot = rotator(curLoc-newLoc);
	newRot.Yaw+=32768;

	if (curRot.Yaw < newRot.Yaw)
	{
		rotUnitsLeft = curRot.Yaw + (65536-newRot.Yaw);
		rotUnitsRight = newRot.Yaw - curRot.Yaw;
	}
	else
	{
		rotUnitsLeft = curRot.Yaw - newRot.Yaw;
		rotUnitsRight = newRot.Yaw + (65536-curRot.Yaw);
	}
	if (Min(rotUnitsLeft,rotUnitsRight) < 500)
		return TurnStop;
	if (rotUnitsLeft<=rotUnitsRight)
		return TurnLeft; // turn left
	else
		return TurnRight; // turn right
}
//--------------------------------------------------------------------------------------------------
function AddScoreToOwner(float HealDmg)
{
	if ( (WeldBot.OwnerPawn != None) && (KFPlayerReplicationInfo(WeldBot.OwnerPawn.PlayerReplicationInfo).ClientVeteranSkill.Default.PerkIndex == 10) )
	{
		KFSteamStatsAndAchievements(KFPlayerReplicationInfo(WeldBot.OwnerPawn.PlayerReplicationInfo).SteamStatsAndAchievements).AddDamageHealed(HealDmg);
		//SRPlayerReplicationInfo(WeldBot.OwnerPawn.PlayerReplicationInfo).outHP += HealDmg;
		//SRPlayerReplicationInfo(Enemy.PlayerReplicationInfo).inHP += HealDmg;
	}
	return;
}
//--------------------------------------------------------------------------------------------------

defaultproperties
{
     HealDmg=12
     CriticalHP=0.500000
     bHunting=True
}
