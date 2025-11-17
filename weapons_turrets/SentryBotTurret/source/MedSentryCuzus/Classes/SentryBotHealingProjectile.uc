class SentryBotHealingProjectile extends HealingProjectile;

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local KFPlayerReplicationInfo PRI;
	local int MedicReward;
	local KFHumanPawn Healed;
	local float HealSum;
	local Pawn SentryOwner;

	SentryOwner=SentryBotTurret(Instigator).OwnerPawn;
	if(SentryOwner==none)
		return;

	if	(
			Other == none
			||	Other == Instigator
			||	Other.Base == Instigator
		)
	{
		return;
	}
	if(Role == ROLE_Authority)
	{
		Healed = KFHumanPawn(Other);
		if(Healed != none)
			HitHealTarget(HitLocation, -vector(Rotation));

		if	(
				Instigator != none
				&&	Healed != none
				&&	Healed.Health > 0
				&&	Healed.Health <  Healed.HealthMax
				&&	Healed.bCanBeHealed
			)
		{
			MedicReward = HealBoostAmount;
			PRI = KFPlayerReplicationInfo(SentryOwner.PlayerReplicationInfo);
			if(PRI != none && PRI.ClientVeteranSkill != none)
			{
				MedicReward *= PRI.ClientVeteranSkill.Static.GetHealPotency(PRI);
			}
			HealSum = MedicReward;
			if(Healed.Health + Healed.healthToGive + MedicReward > Healed.HealthMax)
			{
				MedicReward = Healed.HealthMax - (Healed.Health + Healed.healthToGive);
				if(MedicReward < 0)
				{
					MedicReward = 0;
				}
			}
			Healed.GiveHealth(HealSum, Healed.HealthMax);
			if(PRI != None && Healed!=SentryOwner)
			{
				if(MedicReward > 0 && KFSteamStatsAndAchievements(PRI.SteamStatsAndAchievements) != none)
				{
					AddDamagedHealStats( MedicReward );
				}
				MedicReward = int((FMin(float(MedicReward),Healed.HealthMax)/Healed.HealthMax) * 60);
				PRI.ReceiveRewardForHealing( MedicReward, Healed );
				if ( KFHumanPawn(Instigator) != none )
				{
					KFHumanPawn(Instigator).AlphaAmount = 255;
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

function AddDamagedHealStats(int MedicReward)
{
	local KFSteamStatsAndAchievements KFSteamStats;
	if(Instigator == none || Instigator.PlayerReplicationInfo == none)
	{
		return;
	}
	KFSteamStats = KFSteamStatsAndAchievements(Instigator.PlayerReplicationInfo.SteamStatsAndAchievements);
	if(KFSteamStats != none)
	{
		KFSteamStats.AddDamageHealed(MedicReward);
	}
}

defaultproperties
{
	HealBoostAmount=20
}
