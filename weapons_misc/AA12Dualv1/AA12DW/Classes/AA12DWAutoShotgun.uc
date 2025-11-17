class AA12DWAutoShotgun extends KFWeapon;

// Copied from Dualies.uc
var name altFlashBoneName;
var Actor altThirdPersonActor;

simulated function Notify_ShowShells()
{
		SetBoneScale (0, 1.0, 'LShell');
}

simulated function Notify_HideShells()
{
		SetBoneScale (0, 0.0, 'LShell');
}

// From ZEDMKIIWeapon to handle ammo consumption for alt fire
// and reloading when alt fire dryfires
// Overridden to handle reducing the ammo for the secondary fire
simulated function bool ConsumeAmmo( int Mode, float Load, optional bool bAmountNeededIsMax )
{
	local Inventory Inv;
	local bool bOutOfAmmo;
	local KFWeapon KFWeap;

	if ( Super(Weapon).ConsumeAmmo(Mode, Load, bAmountNeededIsMax) )
	{
		if ( Load > 0 && (Mode == 0 || bReduceMagAmmoOnSecondaryFire) )
			MagAmmoRemaining -= Load;

		NetUpdateTime = Level.TimeSeconds - 1;

		if ( FireMode[Mode].AmmoPerFire > 0 && InventoryGroup > 0 && !bMeleeWeapon && bConsumesPhysicalAmmo &&
			 (Ammo[0] == none || FireMode[0] == none || FireMode[0].AmmoPerFire <= 0 || Ammo[0].AmmoAmount < FireMode[0].AmmoPerFire) &&
			 (Ammo[1] == none || FireMode[1] == none || FireMode[1].AmmoPerFire <= 0 || Ammo[1].AmmoAmount < FireMode[1].AmmoPerFire) )
		{
			bOutOfAmmo = true;

			for ( Inv = Instigator.Inventory; Inv != none; Inv = Inv.Inventory )
			{
				KFWeap = KFWeapon(Inv);

				if ( Inv.InventoryGroup > 0 && KFWeap != none && !KFWeap.bMeleeWeapon && KFWeap.bConsumesPhysicalAmmo &&
					 ((KFWeap.Ammo[0] != none && KFWeap.FireMode[0] != none && KFWeap.FireMode[0].AmmoPerFire > 0 &&KFWeap.Ammo[0].AmmoAmount >= KFWeap.FireMode[0].AmmoPerFire) ||
					 (KFWeap.Ammo[1] != none && KFWeap.FireMode[1] != none && KFWeap.FireMode[1].AmmoPerFire > 0 && KFWeap.Ammo[1].AmmoAmount >= KFWeap.FireMode[1].AmmoPerFire)) )
				{
					bOutOfAmmo = false;
					break;
				}
			}

			if ( bOutOfAmmo )
			{
				PlayerController(Instigator.Controller).Speech('AUTO', 3, "");
			}
		}

		return true;
	}
	return false;
}

// Allow this weapon to auto reload on alt fire
simulated function AltFire(float F)
{
	if( !bIsReloading &&
		 FireMode[1].NextFireTime <= Level.TimeSeconds )
	{
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
//end addition

//Added from Dualies.uc
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

// Copied from Dualies.uc
simulated function ZoomIn(bool bAnimateTransition)
{
    super.ZoomIn(bAnimateTransition);

    if( bAnimateTransition )
    {
        if( bZoomOutInterrupted )
        {
            PlayAnim('GOTO_Iron',1.0,0.1);
        }
        else
        {
            PlayAnim('GOTO_Iron',1.0,0.1);
        }
    }
}

simulated function ZoomOut(bool bAnimateTransition)
{
    local float AnimLength, AnimSpeed;
    super.ZoomOut(false);

    if( bAnimateTransition )
    {
        AnimLength = GetAnimDuration('GOTO_Hip', 1.0);

        if( ZoomTime > 0 && AnimLength > 0 )
        {
            AnimSpeed = AnimLength/ZoomTime;
        }
        else
        {
            AnimSpeed = 1.0;
        }
        PlayAnim('GOTO_Hip',AnimSpeed,0.1);
    }
}

function bool HandlePickupQuery( pickup Item )
{
	if ( Item.InventoryType==Class'AA12AutoShotgun' )
	{
		if( LastHasGunMsgTime<Level.TimeSeconds && PlayerController(Instigator.Controller)!=none )
		{
			LastHasGunMsgTime = Level.TimeSeconds+0.5;
			PlayerController(Instigator.Controller).ReceiveLocalizedMessage(Class'KFMainMessages',1);
		}
		return True;
	}
	Return Super.HandlePickupQuery(Item);
}

function float GetAIRating()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;
	return (AIRating + 0.00092 * FMin(800 - VSize(B.Enemy.Location - Instigator.Location),650));
}

function byte BestMode()
{
    return 0;
}

function bool RecommendRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
    return -0.7;
}


