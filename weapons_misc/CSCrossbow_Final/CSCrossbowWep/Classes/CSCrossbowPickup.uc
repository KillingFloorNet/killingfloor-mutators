class CSCrossbowPickup extends KFWeaponPickup;

#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=WeaponStaticMesh.usx

defaultproperties
{
	cost=1500
	AmmoCost=40 // Increased in Balance Round 1
	BuyClipSize=50 // Increased in Balance Round 1(but has no real effect)
	Weight=8.000000 // Decreased in Balance Round 7/8
	PowerValue=45
	SpeedValue=100
	RangeValue=100
	Description="A super badass crossbow for badass ninjas, coming with a 'mag' of arrows. Shoots in full-auto mode."
	ItemName="CS:O Crossbow"
	ItemShortName="CS:O Crossbow"
	AmmoItemName="Crossbow Bolts"
	AmmoMesh=StaticMesh'KillingFloorStatics.XbowAmmo'
	MaxDesireability=0.850000
	InventoryType=Class'CSCrossbowWep.CSCrossbow'
	PickupMessage="You got the CS:O Crossbow."
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'CSCrossbow_A.cs_xbow_pickup'
	CollisionRadius=25.000000
	CollisionHeight=5.000000
	PickupSound=Sound'KF_XbowSnd.Xbow_Pickup'
	EquipmentCategoryID=3
	CorrespondingPerkIndex=2
	DrawScale=1.500000
}
