class WTFPerksFirebug extends KFVetFirebug
	abstract;

//extra damage with welda, but this only applies when hitting zeds (no bonus for door welding)
static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	if ( class<DamTypeBurned>(DmgType) != none || class<DamTypeFlamethrower>(DmgType) != none || class<WTFEquipDamTypeWelda>(DmgType) != none )
	{
		//Log ("Adding damage for " $ String(KFPRI.ClientVeteranSkill) $ " with " $ String(DmgType));
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
	if ( Item == class'WTFEquipFTPickup' )
	{
		return 0.9 - (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 70% discount
	}
	else if ( Item == class'WTFEquipM79CFPickup' )
	{
		return 1.0 - (0.05 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 35% discount
	}
	
	return 1.0;
}

static function float GetAmmoCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'WTFEquipNadePickup' )
	{
		return 0.95 - (0.05 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 35% discount on flame nades
	}

	return 1.0;
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	if ( (AmmoType == class'WTFEquipFTAmmo')&& KFPRI.ClientVeteranSkillLevel > 0 )
	{
		return 1.0 + (0.2 * float(KFPRI.ClientVeteranSkillLevel));
	}

	return 1.0;
}

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{	
	// If Level 5 or 6, give them a Flame Thrower
	if ( KFPRI.ClientVeteranSkillLevel >= 5 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipFT", GetCostScaling(KFPRI, class'WTFEquipFTPickup'));
	}

	// If Level 6, give them Body Armor
	if ( KFPRI.ClientVeteranSkillLevel == 6 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipFireAxe", GetCostScaling(KFPRI, class'WTFEquipFireAxePickup'));
		P.ShieldStrength = 100;
	}
	
	KFHumanPawn(P).CreateInventory("WTF.WTFEquipFlaregun");
}

defaultproperties
{
}
