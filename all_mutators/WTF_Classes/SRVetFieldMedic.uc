class SRVetFieldMedic extends SRVeterancyTypes
	abstract;

static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	switch( CurLevel )
	{
	case 0:
		FinalInt = 100;
		break;
	case 1:
		FinalInt = 200;
		break;
	case 2:
		FinalInt = 750;
		break;
	case 3:
		FinalInt = 4000;
		break;
	case 4:
		FinalInt = 12000;
		break;
	case 5:
		FinalInt = 25000;
		break;
	case 6:
		FinalInt = 50000;
		break;
	case 7:
		FinalInt = 75000;
		break;
	case 8:
		FinalInt = 100000;
		break;
	case 9:
		FinalInt = 125000;
		break;
	case 10:
		FinalInt = 150000;
		break;
	case 11:
		FinalInt = 175000;
		break;
	case 12:
		FinalInt = 200000;
		break;
	case 13:
		FinalInt = 225000;
		break;
	case 14:
		FinalInt = 250000;
		break;
	case 15:
		FinalInt = 275000;
		break;
	case 16:
		FinalInt = 300000;
		break;
	case 17:
		FinalInt = 325000;
		break;
	case 18:
		FinalInt = 350000;
		break;
	case 19:
		FinalInt = 375000;
		break;
	case 20:
		FinalInt = 400000;
		break;
	case 21:
		FinalInt = 425000;
		break;
	case 22:
		FinalInt = 450000;
		break;
	case 23:
		FinalInt = 475000;
		break;
	case 24:
		FinalInt = 500000;
		break;
	case 25:
		FinalInt = 525000;
		break;
	case 26:
		FinalInt = 550000;
		break;
	case 27:
		FinalInt = 575000;
		break;
	case 28:
		FinalInt = 600000;
		break;
	case 29:
		FinalInt = 625000;
		break;
	case 30:
		FinalInt = 650000;
		break;
	default:
		FinalInt = 650000 + ( 10000 * (CurLevel - 30 ));
	}
	return Min(StatOther.RDamageHealedStat,FinalInt);
}

static function float GetSyringeChargeRate(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel == 0 )
		return 1.10;
	else if ( KFPRI.ClientVeteranSkillLevel <= 4 )
		return 1.25 + (0.25 * float(KFPRI.ClientVeteranSkillLevel));
	else if ( KFPRI.ClientVeteranSkillLevel == 5 )
		return 2.50; // Recharges 150% faster
	else if ( KFPRI.ClientVeteranSkillLevel >= 6 )
		return 3.9 + (0.1 * float(KFPRI.ClientVeteranSkillLevel)); // Level 6 - Recharges 200% faster
	return 2.4 + (0.1 * float(KFPRI.ClientVeteranSkillLevel)); // Level 6 - Recharges 200% faster
}

static function float GetHealPotency(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel == 0 )
		return 1.10;
	else if ( KFPRI.ClientVeteranSkillLevel <= 2 )
		return 1.25;
	else if ( KFPRI.ClientVeteranSkillLevel <= 5 )
		return 1.5;
	else if ( KFPRI.ClientVeteranSkillLevel >= 6 )
		return 4.9 + (0.1 * float(KFPRI.ClientVeteranSkillLevel)); // Level 6 - Recharges 200% faster
	return 1.75;  // Heals for 75% more
}

static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel >= 0 )
		return 1;
	return 7+KFPRI.ClientVeteranSkillLevel; // 9 more carry slots
}


static function float GetMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI)
{
	// Medic movement speed reduced in Balance Round 2(limited to Suicidal and HoE in Round 7)
	if ( KFPRI.ClientVeteranSkillLevel <= 1 )
		return 1.0;
	return 1.35 + FMin(0.05 * float(KFPRI.ClientVeteranSkillLevel - 2),0.55); // Moves up to 25% faster
}

static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, KFMonster DamageTaker, int InDamage, class<DamageType> DmgType)
{
	if ( DmgType == class'DamTypeVomit' )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
			return float(InDamage) * 0.90;
		else if ( KFPRI.ClientVeteranSkillLevel == 1 )
			return float(InDamage) * 0.75;
		else if ( KFPRI.ClientVeteranSkillLevel <= 4 )
			return float(InDamage) * 0.50;
		else if ( KFPRI.ClientVeteranSkillLevel >= 10 )
			return float(InDamage) * 0.01;
		return float(InDamage) * 0.25; // 75% decrease in damage from Bloat's Bile
	}
	return InDamage;
}

static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	if ( (MP7MMedicGun(Other) != none || MP5MMedicGun(Other) != none) && KFPRI.ClientVeteranSkillLevel > 0 )
		return 2.0 + (0.20 * FMin(KFPRI.ClientVeteranSkillLevel, 5.0)); // 100% increase in MP7 Medic weapon ammo carry
	return 1.0;
}

