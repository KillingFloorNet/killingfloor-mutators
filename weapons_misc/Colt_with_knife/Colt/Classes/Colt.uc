//=============================================================================
//=============================================================================
class Colt extends KFWeapon;

var()		name			EmptySelectAnim;
var()		name			EmptyPutDownAnim;
var()		name			EmptyIdleAnim;
var()		name			EmptyIronIdleAnim;
var() 		name 			EmptyReloadAnim;



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

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
	}
	else
	{
		ReloadMulti = 1.0;
	}

	bIsReloading = true;
	if (MagAmmoRemaining > 0)
	{
	PlayAnim(ReloadAnim, ReloadAnimRate*ReloadMulti, 0.1);
	}
	else
	{
	PlayAnim(EmptyReloadAnim, ReloadAnimRate*ReloadMulti, 0.1);
	}
}

simulated function PlayIdle()
{
	if( bAimingRifle )
	{
		if (MagAmmoRemaining>0)
		{
		LoopAnim(IdleAimAnim, IdleAnimRate, 0.2);
		}
		else
		{
		LoopAnim(EmptyIronIdleAnim, IdleAnimRate, 0.2);
		}
	}
	else
	{
		if (MagAmmoRemaining>0)
		{
		LoopAnim(IdleAnim, IdleAnimRate, 0.2);
		}
		else
		{
		LoopAnim(EmptyIdleAnim, IdleAnimRate, 0.2);
		}
	}
}


simulated function bool PutDown()
{
	local int Mode;

	InterruptReload();

	if ( bIsReloading )
		return false;

	if( bAimingRifle )
	{
		ZoomOut(False);
	}

	// From Weapon.uc
	if (ClientState == WS_BringUp || ClientState == WS_ReadyToFire)
	{
		if ( (Instigator.PendingWeapon != None) && !Instigator.PendingWeapon.bForceSwitch )
		{
			for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
			{
		    	// if _RO_
				if( FireMode[Mode] == none )
					continue;
				// End _RO_

				if ( FireMode[Mode].bFireOnRelease && FireMode[Mode].bIsFiring )
					return false;
				if ( FireMode[Mode].NextFireTime > Level.TimeSeconds + FireMode[Mode].FireRate*(1.f - MinReloadPct))
					DownDelay = FMax(DownDelay, FireMode[Mode].NextFireTime - Level.TimeSeconds - FireMode[Mode].FireRate*(1.f - MinReloadPct));
			}
		}

		if (Instigator.IsLocallyControlled())
		{
			for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
			{
		    	// if _RO_
				if( FireMode[Mode] == none )
					continue;
				// End _RO_

				if ( FireMode[Mode].bIsFiring )
					ClientStopFire(Mode);
			}

            if (  DownDelay <= 0  || KFPawn(Instigator).bIsQuickHealing > 0)
            {
				if ( ClientState == WS_BringUp || KFPawn(Instigator).bIsQuickHealing > 0 )
					TweenAnim(SelectAnim,PutDownTime);
				else if ( HasAnim(PutDownAnim) )
				{
					if( ClientGrenadeState == GN_TempDown || KFPawn(Instigator).bIsQuickHealing > 0)
                    {
					   if (MagAmmoRemaining>0)
					   {
                       PlayAnim(PutDownAnim, PutDownAnimRate * (PutDownTime/QuickPutDownTime), 0.0);
					   }
					   else
					   {
                       PlayAnim(EmptyPutDownAnim, PutDownAnimRate * (PutDownTime/QuickPutDownTime), 0.0);
					   }
                	}
                	else
                	{
					   if (MagAmmoRemaining>0)
					   {
                	   PlayAnim(PutDownAnim, PutDownAnimRate, 0.0);
					   }
					   else
					   {
					   PlayAnim(EmptyPutDownAnim, PutDownAnimRate, 0.0);
					   }
                	}

				}
			}
        }
		ClientState = WS_PutDown;
		if ( Level.GRI.bFastWeaponSwitching )
			DownDelay = 0;
		if ( DownDelay > 0 )
		{
			SetTimer(DownDelay, false);
		}
		else
		{
			if( ClientGrenadeState == GN_TempDown )
			{
			   SetTimer(QuickPutDownTime, false);
			}
			else
			{
			   SetTimer(PutDownTime, false);
			}
		}
	}
	for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
	{
		// if _RO_
		if( FireMode[Mode] == none )
			continue;
		// End _RO_

		FireMode[Mode].bServerDelayStartFire = false;
		FireMode[Mode].bServerDelayStopFire = false;
	}
	Instigator.AmbientSound = None;
	OldWeapon = None;
	return true; // return false if preventing weapon switch

}

defaultproperties
{
    SleeveNum=0	
    Skins(1)=Texture'Colt_T.frame'
	Skins(2)=Texture'Colt_T.Slide'
	Skins(3)=Texture'Colt_T.Diffuse'
	 EmptyReloadAnim="Reload"
     EmptyIdleAnim="Idle_Dry"
	 EmptyIronIdleAnim="Idle_Iron_Dry"
	 EmptyPutDownAnim="Put_Down_Dry"
	 EmptySelectAnim="Select_Dry"	

    bShowChargingBar=True
	IdleAimAnim=Idle_Iron
	MagCapacity=7
	ReloadRate=2
	ReloadAnim="Reload_Full"
	ReloadAnimRate=1.2333
	Weight=4.000000
	WeaponReloadAnim="Reload_Single9mm"

	bModeZeroCanDryFire=True
	FireModeClass(0)=Class'Colt.ColtFire'
	FireModeClass(1)=Class'Colt.ColtFireB'
	PutDownAnim="Put_Down"
	SelectSound=Sound'Colt_snd.Draw'
	Description="Colt 1911"
  	Priority=70
	InventoryGroup=2
	GroupOffset=7
	PickupClass=Class'Colt.ColtPickup'
	PlayerViewOffset=(X=20.000000,Y=25.000000,Z=-10.000000)//(X=4.000000,Y=5.000000,Z=-2.000000)
	BobDamping=6.000000
	AttachmentClass=Class'Colt.ColtAttachment'
	IconCoords=(X1=434,Y1=253,X2=506,Y2=292)
	ItemName="Colt 1911 .45ACP"
	Mesh=SkeletalMesh'Colt.Colt'


	AIRating=0.45
	CurrentRating=0.45



	bHasAimingMode=true

	DisplayFOV=70.000000
	StandardDisplayFOV=80//70.0
	PlayerIronSightFOV=75
	ZoomedDisplayFOV=65

	HudImage=texture'Colt_T.HUD.Mag_Unsel'
	SelectedHudImage=texture'Colt_T.HUD.Mag_Sel'
	TraderInfoTexture=texture'Colt_T.HUD.prev'
    bIsTier2Weapon=true
}
