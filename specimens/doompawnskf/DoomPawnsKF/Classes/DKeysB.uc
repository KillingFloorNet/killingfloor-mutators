Class DKeysB extends Inventory;

function Activate();
function TravelPostAccept()
{
	Destroy(); // Keys do not travel
}

defaultproperties
{
     PickupClass=Class'DoomPawnsKF.DoomBlueKey'
     IconMaterial=Texture'DoomPawnsKF.keys.BKEYA0'
     ItemName="Blue key card"
}
