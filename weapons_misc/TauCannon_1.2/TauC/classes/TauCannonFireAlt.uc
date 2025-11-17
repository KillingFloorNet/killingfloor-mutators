class TauCannonFireAlt extends KFShotgunFire;

var 	sound                  AmbientSpinUpSound;           // The charging up of the weapon
var 	float                  AmbientWarningSoundRadius;         // The sound radius for the ambient fire sound
var		sound                  AmbientWarningSound;               // How loud to play the looping ambient fire sound
var		byte                   AmbientFireVolume;              // The ambient fire sound

var		string                 AmbientSpinUpSoundRef;
var		string                 AmbientWarningSoundRef;
var		string                 AmbientExplodeSoundRef;
var() Sound		AmbientExplodeSound;

var()   float	MaxChargeTime;
var() class<Projectile> WeakProjectileClass;
var() class<Projectile> StrongProjectileClass;
var() class<Projectile> OverSplosionProjectileClass;

var() class<Emitter> ChargeEmitterClass;
var() class<Emitter> OverChargeEmitterClass;
var() Emitter ChargeEmitter;
var() Emitter OverChargeEmitter;
var() Emitter BeamEmitter;

var byte OverSplosion; //You've overcharged it, now pay the consequences
var   byte	AmmoAmountToUse; //need to replicate this on server?

static function PreloadAssets(LevelInfo LevelInfo, optional KFShotgunFire Spawned)
{
	super.PreloadAssets(LevelInfo, Spawned);
	if ( default.FireSoundRef != "" )
	{
		default.FireSound = sound(DynamicLoadObject(default.FireSoundRef, class'Sound', true));
	}

	if ( LevelInfo.bLowSoundDetail || (default.StereoFireSoundRef == "" && default.StereoFireSound == none) )
	{
		default.StereoFireSound = default.FireSound;
	}
	else
	{
		default.StereoFireSound = sound(DynamicLoadObject(default.StereoFireSoundRef, class'Sound', true));
	}

	if ( default.NoAmmoSoundRef != "" )
	{
		default.NoAmmoSound = sound(DynamicLoadObject(default.NoAmmoSoundRef, class'Sound', true));
	}

	if ( Spawned != none )
	{
		Spawned.FireSound = default.FireSound;
		Spawned.StereoFireSound = default.StereoFireSound;
		Spawned.NoAmmoSound = default.NoAmmoSound;
	}

	//above from parent KFFire, below from original

	if ( default.AmbientSpinUpSoundRef != "" )
	{
		default.AmbientSpinUpSound = sound(DynamicLoadObject(default.AmbientSpinUpSoundRef, class'sound', true));
	}

	if ( default.AmbientWarningSoundRef != "" )
	{
		default.AmbientWarningSound = sound(DynamicLoadObject(default.AmbientWarningSoundRef, class'sound', true));
	}
	
		if ( default.AmbientExplodeSoundRef != "" )
	{
		default.AmbientExplodeSound = sound(DynamicLoadObject(default.AmbientExplodeSoundRef, class'sound', true));
	}

	if ( TauCannonFireAlt(Spawned) != none )
	{
		TauCannonFireAlt(Spawned).FireSound = default.FireSound;
		TauCannonFireAlt(Spawned).StereoFireSound = default.StereoFireSound;
		TauCannonFireAlt(Spawned).NoAmmoSound = default.NoAmmoSound;
		TauCannonFireAlt(Spawned).AmbientSpinUpSound = default.AmbientSpinUpSound;
		TauCannonFireAlt(Spawned).AmbientWarningSound = default.AmbientWarningSound;
		TauCannonFireAlt(Spawned).AmbientExplodeSound = default.AmbientExplodeSound;
	}
}

