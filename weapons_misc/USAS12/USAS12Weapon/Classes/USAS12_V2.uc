//=============================================================================
// AA12 Automatic Shotgun Inventory class
//=============================================================================
class USAS12_V2 extends KFWeapon;

#exec OBJ LOAD FILE=USAS12_V2_A.ukx

// Use alt fire to switch fire modes
simulated function AltFire(float F)
{
    if(ReadyToFire(0))
    {
        DoToggle();
    }
}

exec function SwitchModes()
{
	DoToggle();
}

simulated function WeaponTick(float dt)
{
	local float LastSeenSeconds,ReloadMulti;

    if( bForceLeaveIronsights )
    {
    	ZoomOut(true);

    	if( Role < ROLE_Authority)
			ServerZoomOut(false);

        bForceLeaveIronsights = false;
    }

    if( ForceZoomOutTime > 0 )
    {
        if( bAimingRifle )
        {
    	    if( Level.TimeSeconds - ForceZoomOutTime > 0 )
    	    {
                ForceZoomOutTime = 0;

            	ZoomOut(true);

            	if( Role < ROLE_Authority)
        			ServerZoomOut(false);
    		}
		}
		else
		{
            ForceZoomOutTime = 0;
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
				if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
				{
					ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
				}
				else
				{
					ReloadMulti = 1.0;
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

defaultproperties
{
	MagCapacity=20

	ReloadRate=3.133000
	ReloadAnim="Reload"
	ReloadAnimRate=1.000000
	WeaponReloadAnim="Reload_AA12"
	HudImage=Texture'USAS12_V2_A.usas12_txr.USAS12_V2_UNSELECT'
	SelectedHudImage=Texture'USAS12_V2_A.usas12_txr.USAS12_V2_SELECT'
	bHasAimingMode=True
	IdleAimAnim="Idle_Iron"
	StandardDisplayFOV=65.000000
	bModeZeroCanDryFire=True
	SleeveNum=5
	TraderInfoTexture=Texture'USAS12_V2_A.usas12_txr.USAS12_V2_TRADER'
	bIsTier3Weapon=True
	PlayerIronSightFOV=80.000000
	ZoomedDisplayFOV=45.000000
	FireModeClass(0)=Class'USAS12_V2Fire'
	FireModeClass(1)=Class'KFMod.NoFire'
	PutDownAnim="PutDown"
	SelectSound=Sound'USAS12_V2_A.USAS12_V2_SND.usas12_draw'
	SelectForce="SwitchToAssaultRifle"
	AIRating=0.550000
	CurrentRating=0.550000
	bShowChargingBar=True
	Description="An advanced automatic shotgun. Fires steel ball shot in semi or full auto."
	EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
	DisplayFOV=65.000000
	Priority=200
	InventoryGroup=4
	GroupOffset=10
	PickupClass=Class'USAS12_V2Pickup'
	PlayerViewOffset=(X=25.000000,Y=20.000000,Z=-2.000000)
	BobDamping=6.000000
	AttachmentClass=Class'USAS12_V2Attachment'
	IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
	ItemName="USAS-12"
	Mesh=SkeletalMesh'USAS12_V2_A.v_Usas12'
	Skins(0)=Combiner'USAS12_V2_A.usas12_txr.front_cmb'
	Skins(1)=Combiner'USAS12_V2_A.usas12_txr.stock_cmb'
	Skins(2)=Combiner'USAS12_V2_A.usas12_txr.mag_cmb'
	Skins(3)=Combiner'USAS12_V2_A.usas12_txr.Rec_cmb'
	Skins(4)=Combiner'USAS12_V2_A.usas12_txr.stuff_cmb'
	Skins(5)=Texture'KF_Weapons_Trip_T.hands.hands_1stP_military_diff'
	TransientSoundVolume=1.250000
}
