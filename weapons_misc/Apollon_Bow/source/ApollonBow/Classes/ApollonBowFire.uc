class ApollonBowFire extends KFShotgunFire;

// sound
var 	sound                  AmbientChargeUpSound;           // The charging up of the weapon
var 	float                  AmbientFireSoundRadius;         // The sound radius for the ambient fire sound
var		sound                  AmbientFireSound;               // How loud to play the looping ambient fire sound
var		byte                   AmbientFireVolume;              // The ambient fire sound

var		string                 AmbientChargeUpSoundRef;
var		string                 AmbientFireSoundRef;

// Won't be used but keep anyway
var()   float                  MaxChargeTime;                   // The maximum amount of time for a full charged shot

var		name					FireAnimE;

// Probably not needed
// var() class<Projectile> WeakProjectileClass;
// var() class<Projectile> StrongProjectileClass;

static function PreloadAssets(LevelInfo LevelInfo, optional KFShotgunFire Spawned)
{
	super.PreloadAssets(LevelInfo, Spawned);

	if ( default.AmbientChargeUpSoundRef != "" )
	{
		default.AmbientChargeUpSound = sound(DynamicLoadObject(default.AmbientChargeUpSoundRef, class'sound', true));
	}

	if ( default.AmbientFireSoundRef != "" )
	{
		default.AmbientFireSound = sound(DynamicLoadObject(default.AmbientFireSoundRef, class'sound', true));
	}

	if ( ApollonBowFire(Spawned) != none )
	{
		ApollonBowFire(Spawned).AmbientChargeUpSound = default.AmbientChargeUpSound;
		ApollonBowFire(Spawned).AmbientFireSound = default.AmbientFireSound;
	}
}

static function bool UnloadAssets()
{
	super.UnloadAssets();

	default.AmbientChargeUpSound = none;
	default.AmbientFireSound = none;

	return true;
}

simulated function bool AllowFire()
{
	return (Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire);
}

function float MaxRange()
{
    return 2500;
}

// ALWAYS SHOOT ONE ARROW NO MATTER WHAT
function DoFireEffect()
{
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator R, Aim;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int p;
    local int SpawnCount;
    local float theta;

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();// + X*Instigator.CollisionRadius;
    StartProj = StartTrace + X*ProjSpawnOffset.X;
    if ( !Weapon.WeaponCentered() && !KFWeap.bAimingRifle )
	    StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;

    // check if projectile would spawn through a wall and adjust start location accordingly
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);

// Collision attachment debugging
 /*   if( Other.IsA('ROCollisionAttachment'))
    {
    	log(self$"'s trace hit "$Other.Base$" Collision attachment");
    }*/

    if (Other != None)
    {
        StartProj = HitLocation;
    }

    Aim = AdjustAim(StartProj, AimError);

    SpawnCount = 1;

    switch (SpreadStyle)
    {
    case SS_Random:
        X = Vector(Aim);
        for (p = 0; p < SpawnCount; p++)
        {
            R.Yaw = Spread * (FRand()-0.5);
            R.Pitch = Spread * (FRand()-0.5);
            R.Roll = Spread * (FRand()-0.5);
            SpawnProjectile(StartProj, Rotator(X >> R));
        }
        break;
    case SS_Line:
        for (p = 0; p < SpawnCount; p++)
        {
			// STRAIGHT!!!
			//X = Vector(Aim);
			
            theta = Spread*PI/32768*(p - float(SpawnCount-1)/2.0);
            X.X = Cos(theta);
            X.Y = Sin(theta);
            X.Z = 0.0;
            SpawnProjectile(StartProj, Aim);
        }
        break;
    default:
        SpawnProjectile(StartProj, Aim);
    }

	if (Instigator != none )
	{
        if( Instigator.Physics != PHYS_Falling  )
        {
            Instigator.AddVelocity(KickMomentum >> Instigator.GetViewRotation());
		}
		// Really boost the momentum for low grav
        else if( Instigator.Physics == PHYS_Falling
            && Instigator.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z)
        {
            Instigator.AddVelocity((KickMomentum * LowGravKickMomentumScale) >> Instigator.GetViewRotation());
        }
	}
}

function PlayPreFire()
{
	Weapon.PlayAnim('Charge', 1.0, 0.1);
}

