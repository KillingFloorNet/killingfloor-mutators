class Beretta96FSDTFire extends KFFire;

var()		sound			FireSoundSil;
var()		class<Emitter>	FlashEmitterClassS;
var()		Emitter			FlashEmitterS;
var()		name			FireAimedEmptyAnim;
var()		name			FireEmptyAnim;
var()		float				DamageMaxS;

event ModeDoFire()
{
	Super.ModeDoFire();
	InitEffects();
}

simulated function InitEffects()
{
	// don't even spawn on server
	if(Level.NetMode == NM_DedicatedServer || AIController(Instigator.Controller) != None)
		return;
	//Log("Fire.InitEffects.0"@Weapon@Beretta96FSDT(Weapon).bSilencerOn);
	if (Beretta96FSDT(Weapon).bSilencerOn)
	{
		if(FlashEmitterClassS != None && (FlashEmitterS == None || FlashEmitterS.bDeleteMe))
		{
			FlashEmitterS = Weapon.Spawn(FlashEmitterClassS);
			Weapon.AttachToBone(FlashEmitterS, Beretta96FSDT(Weapon).altFlashBoneName);
		}
	}
	else 
	{
		if(FlashEmitterClass != None && (FlashEmitter == None || FlashEmitter.bDeleteMe))
		{
			FlashEmitter = Weapon.Spawn(FlashEmitterClass);
			Weapon.AttachToBone(FlashEmitter, KFWeapon(Weapon).FlashBoneName);
		}
	}
	if(SmokeEmitterClass != None && (SmokeEmitter == None || SmokeEmitter.bDeleteMe))
	{
		SmokeEmitter = Weapon.Spawn(SmokeEmitterClass);
	}
		
	if(ShellEjectClass != None && (ShellEjectEmitter == None || ShellEjectEmitter.bDeleteMe))
	{
		ShellEjectEmitter = Weapon.Spawn(ShellEjectClass);
		Weapon.AttachToBone(ShellEjectEmitter, ShellEjectBoneName);
	}

}

function DrawMuzzleFlash(Canvas Canvas)
{
	// Draw smoke first

	if (SmokeEmitter != None && SmokeEmitter.Base != Weapon)
	{
		SmokeEmitter.SetLocation( Weapon.GetEffectStart() );
		Canvas.DrawActor( SmokeEmitter, false, false, Weapon.DisplayFOV );
	}
	//Log("Fire.DrawMuzzleFlash.0"@Weapon@Beretta96FSDT(Weapon).bSilencerOn);
	if (Beretta96FSDT(Weapon).bSilencerOn)
	{
		if (FlashEmitterS != None && FlashEmitterS.Base != Weapon)
		{
			FlashEmitterS.SetLocation( Weapon.GetEffectStart() );
			Canvas.DrawActor( FlashEmitter, false, false, Weapon.DisplayFOV );
		}
	}
	else
	{
		if (FlashEmitter != None && FlashEmitter.Base != Weapon)
		{
			FlashEmitter.SetLocation( Weapon.GetEffectStart() );
			Canvas.DrawActor( FlashEmitter, false, false, Weapon.DisplayFOV );
		}
	}
	//	super.DrawMuzzleFlash(Canvas);
}

function FlashMuzzleFlash()
{
	//Log("Fire.FlashMuzzleFlash.0"@Weapon@Beretta96FSDT(Weapon).bSilencerOn);
	if (Beretta96FSDT(Weapon).bSilencerOn)
	{
		if (FlashEmitterS != None)
			FlashEmitterS.Trigger(Weapon, Instigator);
	}
	else
	{
		if (FlashEmitter != None)
			FlashEmitter.Trigger(Weapon, Instigator);
	}
	if (ShellEjectEmitter != None)
	{
		//ShellEjectEmitter.SpawnParticle(1);//Trigger(Weapon, Instigator);
		ShellEjectEmitter.Trigger(Weapon, Instigator);
	}
	//    super.FlashMuzzleFlash();
}

