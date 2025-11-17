//=============================================================================
// ArchController.				Coded by .:..:
//=============================================================================
class ArchController extends DoomController;

var DoomCarcass TheKilled;
var float LastLookingTime;
var bool bNoRes;

State Idling
{
Ignores Tick,EnemyNotVisible;

Begin:
	Pawn.Acceleration = vect(0,0,0);
	if( Pawn.Physics==PHYS_Falling )
	{
		DoomPawns(Pawn).PlayMyAnim('Fall');
		WaitForLanding();
	}
	DoomPawns(Pawn).PlayMyAnim('Still');
	if( bActLikeInv || bIsWandering )
	{
		Sleep(FRand()*2+0.5);
		Pawn.PlaySound(DoomPawns(Pawn).Roam);
		DoomPawns(Pawn).PlayMyAnim('Walk');
		LookForBodies();
		MoveTo(Pawn.Location+VRand()*700);
		if( bActLikeInv && FRand()<0.35 )
			FindNewEnemy();
		GoTo'Begin';
	}
	Sleep(1+FRand());
	LookForBodies();
	GoTo'Begin';
}
State HuntingEnemy
{
Ignores Tick,EnemyNotVisible,SeePlayer,HearNoise;

Begin:
	CheckDeadEnemy();
	if( LineOfSightTo(Enemy) )
		GoToState('AttackEnemy');
	Pawn.PlaySound(DoomPawns(Pawn).Roam);
	LookForBodies();
	DoomPawns(Pawn).PlayMyAnim('Walk');
	if( !bActLikeInv && VSize(Enemy.Location-Pawn.Location)>1500 )
		MoveTo(Pawn.Location+VRand()*700);
	else
	{
		Node = FindPathToward(Enemy);
		if( Node==None )
			MoveTo(Pawn.Location+VRand()*700);
		else
		{
			CheckAttackDoors(Node.Location);
			MoveToward(Node);
		}
	}
	GoTo'Begin';
}
State AttackEnemy
{
	function damageAttitudeTo( pawn Other, float Damage )
	{
		if( Damage>0 )
			SetEnemy(Other,true);
	}
Begin:
	NoKillMeTimer = Level.TimeSeconds+30;
	bCanBeAgressive = False;
	CheckDeadEnemy();
	bIsAttacking = False;
	LookForBodies();
	DoomPawns(Pawn).PlayMyAnim('Walk');
	if( !DoomPawns(Pawn).bHasMelee && VSize(Enemy.Location-Pawn.Location)<(Enemy.CollisionRadius+Pawn.CollisionRadius+450) )
		MoveTo(Pawn.Location-Normal(Enemy.Location-Pawn.Location)*200+VRand()*100);
	else MoveTo(Pawn.Location+Normal(Enemy.Location-Pawn.Location)*200+VRand()*100);
DoAttack:
	bCanBeAgressive = False;
	if( DoomPawns(Pawn).bConstFiring )
		Pawn.LightType = LT_Strobe;
	if( Pawn.Physics==PHYS_Flying )
		Pawn.Velocity = vect(0,0,0);
	Pawn.Acceleration = vect(0,0,0);
	FocalPoint = Enemy.Location;
	if( NeedToTurn(Enemy.Location) )
	{
		DoomPawns(Pawn).PlayMyAnim('Still');
		Focus = Enemy;
		FinishRotation();
		FocalPoint = Enemy.Location;
		Focus = None;
	}
	Target = Enemy;
	bIsAttacking = True;
	Sleep(DoomPawns(Pawn).PlayMyAnim('Fire'));
	bIsAttacking = False;
	if( !LineOfSightTo(Enemy) )
		GoToState('HuntingEnemy');
	DoomPawns(Pawn).PlayMyAnim('Still');
	if( DoomPawns(Pawn).PauseAfterShooting>0 )
		Sleep(DoomPawns(Pawn).PauseAfterShooting);
	GoTo'Begin';
HealEnemy:
	DoomPawns(Pawn).PlayMyAnim('Walk');
	MoveTo(TheKilled.Location+Normal(Pawn.Location-TheKilled.Location)*(TheKilled.CollisionRadius+Pawn.CollisionRadius+40));
	Acceleration = vect(0,0,0);
	Focus = TheKilled;
	if( NeedToTurn(TheKilled.Location) )
	{
		DoomPawns(Pawn).PlayMyAnim('Still');
		FinishRotation();
	}
	bIsAttacking = True;
	Sleep(DoomPawns(Pawn).PlayMyAnim('Fire2'));
	ResurrectEnemy(TheKilled);
	TheKilled = None;
	bIsAttacking = False;
	LookForBodies();
	GoTo'Begin';
}
function ResurrectEnemy( DoomCarcass Other )
{
	if( Other==None ) Return;
	Pawn.PlaySound(Sound'DSSLOP');
	Spawn(class'Resurrecting',,,Other.Location).SetType(Other);
	Other.Destroy();
}
function LookForBodies()
{
	local DoomCarcass D;

	if( bNoRes || (LastLookingTime>Level.TimeSeconds) ) Return;
	ForEach VisibleActors(Class'DoomCarcass',D,800,Pawn.Location)
	{
		if( D.Class!=Class'Resurrecting' && D.DeadEnemy!=None && D.DeadEnemy.Default.bArchCanRes && FRand()<0.8 && ActorReachable(D) )
		{
			TheKilled = D;
			GoToState('AttackEnemy','HealEnemy');
			Return;
		}
	}
	LastLookingTime = Level.TimeSeconds+3;
}

defaultproperties
{
}
