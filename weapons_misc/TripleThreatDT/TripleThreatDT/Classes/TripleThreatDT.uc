//=============================================================================
// M32 MGL Semi automatic grenade launcher Inventory class
//=============================================================================
class TripleThreatDT extends KFWeapon;

//=============================================================================
// Functions
//=============================================================================

simulated function ZoomIn(bool bAnimateTransition)
{
    super.ZoomIn(bAnimateTransition);
	
	bAimingRifle = True;
	
    if( bAnimateTransition )
    {
        if( bZoomOutInterrupted )
        {
            PlayAnim('Zoom_In',1.0,0.1);
        }
        else
        {
            PlayAnim('Zoom_In',1.0,0.1);
        }
    }
}

simulated function ZoomOut(bool bAnimateTransition)
{
    local float AnimLength, AnimSpeed;
    super.ZoomOut(false);

	bAimingRifle = False;
		
    if( bAnimateTransition )
    {
        AnimLength = GetAnimDuration('Zoom_Out', 1.0);

        if( ZoomTime > 0 && AnimLength > 0 )
        {
            AnimSpeed = AnimLength/ZoomTime;
        }
        else
        {
            AnimSpeed = 1.0;
        }
        PlayAnim('Zoom_Out',AnimSpeed,0.1);
    }
}

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

simulated function AddReloadedAmmo()
{
	UpdateMagCapacity(Instigator.PlayerReplicationInfo);

	if(AmmoAmount(0) >= MagCapacity)
			MagAmmoRemaining = MagCapacity;
		else
			MagAmmoRemaining = AmmoAmount(0) ;

	// Don't do this on a "Hold to reload" weapon, as it can update too quick actually and cause issues maybe - Ramm
	if( !bHoldToReload )
	{
		ClientForceKFAmmoUpdate(MagAmmoRemaining,AmmoAmount(0));
	}
}

function float GetAIRating()
{
	local AIController B;

	B = AIController(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	return (AIRating + 0.0003 * FClamp(1500 - VSize(B.Enemy.Location - Instigator.Location),0,1000));
}

function byte BestMode()
{
	return 0;
}

function bool RecommendRangedAttack()
{
	return true;
}

//TODO: LONG ranged?
function bool RecommendLongRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}

defaultproperties
{
     MagCapacity=9
     ReloadRate=2.634000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_M32_MGL"
     Weight=7.000000
     bHasAimingMode=True
     IdleAimAnim="Idle_Iron"
     StandardDisplayFOV=65.000000
     bModeZeroCanDryFire=True
     SleeveNum=1
     TraderInfoTexture=Texture'TripleThreatDT_A.TripleThreatDT_T.triple_threatDT_Trader'
     bIsTier3Weapon=True
     Mesh=SkeletalMesh'TripleThreatDT_A.TripleThreatDT_Mesh'
     Skins(0)=Combiner'TripleThreatDT_A.TripleThreatDT_T.triple_threatDT_cmb'
     SelectSound=Sound'KF_M79Snd.M79_Select'
     HudImage=Texture'TripleThreatDT_A.TripleThreatDT_T.triple_threatDT_Unselected'
     SelectedHudImage=Texture'TripleThreatDT_A.TripleThreatDT_T.triple_threatDT_Selected'
     PlayerIronSightFOV=70.000000
     ZoomedDisplayFOV=40.000000
     FireModeClass(0)=Class'TripleThreatDTFire'
     FireModeClass(1)=Class'TripleThreatDTFireB'
     PutDownAnim="PutDown"
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.650000
     CurrentRating=0.650000
     Description="An advanced semi automatic grenade launcher. Launches high explosive grenades."
     DisplayFOV=65.000000
     Priority=220
     InventoryGroup=4
     GroupOffset=6
     PickupClass=Class'TripleThreatDTPickup'
	PlayerViewOffset=(X=8.000000,Y=11.000000,Z=-3.000000)
     BobDamping=6.000000
     AttachmentClass=Class'TripleThreatDTAttachment'
     IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
     ItemName="Triple Threat Grenade Launcher"
     LightType=LT_None
     LightBrightness=0.000000
     LightRadius=0.000000
}
