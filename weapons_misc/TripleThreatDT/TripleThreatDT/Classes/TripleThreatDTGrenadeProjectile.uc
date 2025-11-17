//=============================================================================
// SPGrenadeProjectile
//=============================================================================
// Steampunk Grenade launcher bombs
//=============================================================================
// Killing Floor Source
// Copyright (C) 2013 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class TripleThreatDTGrenadeProjectile extends ROBallisticProjectile;

#exec OBJ LOAD FILE=WeaponSounds.uax
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

var     class<Emitter>      SmokeTrailEmitterClass;// Emitter class for the smoke trail/fuze sparks
var     Emitter             SmokeTrail;
var     class<Emitter>      ExplosionEmitterClass;// Emitter class for the explosion

var()   sound               ExplosionSound;     // The sound of the rocket exploding

var     bool                bDisintegrated;     // This nade has been disintegrated by a siren scream.
var()   sound               DisintegrateSound;  // The sound of this projectile disintegrating
//var     bool                bKillMomentum;      // Kill the momentum of this projectile because it hit before arming
var()   float               ArmDistSquared;     // Distance this rocket arms itself at
var     class<DamageType>	ImpactDamageType;   // Damagetype of this rocket hitting something, but not exploding
var     int                 ImpactDamage;       // How much damage to do if this rocket impacts something without exploding

var     bool                bHasExploded;       // Has done the explosion
var     float               ExplodeTimer;       // How long this bomb will wait to explode
var() float DampenFactor, DampenFactorParallel; // How much to dampen the velocity of the bomb with each bounce

var		string	StaticMeshRef;
var		string	ExplosionSoundRef;
var		string	DisintegrateSoundRef;
var		string	ImpactSoundRef;
var		string	AmbientSoundRef;

var class<xEmitter> HitEffectClass;
var float LastSparkTime;
var AvoidMarker Fear;

/*
static function PreloadAssets()
{
	default.ExplosionSound = sound(DynamicLoadObject(default.ExplosionSoundRef, class'Sound', true));
	default.DisintegrateSound = sound(DynamicLoadObject(default.DisintegrateSoundRef, class'Sound', true));
	default.ImpactSound = sound(DynamicLoadObject(default.ImpactSoundRef, class'Sound', true));
	default.AmbientSound = sound(DynamicLoadObject(default.AmbientSoundRef, class'Sound', true));

	UpdateDefaultStaticMesh(StaticMesh(DynamicLoadObject(default.StaticMeshRef, class'StaticMesh', true)));
}

static function bool UnloadAssets()
{
	default.ExplosionSound = none;
	default.DisintegrateSound = none;
	default.ImpactSound = none;
	default.AmbientSound = none;

	UpdateDefaultStaticMesh(none);

	return true;
}
*/
simulated function PostNetReceive()
{
    if( bHidden && !bDisintegrated )
    {
        Disintegrate(Location, vect(0,0,1));
    }
}

function Timer()
{
    if( !bHidden )
    {
        Explode(Location, vect(0,0,1));
    }
    else
    {
        Destroy();
    }
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

// Overridden to tweak the handling of the impact sound
simulated function HitWall( vector HitNormal, actor Wall )
{
    local Vector VNorm;
	local PlayerController PC;

	if ( (Pawn(Wall) != None) || (GameObjective(Wall) != None) )
	{
		Explode(Location, HitNormal);
		return;
	}
/*
    if (!bTimerSet)
    {
        SetTimer(ExplodeTimer, false);
        bTimerSet = true;
    }
*/
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

		if( Fear == none )
		{
		    Fear = Spawn(class'AvoidMarker');
    		Fear.SetCollisionSize(DamageRadius,DamageRadius);
    		Fear.StartleBots();
		}

    //    if ( Trail != None )
    //        Trail.mRegen = false; // stop the emitter from regenerating
    }
    else
    {
		if ( (Level.NetMode != NM_DedicatedServer) && (Speed > 50) )
			PlaySound(ImpactSound, SLOT_Misc );
		else
		{
			bFixedRotationDir = false;
			bRotateToDesired = true;
			DesiredRotation.Pitch = 0;
			RotationRate.Pitch = 50000;
		}
        if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) && (Level.TimeSeconds - LastSparkTime > 0.5) && EffectIsRelevant(Location,false) )
        {
			PC = Level.GetLocalPlayerController();
			if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 6000 )
				Spawn(HitEffectClass,,, Location, Rotator(HitNormal));
            LastSparkTime = Level.TimeSeconds;
        }
    }
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local Controller C;
    local PlayerController  LocalPlayer;

    bHasExploded = True;

    PlaySound(ExplosionSound,,2.0);
    if ( EffectIsRelevant(Location,false) )
    {
        Spawn(ExplosionEmitterClass,,,HitLocation + HitNormal*20,rotator(HitNormal));
        Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }

    BlowUp(HitLocation);
    Destroy();

    // Shake nearby players screens
    LocalPlayer = Level.GetLocalPlayerController();
    if ( (LocalPlayer != None) && (VSize(Location - LocalPlayer.ViewTarget.Location) < DamageRadius) )
        LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);

    for ( C=Level.ControllerList; C!=None; C=C.NextController )
        if ( (PlayerController(C) != None) && (C != LocalPlayer)
            && (VSize(Location - PlayerController(C).ViewTarget.Location) < DamageRadius) )
            C.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);
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
    OrigLoc = Location;

    if (PhysicsVolume.bWaterVolume)
    {
        Velocity=0.6*Velocity;
    }
			
	if ( Role == ROLE_Authority )
	{
		Velocity = Speed * Vector(Rotation);
		RandSpin(35000);
	}
    super(Projectile).PostBeginPlay();

    SetTimer(ExplodeTimer + 0.5*FRand(), false);
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	if (damageType == default.MyDamageType)
		return;
	
    if( damageType == class'SirenScreamDamage')
    {
        Disintegrate(HitLocation, vect(0,0,1));
    }
    else
    {
        Explode(HitLocation, vect(0,0,0));
    }
}

