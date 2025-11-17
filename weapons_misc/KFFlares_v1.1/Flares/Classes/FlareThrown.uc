// subclassing ROBallisticProjectile so we can do the ambient volume scaling
class FlareThrown extends ROBallisticProjectile;

#exec obj load file="KF_IJC_HalloweenSnd.uax"
#exec obj load file="Flare_R.ukx"
//#exec OBJ LOAD FILE=WeaponSounds.uax
#exec OBJ LOAD FILE=ProjectileSounds.uax

// camera shakes //
var() vector ShakeRotMag;           // how far to rot view
var() vector ShakeRotRate;          // how fast to rot view
var() float  ShakeRotTime;          // how much time to rot the instigator's view
var() vector ShakeOffsetMag;        // max view offset vertically
var() vector ShakeOffsetRate;       // how fast to offset view vertically
var() float  ShakeOffsetTime;       // how much time to offset view

var() vector RotMag;            // how far to rot view
var() vector RotRate;           // how fast to rot view
var() float  RotTime;           // how much time to rot the instigator's view
var() vector OffsetMag;         // max view offset vertically
var() vector OffsetRate;        // how fast to offset view vertically
var() float  OffsetTime;        // how much time to offset view

var PanzerfaustTrail SmokeTrail;
var vector Dir;
var bool bRing,bHitWater,bWaterStart;

var()   sound   ExplosionSound; // The sound of the rocket exploding

var     bool    bDisintegrated; // This nade has been disintegrated by a siren scream.
var()   sound   DisintegrateSound;// The sound of this projectile disintegrating
var     bool    bDud;           // This rocket is a dud, it hit too soon
var()   float   ArmDistSquared; // Distance this rocket arms itself at
var   class<DamageType>	   ImpactDamageType; // Damagetype of this rocket hitting something, but not exploding
var     int     ImpactDamage;   // How much damage to do if this rocket impacts something without exploding
var     bool    bHasExploded;

var		string	StaticMeshRef;
var		string	ExplosionSoundRef;
var		string	AmbientSoundRef;
var		string	DisintegrateSoundRef;

var bool bCanHitOwner;
var bool bTimerSet;
var float FizzleTimer;
var() float DampenFactor, DampenFactorParallel;
var		string	ImpactSoundRef;

var()   float       HeadShotDamageMult;

var     Emitter     FlameTrail;
var     class<Emitter> FlameTrailEmitterClass;
var     float       ExplosionSoundVolume;

replication
{
    reliable if (Role==ROLE_Authority)
        FizzleTimer;
}

static function PreloadAssets()
{
	default.ExplosionSound = sound(DynamicLoadObject(default.ExplosionSoundRef, class'Sound', true));
	default.AmbientSound = sound(DynamicLoadObject(default.AmbientSoundRef, class'Sound', true));
	default.DisintegrateSound = sound(DynamicLoadObject(default.DisintegrateSoundRef, class'Sound', true));

	UpdateDefaultStaticMesh(StaticMesh(DynamicLoadObject(default.StaticMeshRef, class'StaticMesh', true)));
}

simulated function PostNetBeginPlay()
{
	if ( Physics == PHYS_None )
    {
        SetTimer(FizzleTimer, false);
        bTimerSet = true;
    }
}

static function bool UnloadAssets()
{
	default.ExplosionSound = none;
	default.AmbientSound = none;
	default.DisintegrateSound = none;

	UpdateDefaultStaticMesh(none);

	return true;
}

simulated function PostNetReceive()
{
	if( bHidden && !bDisintegrated )
	{
		Disintegrate(Location, vect(0,0,1));
	}
}

simulated function Timer()
{
    Destroy();
}

function ShakeView()
{
	local Controller C;
	local PlayerController PC;
	local float Dist, Scale;

	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		PC = PlayerController(C);
		if ( PC != None && PC.ViewTarget != None )
		{
			Dist = VSize(Location - PC.ViewTarget.Location);
			if ( Dist < DamageRadius * 2.0)
			{
				if (Dist < DamageRadius)
					Scale = 1.0;
				else
					Scale = (DamageRadius*2.0 - Dist) / (DamageRadius);
				C.ShakeView(ShakeRotMag*Scale, ShakeRotRate, ShakeRotTime, ShakeOffsetMag*Scale, ShakeOffsetRate, ShakeOffsetTime);
			}
		}
	}
}

