class FlareHandheld extends KFWeapon;

#exec OBJ LOAD FILE=Flare_R.ukx

var bool bBeingDestroyed; // We've thrown the last bomb and this explosive is about to be destroyed

//Taken from ZEDMKIIWeapon
// Allow this weapon to auto reload on alt fire
simulated function AltFire(float F)
{
	if( !bIsReloading &&
		 FireMode[1].NextFireTime <= Level.TimeSeconds )
	{
		// We're dry, ask the server to autoreload
		if( MagAmmoRemaining < 1 )
		{
            ServerRequestAutoReload();
            PlayOwnedSound(FireMode[1].NoAmmoSound,SLOT_None,2.0,,,,false);
        }
        else if( MagAmmoRemaining < FireMode[1].AmmoPerFire )
        {
        	PlayOwnedSound(FireMode[1].NoAmmoSound,SLOT_None,2.0,,,,false);
        }
	}

	super.AltFire(F);
}

// overriden to not try and play a reload animation
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
}

// overriden to not try and play a reload animation
exec function ReloadMeNow()
{
	local float ReloadMulti;

	if(!AllowReload())
		return;

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
	}
	else
	{
		ReloadMulti = 1.0;
	}

	bIsReloading = true;
	ReloadTimer = Level.TimeSeconds;
	ReloadRate = Default.ReloadRate / ReloadMulti;

	if( bHoldToReload )
	{
		NumLoadedThisReload = 0;
	}

	ClientReload();
}

// overriden to not try and play a reload animation
simulated function WeaponTick(float dt)
{
	local float LastSeenSeconds,ReloadMulti;

	 if ( (Level.NetMode == NM_Client) || Instigator == None || KFFriendlyAI(Instigator.Controller) == none && Instigator.PlayerReplicationInfo == None)
		return;

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
			}
		}
		else if(bIsReloading && !bReloadEffectDone && Level.TimeSeconds - ReloadTimer >= ReloadRate / 2)
		{
			bReloadEffectDone = true;
			ClientReloadEffects();
		}
	}
}

simulated function AnimEnd(int channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);

    if (ClientState == WS_ReadyToFire)
    {
        if (anim == FireMode[0].FireAnim && ammoAmount(0) > 0 )
        {
            PlayAnim(SelectAnim, SelectAnimRate, 0.1);
        }
        else if ((FireMode[0] == None || !FireMode[0].bIsFiring) && (FireMode[1] == None || !FireMode[1].bIsFiring))
        {
            PlayIdle();
        }
    }
}

// Kludge to prevent destroyed weapons destroying the ammo if other guns
// are still using the same ammo
simulated function Destroyed()
{
    if( Role < ROLE_Authority )
    {
        // Hack to switch to another weapon on the client when we throw the last pipe bomb out
        if( Instigator != none && Instigator.Controller != none )
        {
            bBeingDestroyed = true;
            Instigator.SwitchToLastWeapon();
        }
    }

    super.Destroyed();
}

simulated function bool PutDown()
{
    // Hack to switch to another weapon on the client when we throw the last pipe bomb out
    if( bBeingDestroyed )
    {
        Instigator.ChangedWeapon();
        return true;
    }
    else
    {
        return super.PutDown();
    }
}

// need to figure out modified rating based on enemy/tactical situation
simulated function float RateSelf()
{
    if( bBeingDestroyed )
        CurrentRating = -2;
    else if( ammoAmount(0) <= 1 )
        CurrentRating = -2;
    else if ( !HasAmmo() )
        CurrentRating = -2;
	else if ( Instigator.Controller == None )
		return 0;
	else
		CurrentRating = Instigator.Controller.RateWeapon(self);
	return CurrentRating;
}

defaultproperties
{
	MagCapacity=1
	HudImage=Texture'Flare_R.HUDUnSelected'
	SelectedHudImage=Texture'Flare_R.HUDSelected'
	Weight=1.000000
	StandardDisplayFOV=65.000000
	bModeZeroCanDryFire=True
	SleeveNum=0
	TraderInfoTexture=Texture'Flare_R.HUDTrader'
	FireModeClass(0)=Class'Flares.FlareThrow'
	FireModeClass(1)=Class'Flares.FlareDrop'
	PutDownAnim="PutDown"
	SelectSound=SoundGroup'KF_AxeSnd.Axe_Select'
	SelectForce="SwitchToAssaultRifle"
	AIRating=0.550000
	CurrentRating=0.550000
	bShowChargingBar=True
	Description="Bright light with minimal smoke and heat; lightweight; easily-stored; these would make some excellent flares if the damp hadn't gotten into them."
	EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
	DisplayFOV=65.000000
	Priority=1
	InventoryGroup=5
	GroupOffset=1
	PickupClass=Class'Flares.FlarePickup'
	BobDamping=6.000000
	AttachmentClass=Class'Flares.FlareAttachment'
	IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
	ItemName="Flares"
	Mesh=SkeletalMesh'Flare_R.FlareMesh1st'
	Skins(0)=Combiner'KF_Weapons_Trip_T.hands.hands_1stP_military_cmb'
	Skins(1)=Combiner'Flare_R.FlareCap_cmb'
	Skins(2)=Combiner'Flare_R.FlareBody_cmb'
	TransientSoundVolume=1.250000
}