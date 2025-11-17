class AA12DWFireAlt extends KFShotgunFire;

//Insert dual-wielding code from 9mm

var()           class<Emitter>  ShellEjectClass;            // class of the shell eject emitter
var()           Emitter         ShellEjectEmitter;          // The shell eject emitter
var()           name            ShellEjectBoneName;         // name of the shell eject bone

//From DualiesFire.uc
var() Emitter Flash2Emitter;
var()           Emitter         ShellEject2Emitter;          // The shell eject emitter
var()           name            ShellEject2BoneName;         // name of the shell eject bone

//From DualFlareRevolverFire.uc
var() vector SightedProjSpawnOffset;
//End Additions

//Variation of KFShotgunFire's recoil handling so alt-fire now has recoil
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
    	//if( Weapon.GetFireMode(0).bIsFiring)
    	if( Weapon.GetFireMode(0).bIsFiring || Weapon.GetFireMode(1).bIsFiring)
    	{
          	NewRecoilRotation.Pitch = RandRange( maxVerticalRecoilAngle * 0.5, maxVerticalRecoilAngle );
         	NewRecoilRotation.Yaw = RandRange( maxHorizontalRecoilAngle * 0.5, maxHorizontalRecoilAngle );

          	if( Rand( 2 ) == 1 )
             	NewRecoilRotation.Yaw *= -1;

            if( Weapon.Owner != none && Weapon.Owner.Physics == PHYS_Falling &&
                Weapon.Owner.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z )
            {
                AdjustedVelocity = Weapon.Owner.Velocity;
                AdjustedVelocity.Z = 0;
                AdjustedSpeed = VSize(AdjustedVelocity);

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
}

simulated function bool AllowFire()
{
	if(KFWeapon(Weapon).bIsReloading)
		return false;
	if(KFPawn(Instigator).SecondaryItem!=none)
		return false;
	if(KFPawn(Instigator).bThrowingNade)
		return false;

	if(KFWeapon(Weapon).MagAmmoRemaining < 2)
	{
    	if( Level.TimeSeconds - LastClickTime>FireRate )
    	{
    		LastClickTime = Level.TimeSeconds;
    	}

		if( AIController(Instigator.Controller)!=None )
			KFWeapon(Weapon).ReloadMeNow();
		return false;
	}

	return super(WeaponFire).AllowFire();
}

simulated function InitEffects()
{
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
        return;
    if ( (FlashEmitterClass != None) && ((FlashEmitter == None) || FlashEmitter.bDeleteMe) )
    {
        FlashEmitter = Weapon.Spawn(FlashEmitterClass);
        Weapon.AttachToBone(FlashEmitter, KFWeapon(Weapon).default.FlashBoneName);
    }
    if ( (FlashEmitterClass != None) && ((Flash2Emitter == None) || Flash2Emitter.bDeleteMe) )
    {
        Flash2Emitter = Weapon.Spawn(FlashEmitterClass);
        Weapon.AttachToBone(Flash2Emitter, AA12DWAutoShotgun(Weapon).default.altFlashBoneName);
    }

    if ( (SmokeEmitterClass != None) && ((SmokeEmitter == None) || SmokeEmitter.bDeleteMe) )
    {
        SmokeEmitter = Weapon.Spawn(SmokeEmitterClass);
    }

    if ( (ShellEjectClass != None) && ((ShellEjectEmitter == None) || ShellEjectEmitter.bDeleteMe) )
    {
        ShellEjectEmitter = Weapon.Spawn(ShellEjectClass);
        Weapon.AttachToBone(ShellEjectEmitter, ShellEjectBoneName);
    }

    if ( (ShellEjectClass != None) && ((ShellEject2Emitter == None) || ShellEject2Emitter.bDeleteMe) )
    {
        ShellEject2Emitter = Weapon.Spawn(ShellEjectClass);
        Weapon.AttachToBone(ShellEject2Emitter, ShellEject2BoneName);
    }
}

function DrawMuzzleFlash(Canvas Canvas)
{
    super.DrawMuzzleFlash(Canvas);
	//Overruled by DualiesFire.uc version
    if (ShellEject2Emitter != None )
    {
        Canvas.DrawActor( ShellEject2Emitter, false, false, Weapon.DisplayFOV );
    }
}


function FlashMuzzleFlash()
{
	//Overruled by DualiesFire.uc version
    if (Flash2Emitter == none || FlashEmitter == none)
        return;

	Flash2Emitter.Trigger(Weapon, Instigator);
	if (ShellEject2Emitter != None)
	{
		ShellEject2Emitter.Trigger(Weapon, Instigator);
	}

	FlashEmitter.Trigger(Weapon, Instigator);
	if (ShellEjectEmitter != None)
	{
		ShellEjectEmitter.Trigger(Weapon, Instigator);
	}
}

simulated function DestroyEffects()
{
    super.DestroyEffects();

    if (ShellEjectEmitter != None)
        ShellEjectEmitter.Destroy();

	//From DualiesFire.uc
    if (ShellEject2Emitter != None)
        ShellEject2Emitter.Destroy();

    if (Flash2Emitter != None)
        Flash2Emitter.Destroy();
}

function DoFireEffect()
{
    local Vector StartProj, Start2Proj, StartTrace, X,Y,Z;
    local Rotator R, AimR, AimL;
    local Vector HitLocation, HitNormal;
    local Actor Other;
    local int p;
    local int SpawnCount;
    local float theta;

    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X,Y,Z);

    StartTrace = Instigator.Location + Instigator.EyePosition();

	// From DualFlareRevolverFire.uc
    if( KFWeap.bAimingRifle )
    {
        StartProj = StartTrace + X*SightedProjSpawnOffset.X;
        Start2Proj = StartProj + -1 * Y*SightedProjSpawnOffset.Y + Z*SightedProjSpawnOffset.Z;
        StartProj = StartProj + Weapon.Hand * Y*SightedProjSpawnOffset.Y + Z*SightedProjSpawnOffset.Z;
	}
	else
	{
        StartProj = StartTrace + X*ProjSpawnOffset.X;
		Start2Proj = StartProj + -1 * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;
		StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;
	}	
	//End Addition

    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);

    if (Other != None)
    {
        StartProj = HitLocation;
        Start2Proj = HitLocation;
    }

    AimR = AdjustAim(StartProj, AimError);
    AimL = AdjustAim(Start2Proj, AimError);

	//From KFMod.ZEDMKIIAltFire
	SpawnCount = ProjPerFire;

    switch (SpreadStyle)
    {
    case SS_Random:
        X = Vector(AimR);
        for (p = 0; p < SpawnCount; p++)
        {
            R.Yaw = Spread * (FRand()-0.5);
            R.Pitch = Spread * (FRand()-0.5);
            R.Roll = Spread * (FRand()-0.5);
            SpawnProjectile(StartProj, Rotator(X >> R));
        }
		X = Vector(AimL);
        for (p = 0; p < SpawnCount; p++)
        {
            R.Yaw = Spread * (FRand()-0.5);
            R.Pitch = Spread * (FRand()-0.5);
            R.Roll = Spread * (FRand()-0.5);
            SpawnProjectile(Start2Proj, Rotator(X >> R));
        }
        break;
    case SS_Line:
        for (p = 0; p < SpawnCount; p++)
        {
            theta = Spread*PI/32768*(p - float(SpawnCount-1)/2.0);
            X.X = Cos(theta);
            X.Y = Sin(theta);
            X.Z = 0.0;
            SpawnProjectile(StartProj, Rotator(X >> AimR));
        }
        break;
    default:
        SpawnProjectile(StartProj, AimR);
    }

	if (Instigator != none )
	{
        if( Instigator.Physics == PHYS_Falling
            && Instigator.PhysicsVolume.Gravity.Z > class'PhysicsVolume'.default.Gravity.Z)
        {
            Instigator.AddVelocity((KickMomentum * 10.0) >> Instigator.GetViewRotation());
        }
	}
}

