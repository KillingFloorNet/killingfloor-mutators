class Burn_RPG_Base_Weapon extends KFWeapon 
	abstract;

  /*
replication
{
	reliable if(Role == ROLE_Authority)
		MagAmmoRemaining;

	reliable if( bNetDirty && bNetOwner && (Role==ROLE_Authority) )
		MagCapacity, SellValue;

	// TODO - which of these ACTUALLY need sending?
	reliable if(Role < ROLE_Authority)
		ReloadMeNow, ServerSetAiming, ServerSpawnLight, ServerRequestAutoReload,
		ServerInterruptReload;

	reliable if(Role == ROLE_Authority)
		ClientReload, ClientFinishReloading, ClientReloadEffects, FlashLight,
		ClientInterruptReload, ClientForceKFAmmoUpdate;
}
*/

exec function ReloadMeNow()
{
	local float ReloadMulti;

	if(!AllowReload())
		return;

	if ( bHasAimingMode && bAimingRifle )
	{
		FireMode[1].bIsFiring = False;

		ZoomOut(false);
		if( Role < ROLE_Authority)
			ServerZoomOut(false);
	}
    
    ReloadMulti = 1.0;
	if ( KFHumanPawn(Instigator) != none)
	{
		ReloadMulti += KFPlayerReplicationInfo(KFHumanPawn(Instigator).PlayerReplicationInfo).ClientVeteranSkillLevel*0.05f;
	}

	bIsReloading = true;
	ReloadTimer = Level.TimeSeconds;
	ReloadRate = Default.ReloadRate / ReloadMulti;
    
	if( bHoldToReload )
	{
		NumLoadedThisReload = 0;
	}

	ClientReload();
	Instigator.SetAnimAction(WeaponReloadAnim);

	// Reload message commented out for now - Ramm
	if ( Level.Game.NumPlayers > 1 && KFGameType(Level.Game).bWaveInProgress && KFPlayerController(Instigator.Controller) != none &&
		 Level.TimeSeconds - KFPlayerController(Instigator.Controller).LastReloadMessageTime > KFPlayerController(Instigator.Controller).ReloadMessageDelay )
	{
		KFPlayerController(Instigator.Controller).Speech('AUTO', 2, "");
		KFPlayerController(Instigator.Controller).LastReloadMessageTime = Level.TimeSeconds;
	}
}

simulated function ClientReload()
{
	local float ReloadMulti;

	if ( bHasAimingMode && bAimingRifle )
	{
		FireMode[1].bIsFiring = False;

		ZoomOut(false);
		if( Role < ROLE_Authority)
			ServerZoomOut(false);
	}

	ReloadMulti = 1.0;

	if ( KFHumanPawn(Instigator) != none)
	{
		ReloadMulti +=  KFPlayerReplicationInfo(KFHumanPawn(Instigator).PlayerReplicationInfo).ClientVeteranSkillLevel*0.05f;
	}

	bIsReloading = true;
	PlayAnim(ReloadAnim, ReloadAnimRate*ReloadMulti, 0.1);
}

simulated function WeaponTick(float dt)
{
	local float LastSeenSeconds,ReloadMulti;

	if( bHasAimingMode && Instigator != none && Instigator.IsLocallyControlled() )
	{
		if ( bAimingRifle && Instigator!=None && Instigator.Physics==PHYS_Falling )
		{
			IronSightZoomOut();
		}
	}

	 if ( (Level.NetMode == NM_Client) || Instigator == None || KFFriendlyAI(Instigator.Controller) == none && Instigator.PlayerReplicationInfo == None)
		return;

	// Turn it off on death  / battery expenditure
	if (FlashLight != none)
	{
		// Keep the 1Pweapon client beam up to date.
		AdjustLightGraphic();
		if (FlashLight.bHasLight)
		{
			if (Instigator.Health <= 0 || KFHumanPawn(Instigator).TorchBatteryLife <= 0 || Instigator.PendingWeapon != none )
			{
				//Log("Killing Light...you're out of batteries, or switched / dropped weapons");
				KFHumanPawn(Instigator).bTorchOn = false;
				ServerSpawnLight();
			}
		}
	}

	UpdateMagCapacity(Instigator.PlayerReplicationInfo);

	if(!bIsReloading)
	{
		if(!Instigator.IsHumanControlled())
		{
			LastSeenSeconds = Level.TimeSeconds - Instigator.Controller.LastSeenTime;
			if(MagAmmoRemaining == 0 || ((LastSeenSeconds >= 5 || LastSeenSeconds > MagAmmoRemaining) && MagAmmoRemaining < MagCapacity))
				ReloadMeNow();
		}
	}
	else
	{
		if((Level.TimeSeconds - ReloadTimer) >= ReloadRate)
		{
			if(AmmoAmount(0) <= MagCapacity && !bHoldToReload)
			{
				MagAmmoRemaining = AmmoAmount(0);
				ActuallyFinishReloading();
			}
			else
			{
				ReloadMulti = 1.0;

                if ( KFHumanPawn(Instigator) != none)
                {
                    ReloadMulti +=  KFPlayerReplicationInfo(KFHumanPawn(Instigator).PlayerReplicationInfo).ClientVeteranSkillLevel*0.05f;
                }

				AddReloadedAmmo();

				if( bHoldToReload )
                {
                    NumLoadedThisReload++;
                }

				if(MagAmmoRemaining < MagCapacity && MagAmmoRemaining < AmmoAmount(0) && bHoldToReload)
					ReloadTimer = Level.TimeSeconds;
				if(MagAmmoRemaining >= MagCapacity || MagAmmoRemaining >= AmmoAmount(0) || !bHoldToReload || bDoSingleReload)
					ActuallyFinishReloading();
				else if( Level.NetMode!=NM_Client )
					Instigator.SetAnimAction(WeaponReloadAnim);
			}
		}
		else if(bIsReloading && !bReloadEffectDone && Level.TimeSeconds - ReloadTimer >= ReloadRate / 2)
		{
			bReloadEffectDone = true;
			ClientReloadEffects();
		}
	}
}

simulated function float GetAmmoMulti()
{
	if ( NextAmmoCheckTime > Level.TimeSeconds )
	{
		return LastAmmoResult;
	}

	NextAmmoCheckTime = Level.TimeSeconds + 1;

	LastAmmoResult = 1;

	return LastAmmoResult;
}

simulated function GetAmmoCount(out float MaxAmmoPrimary, out float CurAmmoPrimary)
{
	if ( Instigator == None || Instigator.Controller == None )
	{
		return;
	}

	if ( AmmoClass[0] == None )
	{
		return;
	}

	if ( bNoAmmoInstances )
	{
		MaxAmmoPrimary = MaxAmmo(0) * 5;
		CurAmmoPrimary = AmmoCharge[0] * 5;

		return;
	}

	if ( Ammo[0] == None )
	{
		return;
	}

	MaxAmmoPrimary = Ammo[0].default.MaxAmmo * 5;
	CurAmmoPrimary = Ammo[0].AmmoAmount * 5;
}

simulated function UpdateMagCapacity(PlayerReplicationInfo PRI)
{
    
    MagCapacity = default.MagCapacity ;
    
	if ( KFPlayerReplicationInfo(PRI) != none )
	{
		MagCapacity += KFPlayerReplicationInfo(KFHumanPawn(Instigator).PlayerReplicationInfo).ClientVeteranSkillLevel*0.05f;
	}
}

defaultproperties
{
}
