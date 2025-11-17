//=============================================================================
// DoomPlasmaPickup.
//=============================================================================
class DoomPlasmaPickup extends DoomWeaponPickups;

defaultproperties
{
     Weight=4.000000
     cost=1800
     AmmoCost=120
     BuyClipSize=40
     PowerValue=24
     SpeedValue=42
     RangeValue=52
     Description="Shoots pulses of blue-hot plasma at high speed, which can take down groups of incoming enemies easily — if aimed properly."
     ItemName="Plasma gun"
     AmmoItemName="Plasma Batteries"
     EquipmentCategoryID=3
     InventoryType=Class'DoomPawnsKF.DoomPlasmaGun'
     PickupMessage="You got the Plasma Gun."
     Texture=Texture'DoomPawnsKF.PlasmaGun.PLASA0'
     DrawScale3D=(X=2.000000)
}
