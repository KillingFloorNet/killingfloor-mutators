class TauBullet extends Projectile;

var	xEmitter    Trail;
var	float	  DamageAtten;
var	sound	  ImpactSounds[6];
var()   int	    MaxPenetrations; // Yeah, Hardy har har. It refers in fact to the number of times the bolt can pass through someone and keep going.
var()   float	  PenDamageReduction; // how much damage does it lose with each person it passes through?
var()   float	  HeadShotDamageMult;

var()	class<ROHitEffect>		ImpactEffect;

var	class<Emitter> ExplosionEmitter;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();

    if( Pawn(Owner) != None )
	   Instigator = Pawn( Owner );
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	Velocity = Speed * Vector(Rotation); // starts off slower so combo can be done closer

    SetTimer(0.4, false);

    if ( Level.NetMode != NM_DedicatedServer )
    {
	   if ( !PhysicsVolume.bWaterVolume )
	   {
			Trail = Spawn(class'TauBulletTrail',self);
		  Trail.Lifespan = Lifespan;
	   }
    }
}

simulated function PostNetBeginPlay()
{
	local PlayerController PC;

	Super.PostNetBeginPlay();

	if ( Level.NetMode == NM_DedicatedServer )
		return;

	PC = Level.GetLocalPlayerController();
	if ( (Instigator != None) && (PC == Instigator.Controller) )
		return;
	if ( Level.bDropDetail || (Level.DetailMode == DM_Low) )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
	else if ( (PC == None) || (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 3000) )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
}

simulated function Destroyed()
{
	if (Trail !=None) Trail.mRegen=False;
	Super.Destroyed();

}

simulated singular function HitWall(vector HitNormal, actor Wall)
{
	
    if ( Role == ROLE_Authority )
	{
		if ( !Wall.bStatic && !Wall.bWorldGeometry )
		{
			if ( Instigator == None || Instigator.Controller == None )
				Wall.SetDelayedDamageInstigatorController( InstigatorController );
			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			if (DamageRadius > 0 && Vehicle(Wall) != None && Vehicle(Wall).Health > 0)
				Vehicle(Wall).DriverRadiusDamage(Damage, DamageRadius, InstigatorController, MyDamageType, MomentumTransfer, Location);
			HurtWall = Wall;
		}
		MakeNoise(1.0);
	}
	Explode(Location + ExploWallOut * HitNormal, HitNormal);

	if (ImpactEffect != None && (Level.NetMode != NM_DedicatedServer))
	{
			Spawn(ImpactEffect,,, Location, rotator(-HitNormal));
			Spawn(ExplosionEmitter,,, Location, rotator(-HitNormal));
	}

	HurtWall = None;


    if (Trail != None)
    {
	   Trail.mRegen=False;
	   Trail.SetPhysics(PHYS_None);
    }

    Destroy();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
    local vector X;
	local Vector TempHitLocation, HitNormal;
	local array<int>	HitPoints;
    local KFPawn HitPawn;

	if ( Other == none || Other == Instigator || Other.Base == Instigator || !Other.bBlockHitPointTraces  )
		return;

    X = Vector(Rotation);

 	if( ROBulletWhipAttachment(Other) != none )
	{
	   if(!Other.Base.bDeleteMe)
	   {
		   Other = Instigator.HitPointTrace(TempHitLocation, HitNormal, HitLocation + (200 * X), HitPoints, HitLocation,, 1);

			if( Other == none || HitPoints.Length == 0 )
				return;

			HitPawn = KFPawn(Other);

		  if (Role == ROLE_Authority)
		  {
    	    	if ( HitPawn != none )
    	    	{
				if( !HitPawn.bDeleteMe )
					HitPawn.ProcessLocationalDamage(Damage, Instigator, TempHitLocation, MomentumTransfer * Normal(Velocity), MyDamageType,HitPoints);
    	    	}
    		}
		}
	}
    else
    {
	   if (Pawn(Other) != none && Pawn(Other).IsHeadShot(HitLocation, X, 1.0))
	   {
		  Pawn(Other).TakeDamage(Damage * HeadShotDamageMult, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
	   }
	   else
	   {
		  Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
	   }
    }

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
   		PenDamageReduction = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.static.GetShotgunPenetrationDamageMulti(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo),default.PenDamageReduction);
	}
	else
	{
   		PenDamageReduction = default.PenDamageReduction;
   	}

   	Damage *= PenDamageReduction; // Keep going, but lose effectiveness each time.

    // if we've struck through more than the max number of foes, destroy.
    if ( Damage / default.Damage <= PenDamageReduction / MaxPenetrations )
    {
	   Destroy();
    }

    speed = VSize(Velocity);

    if( Speed < (default.Speed * 0.25) )
    {
	   Destroy();
    }
}

defaultproperties
{
	bSwitchToZeroCollision=True
	CullDistance=3000.0
	Damage=90
	DamageAtten=5.0
	DamageRadius=5 //0.0
	DrawType=DT_StaticMesh
	ExplosionDecal=class'KFMod.FlameThrowerBurnMark_Medium'
	ExplosionEmitter=class'TauShotImpact_Medium'
	HeadShotDamageMult=1.4
	ImpactEffect=class'ROBulletHitEffect'
	LifeSpan=3.0
	MaxPenetrations=20 //2
	Speed=5000 //3000
	MaxSpeed=7000 //4000.0
	MomentumTransfer=13000 //50000.0
	MyDamageType=Class'TauC.DamTypeTCProjectile'
	PenDamageReduction=0.5
	StaticMesh=StaticMesh'TC_R.TauBeam'
	DrawScale=2 //1
	Style=STY_Alpha
}
