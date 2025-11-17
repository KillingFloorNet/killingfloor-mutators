//======================================================================
// Lost soul...
//======================================================================
class Skull extends DoomPawns;

#exec obj load file=LostSoulS.uax package=DoomPawnsKF
#exec obj load file=LostSoulT.utx package=DoomPawnsKF

var Skull Parent;
var byte NumSouls;
var vector AimRotSpeed;

replication
{
	// Things the server should send to the client.
	unreliable if( bNetDirty && Role==ROLE_Authority )
		AimRotSpeed;
}

simulated function PostNetReceive()
{
	if( AimRotSpeed!=vect(0,0,0) && Health>0 )
		GoToState('DoingAttack');
	Super.PostNetReceive();
}
function bool IsHeadShot(vector loc, vector ray, float AdditionalScale)
{
	Return True; // Always headshot these suckers.
}
function float PlayMyAnim( name MyAnimName )
{
	if( MyAnimName=='Walk' || MyAnimName=='Fall' )
	{
		AnimChange = 0;
		NotifyAnimation(0);
		Return 0;
	}
	else if( MyAnimName=='Still' )
	{
		AnimChange = 0;
		NotifyAnimation(0);
		Return 0.8;
	}
	else
	{
		PlaySound(Sound'DSSKLATK');
		AnimChange = 1;
		NotifyAnimation(1);
		Return 1.5;
	}
}
function RangedAttack(Actor A)
{
	if ( bShotAnim )
		return;
	PlayMyAnim('Fire');
	if( PlayerController(Controller)!=None )
		AimRotSpeed = vector(Controller.Rotation)*900;
	else AimRotSpeed = Normal(A.Location-Location)*900;
	GoToState('DoingAttack');
}
State DoingAttack
{
	final function CanMoveForward()
	{
		local vector Dummy;
		local Actor A;

		Dummy.X = CollisionRadius;
		Dummy.Y = CollisionRadius;
		Dummy.Z = CollisionHeight;
		A = Trace(Dummy,Dummy,Location+Normal(AimRotSpeed)*30.f,Location,true,Dummy);
		if( A==None )
			return;
		if( !A.bStatic && !A.bWorldGeometry )
			Bump(A);
		else EndMoveNow();
	}
	simulated function PostNetReceive()
	{
		if( AimRotSpeed==vect(0,0,0) )
			GoToState('');
		Super.PostNetReceive();
	}
	function BeginState()
	{
		if( Level.NetMode!=NM_Client )
		{
			bShotAnim = True;
			Controller.bPreparingMove = True;
			SetTimer(0,False);
			Enable('Bump');
			AirSpeed*=3;
		}
		Velocity = AimRotSpeed;
		Acceleration = Velocity;
	}
	simulated function EndState()
	{
		bClientIsFiring = False;
		bClientSideFiring = False;
		if( Level.NetMode!=NM_Client )
		{
			AirSpeed = Default.AirSpeed;
			AimRotSpeed = vect(0,0,0);
		}
	}
	function Timer();
	function EndMoveNow()
	{
		if( Level.NetMode==NM_Client )
			return;
		bShotAnim = False;
		Controller.bPreparingMove = False;
		Controller.AnimEnd(0);
		GoToState('');
	}
	simulated function Tick( float Delta )
	{
		Velocity = AimRotSpeed;
		Acceleration = Velocity;
		if( Level.NetMode!=NM_Client )
			CanMoveForward();
	}
	function Bump( Actor Other )
	{
		if( Level.NetMode==NM_Client )
			return;
		Controller.Target = Other;
		MeleeDamageTarget(12, vect(0,0,0));
		PlaySound(Sound'DSPUNCH');
		EndMoveNow();
	}
	event HitWall(vector HitNormal, actor Wall)
	{
		EndMoveNow();
	}
	simulated function FaceRotation( rotator NewRotation, float DeltaTime )
	{
		SetRotation(rotator(AimRotSpeed));
	}

Begin:
	if( Level.NetMode==NM_Client )
		Stop;
	Sleep(7);
	EndMoveNow();
}
simulated function UpdateAnimation( byte MyRot, optional int FrameNum )
{
	if( MyRot==7 )
		MyRot = 1;
	else if( MyRot==6 )
		MyRot = 2;
	else if( MyRot==5 )
		MyRot = 3;
	if( AnimChange==0 )
		UpdateSkin(WalkTextures[MyRot]);
	else UpdateSkin(ShootTextures[MyRot]);
}
simulated function NotifyAnimation( byte AnimNum )
{
	Render.LastCheckB = 9;
}
simulated function bool MirrorMe( byte Dir )
{
	if( Dir>=5 )
		Return True;
	else Return False;
}
simulated function Destroyed()
{
	Super.Destroyed();
	if( Level.NetMode!=NM_Client && Parent!=None )
		Parent.NumSouls--;
}
event EncroachedBy( actor Other )
{
	// Allow encroachment by Vehicles so they can push the pawn out of the way
	if ( Pawn(Other)!=None && Vehicle(Other)==None && Skull(Other)==None && !Class'Resurrecting'.Default.bIsRessurrecting )
		gibbedBy(Other);
}

defaultproperties
{
     WalkTextures(0)=Texture'DoomPawnsKF.Skull.SKULA1'
     WalkTextures(1)=Texture'DoomPawnsKF.SKULA8A2'
     WalkTextures(2)=Texture'DoomPawnsKF.SKULA7A3'
     WalkTextures(3)=Texture'DoomPawnsKF.Skull.SKULA6A4'
     WalkTextures(4)=Texture'DoomPawnsKF.Skull.SKULA5'
     ShootTextures(0)=Texture'DoomPawnsKF.Skull.SKULC1'
     ShootTextures(1)=Texture'DoomPawnsKF.Skull.SKULC8C2'
     ShootTextures(2)=Texture'DoomPawnsKF.Skull.SKULC8C2'
     ShootTextures(3)=Texture'DoomPawnsKF.Skull.SKULC6C4'
     ShootTextures(4)=Texture'DoomPawnsKF.Skull.SKULC5'
     DieTexture=Texture'DoomPawnsKF.Skull.SKULF0'
     DeathSpeed=1.300000
     MeleeDamageType=Class'DoomPawnsKF.SpookedDmg'
     PawnHealth=90
     Die2=Sound'DoomPawnsKF.Cyborg.DSBAREXP'
     Die=Sound'DoomPawnsKF.Cyborg.DSBAREXP'
     Fear=Sound'DoomPawnsKF.Imp.DSBGACT'
     HitSound1=Sound'DoomPawnsKF.Imp.DSDMPAIN'
     HitSound2=Sound'DoomPawnsKF.Imp.DSDMPAIN'
     bCarcassMe=False
     bHasMelee=True
     ScoringValue=15
     bCanFly=True
     bCanStrafe=True
     MeleeRange=500.000000
     AirSpeed=150.000000
     BaseEyeHeight=24.000000
     Health=90
     MenuName="Lost Soul"
     ControllerClass=Class'DoomPawnsKF.SkullController'
     Texture=Texture'DoomPawnsKF.Skull.SKULA1'
     DrawScale=0.250000
     bUnlit=True
     CollisionRadius=25.000000
     CollisionHeight=25.000000
     Buoyancy=99.000000
}
