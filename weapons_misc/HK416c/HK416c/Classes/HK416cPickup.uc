class HK416cPickup extends KFWeaponPickup;

defaultproperties
{
	Weight=6.000000
	cost=4000
	AmmoCost=100 //10
	BuyClipSize=30
	PowerValue=55 //40
	SpeedValue=70 //55
	RangeValue=85
	Description="Heckler & Koch HK416"
	ItemName="HK416c"
	ItemShortName="HK416c"
	AmmoItemName="5.56 NATO Ammo"
	AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
	CorrespondingPerkIndex=3
	EquipmentCategoryID=2
	InventoryType=Class'HK416c.HK416c'
	PickupMessage="You got the HK416c"
	PickupSound=Sound'HK416c_R.Pickup'
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'HK416c_R.HK416c_Static'
	DrawScale=0.500000
	CollisionRadius=25.000000
	CollisionHeight=5.000000
}
