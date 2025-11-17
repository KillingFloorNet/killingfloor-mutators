class WTFPerksSupportSpec extends KFVetSupportSpec
	abstract;

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	if ( DmgType == class'DamTypeShotgun' || DmgType == class'DamTypeDBShotgun' || DmgType == class'DamTypeAA12Shotgun' )
	{
		//Log ("Adding damage for " $ String(KFPRI.ClientVeteranSkill) $ " with " $ String(DmgType));
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
		{
			return float(InDamage) * 1.10;
		}

		return InDamage * (1.00 + (0.10 * float(KFPRI.ClientVeteranSkillLevel))); // Up to 60% more damage with Shotguns
	}
	else if ( DmgType == class'DamTypeFrag' && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 1 )
		{
			return float(InDamage) * 1.05;
		}

		return float(InDamage) * (0.90 + (0.10 * float(KFPRI.ClientVeteranSkillLevel))); // Up to 50% more damage with Nades
	}

	return InDamage;
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'WTFEquipSawedOffShotgunPickup' || Item == class'WTFEquipShotgunPickup' || Item == class'WTFEquipBoomstickPickup' || Item == class'WTFEquipAFS12Pickup')
	{
		return 0.9 - (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 70% discount on Shotguns
	}
	else if ( Item == class'WTFEquipRocketLauncherPickup' )
	{
		return 1.0 - (0.05 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 35% discount on LAW
	}

	return 1.0;
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	if ( AmmoType == class'FragAmmo' )
	{
		// Up to 6 extra Grenades
		return 1.0 + (0.20 * float(KFPRI.ClientVeteranSkillLevel));
	}
	else if ( AmmoType == class'WTFEquipSawedOffShotgunAmmo' || AmmoType == class'ShotgunAmmo' || AmmoType == class'DBShotgunAmmo' || AmmoType == class'AA12Ammo' )
	{
		return 1.0 + (float(KFPRI.ClientVeteranSkillLevel) * 0.05);
	}
	else if ( AmmoType == class'WTFEquipRocketLauncherAmmo' )
	{
		return 1.0 + (float(KFPRI.ClientVeteranSkillLevel) * 0.5);
	}

	return 1.0;
}

static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{		
	if ( KFPRI.ClientVeteranSkillLevel == 5 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipShotgun", GetCostScaling(KFPRI, class'WTFEquipShotgunPickup'));
	}
	else if ( KFPRI.ClientVeteranSkillLevel == 6 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipShotgun", GetCostScaling(KFPRI, class'WTFEquipShotgunPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipBoomStick", GetCostScaling(KFPRI, class'WTFEquipBoomStickPickup'));
	}
	
	KFHumanPawn(P).CreateInventory("WTF.WTFEquipFlaregun");
}

defaultproperties
{
}
