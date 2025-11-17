class WeaponPickupGameRules extends GameRules;

function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup)
{
	if ( (NextGameRules != None) &&  NextGameRules.OverridePickupQuery(Other, item, bAllowPickup) )
		return true;

	if(KFWeaponPickup(item) != None)
	{
		//item is a weapon, disable pickup
		bAllowPickup = 0;


		if ( KFHumanPawn(Other) != none && !KFWeaponPickup(item).CheckCanCarry(KFHumanPawn(Other)) )
		{
			return true;
		}

		PlayerController(Other.Controller).ReceiveLocalizedMessage(class'WeaponPickupMutator.Msg_WeaponPickupNotification', 1, None, None, item);
		
	}
	else
	{
		bAllowPickup = 1;
	}


	return true;
}

defaultproperties
{
}
