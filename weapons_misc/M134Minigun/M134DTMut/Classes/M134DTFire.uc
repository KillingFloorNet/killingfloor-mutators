class M134DTFire extends KFFire;

var() class<M134DTHeater> Heaterclass;
var	M134DTHeater Heater;
var Actor HeaterA;

simulated function bool AllowFire()
{
	if (KFWeapon(Weapon).bIsReloading)
		return false;
		
	if (KFPawn(Instigator).SecondaryItem!=none)
		return false;
		
	if (KFPawn(Instigator).bThrowingNade)
		return false;
		
	if (M134DT(Weapon).HeatLevel>0.95)
		return false;
		
	if (KFWeapon(Weapon).MagAmmoRemaining < 1)
	{
		if( Level.TimeSeconds - LastClickTime>FireRate )
			LastClickTime = Level.TimeSeconds;
			
		if( AIController(Instigator.Controller)!=None )
			KFWeapon(Weapon).ReloadMeNow();
		
		return false;
	}
	
	return super.AllowFire();
}

simulated function DestroyEffects()
{
	super.DestroyEffects();
	
	if (Heater != None)
		Heater.Destroy();
}

defaultproperties
{
	Heaterclass=class'M134DTHeater'
	FireAimedAnim="Fire_Iron"
	FireLoopAnim="Fire_Loop"
	FireEndAnim="Fire_End"
	RecoilRate=0.049000
	maxVerticalRecoilAngle=250
	maxHorizontalRecoilAngle=125
	ShellEjectclass=class'ROEffects.KFShellEjectAK'
	ShellEjectBoneName="ShellEjector"
	FireSound=Sound'm134DT_A.Shoot1'
	StereoFireSound=Sound'm134DT_A.Shoot1'
	//AmbientFireSound=Sound'm134DT_A.minigun_spin'
	DamageType=class'DamTypeM134DT'
	DamageMin=35 //200
	DamageMax=45 //200
	Momentum=8500.000000
	bPawnRapidFireAnim=True
	TransientSoundVolume=4.800000
	TweenTime=0.025000
	FireForce="AssaultRifleFire"
	FireRate=0.066000
	Ammoclass=class'M134DTAmmo'
	AmmoPerFire=1
	ShakeRotMag=(X=50.000000,Y=50.000000,Z=300.000000)
	ShakeRotRate=(X=7500.000000,Y=7500.000000,Z=7500.000000)
	ShakeRotTime=0.650000
	ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=7.500000)
	ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
	ShakeOffsetTime=1.150000
	BotRefireRate=0.990000
	FlashEmitterclass=class'ROEffects.MuzzleFlash1stSTG'
	aimerror=42.000000
	Spread=0.227500
	SpreadStyle=SS_Random
}