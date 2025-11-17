class FlareThrow extends KFShotgunFire;

#exec OBJ LOAD FILE=KF_AxeSnd.uax

var() float ProjectileSpawnDelay;

function InitEffects()
{
}

function Timer()
{
    Weapon.ConsumeAmmo(ThisModeNum, Load);
    DoFireEffect();
    Weapon.PlaySound(Sound'KF_AxeSnd.Axe_Fire',SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,,false);

    if( Weapon.ammoAmount(0) <= 0 && Instigator != none && Instigator.Controller != none )
    {
        Weapon.Destroy();
        Instigator.Controller.ClientSwitchToBestWeapon();
    }
}

event ModeDoFire()
{
    if (!AllowFire())
        return;

    if (MaxHoldTime > 0.0)
        HoldTime = FMin(HoldTime, MaxHoldTime);

    // server
    if (Weapon.Role == ROLE_Authority)
    {
        // Consume ammo, etc later
        SetTimer(ProjectileSpawnDelay, False);

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
        //ShakeView();
        PlayFiring();
        //FlashMuzzleFlash();
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
}


function PlayFireEnd(){}

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

defaultproperties
{
	ProjectileSpawnDelay=0.500000
	bRandomPitchFireSound=False
	ProjPerFire=1
	ProjSpawnOffset=(Y=-10.000000,Z=0.000000)
	bFireOnRelease=True
	bWaitForRelease=True
	bAttachSmokeEmitter=True
	TransientSoundVolume=2.000000
	TransientSoundRadius=500.000000
	FireAnimRate=0.950000
	NoAmmoSound=None
	FireRate=0.500000
	AmmoClass=Class'Flares.FlareAmmo'
	ProjectileClass=Class'Flares.FlareThrown'
	BotRefireRate=1.500000
	aimerror=1.000000
	Spread=0.000000
}