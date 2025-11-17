//=============================================================================
// Deagle Pickup.
//=============================================================================
class DMDeaglePickup extends DeaglePickup;

function inventory SpawnCopy( pawn Other )
{
	local Inventory I;

	For( I=Other.Inventory; I!=None; I=I.Inventory )
	{
		if( Deagle(I)!=None )
		{
			if( Inventory!=None )
				Inventory.Destroy();
			InventoryType = Class'DMDualDeagle';
			I.Destroyed();
			I.Destroy();
			Return Super(KFWeaponPickup).SpawnCopy(Other);
		}
	}
	InventoryType = Default.InventoryType;
	Return Super(KFWeaponPickup).SpawnCopy(Other);
}

defaultproperties
{
     InventoryType=Class'KFDeathMatch.DMDeagle'
}
