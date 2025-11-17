class M202A1Pickup extends LAWPickup;

#exec OBJ LOAD FILE=M202_T.utx
#exec OBJ LOAD FILE=M202_SM.usx

defaultproperties
{
	Weight=14.000000
	cost=6000
	BuyClipSize=4
	PowerValue=100
	SpeedValue=20
	RangeValue=64
	AmmoCost=320
	Description=""
	ItemName="M202 A1 Flash"
	ItemShortName="M202 A1"
	AmmoItemName="66 mm incendiary rockets"
	AmmoMesh=StaticMesh'M202_SM.RocketBoxInc'
	MaxDesireability=0.790000
	InventoryType=Class'M202A1fw'
	RespawnTime=60.000000
	PickupMessage="You got the M202 A1"
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'M202_SM.M202A1'
	CollisionRadius=35.000000
	CollisionHeight=10.000000
	PickupSound=Sound'KF_LAWSnd.LAW_Pickup'
	EquipmentCategoryID=3
	CorrespondingPerkIndex=5
}
