//=============================================================================
// DoomChaingunPickup.
//=============================================================================
class DoomChaingunPickup extends DoomWeaponPickups;

defaultproperties
{
     Weight=3.000000
     cost=400
     BuyClipSize=40
     PowerValue=12
     SpeedValue=32
     RangeValue=46
     Description="Very good against large crowds, but uses up a lot of ammo if not handled carefully."
     ItemName="Chaingun"
     AmmoItemName="9mm Pistol Clips"
     EquipmentCategoryID=2
     InventoryType=Class'DoomPawnsKF.DoomChaingun'
     PickupMessage="You got the Chaingun."
     Texture=Texture'DoomPawnsKF.Chaingun.MGUNA0'
     DrawScale3D=(X=2.000000)
}
