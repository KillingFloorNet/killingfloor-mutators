class AK12LLIPickup extends KFWeaponPickup;

defaultproperties
{
	Weight=7.000000
	cost=8000 //3500
	BuyClipSize=30
	AmmoCost=150
	PowerValue=55
	SpeedValue=80
	RangeValue=30
	Description="The Kalashnikov AK12 (formerly АK-200) is a 5.45x39mm assault rifle. It is the newest derivative of the Soviet/Russian AK (Avtomat Kalshnikova) series of rifles and was proposed for a possible general issue to the Russian Army."
	ItemName="AK-12"
	ItemShortName="AK-12"
	AmmoItemName="AK12 bullets"
	AmmoMesh=StaticMesh'KillingFloorStatics.L85Ammo'
	CorrespondingPerkIndex=3
	EquipmentCategoryID=2
	InventoryType=Class'AK12LLIAssaultRifle'
	PickupMessage="You got the AK-12"
	PickupSound=Sound'AK12LLI_A.AK12LLI_Snd.AK12LLI_select'
	PickupForce="AssaultRiflePickup"
	StaticMesh=StaticMesh'AK12LLI_A.AK12LLI_st'
	DrawScale=1.100000
	CollisionRadius=25.000000
	CollisionHeight=5.000000
}