function ModeHoldFire()
{
    // Play the chargeup sound
    // PlayAmbientSound(AmbientChargeUpSound);
    SetTimer(0.15, true);
}

// Handles toggling the weapon attachment's ambient sound on and off
/*
function PlayAmbientSound(Sound aSound)
{
	local WeaponAttachment WA;

	WA = WeaponAttachment(Weapon.ThirdPersonActor);

    if ( Weapon == none || (WA == none))
        return;

	if(aSound == None)
	{
		WA.SoundVolume = WA.default.SoundVolume;
		WA.SoundRadius = WA.default.SoundRadius;
	}
	else
	{
		WA.SoundVolume = AmbientFireVolume;
		WA.SoundRadius = AmbientFireSoundRadius;
	}

    WA.AmbientSound = aSound;
}
*/

function Timer()
{
    local float ChargeScale;

    if (HoldTime > 0.0 && !bNowWaiting)
    {
        if( HoldTime < MaxChargeTime )
            ChargeScale = HoldTime/MaxChargeTime;
    }
    else
        SetTimer(0, false);
}

/*
function PostSpawnProjectile(Projectile P)
{
    Super.PostSpawnProjectile(P);

    if( HoldTime < MaxChargeTime )
    {
        HuskGunProjectile(p).ImpactDamage *= HoldTime * 2.5;
        HuskGunProjectile(p).Damage *= (1.0 + (HoldTime/MaxChargeTime));// up to double damage
        HuskGunProjectile(p).DamageRadius *= (1.0 + (HoldTime/(MaxChargeTime/2.0)));// up 3x the damage radius
    }
    else
    {
        HuskGunProjectile(p).ImpactDamage *= MaxChargeTime * 2.5;
        HuskGunProjectile(p).Damage *= 2.0;// up to double damage
        HuskGunProjectile(p).DamageRadius *= 3.0;// up 3x the damage radius
    }
}
*/

// Handle setting new recoil
simulated function HandleRecoil(float Rec)
{
	local rotator NewRecoilRotation;
	local KFPlayerController KFPC;
	local KFPawn KFPwn;
	local vector AdjustedVelocity;
	local float AdjustedSpeed;

    if( Instigator != none )
    {
		KFPC = KFPlayerController(Instigator.Controller);
		KFPwn = KFPawn(Instigator);
	}

    if( KFPC == none || KFPwn == none )
    	return;

	if( !KFPC.bFreeCamera )
	{
      	NewRecoilRotation.Pitch = RandRange( maxVerticalRecoilAngle * 0.5, maxVerticalRecoilAngle );
     	NewRecoilRotation.Yaw = RandRange( maxHorizontalRecoilAngle * 0.5, maxHorizontalRecoilAngle );

      	if( Rand( 2 ) == 1 )
         	NewRecoilRotation.Yaw *= -1;

        if( Weapon.Owner != none && Weapon.Owner.Physics == PHYS_Falling &&
            Weapon.Owner.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z )
        {
            AdjustedVelocity = Weapon.Owner.Velocity;
            // Ignore Z velocity in low grav so we don't get massive recoil
            AdjustedVelocity.Z = 0;
            AdjustedSpeed = VSize(AdjustedVelocity);
            //log("AdjustedSpeed = "$AdjustedSpeed$" scale = "$(AdjustedSpeed* RecoilVelocityScale * 0.5));

            // Reduce the falling recoil in low grav
            NewRecoilRotation.Pitch += (AdjustedSpeed* 3 * 0.5);
    	    NewRecoilRotation.Yaw += (AdjustedSpeed* 3 * 0.5);
	    }
	    else
	    {
            //log("Velocity = "$VSize(Weapon.Owner.Velocity)$" scale = "$(VSize(Weapon.Owner.Velocity)* RecoilVelocityScale));
    	    NewRecoilRotation.Pitch += (VSize(Weapon.Owner.Velocity)* 3);
    	    NewRecoilRotation.Yaw += (VSize(Weapon.Owner.Velocity)* 3);
	    }

	    NewRecoilRotation.Pitch += (Instigator.HealthMax / Instigator.Health * 5);
	    NewRecoilRotation.Yaw += (Instigator.HealthMax / Instigator.Health * 5);
	    NewRecoilRotation *= Rec;

	    KFPC.SetRecoil(NewRecoilRotation,RecoilRate * (default.FireRate/FireRate));
 	}
}

