//=============================================================================
// L85 Pickup.
//=============================================================================
class WTFEquipSA80Pickup extends KFWeaponPickup;

simulated function RenderPickupImage(Canvas C)
{
	C.SetPos((C.SizeX - C.SizeY) / 2,0);
	C.DrawTile( Texture'KillingFloorHUD.Trader_Weapon_Images.Trader_Bullpup', C.SizeY, C.SizeY, 0.0, 0.0, 256, 256);
}

defaultproperties
{
	Weight=9.000000
	BuyClipSize=5
	PowerValue=90
	SpeedValue=40
	RangeValue=100
	Description="A deadly weapon."
	ItemName="SA80 Sniper Rifle"
	ItemShortName="SA80 Sniper Rifle"
	AmmoItemName="SA80 Ammo"
	AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
	CorrespondingPerkIndex=2
	EquipmentCategoryID=4
	InventoryType=Class'WTFEquipSA80a'
	PickupMessage="You got the SA80 Sniper Rifle"
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'WTF_A.SA80Pickup'
	DrawScale=0.400000
	CollisionRadius=25.000000
	CollisionHeight=5.000000
}
