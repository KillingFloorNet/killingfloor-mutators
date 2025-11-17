Class DoomBlueKey extends TournamentPickup
	Placeable;

function RespawnEffect()
{
	spawn(class'DRespawnEffect');
}
Auto state Pickup
{
	function bool ValidTouch( actor Other )
	{
		local Inventory I;
		// make sure its a live player
		if ( (Pawn(Other) == None) || !Pawn(Other).bCanPickupInventory || (Pawn(Other).DrivenVehicle == None && Pawn(Other).Controller == None) )
			return false;

		For( I=Pawn(Other).Inventory; I!=None; I=I.Inventory )
		{
			if( I.Class==InventoryType )
				Return False;
		}
		// make sure not touching through wall
		if ( !FastTrace(Other.Location, Location) )
			return false;

		// make sure game will let player pick me up
		if( Level.Game.PickupQuery(Pawn(Other), self) )
		{
			TriggerEvent(Event, self, Pawn(Other));
			return true;
		}
		return false;
	}
}
function SetRespawn()
{
	if( RespawnTime>0 )
		StartSleeping();
	else
		Destroy();
}

defaultproperties
{
     InventoryType=Class'DoomPawnsKF.DKeysB'
     RespawnTime=3.000000
     PickupMessage="You got the blue key card"
     PickupSound=Sound'DoomPawnsKF.Generic.DSITEMUP'
     DrawType=DT_Sprite
     Texture=Texture'DoomPawnsKF.keys.BKEYA0'
}
