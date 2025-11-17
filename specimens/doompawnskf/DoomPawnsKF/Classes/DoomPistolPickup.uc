//=============================================================================
// DoomPistolPickup.
//=============================================================================
class DoomPistolPickup extends DoomWeaponPickups;

defaultproperties
{
     Weight=1.000000
     cost=50
     BuyClipSize=40
     PowerValue=12
     SpeedValue=14
     RangeValue=68
     Description="The default long-range weapon. Not too effective."
     ItemName="Pistol"
     AmmoItemName="9mm Pistol Clips"
     EquipmentCategoryID=1
     InventoryType=Class'DoomPawnsKF.DoomPistol'
     PickupMessage="You got a Pistol."
     Texture=Texture'DoomPawnsKF.pistol.PISGF0'
     DrawScale3D=(X=2.000000)
}
