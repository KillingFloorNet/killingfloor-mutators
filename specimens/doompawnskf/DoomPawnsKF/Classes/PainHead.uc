//======================================================================
// Host of lost souls.
//======================================================================
class PainHead extends Skull;

#exec obj load file=PainElS.uax package=DoomPawnsKF

var() int MaxLostSouls;
var() texture FireAnims1[5],FireAnims2[5],FireAnims3[5];

function float PlayMyAnim( name MyAnimName )
{
	if( MyAnimName=='Walk' || MyAnimName=='Fall' )
	{
		AnimChange = 0;
		NotifyAnimation(0);
		Return 0;
	}
	else if( MyAnimName=='Still' || NumSouls>=15 )
	{
		AnimChange = 1;
		NotifyAnimation(1);
		Return 0.8;
	}
	else
	{
		CallTimer(0.7,False);
		AnimChange = 2;
		NotifyAnimation(2);
		Enable('Bump');
		Return 1;
	}
}
function TimedReply()
{
	local rotator TheRot;
	TheRot.Yaw = Rotation.Yaw;
	AddLostSoul(Location+vector(TheRot)*(CollisionRadius+30));
}
simulated function UpdateAnimation( byte MyRot, optional int FrameNum )
{
	if( MyRot==1 )
		MyRot = 7;
	else if( MyRot==2 )
		MyRot = 6;
	else if( MyRot==3 )
		MyRot = 5;
	if( AnimChange==0 )
		UpdateSkin(WalkTextures[MyRot]);
	else if( AnimChange==1 )
		UpdateSkin(ShootTextures[MyRot]);
	else
	{
		if( MyRot==7 )
			MyRot = 1;
		else if( MyRot==6 )
			MyRot = 2;
		else if( MyRot==5 )
			MyRot = 3;
		if( FrameNum==0 )
			UpdateSkin(FireAnims1[MyRot]);
		else if( FrameNum==1 )
			UpdateSkin(FireAnims2[MyRot]);
		else UpdateSkin(FireAnims3[MyRot]);
	}
}
simulated function bool MirrorMe( byte Dir )
{
	if( Dir>=1 && Dir<=3 )
		Return True;
	else Return False;
}
simulated function NotifyAnimation( byte AnimNum )
{
	if( AnimNum==2 )
		Render.SetAnimatedTime(1.3,3);
	else
	{
		Render.TimeLeft = 0;
		Render.LastCheckB = 9;
	}
}
function NotifyDead()
{
	Render = None;
	SetCollision(false,false,false);
	AddLostSoul(Location+vect(25,0,0));
	AddLostSoul(Location+vect(-25,25,25));
	AddLostSoul(Location+vect(-25,-25,-25));
	Super.NotifyDead();
}
function bool CanAttackNow() // Hack for pain elemental
{
	Return !TooManySouls();
}
function bool AddLostSoul( vector Pos )
{
	local Skull S;

	if( TooManySouls() ) Return False;
	S = Spawn(class'Skull',,,Pos);
	if( S==None ) Return False;
	S.SetPhysics(PHYS_Flying);
	if( Controller!=None && S.Controller!=None )
	{
		S.Controller.Enemy = Controller.Enemy;
		S.Controller.GoToState('AttackEnemy','DoAttack');
	}
	S.Parent = Self;
	NumSouls++;
	if( Level.Game.IsA('Invasion') )
		Invasion(Level.Game).NumMonsters++;
}
function bool TooManySouls()
{
	local Controller C;
	local int i;

	For( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( C.Pawn!=None && C.Pawn.Class==Class'Skull' )
		{
			i++;
			if( i>MaxLostSouls )
				Return True;
		}
	}
	Return False;
}
function RangedAttack(Actor A)
{
	Super(DoomPawns).RangedAttack(A);
}
State DoingAttack
{
Ignores Bump,HitWall;

	function BeginState()
	{
		Acceleration = vect(0,0,0);
		if( Physics==PHYS_Flying )
			Velocity = vect(0,0,0);
		bShotAnim = True;
		Controller.bPreparingMove = True;
	}
	function Timer()
	{
		bShotAnim = False;
		Controller.bPreparingMove = False;
		Controller.AnimEnd(0);
		if( bClientIsFiring && !IsBeingControlled() )
			bClientIsFiring = False; // no longer being controlled.
		GoToState('');
	}
	function EndState()
	{
		OldAnimStuff = 2;
	}
	function EndMoveNow();
	simulated function Tick( float Delta )
	{
		Global.Tick(Delta);
	}
	simulated function FaceRotation( rotator NewRotation, float DeltaTime );

Begin:
	Sleep(3);
	Timer();
}

