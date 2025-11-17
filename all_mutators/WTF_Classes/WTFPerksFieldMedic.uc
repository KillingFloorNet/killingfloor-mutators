class WTFPerksFieldMedic extends KFVetFieldMedic
	abstract;

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	if( class<KFWeaponDamageType>(DmgType) != none)
	{
		if ( class<WTFEquipDamTypeLethalInjection>(DmgType) != none )
		{
			return float(InDamage) * (1.04 + (0.16 * float(KFPRI.ClientVeteranSkillLevel) ) ); //100% bonus damage at rank 6
		}
		else if ( class<DamTypeKnife>(DmgType) != none )
		{
			return float(InDamage) * (1.0 + (0.1 * float(KFPRI.ClientVeteranSkillLevel) ) );
		}
		else if ( DmgType == class'DamTypeDualies' || DmgType == class'DamTypeDeagle' || DmgType == class'DamTypeDualDeagle' || DmgType == class'DamTypeMP7M' )
		{
			return float(InDamage) * (1.0 + (0.03 * float(KFPRI.ClientVeteranSkillLevel) ) );
		}
	}

	return InDamage;
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'Vest' )
	{
		return 0.9 - (0.10 * float(KFPRI.ClientVeteranSkillLevel));  // Up to 70% discount on Body Armor
	}
	else if ( Item == class'WTFEquipMP7M2Pickup')
	{
		return 0.15 - (0.02 * float(KFPRI.ClientVeteranSkillLevel));  // Up to 95% discount on weaps
	}
	else if ( Item == class'WTFEquipMachineDualiesPickup' || Item == class'DeaglePickup' || Item == class'DualDeaglePickup')
	{
		return 0.9 - (0.10 * float(KFPRI.ClientVeteranSkillLevel));
	}
	
	return 1.0;
}

//modest capacity bonus for medics
static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	if ( (AmmoType == class'WTFEquipMP7M2Ammo' || AmmoType == class'SingleAmmo' || AmmoType == class'DeagleAmmo') && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 1 )
		{
			return 1.10;
		}
		else if ( KFPRI.ClientVeteranSkillLevel == 2 )
		{
			return 1.15;
		}

		return 1.25;
	}

	return 1.0;
}

static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	if ( KFPRI.ClientVeteranSkillLevel > 0 )
	{
		if (WTFEquipMP7M2a(Other) != none)
			return 1.0 + (0.20 * FMin(float(KFPRI.ClientVeteranSkillLevel), 5.0)); // 100% increase
		else if ( Deagle(Other) != none )
			return 1.0 + ( 0.125 * float(KFPRI.ClientVeteranSkillLevel) );
		else if ( DualDeagle(Other) != none )
			return 1.0 + ( 0.125 * float(KFPRI.ClientVeteranSkillLevel) );
		else if ( WTFEquipMachinePistol(Other) != none )
			return 1.0 + ( 0.125 * float(KFPRI.ClientVeteranSkillLevel) );
		else if ( WTFEquipMachineDualies(Other) != none )
			return 1.0 + ( 0.125 * float(KFPRI.ClientVeteranSkillLevel) );
	}

	return 1.0;
}

// Give Extra Items as Default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	if ( KFPRI.ClientVeteranSkillLevel == 5 )
	{
		//they spawn with dualies (since you already spawn with 1 MachinePistol)
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipMachineDualies", GetCostScaling(KFPRI, class'WTFEquipMachineDualiesPickup'));
	}
	else if ( KFPRI.ClientVeteranSkillLevel == 6 )
	{
		//they spawn with dualies (since you already spawn with 1 MachinePistol)
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipMachineDualies", GetCostScaling(KFPRI, class'WTFEquipMachineDualiesPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipMP7M2a", GetCostScaling(KFPRI, class'WTFEquipMP7M2Pickup'));
	}
	
	if ( KFPRI.ClientVeteranSkillLevel >= 5 )
	{
		P.ShieldStrength = 100;
	}
	
	KFHumanPawn(P).CreateInventory("WTF.WTFEquipLethalInjection");
}

defaultproperties
{
}
