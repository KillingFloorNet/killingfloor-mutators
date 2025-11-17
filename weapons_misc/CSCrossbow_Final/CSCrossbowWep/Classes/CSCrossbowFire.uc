class CSCrossbowFire extends KFShotgunFire;

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

function float MaxRange()
{
    return 2500;
}

defaultproperties
{
     FireAimedAnim=Fire_Iron
     KickMomentum=(X=0,y=0,Z=0)
     ProjPerFire=1
     TransientSoundVolume=1.8
     FireSoundRef="CSCrossbow_A.cscrossbow_fire_s"
     NoAmmoSoundRef="KF_XbowSnd.Xbow_DryFire"
     FireForce="AssaultRifleFire"
     FireRate=0.150000
     AmmoClass=Class'CSCrossbowWep.CSCrossbowAmmo'
     ShakeOffsetMag=(X=1.000000,Y=1.000000,Z=1.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotMag=(X=3.000000,Y=4.000000,Z=2.000000)
     ProjectileClass=Class'CSCrossbowWep.CSCrossbowArrow'
     BotRefireRate=1.800000
     FlashEmitterClass=None
     aimerror=1.000000
     Spread=0.75
     SpreadStyle=SS_None
     ProjSpawnOffset=(X=25,Y=0,Z=0)//(X=5,Y=5,Z=-25)

     EffectiveRange=2500.000000
     maxVerticalRecoilAngle=100
     maxHorizontalRecoilAngle=50
     bWaitForRelease=false
     bRandomPitchFireSound=false
	 TweenTime=0.000000
}
