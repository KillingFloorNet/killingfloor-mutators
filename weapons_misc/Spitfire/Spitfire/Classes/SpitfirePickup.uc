class SpitfirePickup extends KFWeaponPickup
    config;

defaultproperties
{
     Weight=9.000000
     cost=1500
     AmmoCost=500
     BuyClipSize=100
     PowerValue=50
     SpeedValue=100
     RangeValue=40
     Description="."
     ItemName="Flamethrower 'Spitfire'"
     ItemShortName="Flamethrower 'Spitfire'"
     AmmoItemName="Napalm"
     AmmoMesh=StaticMesh'KillingFloorStatics.FT_AmmoMesh'
     CorrespondingPerkIndex=5
     EquipmentCategoryID=3
     InventoryType=Class'Spitfire.Spitfire'
     PickupMessage="You got the Flamethrower 'Spitfire'"
     PickupSound=Sound'KF_FlamethrowerSnd.FT_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'Spitfire.Spitfire_Pickup'
     CollisionRadius=30.000000
     CollisionHeight=5.000000
}
