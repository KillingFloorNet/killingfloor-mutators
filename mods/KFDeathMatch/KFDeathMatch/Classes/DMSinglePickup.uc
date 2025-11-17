//=============================================================================
// Single Pickup.
//=============================================================================
class DMSinglePickup extends SinglePickup;

function inventory SpawnCopy( pawn Other )
{
	local Inventory I;

	For( I=Other.Inventory; I!=None; I=I.Inventory )
	{
		if( Single(I)!=None )
		{
			if( Inventory!=None )
				Inventory.Destroy();
			InventoryType = Class'DMDualies';
			I.Destroyed();
			I.Destroy();
			return Super(KFWeaponPickup).SpawnCopy(Other);
		}
	}
	InventoryType = Default.InventoryType;
	Return Super(KFWeaponPickup).SpawnCopy(Other);
}

defaultproperties
{
     InventoryType=Class'KFDeathMatch.DMSingle'
}