// Copied from DualiesFire.uc
event ModeDoFire()
{
	Super.ModeDoFire();
	
	InitEffects();
	if (AA12DWAutoShotgun(Weapon).MagAmmoRemaining <= 0)
	{
		AA12DWAutoShotgun(Weapon).Notify_HideShells();
	}
}

defaultproperties
{
    ShellEjectClass=Class'AA12ShellEject'
    ShellEjectBoneName="Shell_eject"
    ShellEject2BoneName="LShell_eject"
    SightedProjSpawnOffset=(X=25.000000,Y=5.000000,Z=-6.000000)
    KickMomentum=(X=-35.000000,Z=5.000000)
    maxVerticalRecoilAngle=2000
    maxHorizontalRecoilAngle=500
    FireAimedAnim="BothFire_Iron"
    StereoFireSound=SoundGroup'AA12DW_R.BothFireGroup'
    bRandomPitchFireSound=False
    FireSoundRef="AA12DW_R.BothFireGroup"
    StereoFireSoundRef="AA12DW_R.BothFireGroup"
    NoAmmoSoundRef="KF_AA12Snd.AA12_DryFire"
    ProjPerFire=5
    ProjSpawnOffset=(Y=15.000000)
    bAttachSmokeEmitter=True
    TransientSoundVolume=2.000000
    TransientSoundRadius=500.000000
    FireAnim="BothFire"
    FireLoopAnim=
    FireSound=SoundGroup'AA12DW_R.BothFireGroup'
    NoAmmoSound=Sound'KF_AA12Snd.AA12_DryFire'
    FireRate=0.200000
    AmmoClass=Class'AA12DWAmmo'
    AmmoPerFire=2
    ShakeRotMag=(X=50.000000,Y=50.000000,Z=250.000000)
    ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
    ShakeRotTime=3.000000
    ShakeOffsetMag=(X=6.000000,Y=2.000000,Z=6.000000)
    ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
    ShakeOffsetTime=1.250000
    ProjectileClass=Class'AA12DWBullet'
    BotRefireRate=0.250000
    FlashEmitterClass=Class'ROEffects.MuzzleFlash1stKar'
    aimerror=1.000000
    Spread=1125.000000
}
