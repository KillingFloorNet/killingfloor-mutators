//=============================================================================
// DoomRLPickup.
//=============================================================================
class DoomRLPickup extends DoomWeaponPickups;

defaultproperties
{
     Weight=5.000000
     cost=2500
     AmmoCost=80
     BuyClipSize=5
     PowerValue=64
     SpeedValue=25
     RangeValue=54
     Description="Fires explosive rockets. Does a lot of damage, but can also seriously hurt the player if used indiscriminately at close range."
     ItemName="Rocket launcher"
     AmmoItemName="64 mm rocket shells"
     EquipmentCategoryID=3
     InventoryType=Class'DoomPawnsKF.DoomRL'
     PickupMessage="You got the Rocket Launcher."
     Texture=Texture'DoomPawnsKF.RocketLauncher.LAUNA0'
     DrawScale3D=(X=2.000000)
}