simulated function Destroyed()
{
	if ( Fear != None )
		Fear.Destroy();
	if( !bHasExploded && !bHidden )
		Explode(Location,vect(0,0,1));
	if( bHidden && !bDisintegrated )
        Disintegrate(Location,vect(0,0,1));

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
//    local vector Other2dLocation, TwoDLocation;
//    local float DistToOtherCenter;
//    local bool bHitIsCloseToCenter;

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

     // Failed attempt at making nades only stop if they are close to the center of the
     // collision. When I have more time, try and do a closest point along the ray test - Ramm
//    if ( !Other.bWorldGeometry && Other != Instigator )
//    {
//        Other2dLocation = Other.Location;
//        Other2dLocation.Z = 0;
//        TwoDLocation = Location;
//        TwoDLocation.Z = 0;
//        DistToOtherCenter = VSize(Other2dLocation - TwoDLocation);
//        bHitIsCloseToCenter = DistToOtherCenter < Other.CollisionRadius/2.0;
//        log("DistToOtherCenter = "$DistToOtherCenter$" Other.CollisionRadius/2.0 "$Other.CollisionRadius/2.0 );
//    }

	// Stop the grenade in its tracks if it hits an enemy.
	if ( !Other.bWorldGeometry && (Other != Instigator && Other.Base != Instigator))
		Velocity = Vect(0,0,0);
}

simulated function Tick( float DeltaTime )
{
    SetRotation(Rotator(Normal(Velocity)));
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
    // SmokeTrailEmitterClass=Class'TripleThreatDTGrenadeTrail'
     ExplosionEmitterClass=Class'TripleThreatDTGrenadeExplosion'
     ArmDistSquared=90000.000000
     ImpactDamageType=Class'TripleThreatDTDamTypeGrenadeImpact'
     ImpactDamage=200
     ExplodeTimer=2.000000
     DampenFactor=0.500000
     DampenFactorParallel=0.800000
     StaticMesh=StaticMesh'TripleThreatDT_A.TripleThreatDT_SM.TripleThreatGrenade_sm'
     ExplosionSound=SoundGroup'TripleThreatDT_A.TripleThreatDT_SND.Expode_sgp'
     DisintegrateSound=Sound'Inf_Weapons.faust_explode_distant02'
     ImpactSound=Sound'KF_GrenadeSnd.Nade_HitSurf'
     AmbientSound=None //Sound'KF_IJC_HalloweenSnd.KF_FlarePistol_Projectile_Loop'
     AmbientVolumeScale=2.000000
     bTrueBallistics=False
     bInitialAcceleration=False
     Speed=1000.000000
     MaxSpeed=1500.000000
     TossZ=150.000000
     Damage=355.000000
     DamageRadius=350.000000
     MomentumTransfer=75000.000000
     MyDamageType=Class'TripleThreatDTDamTypeGrenade'
     ExplosionDecal=Class'KFMod.FlameThrowerBurnMark_Large'
     DrawType=DT_StaticMesh
     bNetTemporary=False
     bUpdateSimulatedPosition=True
     Physics=PHYS_Falling
     LifeSpan=10.000000
     DrawScale=0.500000
     bUnlit=False
     SoundVolume=255
     SoundRadius=250.000000
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     bNetNotify=True
     bBlockHitPointTraces=False
     bBounce=True
     ForceRadius=300.000000
     ForceScale=10.000000
}
