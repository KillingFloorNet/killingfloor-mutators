//=============================================================================
 //AAC By Secret_Agent[AZE]
 // Операция Ы
//=============================================================================
class M4A1IronBeastSAFire extends KFFire;

defaultproperties
{
     FireAimedAnim="Fire_Iron"
     RecoilRate=0.070000
     maxVerticalRecoilAngle=200
     maxHorizontalRecoilAngle=100
     bRecoilRightOnly=True
     ShellEjectClass=Class'ROEffects.KFShellEjectAK'
     ShellEjectBoneName="Eject_Bone"
     bAccuracyBonusForSemiAuto=True
     bRandomPitchFireSound=False
     FireSound=Sound'M4A1IronBeastSA_A.M4A1Iron_SND.M4A1Fire'
     StereoFireSound=Sound'M4A1IronBeastSA_A.M4A1Iron_SND.M4A1Fire'
     NoAmmoSoundRef="KF_AK47Snd.AK47_DryFire"
     DamageType=Class'M4A1IronBeastSAMut.DamTypeM4A1IronBeastSA'
     DamageMin=55
     DamageMax=65
     Momentum=8500.000000
     bPawnRapidFireAnim=True
     TransientSoundVolume=1.800000
     FireLoopAnim="Fire"
     TweenTime=0.025000
     FireForce="AssaultRifleFire"
     FireRate=0.109000
     AmmoClass=Class'M4A1IronBeastSAMut.M4A1IronBeastSAAmmo'
     AmmoPerFire=1
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=350.000000)
     ShakeRotRate=(X=5000.000000,Y=5000.000000,Z=5000.000000)
     ShakeRotTime=0.750000
     ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=7.500000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.250000
     BotRefireRate=0.990000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stSTG'
     aimerror=42.000000
     Spread=0.015000
     SpreadStyle=SS_Random
}
