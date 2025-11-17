//=============================================================================
// Radar Pickup.
//=============================================================================
class RadarPickup extends KFWeaponPickup
	CacheExempt;

defaultproperties
{
     Weight=0.000000
     cost=500
     RangeValue=50
     Description="A Motion trader radar device, to aid you in the combat against the enemies."
     ItemName="Motion tracker radar"
     ItemShortName="Radar"
     AmmoItemName="Null"
     CorrespondingPerkIndex=3
     EquipmentCategoryID=3
     InventoryType=Class'KFRadar.RadarGun'
     PickupMessage="You got a Motion tracker radar device."
     PickupSound=Sound'KF_AA12Snd.AA12_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KillingFloorLabStatics.ClipBoardProp'
     DrawScale=0.150000
     CollisionRadius=22.000000
     CollisionHeight=23.000000
}
