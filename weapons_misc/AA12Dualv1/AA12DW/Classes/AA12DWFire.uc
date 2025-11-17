class AA12DWFire extends KFShotgunFire;

//Insert dual-wielding code from 9mm

var()           class<Emitter>  ShellEjectClass;            // class of the shell eject emitter
var()           Emitter         ShellEjectEmitter;          // The shell eject emitter
var()           name            ShellEjectBoneName;         // name of the shell eject bone

//From DualiesFire.uc
var() Emitter Flash2Emitter;

var()           Emitter         ShellEject2Emitter;          // The shell eject emitter
var()           name            ShellEject2BoneName;         // name of the shell eject bone

var name FireAnim2, FireAimedAnim2;
var name FireAnimInterim;

//From DualFlareRevolverFire.uc
var() vector SightedProjSpawnOffset;
//End Additions

simulated function bool AllowFire()
{
	if(KFWeapon(Weapon).bIsReloading)
		return false;
	if(KFPawn(Instigator).SecondaryItem!=none)
		return false;
	if(KFPawn(Instigator).bThrowingNade)
		return false;

	if(KFWeapon(Weapon).MagAmmoRemaining < 1)
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

    if( KFWeap.bAimingRifle )
    {
        if( FireAimedAnim == 'LeftFire_Iron' )
        {
            Flash2Emitter.Trigger(Weapon, Instigator);
            if (ShellEject2Emitter != None)
            {
                ShellEject2Emitter.Trigger(Weapon, Instigator);
            }
        }
        else
        {
            FlashEmitter.Trigger(Weapon, Instigator);
            if (ShellEjectEmitter != None)
            {
                ShellEjectEmitter.Trigger(Weapon, Instigator);
            }
        }
	}
	else
	{
        if(FireAnim == 'LeftFire')
        {
            Flash2Emitter.Trigger(Weapon, Instigator);
            if (ShellEject2Emitter != None)
            {
                ShellEject2Emitter.Trigger(Weapon, Instigator);
            }
        }
        else
        {
            FlashEmitter.Trigger(Weapon, Instigator);
            if (ShellEjectEmitter != None)
            {
                ShellEjectEmitter.Trigger(Weapon, Instigator);
            }
        }
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
    local Vector StartProj, StartTrace, X,Y,Z;
    local Rotator R, Aim;
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

        if( FireAimedAnim == 'LeftFire_Iron')
        {
            StartProj = StartProj + -1 * Y*SightedProjSpawnOffset.Y + Z*SightedProjSpawnOffset.Z;
        }
        else
        {
            StartProj = StartProj + Weapon.Hand * Y*SightedProjSpawnOffset.Y + Z*SightedProjSpawnOffset.Z;
        }
	}
	else
	{
	    StartProj = StartTrace + X*ProjSpawnOffset.X;
		
        if(FireAnim == 'LeftFire')
        {
            StartProj = StartProj + -1 * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;
        }
        else
        {
            StartProj = StartProj + Weapon.Hand * Y*ProjSpawnOffset.Y + Z*ProjSpawnOffset.Z;
        }
	}


    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);

    if (Other != None)
    {
        StartProj = HitLocation;
    }

    Aim = AdjustAim(StartProj, AimError);

    SpawnCount = Max(1, ProjPerFire * int(Load));

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
            theta = Spread*PI/32768*(p - float(SpawnCount-1)/2.0);
            X.X = Cos(theta);
            X.Y = Sin(theta);
            X.Z = 0.0;
            SpawnProjectile(StartProj, Rotator(X >> Aim));
        }
        break;
    default:
        SpawnProjectile(StartProj, Aim);
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
	local name BoneNameInterim;

	BoneNameInterim = AA12DWAutoShotgun(Weapon).altFlashBoneName;
	AA12DWAutoShotgun(Weapon).altFlashBoneName = AA12DWAutoShotgun(Weapon).FlashBoneName;
	AA12DWAutoShotgun(Weapon).FlashBoneName = BoneNameInterim;

	Super.ModeDoFire();

    if( KFWeap.bAimingRifle )
    {
    	FireAnimInterim = FireAimedAnim2;
    	FireAimedAnim2 = FireAimedAnim;
    	FireAimedAnim = FireAnimInterim;
	}
	else
	{
    	FireAnimInterim = FireAnim2;
    	FireAnim2 = FireAnim;
    	FireAnim = FireAnimInterim;
	}
	InitEffects();
	if (AA12DWAutoShotgun(Weapon).MagAmmoRemaining <= 0)
	{
		AA12DWAutoShotgun(Weapon).Notify_HideShells();
	}
}

defaultproperties
{
    FireAnim2="LeftFire"
    FireAimedAnim2=LeftFire_Iron
	FireAimedAnim=Fire_Iron
    FireLoopAnim=
    FireEndAnim=

    KickMomentum=(X=-35,Z=5)
    ProjPerFire=5
	//ProjSpawnOffset=(X=25,Y=5,Z=-6) //Basic value inherited from KFShotgunFire
	//+/- X fore/back,Y right/left,Z up/down
	ProjSpawnOffset=(X=25,Y=15,Z=-6)
	SightedProjSpawnOffset=(X=25,Y=5,Z=-6)
    bAttachSmokeEmitter=True
    TransientSoundVolume=2.0
    TransientSoundRadius=500
    FireSound=Sound'KF_AA12Snd.AA12_Fire'
    FireSoundRef="KF_AA12Snd.AA12_Fire"
    StereoFireSound=Sound'KF_AA12Snd.AA12_FireST'
    StereoFireSoundRef="KF_AA12Snd.AA12_FireST"
    NoAmmoSound=Sound'KF_AA12Snd.AA12_DryFire'
    NoAmmoSoundRef="KF_AA12Snd.AA12_DryFire"
    FireRate=0.1 //0.2 cut this in half because dual-wield!
    FireAnimRate=1.0
    AmmoClass=Class'AA12DW.AA12DWAmmo'
    ProjectileClass=Class'AA12DW.AA12DWBullet'
    BotRefireRate=0.250000
    FlashEmitterClass=Class'ROEffects.MuzzleFlash1stKar'
    aimerror=1
    Spread=1125.0//1500
    maxVerticalRecoilAngle=1000
    maxHorizontalRecoilAngle=500

    //** View shake **//
    ShakeOffsetMag=(X=6.0,Y=2.0,Z=6.0)
    ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
    ShakeOffsetTime=1.25
    ShakeRotMag=(X=50.0,Y=50.0,Z=250.0)
    ShakeRotRate=(X=12500.0,Y=12500.0,Z=12500.0)
    ShakeRotTime=3.0
    bWaitForRelease=false

    ShellEjectClass=class'AA12DW.AA12ShellEject'
    ShellEjectBoneName=Shell_eject
    ShellEject2BoneName=LShell_eject
	
    bRandomPitchFireSound=false
}
