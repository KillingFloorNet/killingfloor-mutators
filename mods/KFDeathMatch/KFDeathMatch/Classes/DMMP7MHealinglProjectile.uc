//=============================================================================
// MP7MHealinglProjectile
//=============================================================================
class DMMP7MHealinglProjectile extends MP7MHealinglProjectile;

// Don't allow healing of enemies, nor give score.
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local KFPlayerReplicationInfo PRI;
	local int MedicReward;
	local KFHumanPawn Healed;
	local float HealSum; // for modifying based on perks

	if ( Other == none || Other == Instigator || Other.Base == Instigator )
		return;

	if( Role == ROLE_Authority )
	{
		Healed = KFHumanPawn(Other);
		if( Healed != none )
			HitHealTarget(HitLocation, -vector(Rotation));

		if( Instigator!=none && Healed!=none && Healed.Health>0 && Healed.Health<Healed.HealthMax && Level.Game.bTeamGame
		 && Instigator.GetTeamNum()==Healed.GetTeamNum() )
		{
			MedicReward = HealBoostAmount;

			PRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);

			if ( PRI != none && PRI.ClientVeteranSkill != none )
				MedicReward *= PRI.ClientVeteranSkill.Static.GetHealPotency(PRI);

			HealSum = MedicReward;

			if ( (Healed.Health + Healed.healthToGive + MedicReward) > Healed.HealthMax )
			{
				MedicReward = Healed.HealthMax - (Healed.Health + Healed.healthToGive);
				if ( MedicReward < 0 )
					MedicReward = 0;
			}

			Healed.GiveHealth(HealSum, Healed.HealthMax);

			if ( PRI != None )
			{
				if ( MedicReward > 0 && KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements) != none )
					KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements).AddDamageHealed(MedicReward, true);

				if ( KFHumanPawn(Instigator) != none )
					KFHumanPawn(Instigator).AlphaAmount = 255;
				if( MP7MMedicGun(Instigator.Weapon) != none )
					MP7MMedicGun(Instigator.Weapon).ClientSuccessfulHeal(Healed.PlayerReplicationInfo.PlayerName);
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
