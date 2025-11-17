class AmmoCraftGunPickup extends KFWeaponPickup;

defaultproperties
{
	Weight=1.000000
	cost=0
	AmmoCost=500
	BuyClipSize=1
	PowerValue=0
	SpeedValue=5
	RangeValue=30
	Description="Launches ammo boxes" //"A classic Vietnam era grenade launcher. Launches single high explosive grenades."
	ItemName="Ammo Craft Gun" //"M79 Grenade Launcher"
	ItemShortName="Ammo Craft Gun" //"M79 Launcher"
	AmmoItemName="Ammo" //"M79 Grenades"
	AmmoMesh=StaticMesh'KillingFloorStatics.XbowAmmo'
	CorrespondingPerkIndex=1
	EquipmentCategoryID=2
	// VariantClasses(0)=Class'KFMod.GoldenM79Pickup'
	MaxDesireability=0.790000
	InventoryType=Class'AmmoCraftGun'
	PickupMessage="You got the Ammo Craft Gun" //"You got the M79 Grenade Launcher."
	PickupSound=Sound'KF_M79Snd.M79_Pickup'
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'KF_pickups2_Trip.Supers.M79_Pickup'
	Skins(0)=Texture'KF_Weapons3rd_Gold_T.Weapons.Gold_M79_3rd'
	CollisionRadius=25.000000
	CollisionHeight=10.000000
}