simulated function DestroyEffects()
{
	super.DestroyEffects();
	if(FlashEmitterS != None)
		FlashEmitterS.Destroy();
}

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
					if(KFWeapon(Weapon).MagAmmoRemaining>0)
						Weapon.PlayAnim(FireAimedAnim, FireAnimRate, TweenTime);
					else Weapon.PlayAnim(FireAimedEmptyAnim, FireAnimRate, TweenTime);
				}
				else
				{
					if(KFWeapon(Weapon).MagAmmoRemaining>0)
						Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
					else Weapon.PlayAnim(FireEmptyAnim, FireAnimRate, TweenTime);
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
					if(KFWeapon(Weapon).MagAmmoRemaining>0)
						Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
					else Weapon.PlayAnim(FireEmptyAnim, FireAnimRate, TweenTime);
				}
			}
		}
		else
		{
			if( KFWeap.bAimingRifle )
			{
				if( Weapon.HasAnim(FireAimedAnim) )
				{
					if(Beretta96FSDT(Weapon).ClientMagAmmoRemaining>0)
						Weapon.PlayAnim(FireAimedAnim, FireAnimRate, TweenTime);
					else Weapon.PlayAnim(FireAimedEmptyAnim, FireAnimRate, TweenTime);
				}
				else
				{
					if(Beretta96FSDT(Weapon).ClientMagAmmoRemaining>0)
						Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
					else  Weapon.PlayAnim(FireEmptyAnim, FireAnimRate, TweenTime);
				}
			}
			else
			{
				if(Beretta96FSDT(Weapon).ClientMagAmmoRemaining>0)
					Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
				else
					Weapon.PlayAnim(FireEmptyAnim, FireAnimRate, TweenTime);
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

		if(!Beretta96FSDT(Weapon).bSilencerOn)
			Weapon.PlayOwnedSound(StereoFireSound,SLOT_Interact,TransientSoundVolume * 0.85,,TransientSoundRadius,(1.0 + RandPitch),false);
		else
			Weapon.PlayOwnedSound(FireSoundSil,SLOT_Interact,TransientSoundVolume * 0.85,,TransientSoundRadius,(1.0 + RandPitch),false);
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
		if(!Beretta96FSDT(Weapon).bSilencerOn)
			Weapon.PlayOwnedSound(FireSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,(1.0 + RandPitch),false);
		else
			Weapon.PlayOwnedSound(FireSoundSil,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,(1.0 + RandPitch),false);
	}
	ClientPlayForceFeedback(FireForce);  // jdf
	FireCount++;
}

function ServerPlayFiring()
{
	if(!Beretta96FSDT(Weapon).bSilencerOn)
		Weapon.PlayOwnedSound(FireSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,,false);
	else
		Weapon.PlayOwnedSound(FireSoundSil,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,,false);
}

simulated function bool AllowFire()
{
	if(Beretta96FSDT(Weapon).bSilencerSwitch)
		return false;
	if(KFWeapon(Weapon).bIsReloading)
		return false;
	if(KFPawn(Instigator).SecondaryItem!=none)
		return false;
	if(KFPawn(Instigator).bThrowingNade)
		return false;
	//Делаем отдельные счётчики для сервера и клиента
	if(Level.NetMode == NM_DedicatedServer)
	{
		if(KFWeapon(Weapon).MagAmmoRemaining < 1)
		{
			if( Level.TimeSeconds - LastClickTime>FireRate )
				LastClickTime = Level.TimeSeconds;
			if( AIController(Instigator.Controller)!=None )
				KFWeapon(Weapon).ReloadMeNow();
			return false;
		}
	}
	else
	{
		if(Beretta96FSDT(Weapon).ClientMagAmmoRemaining<0)
		{
			if( Level.TimeSeconds - LastClickTime>FireRate )
				LastClickTime = Level.TimeSeconds;
			if( AIController(Instigator.Controller)!=None )
				KFWeapon(Weapon).ReloadMeNow();
			return false;
		}
	}
	return super(WeaponFire).AllowFire();
}

function StartBerserk()
{
	DamageMin = default.DamageMin * 1.33;
	DamageMax = default.DamageMax * 1.33;
}

function StopBerserk()
{
	DamageMin = default.DamageMin;
	DamageMax = default.DamageMax;
}

function StartSuperBerserk();

