class WTFPerksSharpshooter extends KFVetSharpshooter
	abstract;

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	if ( DmgType == class'DamTypeCrossbow' || DmgType == class'DamTypeCrossbowHeadShot' ||
		 DmgType == class'DamTypeWinchester' || DmgType == class'DamTypeDeagle' || DmgType == class'DamTypeDualDeagle' ||
		 DmgType == class'DamTypeDualies' || DmgType == class'DamTypeM14EBR' || DmgType == class'WTFEquipDamTypeSA80a' )
	{
		//Log ("Adding damage for " $ String(KFPRI.ClientVeteranSkill) $ " with " $ String(DmgType));
		if ( KFPRI.ClientVeteranSkillLevel <= 3 )
		{
			return float(InDamage) * (1.05 + (0.05 * float(KFPRI.ClientVeteranSkillLevel)));
		}
		else if ( KFPRI.ClientVeteranSkillLevel == 4 )
		{
			return float(InDamage) * 1.30;
		}
		else if ( KFPRI.ClientVeteranSkillLevel == 5 )
		{
			return float(InDamage) * 1.50;
		}

		return float(InDamage) * 1.60; // 60% increase in Crossbow/Winchester/Handcannon damage
	}

	return InDamage;
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	if ( Crossbow(Other) != none || Winchester(Other) != none || Deagle(Other) != none || DualDeagle(Other) != none ||
		 Single(Other) != none || Dualies(Other) != none || M14EBRBattleRifle(Other) != none || WTFEquipSA80a(Other) != none)
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
		{
			return 1.0;
		}

		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% faster reload with Crossbow/Winchester/Handcannon
	}

	return 1.0;
}

static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Recoil)
{
	if ( Crossbow(Other.Weapon) != none || Winchester(Other.Weapon) != none || Deagle(Other.Weapon) != none || DualDeagle(Other.Weapon) != none ||
		 Single(Other.Weapon) != none || Dualies(Other.Weapon) != none || M14EBRBattleRifle(Other.Weapon) != none || WTFEquipSA80a(Other.Weapon) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 1)
		{
			Recoil = 0.75;
		}
		else if ( KFPRI.ClientVeteranSkillLevel == 2 )
		{
			Recoil = 0.50;
		}
		else
		{
			Recoil = 0.25; // 75% recoil reduction with Crossbow/Winchester/Handcannon
		}

		return Recoil;
	}

	Recoil = 1.0;
	Return Recoil;
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'DeaglePickup' || Item == class'DualDeaglePickup' || Item == class'M14EBRPickup' || Item == class'WTFEquipSA80Pickup')
	{
		return 0.9 - (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 70% discount on Handcannon/Dual Handcannons/EBR
	}

	return 1.0;
}

// Give Extra Items as Default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	if ( KFPRI.ClientVeteranSkillLevel == 4 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Deagle", GetCostScaling(KFPRI, class'DeaglePickup'));
	}
	else if ( KFPRI.ClientVeteranSkillLevel == 5 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Deagle", GetCostScaling(KFPRI, class'DeaglePickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Winchester", GetCostScaling(KFPRI, class'WinchesterPickup'));
	}
	else if ( KFPRI.ClientVeteranSkillLevel == 6 ) //change back to xbow after testing
	{
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Deagle", GetCostScaling(KFPRI, class'DeaglePickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipSA80a", GetCostScaling(KFPRI, class'WTFEquipSA80Pickup'));
	}
}

defaultproperties
{
}
