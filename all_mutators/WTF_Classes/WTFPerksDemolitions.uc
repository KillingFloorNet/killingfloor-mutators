class WTFPerksDemolitions extends KFVetDemolitions
	abstract;

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	if ( class<DamTypeFrag>(DmgType) != none || class<DamTypePipeBomb>(DmgType) != none ||
		 class<DamTypeM79Grenade>(DmgType) != none || class<DamTypeM32Grenade>(DmgType) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
		{
			return float(InDamage) * 1.05;
		}

		return float(InDamage) * (1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel))); //  Up to 60% extra damage
	}

	return InDamage;
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'WTFEquipPipeBombPickup' )
	{
		return 0.25 - (0.03 * float(KFPRI.ClientVeteranSkillLevel));
	}
	else if ( Item == class'WTF.WTFEquipM79CFPickup' || Item == class 'WTFEquipUM32Pickup' || Item == class'WTF.WTFEquipAFS12Pickup' )
	{
		return 0.90 - (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 70% discount on M79/M32
	}

	return 1.0;
}

static function float GetAmmoCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'WTFEquipPipeBombPickup' )
	{
		return 0.25 - (0.03 * float(KFPRI.ClientVeteranSkillLevel));
	}

	return 1.0;
}

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{		
	// If Level 5, give them a pipe bomb
	if ( KFPRI.ClientVeteranSkillLevel == 5 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipPipeBomb", GetCostScaling(KFPRI, class'WTFEquipPipeBombPickup'));
	}
	else if ( KFPRI.ClientVeteranSkillLevel == 6 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipPipeBomb", GetCostScaling(KFPRI, class'WTFEquipPipeBombPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipM79CF", GetCostScaling(KFPRI, class'WTFEquipM79CFPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipBanHammer", GetCostScaling(KFPRI, class'WTFEquipBanHammerPickup'));
	}
}

defaultproperties
{
}
