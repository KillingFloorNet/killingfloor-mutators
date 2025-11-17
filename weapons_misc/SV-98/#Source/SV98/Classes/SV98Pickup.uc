class SV98Pickup extends KFWeaponPickup;

defaultproperties
{
     cost=1500
     AmmoCost=100
     BuyClipSize=60
     Weight=6.000000
     PowerValue=75
     SpeedValue=50
     RangeValue=100
     Description="The SV-98 is a Russian bolt action sniper rifle designed by Vladimir Stronskiy. In 2003 special operations troops were armed with the 7.62 mm 6S11 sniper system comprising the SV-98 sniper rifle (index 6V10) and 7N14 sniper enhanced penetration round. The rifle has been used in combat during operations in Chechnya."
     ItemName="SV-98"
     ItemShortName="SV-98"
     AmmoItemName="7.62mm Ammo"
     MaxDesireability=0.790000
     InventoryType=Class'SV98SniperRifle'
     PickupMessage="You got the SV-98."
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'SV98_A.SV98_Pickup'
     CollisionRadius=25.000000
     CollisionHeight=10.000000
     PickupSound=Sound'KF_M14EBRSnd.M14EBR_Pickup'
     EquipmentCategoryID=3
     CorrespondingPerkIndex=2
}