static function bool UnloadAssets()
{
	super.UnloadAssets();

	default.AmbientSpinUpSound = none;
	default.AmbientWarningSound = none;
	default.AmbientExplodeSound = none;

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

function DoFireEffect()
{
   Super(KFShotgunFire).DoFireEffect();
}

function PlayPreFire()
{
	if( KFWeapon(Weapon).bAimingRifle )
	{
		Weapon.PlayAnim('Charge_Iron_NR', 1.0, 0.1);
	}
	else
	{
		Weapon.PlayAnim('Charge_NR', 1.0, 0.1);
	}
}

function ModeHoldFire()
{
    // Play the chargeup sound
    PlayAmbientSound(AmbientSpinUpSound);
    InitChargeEffect();
    SetTimer(0.25, true); //Originally 0.15, but we want it to go every quarter-second
}

// Handles toggling the weapon attachment's ambient sound on and off
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
		WA.SoundRadius = AmbientWarningSoundRadius;
	}

    WA.AmbientSound = aSound;
}

function Timer()
{
    local float ChargeScale;
    local float OverChargeScale;
	local TauCannonAttachment WA;

	WA = TauCannonAttachment(Weapon.ThirdPersonActor);
	
    if (HoldTime > 0.0 && !bNowWaiting)
    {
		if(HoldTime < MaxChargeTime)
		{
			PlayAmbientSound(AmbientSpinUpSound);
			
			if((AmmoAmountToUse <=19) && (KFWeapon(Weapon).MagAmmoRemaining > 1) )
			{
				AmmoAmountToUse += 1;
				Weapon.ConsumeAmmo(ThisModeNum, 1);
			}
		}
        else
        {
            PlayAmbientSound(AmbientWarningSound);
        }
		
		// Change the damage, firing sound, and tracer size according to the charge time
		if( AmmoAmountToUse <= 3)
		{
			FireSound=Sound'TC_R.FireUnder';
			StereoFireSound=Sound'TC_R.FireUnder';
		}
		else if( AmmoAmountToUse <= 10)
		{
			FireSound=default.FireSound;
			StereoFireSound=default.StereoFireSound;
		}
		else if( AmmoAmountToUse <=15)
		{
			FireSound=default.FireSound;
			StereoFireSound=default.StereoFireSound;
		}
		else
		{
			FireSound=SoundGroup'TC_R.FireOver';
			StereoFireSound=SoundGroup'TC_R.FireOver';
		}	

		// in danger of overcharging the weapon, start up the other emitter
		if (HoldTime >= MaxChargeTime)
		{
			InitOverChargeEffect();
		}
	
		// overcharged, now it fries the user
        if( HoldTime >= (MaxChargeTime + (3 + (FRand() * 5))))
        //if( HoldTime >= (MaxChargeTime + 7))
		//originally 7 seconds, but we want it to explode at random 3.5 to 8 seconds after maxing out
		//NOTE- the random part is recalculated EACH TICK, so you'd be lucky to reach 8 seconds, but it is still 'possible'.
		{
			Weapon.PlayOwnedSound(AmbientExplodeSound,SLOT_None,2.0,,,,false);
			DestroyChargeEffect();
			DestroyOverChargeEffect();
			WA.TauCannonCharge = 0;
			WA.UpdateTauCannonCharge();

			SetTimer(0, false);
			OverSplosion = 1;
			KFGameType(Level.Game).DramaticEvent(1);
			KFPawn(Instigator).TakeDamage(500, None, KFPawn(Instigator).Location, vect(0,0,0), class'DamTypeTauExplode');
			
			//PUT CODE HERE to make it not fire when overcharged!
			//PUT CODE HERE to make it explode on everyone around - grenade code maybe?
		}
		
		OverChargeScale = (HoldTime-5)/MaxChargeTime;
		ChargeScale = (HoldTime-5)/MaxChargeTime;
		WA.TauCannonCharge = ChargeScale * 255; //255 is too big?
		WA.UpdateTauCannonCharge();
		if( ChargeEmitter != none )
		{
			ChargeEmitter.Emitters[0].StartVelocityRadialRange.Min = Lerp( ChargeScale, 50, 300 );
			ChargeEmitter.Emitters[0].StartVelocityRadialRange.Max = Lerp( ChargeScale, 50, 300 );
			ChargeEmitter.Emitters[0].SizeScale[0].RelativeSize = Lerp( ChargeScale, 2, 6 );
		}
		if( OverChargeEmitter != none )
		{
			OverChargeEmitter.Emitters[0].SizeScale[1].RelativeSize = Lerp( OverChargeScale, 4, 10 );
			OverChargeEmitter.Emitters[1].StartVelocityRadialRange.Min = Lerp( OverChargeScale, 50, 300 );
			OverChargeEmitter.Emitters[1].StartVelocityRadialRange.Max = Lerp( OverChargeScale, 50, 300 );
			OverChargeEmitter.Emitters[1].SizeScale[0].RelativeSize = Lerp( OverChargeScale, 2, 6 );
		}
    }
    else
    {
        PlayAmbientSound(none);
        DestroyChargeEffect();
        DestroyOverChargeEffect();
        WA.TauCannonCharge = 0;
        WA.UpdateTauCannonCharge();

        SetTimer(0, false);
    }
}

