//=============================================================================
// DoomShotgunPickup.
//=============================================================================
class DoomShotgunPickup extends DoomWeaponPickups;

defaultproperties
{
     Weight=2.000000
     cost=400
     AmmoCost=40
     BuyClipSize=10
     PowerValue=18
     SpeedValue=15
     RangeValue=43
     Description="A good general-purpose weapon, especially at close range. Reload time is slightly longer than normal."
     ItemName="Shotgun"
     AmmoItemName="33 mg shotgun shells"
     EquipmentCategoryID=2
     InventoryType=Class'DoomPawnsKF.DoomShotgun'
     PickupMessage="You got the Shotgun."
     Texture=Texture'DoomPawnsKF.Shotgun.SHOTA0'
     DrawScale3D=(X=2.000000)
}