defaultproperties
{
     MaxLostSouls=20
     FireAnims1(0)=Texture'DoomPawnsKF.PainElem.PAIND1'
     FireAnims1(1)=Texture'DoomPawnsKF.PainElem.PAIND2D8'
     FireAnims1(2)=Texture'DoomPawnsKF.PainElem.PAIND3D7'
     FireAnims1(3)=Texture'DoomPawnsKF.PainElem.PAIND4D6'
     FireAnims1(4)=Texture'DoomPawnsKF.PainElem.PAIND5'
     FireAnims2(0)=Texture'DoomPawnsKF.PainElem.PAINE1'
     FireAnims2(1)=Texture'DoomPawnsKF.PainElem.PAINE2E8'
     FireAnims2(2)=Texture'DoomPawnsKF.PainElem.PAINE3E7'
     FireAnims2(3)=Texture'DoomPawnsKF.PainElem.PAINE4E6'
     FireAnims2(4)=Texture'DoomPawnsKF.PainElem.PAINE5'
     FireAnims3(0)=Texture'DoomPawnsKF.PainElem.PAINF1'
     FireAnims3(1)=Texture'DoomPawnsKF.PainElem.PAINF2F8'
     FireAnims3(2)=Texture'DoomPawnsKF.PainElem.PAINF3F7'
     FireAnims3(3)=Texture'DoomPawnsKF.PainElem.PAINF4F6'
     FireAnims3(4)=Texture'DoomPawnsKF.PainElem.PAINF5'
     RenderingClass=Class'DoomPawnsKF.FlatDisplay'
     WalkTextures(0)=Texture'DoomPawnsKF.PainElem.PAINA1'
     WalkTextures(1)=None
     WalkTextures(2)=None
     WalkTextures(3)=None
     WalkTextures(4)=Texture'DoomPawnsKF.PainElem.PAINA5'
     WalkTextures(5)=Texture'DoomPawnsKF.PainElem.PAINA4A6'
     WalkTextures(6)=Texture'DoomPawnsKF.PainElem.PAINA3A7'
     WalkTextures(7)=Texture'DoomPawnsKF.PainElem.PAINA2A8'
     ShootTextures(0)=Texture'DoomPawnsKF.PainElem.PAINC1'
     ShootTextures(1)=None
     ShootTextures(2)=None
     ShootTextures(3)=None
     ShootTextures(4)=Texture'DoomPawnsKF.PainElem.PAINC5'
     ShootTextures(5)=Texture'DoomPawnsKF.PainElem.PAINC4C6'
     ShootTextures(6)=Texture'DoomPawnsKF.PainElem.PAINC3C7'
     ShootTextures(7)=Texture'DoomPawnsKF.PainElem.PAINC2C8'
     DieTexture=Texture'DoomPawnsKF.PainElem.PAINH0'
     DeathSpeed=1.500000
     PawnHealth=410
     Acquire2=Sound'DoomPawnsKF.PainElem.DSPESIT'
     Die2=None
     Die=Sound'DoomPawnsKF.PainElem.DSPEDTH'
     Acquire=Sound'DoomPawnsKF.PainElem.DSPESIT'
     Fear=None
     Threaten=Sound'DoomPawnsKF.PainElem.DSPESIT'
     HitSound1=Sound'DoomPawnsKF.PainElem.DSPEPAIN'
     HitSound2=Sound'DoomPawnsKF.PainElem.DSPEPAIN'
     bHasMelee=False
     bHasRangedAttack=True
     ScoringValue=40
     AirSpeed=160.000000
     Health=410
     MenuName="Pain Elemental"
     ControllerClass=Class'DoomPawnsKF.DoomController'
     Texture=Texture'DoomPawnsKF.PainElem.PAINA1'
     DrawScale=0.450000
     CollisionRadius=47.000000
     CollisionHeight=47.000000
}