function class<Projectile> GetDesiredProjectileClass()
{
	if (OverSplosion != 1)
	{
		if( AmmoAmountToUse <= 3)
		{
			return WeakProjectileClass;
		}
		else if( AmmoAmountToUse <=15)
		{
			return default.ProjectileClass;
		}
		else
		{
			return StrongProjectileClass;
		}
	}
	else
	{
	return OverSplosionProjectileClass;
	}
}

function PostSpawnProjectile(Projectile P)
{
    Super.PostSpawnProjectile(P);

	if( AmmoAmountToUse <= 3)
    {
        //TauBulletWeak(p).ImpactDamage = (100 * (0.75 * AmmoAmountToUse));
        TauBulletWeak(p).Damage = (90 * (0.75 * AmmoAmountToUse));
        //TauBulletWeak(p).DamageRadius = (0.75 * AmmoAmountToUse);
    }
	else if( AmmoAmountToUse <=10)
	{
        //TauBullet(p).ImpactDamage = (100 * (0.75 * AmmoAmountToUse));
        TauBullet(p).Damage = (90 * (0.75 * AmmoAmountToUse));
        //TauBullet(p).DamageRadius = (1.0 * AmmoAmountToUse);
    }
	else if( AmmoAmountToUse <=15)
	{
        //TauBullet(p).ImpactDamage = (100 * (1.3 * AmmoAmountToUse));
        TauBullet(p).Damage = (90 * (1.3 * AmmoAmountToUse));
        //TauBullet(p).DamageRadius = (1.3 * AmmoAmountToUse);
    }
    else
    {
        //TauBulletStrong(p).ImpactDamage = (100 * (1.6 * AmmoAmountToUse));
        TauBulletStrong(p).Damage = (90 * (1.6 * AmmoAmountToUse));
        //TauBulletStrong(p).DamageRadius = (1.6 * AmmoAmountToUse);
    }
	AmmoAmountToUse = 0;
}

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

            // Reduce the falling recoil in low grav
            NewRecoilRotation.Pitch += (AdjustedSpeed* 3 * 0.5);
    	    NewRecoilRotation.Yaw += (AdjustedSpeed* 3 * 0.5);
	    }
	    else
	    {
    	    NewRecoilRotation.Pitch += (VSize(Weapon.Owner.Velocity)* 3);
    	    NewRecoilRotation.Yaw += (VSize(Weapon.Owner.Velocity)* 3);
	    }

	    NewRecoilRotation.Pitch += (Instigator.HealthMax / Instigator.Health * 5);
	    NewRecoilRotation.Yaw += (Instigator.HealthMax / Instigator.Health * 5);
	    NewRecoilRotation *= Rec;

	    KFPC.SetRecoil(NewRecoilRotation,RecoilRate * (default.FireRate/FireRate));
 	}
}

