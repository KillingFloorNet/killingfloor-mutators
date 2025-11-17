//=============================================================================
// SkullController.				Coded by .:..:
//=============================================================================
class SkullController extends DoomController;

State HateDoorz
{
Begin:
	NoKillMeTimer = Level.TimeSeconds+30;
	DoorAttackTime = Level.TimeSeconds+4.f;
	While( TargetDoor!=none && !TargetDoor.bHidden && TargetDoor.bSealed && !TargetDoor.bZombiesIgnore && Level.TimeSeconds<DoorAttackTime )
	{
		bCanBeAgressive = False;
		Pawn.Velocity = vect(0,0,0);
		Pawn.Acceleration = vect(0,0,0);
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
			Sleep(DoomPawns(Pawn).PlayMyAnim('Melee'));
			Pawn.AirSpeed = Pawn.Default.AirSpeed*3;
			MoveTo(DoorAimingPosition);
			DoomPawns(Pawn).MeleeDamageTarget(Rand(21)+3, vect(0,0,0));
			PlaySound(Sound'DSPUNCH');
			bIsAttacking = False;
			if( bFastMonster )
				Pawn.AirSpeed = Pawn.Default.AirSpeed*1.5;
			else Pawn.AirSpeed = Pawn.Default.AirSpeed;
			MoveTo(Normal(Pawn.Location-DoorAimingPosition)*100+Pawn.Location+VRand()*10);
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
Ignores EnemyNotVisible,SeePlayer,HearNoise;

	function bool NotifyBump( Actor Other )
	{
		if( bIsAttacking && Other.IsA('Pawn') && (Other.Class!=Class || Pawn(Other)==Enemy) )
		{
			Disable('NotifyBump');
			bIsAttacking = False;
			Target = Other;
			DoomPawns(Pawn).MeleeDamageTarget(9, vect(0,0,0));
			PlaySound(Sound'DSPUNCH');
			GoToState('AttackEnemy','BackOff');
		}
		Return False;
	}
	event bool NotifyHitWall( vector HitNormal, actor HitWall )
	{
		if( bIsAttacking )
			GoToState('AttackEnemy','BackOff');
		Return Global.NotifyHitWall(HitNormal,HitWall);
	}
	function Tick( float Delta )
	{
		if( bIsAttacking && VSize(Velocity)<50 )
			GoToState('AttackEnemy','BackOff');
	}
Begin:
	NoKillMeTimer = Level.TimeSeconds+30;
	FreezePawn(false);
	bCanBeAgressive = False;
	if( DoomPawns(Pawn).bConstFiring )
		Pawn.LightType = LT_None;
	CheckDeadEnemy();
	bIsAttacking = False;
	DoomPawns(Pawn).PlayMyAnim('Walk');
DoAttack:
	NoKillMeTimer = Level.TimeSeconds+30;
	Pawn.Velocity = vect(0,0,0);
	Pawn.Acceleration = vect(0,0,0);
	FocalPoint = Enemy.Location;
	if( NeedToTurn(Enemy.Location) )
	{
		FreezePawn(true);
		DoomPawns(Pawn).PlayMyAnim('Still');
		Focus = Enemy;
		FinishRotation();
		FocalPoint = Enemy.Location;
		Focus = None;
	}
	FreezePawn(false);
	bIsAttacking = True;
	DoomPawns(Pawn).PlayMyAnim('Fire');
	Pawn.AirSpeed = Pawn.Default.AirSpeed*3;
	Enable('NotifyBump');
	if( bFastMonster )
	{
		Pawn.AirSpeed = Pawn.Default.AirSpeed*6;
		Velocity = Normal(Enemy.Location-Pawn.Location)*600;
	}
	else Velocity = Normal(Enemy.Location-Pawn.Location)*Pawn.AirSpeed;
	MoveTo(Velocity*10000+Pawn.Location);
BackOff:
	if( bFastMonster )
		Pawn.AirSpeed = Pawn.Default.AirSpeed*1.5;
	else Pawn.AirSpeed = Pawn.Default.AirSpeed;
	bIsAttacking = False;
	if( !LineOfSightTo(Enemy) )
		GoToState('HuntingEnemy');
	DoomPawns(Pawn).PlayMyAnim('Still');
	Pawn.Velocity = vect(0,0,0);
	Pawn.Acceleration = vect(0,0,0);
	Sleep(0.1);
	if( bFastMonster )
		MoveTo(Normal(Pawn.Location-Enemy.Location)*100+Pawn.Location+VRand()*10,Enemy);
	else MoveTo(Normal(Pawn.Location-Enemy.Location)*400+Pawn.Location+VRand()*100,Enemy);
	GoTo'Begin';
}

defaultproperties
{
}
