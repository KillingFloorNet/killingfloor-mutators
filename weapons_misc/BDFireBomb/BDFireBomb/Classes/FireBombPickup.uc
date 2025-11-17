//=============================================================================
// Flammable PipeBombPickup Pickup.
//=============================================================================
class FireBombPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=1.000000
     cost=1500
     AmmoCost=750
     BuyClipSize=1
     PowerValue=100
     SpeedValue=5
     RangeValue=15
     Description="An improvised proximity flammable explosive. Blows up when enemies get close."
     ItemName="Fire Bomb"
     ItemShortName="Fire Bomb"
     AmmoItemName="Fire Bomb"
     CorrespondingPerkIndex=5
     EquipmentCategoryID=3
     InventoryType=Class'BDFireBomb.FireBombExplosive'
     PickupMessage="You got the PipeBomb proximity explosive."
     PickupSound=Sound'KF_AA12Snd.AA12_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'BDFLPipeBomb_SM.FlamPipeBombPickup'
     CollisionRadius=35.000000
     CollisionHeight=10.000000
}
