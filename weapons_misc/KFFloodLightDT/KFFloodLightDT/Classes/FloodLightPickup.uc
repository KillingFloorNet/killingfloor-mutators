class FloodLightPickup extends KFWeaponPickup;

defaultproperties
{
	Weight=1.000000
	cost=1500
	AmmoCost=9000
	BuyClipSize=1
	PowerValue=0
	SpeedValue=0
	RangeValue=0
	Description="FloodLight"
	ItemName="FloodLight"
	ItemShortName="FloodLight"
	AmmoItemName="FloodLight"
	InventoryType=Class'FLight'
	PickupMessage="You got a FloodLight."
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'FloodLightDT_SM.FloodLightModDT_sm'
	CollisionRadius=22
	CollisionHeight=2
	PickupSound=Sound'KF_AA12Snd.AA12_Pickup'
	EquipmentCategoryID=3
	CorrespondingPerkIndex=7
	Skins(0)=Texture'KillingFloorTextures.Statics.FloodLightSkin'
	DrawScale=1.45000
}