class FlarePickup extends KFWeaponPickup;

defaultproperties
{
     Weight=1.000000
     cost=50
     AmmoCost=5
     BuyClipSize=1
     Description="Bright light with minimal smoke and heat; lightweight; easily-stored; these would make some excellent flares if the damp hadn't gotten into them."
     ItemName="Flares"
     ItemShortName="Flares"
     AmmoItemName="Emergency Flares"
     AmmoMesh=StaticMesh'Flare_R.FlareMeshPickup'
     CorrespondingPerkIndex=7
     EquipmentCategoryID=3
     InventoryType=Class'Flares.FlareHandheld'
     PickupMessage="You got some emergency flares."
     PickupSound=Sound'KF_GrenadeSnd.Nade_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'Flare_R.FlareMeshPickup'
     DrawScale=0.400000
     CollisionRadius=35.000000
     CollisionHeight=5.000000
}
