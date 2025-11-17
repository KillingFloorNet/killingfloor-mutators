//=============================================================================
// WMediShotgun Pickup.
//=============================================================================
class WeldShotPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=5.000000
     cost=1000
     BuyClipSize=6
     PowerValue=75
     SpeedValue=45
     RangeValue=20
     Description="A modified Supra Shorty shotgun. "
     ItemName="WSG80 WeldGun"
     ItemShortName="WSG80 WeldGun"
     AmmoItemName="12-gauge shells"
     CorrespondingPerkIndex=1
     EquipmentCategoryID=2
     InventoryType=Class'Weldgun.WeldShot'
     PickupMessage="You got the Welder Shotgun."
     PickupSound=Sound'KF_PumpSGSnd.SG_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'MRS138DT_SM.mrs138pickup'
     CollisionRadius=35.000000
     CollisionHeight=5.000000
}
