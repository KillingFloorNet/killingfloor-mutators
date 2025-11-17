//=============================================================================
// SkeleRocket.
//=============================================================================
class SkeleRocket extends DoomRocket;

var Pawn Seeking;
var float MagnitudeVel;
var int FollowTime;
var pclSmoke MyTrail;

replication
{
	unreliable if( Role==ROLE_Authority && bNetInitial )
		Seeking,FollowTime;
}

function PreBeginPlay()
{
	Super.PreBeginPlay();
	if( Instigator!=None && Instigator.Controller!=None && FRand()<0.4 )
		Seeking = Instigator.Controller.Enemy;
}
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(0.07,True);
}
simulated function UpdateAnimation( byte Rot, byte Frame )
{
	if( rot==7 )
		Rot = 1;
	else if( rot==6 )
		Rot = 2;
	else if( rot==5 )
		Rot = 3;
	Texture = MyFrames[rot];
}
simulated function Update3DScale( out vector D3D, byte Rot )
{
	if( rot==4 )
		D3D.X/=2;
}
simulated function Explode(vector HitLocation, vector HitNormal)
{
	local DoomExplosionSk s;

	s = spawn(class'DoomExplosionSk',,,HitLocation + HitNormal*16);	
 	s.RemoteRole = ROLE_None;
	MakeNoise(2.0);

 	Destroy();
}
//Rotate vector A towards vector B, an amount of degrees (Thanks to Jon for this function).
static final function RotateVector( out vector A, vector B, float Degree )
{
	local float Magnitude;
	local vector C, X, Z;

	Degree = Degree * Pi / 180.0;//Convert to radians.
	Magnitude = VSize(A);
	A = Normal(A);
	B = Normal(B);

	//form a right angle with vector A
	if( A Dot B == -1.0 )//vectors are pointing in opposite directions
		GetAxes( rotator(B), X, C, Z );
	else C = B - (A Dot B) * A;

	C = Normal(C);
	A = Normal( A * Cos(Degree) + C * Sin(Degree) ) * Magnitude;
}
simulated function Timer()
{
	if( Seeking==None || FollowTime>400 ) Return;
	RotateVector(Velocity,(Seeking.Location-Location),3);
	InitRot = rotator(Velocity);
	FollowTime++;
	if( MyTrail==None && Level.NetMode!=NM_DedicatedServer )
	{
		MyTrail = Spawn(class'pclSmoke',Self);
		MyTrail.SetBase(Self);
	}
}
simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if( KFBulletWhipAttachment(Other)==None && Other!=Instigator && DoomProjectile(Other)==None )
	{
		if ( Role == ROLE_Authority )
			Other.TakeDamage( Damage-(Damage*0.7*FRand()), instigator, HitLocation, MomentumTransfer*Vector(Rotation), Class'RevenBlown');
		Explode(HitLocation,Normal(HitLocation-Other.Location));
	}
}
simulated function bool MirrorMe( byte rot )
{
	Return (rot<=7 && rot>=5);
}
simulated function Destroyed()
{
	if( MyTrail!=None )
	{
		MyTrail.mRegen = false;
		MyTrail.LifeSpan = 1.f;
	}
	Super.Destroyed();
}

defaultproperties
{
     MyFrames(0)=Texture'DoomPawnsKF.Skeleton.FATBA1'
     MyFrames(1)=Texture'DoomPawnsKF.Skeleton.FATBA2A8'
     MyFrames(2)=Texture'DoomPawnsKF.Skeleton.FATBA3A7'
     MyFrames(3)=Texture'DoomPawnsKF.Skeleton.FATBA4A6'
     MyFrames(4)=Texture'DoomPawnsKF.Skeleton.FATBA5'
     Speed=750.000000
     Damage=80.000000
     MomentumTransfer=30000.000000
     SpawnSound=Sound'DoomPawnsKF.Imp.DSFIRSHT'
     LifeSpan=32.000000
     Texture=Texture'DoomPawnsKF.Skeleton.FATBA1'
     DrawScale=1.150000
     DrawScale3D=(X=2.000000)
     ScaleGlow=2.000000
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     bRotateToDesired=True
     RotationRate=(Pitch=1000,Yaw=1000,Roll=1000)
}
