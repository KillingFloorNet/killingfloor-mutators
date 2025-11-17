class WTFPerksBerserker extends KFVetBerserker
	abstract;

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	if( class<KFWeaponDamageType>(DmgType) != none && class<KFWeaponDamageType>(DmgType).default.bIsMeleeDamage )
	{
		//Log ("Adding damage for " $ String(KFPRI.ClientVeteranSkill) $ " with " $ String(DmgType));
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
		{
			return float(InDamage) * 1.10;
		}

		// Up to 100% increase in Melee Damage
		return float(InDamage) * (1.0 + (0.20 * float(Min(KFPRI.ClientVeteranSkillLevel, 5))));
	}

	return InDamage;
}

static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'MachetePickup' || Item == class'WTFEquipFireAxePickup' || Item == class'WTFEquipChainsawPickup' || Item == class'WTFEquipKatanaPickup')
	{
		return 0.9 - (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 70% discount on Melee Weapons
	}

	return 1.0;
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	if ( AmmoType == class'FragAmmo'  )
	{
		return 1.0 + (0.2 * float(KFPRI.ClientVeteranSkillLevel));
	}

	return 1.0;
}

static function float GetAmmoCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'WTFEquipNadePickup' )
	{
		return 0.9 - (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 70% discount on Throwing Knives
	}

	return 1.0;
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, KFMonster DamageTaker, int InDamage, class<DamageType> DmgType)
{
	if ( DmgType == class'DamTypeVomit' )
	{
		switch ( KFPRI.ClientVeteranSkillLevel )
		{
			case 0:
				return float(InDamage) * 0.90;
			case 1:
				return float(InDamage) * 0.75;
			case 2:
				return float(InDamage) * 0.65;
			case 3:
				return float(InDamage) * 0.50;
			case 4:
				return float(InDamage) * 0.35;
			case 5:
				return float(InDamage) * 0.25;
			case 6:
				return float(InDamage) * 0.20; // 80% reduced Bloat Bile damage
		}
	}

	switch ( KFPRI.ClientVeteranSkillLevel )
	{
		case 1:
			return float(InDamage) * 0.9;
		case 2:
			return float(InDamage) * 0.8;
		case 3:
		case 4:
			return float(InDamage) * 0.7;
		case 5:
			return float(InDamage) * 0.65;
		case 6:
			return float(InDamage) * 0.6; // 40% reduced Damage
	}

	return InDamage;
}

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	if ( KFPRI.ClientVeteranSkillLevel == 4 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipFireAxe", GetCostScaling(KFPRI, class'WTFEquipFireAxePickup'));
	}
	else if ( KFPRI.ClientVeteranSkillLevel == 5 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipKatana", GetCostScaling(KFPRI, class'WTFEquipKatanaPickup'));
	}
	else if ( KFPRI.ClientVeteranSkillLevel == 6 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipChainsaw", GetCostScaling(KFPRI, class'WTFEquipChainsawPickup'));
		P.ShieldStrength = 100;
	}
}

defaultproperties
{
}