simulated function HitWall( vector HitNormal, actor Wall )
{
    local Vector VNorm;

    if( Instigator != none )
    {
        OrigLoc = Instigator.Location;
    }

	if ( (Pawn(Wall) != None) || (GameObjective(Wall) != None) )
	{
		return;
	}
	
	if (!bTimerSet)
    {
        SetTimer(FizzleTimer, false);
        bTimerSet = true;
    }

    // Reflect off Wall w/damping
    VNorm = (Velocity dot HitNormal) * HitNormal;
    Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;

	RandSpin(100000);
    DesiredRotation.Roll = 0;
    RotationRate.Roll = 0;
    Speed = VSize(Velocity);

    if ( Speed < 20 )
    {
        bBounce = False;
		PrePivot.Z = -1.5;
		SetPhysics(PHYS_None);
		DesiredRotation = Rotation;
		DesiredRotation.Roll = 0;
		DesiredRotation.Pitch = 0;
		SetRotation(DesiredRotation);
    }
    else
    {
		if ( (Level.NetMode != NM_DedicatedServer) && (Speed > 250) )
			PlaySound(ImpactSound, SLOT_Misc );
		else
		{
			bFixedRotationDir = false;
			bRotateToDesired = true;
			DesiredRotation.Pitch = 0;
			RotationRate.Pitch = 50000;
		}
    }
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    bHasExploded = True;

    // Don't explode if this is a dud
    if( bDud )
    {
        Velocity = vect(0,0,0);
        LifeSpan=1.0;
        SetPhysics(PHYS_Falling);
    }

    PlaySound(ExplosionSound,,ExplosionSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
        Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }

    BlowUp(HitLocation);
    Destroy();
}

// Make the projectile distintegrate, instead of explode
simulated function Disintegrate(vector HitLocation, vector HitNormal)
{
	bDisintegrated = true;
	bHidden = true;

	if( Role == ROLE_Authority )
	{
	   SetTimer(0.1, false);
	   NetUpdateTime = Level.TimeSeconds - 1;
	}

	PlaySound(DisintegrateSound,,2.0);

	if ( EffectIsRelevant(Location,false) )
	{
		Spawn(Class'KFMod.SirenNadeDeflect',,, HitLocation, rotator(vect(0,0,1)));
	}
}

simulated function PostBeginPlay()
{

	if ( Role == ROLE_Authority )
	{
		Velocity = Speed * Vector(Rotation);
		RandSpin(25000);
		bCanHitOwner = false;
		if (Instigator.HeadVolume.bWaterVolume)
		{
			bHitWater = true;
			Velocity = 0.6*Velocity;
		}
	}

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( !PhysicsVolume.bWaterVolume )
		{
			FlameTrail = Spawn(FlameTrailEmitterClass,self);
			FlameTrail.SetBase(self);
		}
	}

    OrigLoc = Location;

    if( !bDud )
    {
        Dir = vector(Rotation);
        Velocity = speed * Dir;
    }

    super(ROBallisticProjectile).PostBeginPlay();
}

//Make siren screams destroy the flare
function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
    if( damageType == class'SirenScreamDamage')
    {
        Disintegrate(HitLocation, vect(0,0,1));
    }
}

simulated function Destroyed()
{
	if ( FlameTrail != none )
	{
        FlameTrail.Kill();
        FlameTrail.SetPhysics(PHYS_None);
	}

	Super.Destroyed();
}

/* HurtRadius()
 Hurt locally authoritative actors within the radius.
*/
simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dirs;
	local int NumKilled;
	local KFMonster KFMonsterVictim;
	local Pawn P;
	local KFPawn KFP;
	local array<Pawn> CheckedPawns;
	local int i;
	local bool bAlreadyChecked;

	if ( bHurtEntry )
		return;

	bHurtEntry = true;

	foreach CollidingActors (class 'Actor', Victims, DamageRadius, HitLocation)
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo')
		 && ExtendedZCollision(Victims)==None )
		{
			dirs = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dirs));
			dirs = dirs/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			if ( Instigator == None || Instigator.Controller == None )
				Victims.SetDelayedDamageInstigatorController( InstigatorController );
			if ( Victims == LastTouched )
				LastTouched = None;

			P = Pawn(Victims);

			if( P != none )
			{
		        for (i = 0; i < CheckedPawns.Length; i++)
				{
		        	if (CheckedPawns[i] == P)
					{
						bAlreadyChecked = true;
						break;
					}
				}

				if( bAlreadyChecked )
				{
					bAlreadyChecked = false;
					P = none;
					continue;
				}

				KFMonsterVictim = KFMonster(Victims);

				if( KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
				{
					KFMonsterVictim = none;
				}

				KFP = KFPawn(Victims);

				if( KFMonsterVictim != none )
				{
					damageScale *= KFMonsterVictim.GetExposureTo(HitLocation/*Location + 15 * -Normal(PhysicsVolume.Gravity)*/);
				}
				else if( KFP != none )
				{
				    damageScale *= KFP.GetExposureTo(HitLocation/*Location + 15 * -Normal(PhysicsVolume.Gravity)*/);
				}

				CheckedPawns[CheckedPawns.Length] = P;

				if ( damageScale <= 0)
				{
					P = none;
					continue;
				}
				else
				{
					//Victims = P;
					P = none;
				}
			}


			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dirs,
				(damageScale * Momentum * dirs),
				DamageType
			);

			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);

			if( Role == ROLE_Authority && KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
			{
				NumKilled++;
			}
		}
	}
	if ( (LastTouched != None) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
	{
		Victims = LastTouched;
		LastTouched = None;
		dirs = Victims.Location - HitLocation;
		dist = FMax(1,VSize(dirs));
		dirs = dirs/dist;
		damageScale = FMax(Victims.CollisionRadius/(Victims.CollisionRadius + Victims.CollisionHeight),1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius));
		if ( Instigator == None || Instigator.Controller == None )
			Victims.SetDelayedDamageInstigatorController(InstigatorController);
		Victims.TakeDamage
		(
			damageScale * DamageAmount,
			Instigator,
			Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dirs,
			(damageScale * Momentum * dirs),
			DamageType
		);
		if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
			Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
	}

	if( Role == ROLE_Authority )
	{
		if( NumKilled >= 4 )
		{
			KFGameType(Level.Game).DramaticEvent(0.05);
		}
		else if( NumKilled >= 2 )
		{
			KFGameType(Level.Game).DramaticEvent(0.03);
		}
	}

	bHurtEntry = false;
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{

    if( KFBulletWhipAttachment(Other) != none )
    {
        return;
    }

    // Don't allow hits on poeple on the same team
    if( KFHumanPawn(Other) != none && Instigator != none
        && KFHumanPawn(Other).PlayerReplicationInfo.Team.TeamIndex == Instigator.PlayerReplicationInfo.Team.TeamIndex )
    {
        return;
    }

	// more realistic interactions with karma objects.
	if (Other.IsA('NetKActor'))
		KAddImpulse(Velocity,HitLocation,);

	// Stop the grenade in its tracks if it hits an enemy.
	if ( !Other.bWorldGeometry && ((Other != Instigator && Other.Base != Instigator)|| bCanHitOwner) )
		Velocity = Vect(0,0,0);
}

