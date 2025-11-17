class TauCannonFire extends KFShotgunFire;

simulated function bool AllowFire()
{
	return (Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire);
}

function DoFireEffect()
{
   Super(KFShotgunFire).DoFireEffect();
}

defaultproperties
{
	aimerror=42.0 //1
	AmmoClass=Class'TauC.TauCannonAmmo'
	AmmoPerFire=1
	bAttachSmokeEmitter=False //True
	BotRefireRate=0.990000
	bRandomPitchFireSound=false
	bWaitForRelease=true
	FireAimedAnim=Fire_Iron
	FireAnim=Fire_NR
	FireAnimRate=0.95
	FireLoopAnim="Fire"
	FireRate=0.175
	FireSound=SoundGroup'TC_R.Fire'
	FireSoundRef="TC_R.Fire"
	FlashEmitterClass=Class'TauC.TauCannonMuzzleFlash'
	KickMomentum=(X=0,Z=0)
	maxHorizontalRecoilAngle=250
	maxVerticalRecoilAngle=1500
	NoAmmoSound=Sound'TC_R.Fizzle'
	NoAmmoSoundRef="TC_R.Fizzle"
	ProjectileClass=Class'TauC.TauBullet'
	ProjPerFire=1
	ProjSpawnOffset=(X=50,Y=10,Z=-20)
	Spread=0.005
	StereoFireSound=SoundGroup'TC_R.Fire'
	StereoFireSoundRef="TC_R.Fire"
	TransientSoundRadius=500.0
	TransientSoundVolume=1.8

	//** View shake **//
	ShakeOffsetMag=(X=10.0,Y=3.0,Z=12.0)
	ShakeOffsetRate=(X=1000.0,Y=1000.0,Z=1000.0)
	ShakeOffsetTime=2.0
	ShakeRotMag=(X=100.0,Y=100.0,Z=500.0)
	ShakeRotRate=(X=10000.0,Y=10000.0,Z=10000.0)
	ShakeRotTime=2.0
}