function AttachToPawn(Pawn P)
{
	local name BoneName;

	Super.AttachToPawn(P);

	if(altThirdPersonActor == None)
	{
		altThirdPersonActor = Spawn(AttachmentClass,Owner);
		InventoryAttachment(altThirdPersonActor).InitFor(self);
	}
	else altThirdPersonActor.NetUpdateTime = Level.TimeSeconds - 1;
	BoneName = P.GetOffhandBoneFor(self);
	if(BoneName == '')
	{
		altThirdPersonActor.SetLocation(P.Location);
		altThirdPersonActor.SetBase(P);
	}
	else P.AttachToBone(altThirdPersonActor,BoneName);

	if(altThirdPersonActor != None)
		AA12DWAttachment(altThirdPersonActor).bIsOffHand = true;
	if(altThirdPersonActor != None && ThirdPersonActor != None)
	{
		AA12DWAttachment(altThirdPersonActor).brother = AA12DWAttachment(ThirdPersonActor);
		AA12DWAttachment(ThirdPersonActor).brother = AA12DWAttachment(altThirdPersonActor);
		altThirdPersonActor.LinkMesh(AA12DWAttachment(ThirdPersonActor).BrotherMesh);
	}
}

simulated function DetachFromPawn(Pawn P)
{
	Super.DetachFromPawn(P);
	if ( altThirdPersonActor != None )
	{
		altThirdPersonActor.Destroy();
		altThirdPersonActor = None;
	}
}

simulated function Destroyed()
{
	Super.Destroyed();

	if( ThirdPersonActor!=None )
		ThirdPersonActor.Destroy();
	if( altThirdPersonActor!=None )
		altThirdPersonActor.Destroy();
}

simulated function vector GetEffectStart()
{
    local Vector RightFlashLoc,LeftFlashLoc;

    RightFlashLoc = GetBoneCoords(default.FlashBoneName).Origin;
    LeftFlashLoc = GetBoneCoords(default.altFlashBoneName).Origin;

    if (Instigator.IsFirstPerson())
    {
        if ( WeaponCentered() )
            return CenteredEffectStart();

        if( bAimingRifle )
        {
            if( KFFire(GetFireMode(0)).FireAimedAnim == 'LeftFire_Iron' )
            {
                return LeftFlashLoc;
            }
            else
            {
                return RightFlashLoc;
            }
    	}
    	else
    	{
            if (GetFireMode(0).FireAnim == 'LeftFire')
            {
                return LeftFlashLoc;
            }
            else
            {
                return RightFlashLoc;
            }
    	}
    }
    else
    {
        return (Instigator.Location +
            Instigator.EyeHeight*Vect(0,0,0.5) +
            Vector(Instigator.Rotation) * 40.0);
    }
}

simulated function bool PutDown()
{
	if ( Instigator.PendingWeapon.class == class'AA12AutoShotgun' )
	{
		bIsReloading = false;
	}

	return super.PutDown();
}
//End Additions

defaultproperties
{
    altFlashBoneName="Ltip"
	FlashBoneName="tip"
	bDualWeapon=true //Not sure if this one is needed or not

	Skins(0)=Combiner'KF_Weapons2_Trip_T.Special.AA12_cmb'
	SkinRefs(0)="KF_Weapons2_Trip_T.Special.AA12_cmb"
    SleeveNum=1

    WeaponReloadAnim=Reload_AA12 //C?
    IdleAimAnim=Idle_Iron

    MagCapacity=40
    ReloadRate=8.43
    ReloadAnim="Reload"
    ReloadAnimRate=1

    Weight=16
    bModeZeroCanDryFire=True
    FireModeClass(0)=Class'AA12DW.AA12DWFire'
    FireModeClass(1)=Class'AA12DW.AA12DWFireAlt'
    PutDownAnim="PutDown"
    SelectSound=Sound'AA12DW_R.Snd_Select'
    SelectSoundRef="AA12DW_R.Snd_Select"
    SelectForce="SwitchToAssaultRifle"
    bShowChargingBar=True
    Description="Two advanced automatic shotguns, one under each arm!"
    EffectOffset=(X=100,Y=25,Z=-10)
    Priority=200
    InventoryGroup=4
    GroupOffset=10
    PickupClass=Class'AA12DW.AA12DWPickup'
	//+/- X fore/back,Y right/left,Z up/down
	// Use EditActor Class=AA12DW.AA12DWAutoShotgun, look under the None category
    PlayerViewOffset=(X=40,Y=0,Z=-5)
    BobDamping=6
    AttachmentClass=Class'AA12DW.AA12DWAttachment'
    IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
    ItemName="Dual AA12 Shotguns"
    Mesh=SkeletalMesh'AA12DW_R.Mesh1st'
    MeshRef="AA12DW_R.Mesh1st"
    DrawScale=1.00000
    TransientSoundVolume=1.250000
    AmbientGlow=0

    AIRating=0.55
    CurrentRating=0.55

    DisplayFOV=65
    StandardDisplayFOV=65.0//60.0
    PlayerIronSightFOV=80
    ZoomTime=0.25
    FastZoomOutTime=0.2
    ZoomInRotation=(Pitch=-910,Yaw=0,Roll=2910)
    bHasAimingMode=true
    ZoomedDisplayFOV=45

	HudImage=Texture'AA12DW_R.HUD_Unselected'
	HudImageRef="AA12DW_R.HUD_Unselected"
	SelectedHudImage=Texture'AA12DW_R.HUD_Selected'
	SelectedHudImageRef="AA12DW_R.HUD_Selected"
	TraderInfoTexture=texture'AA12DW_R.HUD_Trader'

	bIsTier3Weapon=true
}