simulated function Tick( float DeltaTime )
{
	if( bDud && Physics == PHYS_Falling )
	{
		SetRotation(Rotator(Normal(Velocity)));
	}
	if (LifeSpan != 0)
	{
		if (LifeSpan <= 20)
			{
			AmbientVolumeScale *= 0.9;
			}
		else
		{
		AmbientVolumeScale = default.AmbientVolumeScale;
		}
	}
}

simulated function Landed( vector HitNormal )
{
    HitWall( HitNormal, None );
}

defaultproperties
{
     ShakeRotMag=(X=600.000000,Y=600.000000,Z=600.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(X=5.000000,Y=10.000000,Z=5.000000)
     ShakeOffsetRate=(X=300.000000,Y=300.000000,Z=300.000000)
     ShakeOffsetTime=3.500000
     RotMag=(X=700.000000,Y=700.000000,Z=700.000000)
     RotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     RotTime=6.000000
     OffsetMag=(X=5.000000,Y=10.000000,Z=7.000000)
     OffsetRate=(X=300.000000,Y=300.000000,Z=300.000000)
     OffsetTime=3.500000
     ExplosionSound=Sound'KF_IJC_HalloweenSnd.Fire.KF_FlarePistol_Projectile_Hit'
     DisintegrateSound=Sound'Inf_Weapons.panzerfaust60.faust_explode_distant02'
     ImpactDamageType=Class'KFMod.DamTypeFlareProjectileImpact'
     ImpactDamage=10
     StaticMeshRef="Flare_R.FlareMeshThrown"
     ExplosionSoundRef="KF_IJC_HalloweenSnd.KF_FlarePistol_Projectile_Hit"
     AmbientSoundRef="KF_IJC_HalloweenSnd.KF_FlarePistol_Projectile_Loop"
     DisintegrateSoundRef="Inf_Weapons.faust_explode_distant02"
     FizzleTimer=160.000000
     DampenFactor=0.200000
     DampenFactorParallel=0.800000
     HeadShotDamageMult=1.500000
     FlameTrailEmitterClass=Class'Flares.FlareTrail'
     ExplosionSoundVolume=1.650000
     AmbientVolumeScale=2.500000
     bTrueBallistics=False
     Speed=1000.000000
     MaxSpeed=1500.000000
     Damage=10.000000
     DamageRadius=5.000000
     MomentumTransfer=125000.000000
     MyDamageType=Class'KFMod.DamTypeFlareRevolver'
     ImpactSound=SoundGroup'KF_GrenadeSnd.Nade_HitSurf'
     ExplosionDecal=Class'KFMod.FlameThrowerBurnMark_Medium'
     LightHue=25
     LightSaturation=100
     LightBrightness=250.000000
     LightRadius=10.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Flare_R.FlareMeshThrown'
     Physics=PHYS_Falling
     AmbientSound=Sound'KF_IJC_HalloweenSnd.Fire.KF_FlarePistol_Projectile_Loop'
     LifeSpan=140.000000
     DrawScale=0.400000
     AmbientGlow=254
     SoundVolume=255
     SoundRadius=250.000000
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     bNetNotify=True
     bBlockHitPointTraces=False
     bBounce=True
     bFixedRotationDir=True
     ForceRadius=300.000000
     ForceScale=10.000000
}
