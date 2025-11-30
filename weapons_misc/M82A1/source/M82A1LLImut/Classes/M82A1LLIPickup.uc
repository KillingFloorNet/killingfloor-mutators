class M82A1LLIPickup extends KFWeaponPickup;

#exec OBJ LOAD FILE="M82A1LLI_A.ukx" PACKAGE=M82A1LLI_A

defaultproperties
{
	Weight=14.000000
	cost=6000
	BuyClipSize=10
	AmmoCost=260
	PowerValue=100
	SpeedValue=15
	RangeValue=100
	Description="Barrett M82A1 - recoil-operated, semi-automatic anti-material rifle developed by the American Barrett Firearms Manufacturing company."
	ItemName="M82A1"
	ItemShortName="Barrett M82A1"
	AmmoItemName="Bullets 12,7x99 mm"
	//showMesh=SkeletalMesh'M82A1LLI_A.M82A1LLI_3rd'
	Mesh=SkeletalMesh'M82A1LLI_A.M82A1LLI_3rd'
	CorrespondingPerkIndex=2
	EquipmentCategoryID=2
	InventoryType=Class'M82A1LLImut.M82A1LLI'
	PickupMessage="You got the Barrett M82A1"
	PickupSound=Sound'M82A1LLI_A.M82A1LLI_Snd.M82A1LLI_pickup'
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'M82A1LLI_A.M82A1LLI_st'
	CollisionRadius=30.000000
	CollisionHeight=5.000000
}
