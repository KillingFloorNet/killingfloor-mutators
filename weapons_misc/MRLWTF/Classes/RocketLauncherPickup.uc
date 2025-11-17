class RocketLauncherPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=13.000000
     cost=3000
     AmmoCost=500
     BuyClipSize=1
     PowerValue=100
     SpeedValue=20
     RangeValue=64
     Description="A DEADLY WEAPON."
     ItemName="WTF Rocket Launcher"
     ItemShortName="WTF Rocket Launcher"
     AmmoItemName="Nuclear Rockets"
     AmmoMesh=StaticMesh'KillingFloorStatics.LAWAmmo'
     CorrespondingPerkIndex=6
     EquipmentCategoryID=3
     MaxDesireability=0.790000
     InventoryType=Class'MRLWTF.RocketLauncher'
     RespawnTime=60.000000
     PickupMessage="You got the WTF Rocket Launcher"
     PickupSound=Sound'KF_LAWSnd.LAW_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.Super.LAW_Pickup'
     CollisionRadius=35.000000
     CollisionHeight=10.000000
}
