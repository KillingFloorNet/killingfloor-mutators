class MyPlayerController extends KFPlayerController;
function ServerUse()
{
    local Actor A;
	local Vehicle DrivenVehicle, EntryVehicle, V;

	if ( Role < ROLE_Authority )
		return;

    if ( Level.Pauser == PlayerReplicationInfo )
    {
        SetPause(false);
        return;
    }

    if (Pawn == None || !Pawn.bCanUse)
        return;

	DrivenVehicle = Vehicle(Pawn);
	if( DrivenVehicle != None )
	{
		DrivenVehicle.KDriverLeave(false);
		return;
	}

    // Check for nearby vehicles
    ForEach Pawn.VisibleCollidingActors(class'Vehicle', V, VehicleCheckRadius)
    {
        // Found a vehicle within radius
        EntryVehicle = V.FindEntryVehicle(Pawn);
        if (EntryVehicle != None && EntryVehicle.TryToDrive(Pawn))
            return;
    }

    // Send the 'DoUse' event to each actor player is touching.
    ForEach Pawn.TouchingActors(class'Actor', A)
       CheckWeaponPickupUse(A, Pawn); //OVERRIDE THIS FOR WEAPON PICKUP

	if ( Pawn.Base != None )
		Pawn.Base.UsedBy( Pawn );
}

//P is player
//A is object
function CheckWeaponPickupUse(Actor A, Pawn P)
{
	if(KFWeaponPickup(A) != None)
	{
		WeaponTouch(KFWeaponPickup(A), P);
	}
	A.UsedBy(P);
}

function WeaponTouch(KFWeaponPickup A, Actor Other)
{
	local Inventory Copy;

	if ( KFHumanPawn(Other) != none && !A.CheckCanCarry(KFHumanPawn(Other)) )
	{
		return;
	}

	// If touched by a player pawn, let him pick this up.
	if ( true )
	{
		Copy = A.SpawnCopy(Pawn(Other));
		A.AnnouncePickup(Pawn(Other));
		A.SetRespawn();

		if ( Copy != None )
		{
			Copy.PickupFunction(Pawn(Other));
		}

		if ( A.MySpawner != none && KFGameType(Level.Game) != none )
		{
			KFGameType(Level.Game).WeaponPickedUp(A.MySpawner);
		}

		if ( KFWeapon(Copy) != none )
		{
			KFWeapon(Copy).SellValue = A.SellValue;
			KFWeapon(Copy).bPreviouslyDropped = A.bDropped;

			if ( !A.bPreviouslyDropped && KFWeapon(Copy).bIsTier3Weapon &&
				 Pawn(Other).Controller != none && Pawn(Other).Controller != A.DroppedBy )
			{
				KFWeapon(Copy).Tier3WeaponGiver = A.DroppedBy;
			}
		}
	}
}

defaultproperties
{
}