function DoTrace(Vector Start, Rotator Dir)
{
	local Vector X,Y,Z, End, HitLocation, HitNormal, ArcEnd;
	local Actor Other;
	local KFWeaponAttachment WeapAttach;
	local array<int>	HitPoints;
	local KFPawn HitPawn;
	
	//Flame
	local Pawn StoreEnemy;
	local KFMonster Victim;
	local int myDamage;
	//
	MaxRange();

	Weapon.GetViewAxes(X, Y, Z);
	if ( Weapon.WeaponCentered() )
		ArcEnd = (Instigator.Location + Weapon.EffectOffset.X * X + 1.5 * Weapon.EffectOffset.Z * Z);
	else ArcEnd = (Instigator.Location + Instigator.CalcDrawOffset(Weapon) + Weapon.EffectOffset.X * X + Weapon.Hand * Weapon.EffectOffset.Y * Y +
		Weapon.EffectOffset.Z * Z);

	X = Vector(Dir);
	End = Start + TraceRange * X;
	Other = Instigator.HitPointTrace(HitLocation, HitNormal, End, HitPoints, Start,, 1);

	if ( Other != None && Other != Instigator && Other.Base != Instigator )
	{
		WeapAttach = KFWeaponAttachment(Weapon.ThirdPersonActor);

		if ( !Other.bWorldGeometry )
		{
			// Update hit effect except for pawns
			if ( !Other.IsA('Pawn') && !Other.IsA('HitScanBlockingVolume') &&
				!Other.IsA('ExtendedZCollision') )
			{
				if( WeapAttach!=None )
				{
					WeapAttach.UpdateHit(Other, HitLocation, HitNormal);
				}
			}
			HitPawn = KFPawn(Other);
			
			//Flame
			if(Beretta96FSDT(Weapon).bSilencerOn)
				myDamage=default.DamageMaxS;
			else
				myDamage=default.DamageMax;
			//
			if ( HitPawn != none )
			{
				// Hit detection debugging
				/*log("PreLaunchTrace hit "$HitPawn.PlayerReplicationInfo.PlayerName);
				HitPawn.HitStart = Start;
				HitPawn.HitEnd = End;*/
				if(!HitPawn.bDeleteMe)
					HitPawn.ProcessLocationalDamage(myDamage, Instigator, HitLocation, Momentum*X,DamageType,HitPoints);

				// Hit detection debugging
				/*if( Level.NetMode == NM_Standalone)
					HitPawn.DrawBoneLocation();*/
			}
			else
			{
				Victim=KFMonster(Other);
				if(Victim!=none)
				{
					StoreEnemy=Victim.Controller.Enemy;
					//Log("Victim.0"@Victim.Controller.Enemy.PlayerReplicationInfo.PlayerName);
					Victim.TakeDamage(myDamage, Instigator, HitLocation, Momentum*X,DamageType);
					//Log("Victim.1"@Victim.Controller.Enemy.PlayerReplicationInfo.PlayerName);
					if(Beretta96FSDT(Weapon).bSilencerOn && Victim.Controller!=none)
						Victim.Controller.Enemy=StoreEnemy;
					//Log("Victim.2"@Victim.Controller.Enemy.PlayerReplicationInfo.PlayerName);
				}
				else
				{
					Victim=KFMonster(Other.Owner);
					if(Victim!=none)
					{
						StoreEnemy=Victim.Controller.Enemy;
						//Log("Victim.3"@Victim.Controller.Enemy.PlayerReplicationInfo.PlayerName);
						Victim.TakeDamage(myDamage, Instigator, HitLocation, Momentum*X,DamageType);
						//Log("Victim.4"@Victim.Controller.Enemy.PlayerReplicationInfo.PlayerName);
						if(Beretta96FSDT(Weapon).bSilencerOn && Victim.Controller!=none)
							Victim.Controller.Enemy=StoreEnemy;
						//Log("Victim.5"@Victim.Controller.Enemy.PlayerReplicationInfo.PlayerName);
					}
					else
					{
						Other.TakeDamage(myDamage, Instigator, HitLocation, Momentum*X,DamageType);
					}
				}
			}
		}
		else
		{
			HitLocation = HitLocation + 2.0 * HitNormal;
			if ( WeapAttach != None )
			{
				WeapAttach.UpdateHit(Other,HitLocation,HitNormal);
			}
		}
	}
	else
	{
		HitLocation = End;
		HitNormal = Normal(Start - End);
	}
}

defaultproperties
{
	FireAimedEmptyAnim="Fire_Last"
	FireEmptyAnim="Fire_Last"
	FireSoundSil=Sound'Beretta96FS_DT_A.Beretta96FS_DT_Snd.FireSilenced';
	FireAimedAnim="Fire_Iron"
	RecoilRate=0.070000
	maxVerticalRecoilAngle=300
	maxHorizontalRecoilAngle=50
	ShellEjectClass=Class'ROEffects.KFShellEject9mm'
	ShellEjectBoneName="Shell_eject"
	bRandomPitchFireSound=False
	StereoFireSoundRef="KF_9MMSnd.9mm_FireST"
	DamageType=Class'KFMod.DamTypeDualies'
	DamageMax=35
	DamageMaxS=30
	Momentum=10000.000000
	bPawnRapidFireAnim=True
	bWaitForRelease=True
	bAttachSmokeEmitter=True
	TransientSoundVolume=1.800000
	FireAnimRate=1.500000
	TweenTime=0.025000
	FireSound=Sound'Beretta96FS_DT_A.Beretta96FS_DT_Snd.FireUnsilenced'
	NoAmmoSound=Sound'KF_9MMSnd.9mm_DryFire'
	FireForce="AssaultRifleFire"
	FireRate=0.175000
	AmmoClass=Class'Beretta96FSDTAmmo'
	AmmoPerFire=1
	ShakeRotMag=(X=75.000000,Y=75.000000,Z=250.000000)
	ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
	ShakeRotTime=3.000000
	ShakeOffsetMag=(X=6.000000,Y=3.000000,Z=10.000000)
	ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
	ShakeOffsetTime=2.000000
	BotRefireRate=0.350000
	FlashEmitterClass=Class'Beretta96FSDTMuzzleFlash'
	FlashEmitterClassS=Class'Beretta96FSDTMuzzleFlashS'
	aimerror=30.000000
	Spread=0.015000
	SpreadStyle=SS_Random
}
