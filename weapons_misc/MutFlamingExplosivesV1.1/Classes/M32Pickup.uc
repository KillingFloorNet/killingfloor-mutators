class M32Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=7.000000
     cost=1125
     BuyClipSize=6
     PowerValue=85
     SpeedValue=65
     RangeValue=75
     Description="An advanced semi automatic grenade launcher. Launches high explosive grenades."
     ItemName="M32 Grenade Launcher"
     ItemShortName="M32 Launcher"
     AmmoItemName="M32 Grenades"
     AmmoMesh=StaticMesh'KillingFloorStatics.XbowAmmo'
     CorrespondingPerkIndex=6
     EquipmentCategoryID=2
     MaxDesireability=0.790000
     InventoryType=Class'KFProd.M32GrenadeLauncher'
     PickupMessage="You got the M32 Multiple Grenade Launcher."
     PickupSound=Sound'KF_M79Snd.M79_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups2_Trip.Supers.M32_MGL_Pickup'
     CollisionRadius=25.000000
     CollisionHeight=10.000000
}
