class ColtFire extends KFFire;

var() 		name 			EmptyFiringAnim;
var()		name			EmptyFireAimedAnim;

function PlayFiring()
{
    local float RandPitch;

	if ( Weapon.Mesh != None )
	{
		if ( FireCount > 0 )
		{
			if( KFWeap.bAimingRifle )
			{
                if ( Weapon.HasAnim(FireLoopAimedAnim) )
    			{
    				Weapon.PlayAnim(FireLoopAimedAnim, FireLoopAnimRate, 0.0);
    			}
    			else if( Weapon.HasAnim(FireAimedAnim) )
    			{
    				if( Weapon.HasAnim(FireAimedAnim) )
					{
						if (KFWeapon(Weapon).MagAmmoRemaining>0)
						{
						Weapon.PlayAnim(FireAimedAnim, FireAnimRate, TweenTime);
						}
						else
						{
						Weapon.PlayAnim(EmptyFireAimedAnim, FireAnimRate, TweenTime);
						}
					}
    			}
    			else
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
			}
			else
			{
                if ( Weapon.HasAnim(FireLoopAnim) )
    			{
    				Weapon.PlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
    			}
    			else
    			{
    				Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
    			}
			}
		}
		else
		{
            if( KFWeap.bAimingRifle )
			{
                if( Weapon.HasAnim(FireAimedAnim) )
    			{
					if (KFWeapon(Weapon).MagAmmoRemaining>0)
					{
                    Weapon.PlayAnim(FireAimedAnim, FireAnimRate, TweenTime);
					}
					else
					{
                    Weapon.PlayAnim(EmptyFireAimedAnim, FireAnimRate, TweenTime);
					}
    			}
    			else
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
			}
			else
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
		}
	}


	if( Weapon.Instigator != none && Weapon.Instigator.IsLocallyControlled() &&
	   Weapon.Instigator.IsFirstPerson() && StereoFireSound != none )
	{
        if( bRandomPitchFireSound )
        {
            RandPitch = FRand() * RandomPitchAdjustAmt;

            if( FRand() < 0.5 )
            {
                RandPitch *= -1.0;
            }
        }

        Weapon.PlayOwnedSound(StereoFireSound,SLOT_Interact,TransientSoundVolume * 0.85,,TransientSoundRadius,(1.0 + RandPitch),false);
    }
    else
    {
        if( bRandomPitchFireSound )
        {
            RandPitch = FRand() * RandomPitchAdjustAmt;

            if( FRand() < 0.5 )
            {
                RandPitch *= -1.0;
            }
        }

        Weapon.PlayOwnedSound(FireSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,(1.0 + RandPitch),false);
    }
    ClientPlayForceFeedback(FireForce);  // jdf

    FireCount++;
}

defaultproperties
{
     FireAimedAnim="Fire"
	 EmptyFiringAnim="Fire_Last"
	 EmptyFireAimedAnim="Fire_Last"
	 
     RecoilRate=0.050000
     maxVerticalRecoilAngle=1000
     maxHorizontalRecoilAngle=140
     FireSoundRef="Colt_Snd.Fire"
     StereoFireSoundRef="Colt_Snd.Fire_m"
     NoAmmoSoundRef="KF_HandcannonSnd.50AE_DryFire"
     DamageType=Class'Colt.DamTypeColt'
     DamageMin=105
     DamageMax=130
     Momentum=15000.000000
     bWaitForRelease=True
     bAttachSmokeEmitter=True
     TransientSoundVolume=2.000000
     TweenTime=0.025000
     FireRate=0.200000
     AmmoClass=Class'Colt.ColtAmmo'
     AmmoPerFire=1
     ShakeRotMag=(X=75.000000,Y=75.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=10000.000000)
     ShakeRotTime=3.500000
     ShakeOffsetMag=(X=6.000000,Y=1.000000,Z=8.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.500000
     BotRefireRate=0.650000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stKar'
     aimerror=45.000000
     Spread=0.009000
     SpreadStyle=SS_Random
	  ShellEjectBoneName="Shell"     
	  ShellEjectClass=Class'ROEffects.KFShellEjectHandCannon'
	  
	  
	  }

