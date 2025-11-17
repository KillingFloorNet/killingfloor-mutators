//=============================================================================
// AA12 Shotgun Pickup.
//=============================================================================
class USAS12_V2Pickup extends KFWeaponPickup;

defaultproperties
{
	Weight=10.0
	cost=8000 //5500
	AmmoCost=100 //40
	BuyClipSize=20

	// PowerValue=85
	// SpeedValue=65
	// RangeValue=20

	// Golden AA12 (copy)
	PowerValue=85
	SpeedValue=75
	RangeValue=25

	Description="An advanced fully automatic shotgun."
	ItemName="USAS-12 Shotgun"
	ItemShortName="USAS-12 Shotgun"
	AmmoItemName="12-gauge drum"
	CorrespondingPerkIndex=1
	EquipmentCategoryID=3
	InventoryType=Class'USAS12_V2'
	PickupMessage="You got the USAS-12 auto shotgun."
	PickupSound=Sound'KF_AA12Snd.AA12_Pickup'
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'USAS12_V2_A.USAS12_V2_STC.usas12_v2_w'
	CollisionRadius=35.000000
	CollisionHeight=5.000000
}
