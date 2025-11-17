class AA12DWPickup extends AA12Pickup;

defaultproperties
{
	Weight=16
	cost=6500
	AmmoCost=100 //80
	BuyClipSize=40
	PowerValue=100
	SpeedValue=100
	RangeValue=30
	Description="Two fully automatic shotguns, one under each arm!"
	ItemName="Dual AA12 Shotguns"
	ItemShortName="Dual AA12s"
	InventoryType=Class'AA12DW.AA12DWAutoShotgun'
	PickupMessage="You got dual AA12 shotguns."
	StaticMesh=StaticMesh'AA12DW_R.MeshPickup'
	PickupSound=Sound'AA12DW_R.Snd_Pickup'
}