event ModeDoFire()
{
	local float Rec;

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

	//AmmoAmountToUse = 0;
		
    // server
    if (Weapon.Role == ROLE_Authority)
    {
		Weapon.ConsumeAmmo(ThisModeNum, 1);
		
        DoFireEffect();
		HoldTime = 0;
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

simulated function InitChargeEffect()
{
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;

    if ( (ChargeEmitterClass != None) && ((ChargeEmitter == None) || ChargeEmitter.bDeleteMe) )
    {
        ChargeEmitter = Weapon.Spawn(ChargeEmitterClass);
        if ( ChargeEmitter != None )
    		Weapon.AttachToBone(ChargeEmitter, 'tip');
    }
}

simulated function InitOverChargeEffect()
{
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;

	if ( (OverChargeEmitterClass != None) && ((OverChargeEmitter == None) || OverChargeEmitter.bDeleteMe) )
	{
		OverChargeEmitter = Weapon.Spawn(OverChargeEmitterClass);
		if ( OverChargeEmitter != None )
			Weapon.AttachToBone(OverChargeEmitter, 'Coil');
	}
}

simulated function DestroyChargeEffect()
{
    if (ChargeEmitter != None)
        ChargeEmitter.Destroy();
}

simulated function DestroyOverChargeEffect()
{		
    if (OverChargeEmitter != None)
        OverChargeEmitter.Destroy();
}

simulated function DestroyEffects()
{
    super.DestroyEffects();

    DestroyChargeEffect();
    DestroyOverChargeEffect();
}

defaultproperties
{
	aimerror=42.000000
	AmbientExplodeSound=Sound'TC_R.ChargeExplode'
	AmbientExplodeSoundRef="TC_R.ChargeExplode"
	AmbientFireVolume=255
	AmbientSpinUpSound=Sound'TC_R.Spinup'
	AmbientSpinUpSoundRef="TC_R.Spinup"
	AmbientWarningSound=Sound'TC_R.ChargeWarning'
	AmbientWarningSoundRadius=500
	AmbientWarningSoundRef="TC_R.ChargeWarning"
	AmmoClass=Class'TauC.TauCannonAmmo'
	AmmoPerFire=1
	bFireOnRelease=true
	BotRefireRate=0.990000
	bPawnRapidFireAnim=False
	bWaitForRelease=true 
	ChargeEmitterClass=Class'TauC.TauChargeNormal'
	FireAimedAnim=Fire_Iron
	FireAnim=Fire_NR
	FireForce="AssaultRifleFire"
	FireRate=0.75
	FireSound=SoundGroup'TC_R.Fire'
	FireSoundRef="TC_R.Fire"
	FlashEmitterClass=Class'TauC.TauCannonMuzzleFlash'
	KickMomentum=(X=0,y=0,Z=0)
	MaxChargeTime=5
	maxHorizontalRecoilAngle=250
	maxVerticalRecoilAngle=1500
	NoAmmoSound=Sound'TC_R.Fizzle'
	NoAmmoSoundRef="TC_R.Fizzle"
	OverChargeEmitterClass=Class'TauC.TauChargeOver'
	ProjectileClass=Class'TauC.TauBullet'
    WeakProjectileClass=Class'TauC.TauBulletWeak'
    StrongProjectileClass=Class'TauC.TauBulletStrong'
    OverSplosionProjectileClass=Class'TauC.TauBulletOver'
	ProjPerFire=1
	ProjSpawnOffset=(X=50,Y=10,Z=-20)
	RecoilRate=0.12
	Spread=0.015
	SpreadStyle=SS_Random
	StereoFireSound=SoundGroup'TC_R.Fire'
	StereoFireSoundRef="TC_R.Fire"
	TransientSoundRadius=500.000000
	TransientSoundVolume=2.0
	TweenTime=0.025
	
    //** View shake **//
    ShakeOffsetMag=(X=10.0,Y=3.0,Z=12.0)
    ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
    ShakeOffsetTime=2.0
    ShakeRotMag=(X=100.0,Y=100.0,Z=500.0)
    ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
    ShakeRotTime=2.0
}
