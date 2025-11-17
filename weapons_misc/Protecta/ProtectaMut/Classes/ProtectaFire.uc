class ProtectaFire extends ShotgunFire;

simulated function bool AllowFire()
{
	if(KFWeapon(Weapon).bIsReloading)
		return true;
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

    if(Protecta(Weapon).bSpreadType)
{
	maxVerticalRecoilAngle=2000;
	maxHorizontalRecoilAngle=700;
	RecoilRate=0.130000;
	bWaitForRelease=False;
	Spread=3000.000000;
}  
  else
{
	maxVerticalRecoilAngle=1500;
	maxHorizontalRecoilAngle=350;
	RecoilRate=0.050000;
	bWaitForRelease=True;
	Spread=1200.000000;
}

	return super(WeaponFire).AllowFire();
}

function DrawMuzzleFlash(Canvas Canvas)
{
    super.DrawMuzzleFlash(Canvas);
}

function FlashMuzzleFlash()
{
    super.FlashMuzzleFlash();
}

simulated function DestroyEffects()
{
    super.DestroyEffects();
}

defaultproperties
{
     maxVerticalRecoilAngle=2000
     maxHorizontalRecoilAngle=700
     RecoilRate=0.100000
     FireAimedAnim="Fire_Iron"
     bRandomPitchFireSound=False
     FireSound=Sound'Protecta_A.striker_shot_stereo'
     StereoFireSound=Sound'Protecta_A.striker_shot_stereo'
     NoAmmoSound=Sound'Protecta_A.striker_empty'
     bWaitForRelease=False//true
     bModeExclusive=False
     ProjPerFire=10
     bAttachSmokeEmitter=True
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     FireRate=0.300000
     AmmoClass=Class'ProtectaMut.ProtectaAmmo'
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=5.000000
     ShakeOffsetMag=(X=6.000000,Y=2.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=3.000000
     ProjectileClass=Class'ProtectaMut.ProtectaBullet'
     BotRefireRate=0.250000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stKar'
     aimerror=2.000000
     Spread=3000.000000
}
