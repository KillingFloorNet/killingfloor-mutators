//=============================================================================
// DoomBFGPickup.
//=============================================================================
class DoomBFGPickup extends DoomWeaponPickups;

defaultproperties
{
     Weight=7.000000
     cost=4500
     AmmoCost=120
     BuyClipSize=40
     PowerValue=99
     SpeedValue=10
     RangeValue=24
     Description="The 'Big Fucking Gun'. Somewhat counterintuitive to operate at first, but kills almost any monster in one shot."
     ItemName="BFG 9000"
     AmmoItemName="Plasma Batteries"
     EquipmentCategoryID=3
     AmmoAmount(0)=40
     MaxDesireability=3.000000
     InventoryType=Class'DoomPawnsKF.DoomBFG'
     RespawnTime=80.000000
     PickupMessage="You got the BFG9000."
     Texture=Texture'DoomPawnsKF.BFG.BFUGA0'
     DrawScale3D=(X=2.000000)
}
