//=============================================================================
// Single Pickup.
//=============================================================================
class ColtPickup extends KFWeaponPickup;



defaultproperties
{
	Weight=4.000000
	cost=200
	AmmoCost=30
	BuyClipSize=7
	PowerValue=30
	SpeedValue=50
	RangeValue=35
	Description="The M1911 is a single-action, semi-automatic, magazine-fed, recoil-operated pistol chambered for the .45 ACP cartridge, which served as the standard-issue sidearm for the United States armed forces from 1911 to 1985."
	ItemName="Colt 1911 .45 ACP"
	ItemShortName="Colt 1911"
	AmmoItemName="9mm Rounds"
	AmmoMesh=StaticMesh'KillingFloorStatics.DualiesAmmo'
	InventoryType=Class'Colt.Colt'
	PickupMessage="You got the  Colt 1911"
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'Colt_SM.Colt'
	CollisionHeight=5.000000
	PickupSound=Sound'KF_9MMSnd.9mm_Pickup'
	EquipmentCategoryID=1
	CorrespondingPerkIndex=2
}
