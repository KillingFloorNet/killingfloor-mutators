//=============================================================================
// Shotgun Fire
//=============================================================================
class WeldShotFire extends KFShotgunFire;

defaultproperties
{
     KickMomentum=(X=-85.000000,Z=15.000000)
     maxVerticalRecoilAngle=1500
     maxHorizontalRecoilAngle=900
     FireAimedAnim="Fire_Iron"
     StereoFireSound=Sound'MRS138.RSS-Fire'
     bRandomPitchFireSound=False
     ProjPerFire=7
     bWaitForRelease=True
     bAttachSmokeEmitter=True
     TransientSoundVolume=2.000000
     TransientSoundRadius=500.000000
     FireAnimRate=1.750000
     FireSound=Sound'MRS138.RSS-Fire'
     NoAmmoSound=Sound'KF_PumpSGSnd.SG_DryFire'
     FireRate=1.100000
     AmmoClass=Class'Weldgun.WeldShotAmmo'
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=5.000000
     ShakeOffsetMag=(X=6.000000,Y=2.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=3.000000
     ProjectileClass=Class'Weldgun.WeldShotBullet'
     BotRefireRate=1.500000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stKar'
     aimerror=1.000000
     Spread=1125.000000
}