function PlayFiring()
{
	if (KFWeapon(Weapon).AmmoAmount(0) > 0)
		FireAnim = default.FireAnim;
	else
		FireAnim = FireAnimE;
		
	super.PlayFiring();
}

event ModeDoFire()
{
	local float Rec;
	local float AmmoAmountToUse;

	if (!AllowFire())
		return;

	Spread = Default.Spread;
	Rec = 1;

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		Spread *= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.ModifyRecoilSpread(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self, Rec);
	}

	if( !bFiringDoesntAffectMovement )
	{
		if (FireRate > 0.25)
		{
			Instigator.Velocity.x *= 0.1;
			Instigator.Velocity.y *= 0.1;
		}
		else
		{
			Instigator.Velocity.x *= 0.5;
			Instigator.Velocity.y *= 0.5;
		}
	}

    if (!AllowFire())
        return;

    if (MaxHoldTime > 0.0)
        HoldTime = FMin(HoldTime, MaxHoldTime);

    // server
    if (Weapon.Role == ROLE_Authority)
    {
        AmmoAmountToUse = 1.0;
        Weapon.ConsumeAmmo(ThisModeNum, AmmoAmountToUse);


        DoFireEffect();
		HoldTime = 0;	// if bot decides to stop firing, HoldTime must be reset first
        if ( (Instigator == None) || (Instigator.Controller == None) )
			return;

        if ( AIController(Instigator.Controller) != None )
            AIController(Instigator.Controller).WeaponFireAgain(BotRefireRate, true);

        Instigator.DeactivateSpawnProtection();
    }

    // client
    if (Instigator.IsLocallyControlled())
    {
        ShakeView();
        PlayFiring();
        FlashMuzzleFlash();
        StartMuzzleSmoke();
    }
    else // server
    {
        ServerPlayFiring();
    }

    Weapon.IncrementFlashCount(ThisModeNum);

    // set the next firing time. must be careful here so client and server do not get out of sync
    if (bFireOnRelease)
    {
        if (bIsFiring)
            NextFireTime += MaxHoldTime + FireRate;
        else
            NextFireTime = Level.TimeSeconds + FireRate;
    }
    else
    {
        NextFireTime += FireRate;
        NextFireTime = FMax(NextFireTime, Level.TimeSeconds);
    }

    Load = AmmoPerFire;
    HoldTime = 0;

    if (Instigator.PendingWeapon != Weapon && Instigator.PendingWeapon != None)
    {
        bIsFiring = false;
        Weapon.PutDown();
    }

    // client
    if (Instigator.IsLocallyControlled())
    {
        HandleRecoil(Rec);
    }
}

defaultproperties
{
	FireAnimE=Fire_E
	
    bFireOnRelease=true
	
    FireAimedAnim=Fire
	
    KickMomentum=(X=0,y=0,Z=0)
    ProjPerFire=1
    TransientSoundVolume=2.0
    TransientSoundRadius=500.000000
    FireSound=Sound'ApollonBow.abow_fire'
    StereoFireSound=Sound'ApollonBow.abow_fire'
    AmbientFireSound=none
    AmbientChargeUpSound=none
    NoAmmoSound=Sound'KF_XbowSnd.Xbow_DryFire'
    AmbientFireSoundRadius=500
    AmbientFireVolume=255
    FireForce="AssaultRifleFire"
    FireRate=0.75
    AmmoClass=Class'ApollonBow.ApollonAmmo'
    ProjectileClass=Class'ApollonBow.ApollonArrow'

    BotRefireRate=1.800000
    aimerror=0.000000
    Spread=0.0001
    SpreadStyle=SS_Line
    ProjSpawnOffset=(X=50,Y=5,Z=-10)
    FlashEmitterClass=None
    MaxChargeTime=3.0

    EffectiveRange=5000.000000
    maxVerticalRecoilAngle=200
    maxHorizontalRecoilAngle=50
    bWaitForRelease=true
	
	AmmoPerFire=1

    //** View shake **//
    ShakeOffsetMag=(X=3.000000,Y=3.000000,Z=3.000000)
    ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
    ShakeRotMag=(X=3.000000,Y=4.000000,Z=2.000000)
    bRandomPitchFireSound=true
}
