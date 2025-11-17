class WTFPerksCommando extends KFVetCommando
	abstract;

//add Shotgun
static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	if ( DmgType == class'DamTypeMP7M' || DmgType == class'DamTypeShotgun' || DmgType == class'DamTypeBullpup' || DmgType == class'DamTypeAK47AssaultRifle' || DmgType == class'DamTypeSCARMK17AssaultRifle' )
	{
		//Log ("Adding damage for " $ String(KFPRI.ClientVeteranSkill) $ " with " $ String(DmgType));
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
		{
			return float(InDamage) * 1.05;
		}

		return float(InDamage) * (1.00 + (0.10 * float(KFPRI.ClientVeteranSkillLevel))); // Up to 60% increase in Damage with Bullpup
	}

	return InDamage;
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'WTFEquipShotgunPickup' || Item == class'WTFEquipBulldogPickup' || Item == class'WTFEquipAK48SPickup' || Item == class'WTFEquipSCAR19Pickup' )
	{
		return 0.9 - (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 70% discount on Assault Rifles
	}
	else if ( Item == class'WTFEquipMP7M2Pickup' )
	{
		return 0.95 - (0.05 * float(KFPRI.ClientVeteranSkillLevel));
	}

	return 1.0;
}

static function float GetStalkerViewDistanceMulti(KFPlayerReplicationInfo KFPRI)
{
	//big time increase in stalker/patriarch view distance
	switch ( KFPRI.ClientVeteranSkillLevel )
	{
		case 0:
			return 0.0625 * 2; // 25% x2
		case 1:
			return 0.25 * 2; // 50% x2
		case 2:
			return 0.36 * 2; // 60% x2
		case 3:
			return 0.49 * 2; // 70% x2
		case 4:
			return 0.64 * 2; // 80% x2
		case 5:
			return 1.0 * 2;
		case 6:
			return 1.0 * 3;
	}

	return 1.0; // 100% of Standard Distance(800 units or 16 meters)
}

//add shotgun
static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	if ( ( WTFEquipMP7M2a(Other) != none || WTFEquipBulldog(Other) != none || WTFEquipAK48S(Other) != none || WTFEquipSCAR19a(Other) != none ) && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 1 )
		{
			return 1.10;
		}
		else if ( KFPRI.ClientVeteranSkillLevel == 2 )
		{
			return 1.20;
		}

		return 1.25;
	}

	return 1.0;
}

//add shotgun
static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	if ( (ShotgunAmmo(Other) != none || WTFEquipMP7M2Ammo(Other) != none || BullpupAmmo(Other) != none || AK47Ammo(Other) != none || SCARMK17Ammo(Other) != none) && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 1 )
		{
			return 1.10;
		}
		else if ( KFPRI.ClientVeteranSkillLevel == 2 )
		{
			return 1.20;
		}

		return 1.25; // 25% increase in assault rifle ammo carry
	}

	return 1.0;
}

//add shotgun
static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	if ( (AmmoType == class'ShotgunAmmo' || AmmoType == class'WTFEquipMP7M2Ammo' || AmmoType == class'BullpupAmmo' || AmmoType == class'AK47Ammo' || AmmoType == class'SCARMK17Ammo') && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 1 )
		{
			return 1.10;
		}
		else if ( KFPRI.ClientVeteranSkillLevel == 2 )
		{
			return 1.20;
		}

		return 1.25; // 25% increase in assault rifle ammo carry
	}

	return 1.0;
}

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	if ( KFPRI.ClientVeteranSkillLevel == 5 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipBulldog", GetCostScaling(KFPRI, class'WTFEquipBulldogPickup'));
	}
	else if ( KFPRI.ClientVeteranSkillLevel == 6 )
	{
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipShotgun", GetCostScaling(KFPRI, class'WTFEquipShotgunPickup'));
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipAK48S", GetCostScaling(KFPRI, class'WTF.WTFEquipAK48SPickup'));
	}
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	return 1.1 + (0.05 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 40% instead of 35% faster reload speed //1.05 base on the left
}

defaultproperties
{
}