static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	if ( (MP7MAmmo(Other) != none || MP5MAmmo(Other) != none) && KFPRI.ClientVeteranSkillLevel > 0 )
		return 2.0 + (0.20 * FMin(KFPRI.ClientVeteranSkillLevel, 5.0)); // 100% increase in MP7 Medic weapon ammo carry
	return 1.0;
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'Vest' )
		return FMax(0.255 - (0.001 * float(KFPRI.ClientVeteranSkillLevel)),0.1f);  // Up to 70% discount on Body Armor
	else if ( Item == class'MP7MPickup' || Item == class'WTFEquipMP7M2Pickup' || Item == class'MP5MPickup' )
		return FMax(0.255 - (0.001 * float(KFPRI.ClientVeteranSkillLevel)),0.02f);  // Up to 95% discount on Medic Gun
	return 1.0;
}

// Reduce damage when wearing Armor
static function float GetBodyArmorDamageModifier(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel >= 20 )
		return 0.16 - (0.00055 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 50% improvement of Body Armor
	return 0.25; // Level 6 - 75% Better Body Armor
}

// Give Extra Items as Default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	// If Level 5 or Higher, give them Body Armor
	if ( KFPRI.ClientVeteranSkillLevel >= 5 )
		P.ShieldStrength = 100;
	// If Level 6, give them a Medic Gun
	if ( KFPRI.ClientVeteranSkillLevel >= 6 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.MP5MMedicGun", GetCostScaling(KFPRI, class'MP5MPickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 15 )
		KFHumanPawn(P).CreateInventoryVeterancy("IJCWeaponPack-WhiteV27.M7A3MMedicGun", GetCostScaling(KFPRI, class'M7A3MPickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 20 )
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipLethalInjection", GetCostScaling(KFPRI, class'WTFEquipLethalInjectionPickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 25 )
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipMP7M2a", GetCostScaling(KFPRI, class'WTFEquipMP7M2Pickup'));
}

static function string GetCustomLevelInfo( byte Level )
{
	local string S;

	S = Default.CustomLevelInfo;
	ReplaceText(S,"%s",GetPercentStr(2.4 + (0.1 * float(Level))));
	ReplaceText(S,"%d",GetPercentStr(0.1+FMin(0.1 * float(Level),0.8f)));
	ReplaceText(S,"%m",GetPercentStr(0.15+FMin(0.02 * float(Level),0.83f)));
	ReplaceText(S,"%r",GetPercentStr(FMin(0.05 * float(Level),0.65f)-0.05));
	return S;
}

defaultproperties
{
     CustomLevelInfo="%s faster Syringe recharge|75% more potent medical injections|75% less damage from Bloat Bile|%r faster movement speed|100% larger MP7M Medic Gun clip|75% better Body Armor|%d discount on Body Armor||%m discount on MP7M Medic Guns| Spawn with Body Armor and Medic Gun"
     SRLevelEffects(0)="10% faster Syringe recharge|10% more potent medical injections|10% less damage from Bloat Bile|10% discount on Body Armor|85% discount on MP7M Medic Gun"
     SRLevelEffects(1)="25% faster Syringe recharge|25% more potent medical injections|25% less damage from Bloat Bile|20% larger MP7M Medic Gun clip|10% better Body Armor|20% discount on Body Armor|87% discount on MP7M Medic Gun"
     SRLevelEffects(2)="50% faster Syringe recharge|25% more potent medical injections|50% less damage from Bloat Bile|5% faster movement speed|40% larger MP7M Medic Gun clip|20% better Body Armor|30% discount on Body Armor|89% discount on MP7M Medic Guns"
     SRLevelEffects(3)="75% faster Syringe recharge|50% more potent medical injections|50% less damage from Bloat Bile|10% faster movement speed|60% larger MP7M Medic Gun clip|30% better Body Armor|40% discount on Body Armor|91% discount on MP7M Medic Guns"
     SRLevelEffects(4)="100% faster Syringe recharge|50% more potent medical injections|50% less damage from Bloat Bile|15% faster movement speed|80% larger MP7M Medic Gun clip|40% better Body Armor|50% discount on Body Armor|93% discount on MP7M Medic Guns"
     SRLevelEffects(5)="150% faster Syringe recharge|50% more potent medical injections|75% less damage from Bloat Bile|20% faster movement speed|100% larger MP7M Medic Gun clip|50% better Body Armor|60% discount on Body Armor|95% discount on MP7M Medic Guns|Spawn with Body Armor"
     SRLevelEffects(6)="200% faster Syringe recharge|75% more potent medical injections|75% less damage from Bloat Bile|25% faster movement speed|100% larger MP7M Medic Gun clip|75% better Body Armor|70% discount on Body Armor||97% discount on MP7M Medic Guns| Spawn with Body Armor and Medic Gun"
     PerkIndex=0
     OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_Medic'
     OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Medic_Gold'
     VeterancyName="Field Medic"
     Requirements(0)="Heal %x HP on your teammates"
}
