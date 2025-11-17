class M134DTPickup extends KFWeaponPickup;

var float StoreHeatLevel;

function inventory SpawnCopy( pawn Other )
{
	local inventory Copy;
	if ( Inventory != None )
	{
		Copy = Inventory;
		Inventory = None;
	}
	else
		Copy = spawn(InventoryType,Other,,,rot(0,0,0));
	if(M134DT(Copy)!=none)
		M134DT(Copy).HeatLevel=StoreHeatLevel;
	Copy.GiveTo( Other, self );
	return Copy;
}

simulated event Tick(float dt)
{
	super.Tick(dt);
	
	if (StoreHeatLevel > 0)
		StoreHeatLevel = FMax(0, StoreHeatLevel - dt/10);
}

defaultproperties
{
	Weight=13.000000
	cost=4000
	AmmoCost=200
	BuyClipSize=200
	PowerValue=44
	SpeedValue=100
	RangeValue=50
	Description=""
	ItemName="M-134"
	ItemShortName="M-134"
	AmmoItemName="7.62x51mm Ammo"
	AmmoMesh=StaticMesh'KillingFloorStatics.FT_AmmoMesh'
	CorrespondingPerkIndex=3 // Commando
	EquipmentCategoryID=3
	InventoryType=Class'M134DT'
	PickupMessage="You got the minigun."
	PickupSound=Sound'KF_HuskGunSnd.foley.Husk_Pickup'
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'm134DT_A.M134DT_sm.M134DT_pickup'
	CollisionRadius=25.000000
	CollisionHeight=5.000000
	DrawScale=0.60
}