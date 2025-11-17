class MHMP7MHealinglProjectile extends MP7MHealinglProjectile;

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local KFPlayerReplicationInfo PRI;
	local int MedicReward;
	local Pawn Healed;
	local float HealSum; // for modifying based on perks

	if ( Other == none || Other == Instigator || Other.Base == Instigator )
		return;

	if( Role == ROLE_Authority )
	{
		Healed = Pawn(Other);

		if( Healed != none )
		{
			HitHealTarget(HitLocation, -vector(Rotation));
		}

		if( Instigator != none && Healed != none && Healed.Health > 0 &&
			Healed.Health <  Healed.HealthMax )
		{

			MedicReward = HealBoostAmount;

			PRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);

			if ( PRI != none && PRI.ClientVeteranSkill != none )
			{
				MedicReward *= PRI.ClientVeteranSkill.Static.GetHealPotency(PRI);
			}

			HealSum = MedicReward;

			if(KFMonster(healed) != none)
				HealSum = Max(Healed.HealthMax * 0.2,200);

			if ( (Healed.Health + MedicReward) > Healed.HealthMax )
			{
				MedicReward = Healed.HealthMax - Healed.Health;
				if ( MedicReward < 0 )
				{
					MedicReward = 0;
				}
			}

			Healed.GiveHealth(HealSum, Healed.HealthMax);

	 		if ( PRI != None )
			{
				if ( MedicReward > 0 && KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements) != none )
				{
					KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements).AddDamageHealed(MedicReward, true);
				}

				// Give the medic reward money as a percentage of how much of the person's health they healed
				MedicReward = int((FMin(float(MedicReward),Healed.HealthMax)/Healed.HealthMax) * 40);

				PRI.Score += MedicReward;
				PRI.ThreeSecondScore += MedicReward;
   				PRI.Team.Score += MedicReward;

				if ( KFHumanPawn(Instigator) != none )
				{
					KFHumanPawn(Instigator).AlphaAmount = 255;
				}

				if( MP7MMedicGun(Instigator.Weapon) != none )
				{
					MP7MMedicGun(Instigator.Weapon).ClientSuccessfulHeal(Healed.PlayerReplicationInfo.PlayerName);
				}
			}
		}
	}
	else if( KFHumanPawn(Other) != none )
	{
		bHidden = true;
		SetPhysics(PHYS_None);
		return;
	}

	Explode(HitLocation,-vector(Rotation));
}

defaultproperties
{
}
