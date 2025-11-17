Class SentryController extends AIController;

var Sentry Sentry;
var bool bLostContactToPL;

function Restart()
{
	Enemy = None;
	Sentry = Sentry(Pawn);
	GoToState('WakeUp');
}

function SeeMonster( Pawn Seen )
{
	ChangeEnemy(Seen);
}
function HearNoise( float Loudness, Actor NoiseMaker)
{
	if( NoiseMaker!=None && NoiseMaker.Instigator!=None && FastTrace(NoiseMaker.Location,Pawn.Location) )
		ChangeEnemy(NoiseMaker.Instigator);
}
function SeePlayer( Pawn Seen )
{
	ChangeEnemy(Seen);
}
function damageAttitudeTo(pawn Other, float Damage)
{
	ChangeEnemy(Other);
}

function ChangeEnemy( Pawn Other )
{
	if( Other==None || Other.Health<=0 || Other.Controller==None || Other==Enemy )
		return;
	if( Sentry.OwnerPawn==None && KFPawn(Other)!=None )
	{
		Sentry.SetOwningPlayer(Other,None);
		return;
	}
	if( Monster(Other)==None )
		return;

	if( Enemy!=None && Enemy.Health<=0 )
		Enemy = None;

	// Current enemy is visible, new one is not or current enemy is closer, then ignore new one.
	if( Enemy!=None && ((LineOfSightTo(Enemy) && !LineOfSightTo(Other)) || VSizeSquared(Other.Location-Pawn.Location)>VSizeSquared(Enemy.Location-Pawn.Location)) )
		return;

	Enemy = Other;
	EnemyChanged();
}
function EnemyChanged();

final function GoNextOrders()
{
	bIsPlayer = true; // Make sure it is set so zeds fight me.

	if( Sentry.OwnerPawn==None || Sentry.OwnerPawn.Health<=0 )
	{
		Sentry.OwnerPawn = None;
		Sentry.PlayerReplicationInfo = None;
	}
	if( Enemy!=None && Enemy.Health>=0 && (Sentry.OwnerPawn==None || LineOfSightTo(Sentry.OwnerPawn)) )
	{
		GoToState('FightEnemy','Begin');
		return;
	}
	else Enemy = None;
	GoToState('FollowOwner','Begin');
}

function PawnDied(Pawn P)
{
	if ( Pawn==P )
		Destroy();
}

State WakeUp
{
Ignores SeePlayer,HearNoise,SeeMonster;

Begin:
	Sentry.SetAnimationNum(1);
	WaitForLanding();
	Sentry.SetAnimationNum(0);
	Sleep(1.f);
	GoNextOrders();
}
State FightEnemy
{
	function EnemyChanged()
	{
		Sentry.Speech(2);
		if( Sentry.RepAnimationAction!=0 )
			Sentry.SetAnimationNum(0);
		GoToState(,'Begin');
	}
	function BeginState()
	{
		Sentry.Speech(2);
	}
	function EndState()
	{
		if( Sentry.RepAnimationAction!=0 )
			Sentry.SetAnimationNum(0);
		Sentry.Speech(3);
	}
Begin:
	if( Enemy==None || Enemy.Health<=0 )
	{
BadEnemy:
		Enemy = None;
		GoNextOrders();
	}
	if( LineOfSightTo(Enemy) )
		GoTo 'ShootEnemy';
	MoveTarget = FindPathToward(Enemy);
	if( MoveTarget==None || (Sentry.OwnerPawn!=None && !LineOfSightTo(Sentry.OwnerPawn)) )
		GoTo'BadEnemy';
	MoveToward(MoveTarget);
	GoTo'Begin';
ShootEnemy:
	if( Sentry.OwnerPawn!=None && !LineOfSightTo(Sentry.OwnerPawn) )
	{
		MoveTarget = FindPathToward(Sentry.OwnerPawn);
		if( MoveTarget==None )
			GoTo'BadEnemy';
		MoveToward(MoveTarget);
		GoTo'Begin';
	}
	Focus = Enemy;
	Pawn.Acceleration = vect(0,0,0);
	FinishRotation();
	Sentry.SetAnimationNum(2);
	while( Enemy!=None && Enemy.Health>0 && LineOfSightTo(Enemy) && (Sentry.OwnerPawn==None || LineOfSightTo(Sentry.OwnerPawn)) )
	{
		Pawn.Acceleration = vect(0,0,0);
		if( Enemy.Controller!=None )
			Enemy.Controller.damageAttitudeTo(Pawn,5);
		Sleep(0.35f);
	}
	Sentry.SetAnimationNum(0);
	Sleep(0.45f);
	GoTo'Begin';
}
State FollowOwner
{
	function bool NotifyBump(Actor Other)
	{
		if( KFPawn(Other)!=None ) // Step aside from a player.
		{
			Destination = (Normal(Pawn.Location-Other.Location)+VRand()*0.35)*(Other.CollisionRadius+30.f+FRand()*50.f)+Pawn.Location;
			GoToState(,'StepAside');
		}
		return false;
	}
	final function CheckShopTeleport()
	{
		local ShopVolume S;

		foreach Pawn.TouchingActors(Class'ShopVolume',S)
		{
			if( !S.bCurrentlyOpen && S.TelList.Length>0 )
				S.TelList[Rand(S.TelList.Length)].Accept( Pawn, S );
			return;
		}
	}
Begin:
	CheckShopTeleport(); // Make sure not stuck inside trader.
	Disable('NotifyBump');
	if( Sentry.OwnerPawn==None || (VSizeSquared(Sentry.OwnerPawn.Location-Pawn.Location)<160000.f && LineOfSightTo(Sentry.OwnerPawn)) )
	{
		if( bLostContactToPL )
		{
			Sentry.Speech(6);
			bLostContactToPL = false;
		}
Idle:
		Enable('NotifyBump');
		Focus = None;
		FocalPoint = VRand()*20000.f+Pawn.Location;
		FocalPoint.Z = Pawn.Location.Z;
		Pawn.Acceleration = vect(0,0,0);
		Sleep(0.4f+FRand());
	}
	else if( ActorReachable(Sentry.OwnerPawn) )
	{
		Enable('NotifyBump');
		MoveTo(Sentry.OwnerPawn.Location+VRand()*(Sentry.OwnerPawn.CollisionRadius+80.f));
	}
	else
	{
		if( !bLostContactToPL )
		{
			Sentry.Speech(7);
			bLostContactToPL = true;
		}
		MoveTarget = FindPathToward(Sentry.OwnerPawn);
		if( MoveTarget!=None )
			MoveToward(MoveTarget);
		else
		{
			Sentry.Speech(1);
			GoTo'Idle';
		}
	}
	GoNextOrders();
StepAside:
	MoveTo(Destination);
	GoNextOrders();
}

defaultproperties
{
     bHunting=True
}
