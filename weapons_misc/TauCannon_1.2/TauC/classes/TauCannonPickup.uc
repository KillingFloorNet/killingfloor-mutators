class TauCannonPickup extends HuskGunPickup;
//class TauCannonPickup extends KFWeaponPickup;

defaultproperties
{
    Weight=10
    cost=4000
	//Game is dividing the ammo cost per shot by the weapon's magazine size,
	//so 200 shots for 1000 comes out to 5 per shot, but topping off is nearly
	//impossible since it expects players to buy the full ammount instead of
	//the BuyClipSize value.
    AmmoCost=100 //1000 //We want it to be 5 per shot
    BuyClipSize=25
    PowerValue=100
    SpeedValue=25
    RangeValue=75
    Description="The XVL-1456 is an obviously-prototypical energy weapon with awesome damage-dealing ability, both to targets and the user if they charge the alt-fire for too long! [Original from Black Mesa Source by Crowbar Collective, port by BoF]"
    ItemName="Tau Cannon"
	ItemShortName="Tau Cannon"
    AmmoItemName="Tau Cannon Fuel Cells"
    AmmoMesh=StaticMesh'KillingFloorStatics.FT_AmmoMesh'
    MaxDesireability=0.790000
    InventoryType=Class'TauC.TauCannon'
    PickupMessage="You got the Tau Cannon."
    PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'TC_R.TCPickup'
	DrawScale=0.6
	Skins(0)=Texture'TC_R.TC3rd_tex'
    CollisionRadius=25.000000
    CollisionHeight=10.000000
	PickupSound=Sound'KF_HuskGunSnd.Husk_Pickup'
    EquipmentCategoryID=3
    CorrespondingPerkIndex=3
}
