class M249Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=9.000000
     cost=4000
     AmmoCost=10
     BuyClipSize=30
     PowerValue=42
     SpeedValue=90
     RangeValue=50
     Description="The M249 light machine gun (LMG), previously designated the M249 Squad Automatic Weapon (SAW), and formally written as Light Machine Gun, 5.56 mm, M249, is an American version of the Belgian FN Minimi, a light machine gun manufactured by the Belgian company FN Herstal (FN)."
     ItemName="M249 SAW"
     ItemShortName="M249 SAW"
     AmmoItemName="Bullets 5,56mm NATO"
     showMesh=SkeletalMesh'm249_A.m249_3rd'
     AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
     CorrespondingPerkIndex=3
     EquipmentCategoryID=2
     InventoryType=Class'M249Mut.M249'
     PickupMessage="You got the M249 SAW"
     PickupSound=Sound'm249_A.m249_pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'm249_A.M249_ST'
     CollisionRadius=25.000000
     CollisionHeight=5.000000
}
