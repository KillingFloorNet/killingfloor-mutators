class MyAmmoPickup extends KFAmmoPickup;

state Pickup
{
	// When touched by an actor.
	function Touch(Actor Other)
	{
		local Inventory CurInv;
		local bool bPickedUp;
		local int AmmoPickupAmount;

		if ( Pawn(Other) != none && Pawn(Other).bCanPickupInventory && Pawn(Other).Controller != none &&
			 FastTrace(Other.Location, Location) )
		{
			for ( CurInv = Other.Inventory; CurInv != none; CurInv = CurInv.Inventory )
			{
				if ( KFAmmunition(CurInv) != none && KFAmmunition(CurInv).bAcceptsAmmoPickups )
				{
					if ( KFAmmunition(CurInv).AmmoPickupAmount > 1 )
					{
						if ( KFAmmunition(CurInv).AmmoAmount < KFAmmunition(CurInv).MaxAmmo )
						{
							if ( KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo).ClientVeteranSkill != none )
							{
								AmmoPickupAmount = float(KFAmmunition(CurInv).AmmoPickupAmount) * KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo).ClientVeteranSkill.static.GetAmmoPickupMod(KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo), KFAmmunition(CurInv));
							}
							else
							{
								AmmoPickupAmount = KFAmmunition(CurInv).AmmoPickupAmount;
							}

							KFAmmunition(CurInv).AmmoAmount = Min(KFAmmunition(CurInv).MaxAmmo, KFAmmunition(CurInv).AmmoAmount + AmmoPickupAmount);
							bPickedUp = true;
						}
					}
					else if ( KFAmmunition(CurInv).AmmoAmount < KFAmmunition(CurInv).MaxAmmo )
					{
						bPickedUp = true;

						if ( FRand() <= (1.0 / Level.Game.GameDifficulty) )
						{
							KFAmmunition(CurInv).AmmoAmount++;
						}
					}
				}
			}

			if ( bPickedUp )
			{
				AnnouncePickup(Pawn(Other));
				//GotoState('FinalSleep', 'Begin');
				Destroy();

				
				/*if ( KFGameType(Level.Game) != none )
				{
					KFGameType(Level.Game).AmmoPickedUp(self);
				}*/
				
			}
			
			
		}
	}
}

state FinalSleep
{
Begin:
	bSleeping = true;
	bHidden = true;
	bShowPickup = true;
	Sleep(1000000.0);
}

auto state Sleeping
{
	ignores Touch;

	function bool ReadyToPickup(float MaxWait)
	{
		return (bPredictRespawns && LatentFloat < MaxWait);
	}

	function StartSleeping() {}

	function BeginState()
	{
		local int i;

		NetUpdateTime = Level.TimeSeconds - 1;
		bHidden = true;
		bSleeping = true;
		SetCollision(false, false);

		for ( i = 0; i < 4; i++ )
		{
			TeamOwner[i] = None;
		}
	}

	function EndState()
	{
		NetUpdateTime = Level.TimeSeconds - 1;
		bHidden = false;
		bSleeping = false;
		SetCollision(default.bCollideActors, default.bBlockActors);
	}

Begin:
	bSleeping = false;
	//Sleep(1000000.0); // Sleep for 11.5 days(never wake up)

DelayedSpawn:
	bSleeping = false;
	//Sleep(RespawnTime/GetNumPlayers()); // Delay before respawning
	goto('Respawn');

TryToRespawnAgain:
	Sleep(1.0);

Respawn:
	bShowPickup = true;
	for ( OtherPlayer = Level.ControllerList; OtherPlayer != none; OtherPlayer=OtherPlayer.NextController )
	{
		if ( PlayerController(OtherPlayer) != none && OtherPlayer.Pawn != none )
		{
	 		/*if ( FastTrace(self.Location, OtherPlayer.Pawn.Location) )
	 		{
	 			bShowPickup = false;
	 			break;
			}*/
		}
	}

	if ( bShowPickup )
	{
		RespawnEffect();
		Sleep(RespawnEffectTime);

		if ( PickUpBase != none )
		{
			PickUpBase.TurnOn();
		}

		GotoState('Pickup');
	}

	Goto('TryToRespawnAgain');
}

defaultproperties
{
}
