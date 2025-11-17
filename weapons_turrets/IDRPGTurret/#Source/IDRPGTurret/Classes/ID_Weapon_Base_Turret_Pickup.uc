class ID_Weapon_Base_Turret_Pickup extends KFWeaponPickup;

defaultproperties
{ 
    Cost=2000
    AmmoCost=5000
    BuyClipSize=1
    InventoryType=Class'IDRPGTurret.ID_Weapon_Base_Turret'
    Description="A USCM Sentry Gun."  
    AmmoItemName="USCM Sentry Gun"
    CorrespondingPerkIndex=3
    EquipmentCategoryID=3
    PickupMessage="You got a USCM Sentry Gun"
    PickupSound=Sound'KF_AA12Snd.AA12_Pickup'
    PickupForce="AssaultRiflePickup"
    StaticMesh=StaticMesh'IDRPGTurret_SM.Laptop'
    Skins(0)=Combiner'IDRPGTurret_T.Weapons.SentryLaptopFinal'
    CollisionRadius=22
    CollisionHeight=23
}
