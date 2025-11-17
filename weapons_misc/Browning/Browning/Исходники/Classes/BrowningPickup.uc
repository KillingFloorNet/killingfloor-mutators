class BrowningPickup extends KFWeaponPickup;

defaultproperties
{
	Weight=10.000000
	cost=2000
	AmmoCost=50
	BuyClipSize=30
	PowerValue=40
	SpeedValue=80
	RangeValue=50
	Description="Browning is a heavy machine gun designed towards the end of World War I by John Browning. And was finalized after a zombie apocalypse."
	ItemName="Browning"
	ItemShortName="Browning"
	AmmoItemName="12.7mm Ammo"
	AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
	InventoryType=Class'Browning.Browning'
	PickupMessage="You got the Browning"
	PickupForce="AssaultRiflePickup"
	DrawType=DT_StaticMesh
	StaticMesh=StaticMesh'Browning.sawBrowning_Pickup'
	DrawScale=1.000000
	CollisionRadius=25.000000
	CollisionHeight=5.000000
	PickupSound=Sound'Browning.Browning_Pickup'
	EquipmentCategoryID=2
	CorrespondingPerkIndex=3
	
}
