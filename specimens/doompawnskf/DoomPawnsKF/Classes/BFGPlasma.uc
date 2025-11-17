//=============================================================================
// BFGPlasma.
//=============================================================================
class BFGPlasma extends ImpFlameBall;

var vector InstigPosition;
var rotator InitialRot;

function PostBeginPlay()
{
	InitialRot = Rotation;
	InstigPosition = Location;
	Super.PostBeginPlay();
}

auto state Flying
{
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local BFGBallExp s;
	
		if ( Role == ROLE_Authority )
			MakeNoise(15.0); //FIXME - set appropriate loudness
	
		if( Level.NetMode!=NM_DedicatedServer )
		{
			s = Spawn(class'BFGBallExp',,,HitLocation+HitNormal*9);
			s.RemoteRole = ROLE_None;
		}
		if( Level.NetMode==NM_Client )
			Destroy();
		else
		{
			SetTimer(0.457,False);
			SetPhysics(PHYS_None);
			bHidden = True;
			SetCollision(False,False,False);
		}
	}
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if( KFBulletWhipAttachment(Other)==None && (Other != instigator) )
		{
			if ( Role == ROLE_Authority )
				Other.TakeDamage(Damage+Rand(700), instigator,HitLocation,
						15000.0 * Normal(velocity),MyDamage);
			Explode(HitLocation, Vect(0,0,0));
		}
	}
	function Tick( float Delta )
	{
		if( Instigator!=None )
			InstigPosition = Instigator.Location;
	}
	function Timer()
	{
		local vector End,X,Y,Z,HitL,HitN;
		local int i;
		local Actor A;
		
		GetAxes(InitialRot,X,Y,Z);
		For( i=0; i<40; i++ )
		{
			End = InstigPosition+X*4280+Y*(FRand()*8560-4280)+Z*(FRand()*8560-4280); // Get randomized cone radius
			A = Trace(HitL,HitN,End,InstigPosition,True);
			if( A!=None && !A.bWorldGeometry )
			{
				if( KFBulletWhipAttachment(A)!=None && A.Owner!=None )
					A = A.Owner;
				Spawn(Class'BFGRayFX',,,A.Location);
				A.TakeDamage(49+Rand(40), instigator,HitL,15000.0*X,MyDamage);
			}
		}
		ForEach VisibleCollidingActors(Class'Actor',A,850)
		{
			if( KFBulletWhipAttachment(A)==None && A!=Instigator && !A.bWorldGeometry && FastTrace(InstigPosition,A.Location) )
			{
				Spawn(Class'BFGRayFX',,,A.Location);
				A.TakeDamage(49+Rand(80), instigator,HitL,15000.0*X,MyDamage);
			}
		}
		Destroy();
	}
}

defaultproperties
{
     MyDamage=Class'DoomPawnsKF.BFGZapped'
     Speed=650.000000
     Damage=100.000000
     LightHue=83
     LightSaturation=50
     Texture=Texture'DoomPawnsKF.BFG.BFS1A0'
     DrawScale=2.100000
}
