//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ColtFireB extends KFMeleeFire;


var() 		name 			EmptyFiringAnim;


function PlayFiring()
{
   
    if (KFWeapon(Weapon).MagAmmoRemaining>0)
					{
                    Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
					}
					else
					{
                    Weapon.PlayAnim(EmptyFiringAnim, FireAnimRate, TweenTime);
					}
    	
}
simulated event ModeDoFire()
{
	local float Rec;

	if (!AllowFire())
		return;

	Rec = GetFireSpeed();
	SetTimer(DamagedelayMin/Rec, False);
	FireRate = default.FireRate/Rec;
	FireAnimRate = default.FireAnimRate*Rec;
	ReloadAnimRate = default.ReloadAnimRate*Rec;

	if (MaxHoldTime > 0.0)
		HoldTime = FMin(HoldTime, MaxHoldTime);

	// server
	if (Weapon.Role == ROLE_Authority)
	{
		Weapon.ConsumeAmmo(ThisModeNum, Load);
		DoFireEffect();

		HoldTime = 0;   // if bot decides to stop firing, HoldTime must be reset first
		if ( (Instigator == None) || (Instigator.Controller == None) )
			return;

		if ( AIController(Instigator.Controller) != None )
			AIController(Instigator.Controller).WeaponFireAgain(BotRefireRate, true);

		Instigator.DeactivateSpawnProtection();
	}

	// client
	if (Instigator.IsLocallyControlled())
	{
		ShakeView();
		PlayFiring();
		FlashMuzzleFlash();
		StartMuzzleSmoke();
		ClientPlayForceFeedback(FireForce);
	}
	else // server
		ServerPlayFiring();

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

   /* if( Weapon.Owner != none && Weapon.Owner.Physics != PHYS_Falling )
    {
        Weapon.Owner.Velocity.x *= KFMeleeGun(Weapon).ChopSlowRate;
        Weapon.Owner.Velocity.y *= KFMeleeGun(Weapon).ChopSlowRate;
    }*/
}



DefaultProperties

	MeleeDamage=40
	WideDamageMinHitAngle=0.75
	ProxySize=0.150000
	
	DamagedelayMin=0.55
	DamagedelayMax=0.65
	hitDamageClass=Class'Colt.DamTypeTacticalKnife'
	FireRate=1
	EmptyFiringAnim="Alt4_Dry"
	MeleeHitSounds(0)=SoundGroup'KF_AxeSnd.Axe_HitFlesh'
    HitEffectClass=Class'KFMod.ScytheHitEffect'
	FireAnim="Alt4"
	BotRefireRate=0.300000
	TransientSoundVolume=3.000000
}
