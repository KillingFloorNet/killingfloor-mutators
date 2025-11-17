//=============================================================================
// G3 By Secret_Agent[AZE]
// Операция Ы
//=============================================================================
class EvoProSAPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=3.000000
     cost=800
     AmmoCost=10
     BuyClipSize=30
     PowerValue=40
     SpeedValue=80
     RangeValue=50
     Description="EvoPro From CoD Ghosts."
     ItemName="EVO-PRO"
     ItemShortName="EVO-PRO"
     AmmoItemName="4.6x30mm Ammo"
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     CorrespondingPerkIndex=3
     EquipmentCategoryID=2
     InventoryType=Class'EvoProSAMut.EvoProSAAssaultRifle'
     PickupMessage="You got the EVO-PRO"
     PickupSound=Sound'EvoProSA_A.PROSND.EvoProPickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'EvoProSA_A.ProStatic.EvoProPickupSA'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
