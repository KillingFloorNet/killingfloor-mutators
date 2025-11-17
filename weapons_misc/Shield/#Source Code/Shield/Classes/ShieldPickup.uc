class ShieldPickup extends KFWeaponPickup
    config;

defaultproperties
{
    Weight=1.0
    cost=5000
    AmmoCost=1
    BuyClipSize=500
    SpeedValue=10
    Description="Riot shields are lightweight protection devices deployed by police and some military organizations."
    ItemName="Shield"
    ItemShortName="Shield"
    AmmoItemName="Shield"
    EquipmentCategoryID=0
    CorrespondingPerkIndex=4
    InventoryType=Class'Shield'
    PickupMessage="You got Shield"
    PickupForce="AssaultRiflePickup"
    StaticMesh=StaticMesh'ShieldUM.Shield_Pickup'
    PickupSound=Sound'KF_AxeSnd.Axe_Pickup'
    CollisionRadius=30.0
    CollisionHeight=5.0
}