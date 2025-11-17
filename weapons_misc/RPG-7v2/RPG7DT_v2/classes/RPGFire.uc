class RPGFire extends KFShotgunFire;

var name EmptyFireAnim,LoadedFireAnim;

simulated function bool AllowFire()
{
	if( Instigator != none && Instigator.IsHumanControlled() )
	{
		if( !KFWeapon(Weapon).bAimingRifle || KFWeapon(Weapon).bZoomingIn )
			return false;
	}
	if ( Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire )
	{
		if ( Instigator.Weapon.ThirdPersonActor != none )
			RPGAttachment(Instigator.Weapon.ThirdPersonActor).SizeRocket(0);
		if ( Weapon.Mesh != none )
		{
			if(Weapon.Role==ROLE_Authority)
			{
				if ( Weapon.AmmoAmount(ThisModeNum) > 1 )
					FireAnim = LoadedFireAnim;
				else
					FireAnim = EmptyFireAnim;
			}
			else
			{ //Flame
				if(int(Weapon.GetPropertyText("ClientMagAmmoRemaining"))>0)
					FireAnim = LoadedFireAnim;
				else
					FireAnim = EmptyFireAnim;
			}
		}
		return true;
	}
}

function ServerPlayFiring()
{
	//Log("ServerPlayFiring.0");
	Super.ServerPlayFiring();
	KFWeapon(Weapon).ZoomOut(false);
	KFPawn(KFWeapon(Weapon).Instigator).StopAnimating();
	KFPawn(KFWeapon(Weapon).Instigator).PlayAnim(KFWeapon(Weapon).WeaponReloadAnim);
}

function PlayFiring()
{
	//Log("PlayFiring.0");
	Super.PlayFiring();
	KFWeapon(Weapon).ZoomOut(false);
}

defaultproperties
{
	LoadedFireAnim = "FireReload"
	EmptyFireAnim = "Fire"
	//KickMomentum=(X=-45.000000,Z=25.000000)
	ProjSpawnOffset=(X=50.000000,Z=0)
	bSplashDamage=True
	bRecommendSplashDamage=True
	TransientSoundVolume=1.8
	//PreFireAnim ="FireShort"
	FireSound=Sound'RPG7DTv2_A.Fire'
	//StereoFireSound=Sound'KF_LAWSnd.LAW_FireST'
	NoAmmoSound=Sound'RPG7DTv2_A.empty'
	FireForce="redeemer_shoot"
	FireRate=3.250000
	AmmoClass=Class'RPG7DT_v2.RPGAmmo'
	AmmoPerFire=1

	//** View shake **//
	ShakeOffsetMag=(X=-20.000000)
	ShakeOffsetRate=(X=-1000.000000)
	ShakeOffsetTime=2.500000
	ShakeRotMag=(X=128.000000,Y=64.000000,Z=16.000000)
	ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
	ShakeRotTime=2.500000
	ProjectileClass=Class'RPG7DT_v2.RPGProj'
	BotRefireRate=3.250000
	FlashEmitterClass=Class'KFMod.ShotgunMuzzFlash'
	Spread=0.1
	SpreadStyle=SS_Random
	ProjPerFire=1

	// Lets not make people wait to shoot, it feels broken - Ramm
	PreFireTime=0.0
	CrouchedAccuracyBonus = 0.1
	maxVerticalRecoilAngle=1000
	maxHorizontalRecoilAngle=250

	//в лав этого нет!!!
	//bWaitForRelease=true 
	bRandomPitchFireSound=false
}