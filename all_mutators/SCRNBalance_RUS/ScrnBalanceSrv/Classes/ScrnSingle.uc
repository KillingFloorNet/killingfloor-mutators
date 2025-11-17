class ScrnSingle extends Single;

simulated function bool PutDown()
{
	if (  Instigator.PendingWeapon != none && Instigator.PendingWeapon.class == class'ScrnDualies' )
	{
		bIsReloading = false;
	}

	return super.PutDown();
}

function bool HandlePickupQuery( pickup Item )
{
	if ( Item.InventoryType == Class )
	{
		if ( KFPlayerController(Instigator.Controller) != none )
		{
			KFPlayerController(Instigator.Controller).PendingAmmo = WeaponPickup(Item).AmmoAmount[0];
		}

		return false; // Allow to "pickup" so this weapon can be replaced with dual deagle.
	}

	return Super.HandlePickupQuery(Item);
}

defaultproperties
{
     bKFNeverThrow=False
     FireModeClass(0)=Class'ScrnBalanceSrv.ScrnSingleFire'
     Priority=4
     PickupClass=Class'ScrnBalanceSrv.ScrnSinglePickup'
     ItemName="9mm Tactical SE"
}
