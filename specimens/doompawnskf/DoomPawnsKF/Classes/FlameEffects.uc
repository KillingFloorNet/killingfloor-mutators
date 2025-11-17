//=============================================================================
// FlameEffects.
//=============================================================================
class FlameEffects extends Effects;

var() texture SpriteAnimation[8];
var() float ShowTime;
var Actor Affected,AttachTo;
var vector LostContactVect;
var bool bLastSeen;
var() Sound EffectSound1,EffectSound2;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		AttachTo, LostContactVect;
}

function PostBeginPlay()
{
	SetTimer(0.2,True);
	MakeSound(0);
	Instigator = Pawn(Owner);
}
function Timer()
{
	if( Owner==None || Owner.bDeleteMe )
	{
		if( bLastSeen )
		{
			bLastSeen = False;
			LostContactVect = Location;
			AttachTo = None;
		}
		SetOwner(None);
		SetTimer(0,False);
		Return;
	}
	if( Affected==None || Pawn(Owner)==None || Pawn(Owner).Health<=0 )
	{
		LostContactVect = Location;
		AttachTo = None;
		SetTimer(0,false);
		Return;
	}
	if( Pawn(Owner).Controller!=None && (Mover(Affected)!=None || Pawn(Owner).Controller.LineOfSightTo(Affected)) )
	{
		if( !bLastSeen )
		{
			AttachTo = Affected;
			bLastSeen = True;
		}
	}
	else if( bLastSeen )
	{
		bLastSeen = False;
		LostContactVect = Location;
		AttachTo = None;
	}
}
simulated function Tick( float DeltaTime )
{
	local float V;
	local rotator ZeroRot;
	
	if( ShowTime>0 )
		ShowTime-=DeltaTime;
	if ( Level.NetMode != NM_DedicatedServer )
	{
		V = (ShowTime/Default.ShowTime);
		if( V<0 )
			V = 0;
		Texture = SpriteAnimation[V*7];
		V-=0.5;
		PrePivot = vect(0,0,70)*V;
	}
	if( Level.NetMode==NM_Client && AttachTo==None && LostContactVect!=vect(0,0,0) )
	{
		SetLocation(LostContactVect);
		LostContactVect = vect(0,0,0);
	}
	else if( AttachTo!=None )
	{
		ZeroRot = AttachTo.Rotation;
		ZeroRot.Pitch = 0;
		SetLocation(AttachTo.Location+vector(ZeroRot)*(AttachTo.CollisionRadius+30)-PrePivot);
	}
	if( Level.NetMode!=NM_Client && ShowTime<=0 )
	{
		if( Owner==None )
			Instigator = None;
		else Instigator = Pawn(Owner);
		if( AttachTo!=None )
		{
			AttachTo.TakeDamage(65-40*FRand(),Instigator,Location,vect(0,0,50000),Class'VileCursed');
			MakeSound(1);
			MakeNoise(2);
		}
		Destroy();
	}
}
function MakeSound( byte Num )
{
	if( Num==0 )
		PlaySound(EffectSound1,,7.0);
	else PlaySound(EffectSound2,,7.0);
}

defaultproperties
{
     SpriteAnimation(0)=Texture'DoomPawnsKF.ArchVile.FIREA0'
     SpriteAnimation(1)=Texture'DoomPawnsKF.ArchVile.FIREB0'
     SpriteAnimation(2)=Texture'DoomPawnsKF.ArchVile.FIREC0'
     SpriteAnimation(3)=Texture'DoomPawnsKF.ArchVile.FIRED0'
     SpriteAnimation(4)=Texture'DoomPawnsKF.ArchVile.FIREE0'
     SpriteAnimation(5)=Texture'DoomPawnsKF.ArchVile.FIREF0'
     SpriteAnimation(6)=Texture'DoomPawnsKF.ArchVile.FIREG0'
     SpriteAnimation(7)=Texture'DoomPawnsKF.ArchVile.FIREH0'
     ShowTime=2.000000
     EffectSound1=Sound'DoomPawnsKF.ArchVile.DSFLAME'
     EffectSound2=Sound'DoomPawnsKF.Cyborg.DSBAREXP'
     bNetTemporary=False
     RemoteRole=ROLE_SimulatedProxy
     Texture=Texture'DoomPawnsKF.ArchVile.FIREA0'
     Style=STY_Masked
}
