class AssaultRiflePickup extends KFWeaponPickup;

#exec OBJ LOAD FILE=AssaultRifleU_A.ukx
#exec OBJ LOAD FILE=AssaultRifle_SM.usx

defaultproperties
{
	Weight=6.000000
	cost=650
	BuyClipSize=100
	PowerValue=17
	SpeedValue=85
	RangeValue=40
	AmmoCost=60
	Description="The Assault Rifle from Unreal"
	ItemName="AssaultRifle"
	ItemShortName="AssaultRifle"
	AmmoItemName=".300 JHP Ammo"
	showMesh=SkeletalMesh'AssaultRifleU_A.AssaultRifle_3rd'
	AmmoMesh=none
	InventoryType=Class'AssaultRifleUnreal2k4.AssaultRifle'
	PickupMessage="You got the AssaultRifle"
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'AssaultRifle_SM.AssaultRifle3rd'
	DrawScale=1.000000
	CollisionRadius=20.000000
	CollisionHeight=5.000000
	PickupSound=Sound'AssaultRifleU_Snd.SwitchToAssaultRifle'
	EquipmentCategoryID=3
	CorrespondingPerkIndex=3
}
