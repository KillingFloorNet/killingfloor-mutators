class SRVetBerserker extends SRVeterancyTypes
	abstract;

static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	switch( CurLevel )
	{
	case 0:
		FinalInt = 5000;
		break;
	case 1:
		FinalInt = 25000;
		break;
	case 2:
		FinalInt = 100000;
		break;
	case 3:
		FinalInt = 500000;
		break;
	case 4:
		FinalInt = 1500000;
		break;
	case 5:
		FinalInt = 3500000;
		break;
	case 6:
		FinalInt = 5500000;
		break;
	case 7:
		FinalInt = 7500000;
		break;
	case 8:
		FinalInt = 9500000;
		break;
	case 9:
		FinalInt = 11500000;
		break;
	case 10:
		FinalInt = 13500000;
		break;
	case 11:
		FinalInt = 15500000;
		break;
	case 12:
		FinalInt = 16500000;
		break;
	case 13:
		FinalInt = 17500000;
		break;
	case 14:
		FinalInt = 18500000;
		break;
	case 15:
		FinalInt = 19500000;
		break;
	case 16:
		FinalInt = 20500000;
		break;
	case 17:
		FinalInt = 21500000;
		break;
	case 18:
		FinalInt = 22500000;
		break;
	case 19:
		FinalInt = 23500000;
		break;
	case 20:
		FinalInt = 24500000;
		break;
	case 21:
		FinalInt = 25500000;
		break;
	case 22:
		FinalInt = 26500000;
		break;
	case 23:
		FinalInt = 27500000;
		break;
	case 24:
		FinalInt = 28500000;
		break;
	case 25:
		FinalInt = 30000000;
		break;
	case 26:
		FinalInt = 31000000;
		break;
	case 27:
		FinalInt = 32000000;
		break;
	case 28:
		FinalInt = 33000000;
		break;
	case 29:
		FinalInt = 40000000;
		break;
	case 30:
		FinalInt = 70000000;
		break;
	default:
		FinalInt = 70000000 + ( 2500000 * (CurLevel - 30 ));
	}
	return Min(StatOther.RMeleeDamageStat,FinalInt);
}

static function float GetHealPotency(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel <= 5 )
		return 1.00;
	else if ( KFPRI.ClientVeteranSkillLevel >= 6 )
		return 4.00;
	return 4.00;  // Heals for 75% more
}

static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel >= 0 )
		return 1;
	return 7+KFPRI.ClientVeteranSkillLevel; // 9 more carry slots
}



static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	if( class<DamTypePipeBomb>(DmgType) != none || class<DamTypeM79Grenade>(DmgType) != none || class<DamTypeFrag>(DmgType) != none || class<KFWeaponDamageType>(DmgType) != none && class<KFWeaponDamageType>(DmgType).default.bIsMeleeDamage )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
			return float(InDamage) * 1.10;
		if ( KFPRI.ClientVeteranSkillLevel <= 5 )
			return float(InDamage) * 3.50;
		if( KFPRI.ClientVeteranSkillLevel >= 6 )
			return float(InDamage) * (4.50 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)));

		// Up to 100% increase in Melee Damage
		return float(InDamage) * (1.0 + (0.20 * float(Min(KFPRI.ClientVeteranSkillLevel, 5))));
	}
	return InDamage;
}

static function float GetFireSpeedMod(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
	if ( KFMeleeGun(Other) != none )
	{
		switch ( KFPRI.ClientVeteranSkillLevel )
		{
			case 1:
				return 1.05;
			case 2:
			case 3:
				return 1.10;
			case 4:
				return 1.15;
			case 5:
				return 1.20;
			case 6:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 7:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 8:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 9:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 10:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 11:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 12:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 13:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 14:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 15:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 16:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 17:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 18:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 19:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 20:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 21:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 22:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 23:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 24:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 25:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 26:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 27:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 28:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 29:
				return 2.00; // 25% increase in wielding Melee Weapon
			case 30:
				return 2.50; // 25% increase in wielding Melee Weapon
			default:
				return 2.50+0.01*float(KFPRI.ClientVeteranSkillLevel);
		}
	}

	return 1.0;
}

static function float GetMeleeMovementSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel == 0 )
		return 0.05; // Was 0.10 in Balance Round 1
	else if ( KFPRI.ClientVeteranSkillLevel == 1 )
		return 0.10; // Was 0.15 in Balance Round 1
	else if ( KFPRI.ClientVeteranSkillLevel == 2 )
		return 0.15; // Was 0.20 in Balance Round 1;
	else if ( KFPRI.ClientVeteranSkillLevel == 6 )
		return 0.60; // Was 0.20 in Balance Round 1;
	else if ( KFPRI.ClientVeteranSkillLevel >= 7 )
        return 0.60 + (0.06 * float(KFPRI.ClientVeteranSkillLevel)); // Was 0.20 in Balance Round 1;
	return 0.20; // 20% increase in movement speed while wielding Melee Weapon
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
				return float(InDamage) * 0.01;
			default:
				return float(InDamage) * 0.01; // 80% reduced Bloat Bile damage
		}
	}

	switch ( KFPRI.ClientVeteranSkillLevel )
	{
//		This did exist in Balance Round 1, but was removed for Balance Round 2
//		case 0:
//			return float(InDamage) * 0.95;
		case 1:
			return float(InDamage) * 0.90; // was 0.90 in Balance Round 1
		case 2:
			return float(InDamage) * 0.85; // was 0.85 in Balance Round 1
		case 3:
			return float(InDamage) * 0.80; // was 0.80 in Balance Round 1
		case 4:
			return float(InDamage) * 0.75; // was 0.70 in Balance Round 1
		case 5:
			return float(InDamage) * 0.70; // was 0.60 in Balance Round 1
		case 6:
			return float(InDamage) * 0.65; // 40% reduced Damage(was 50% in Balance Round 1)
		case 7:
			return float(InDamage) * 0.60; // 40% reduced Damage(was 50% in Balance Round 1)
		case 8:
			return float(InDamage) * 0.55; // 40% reduced Damage(was 50% in Balance Round 1)
		case 9:
			return float(InDamage) * 0.50; // 40% reduced Damage(was 50% in Balance Round 1)
		case 10:
			return float(InDamage) * 0.45; // 40% reduced Damage(was 50% in Balance Round 1)
		case 11:
			return float(InDamage) * 0.40; // 40% reduced Damage(was 50% in Balance Round 1)
		case 12:
			return float(InDamage) * 0.35; // 40% reduced Damage(was 50% in Balance Round 1)
		case 13:
			return float(InDamage) * 0.30; // 40% reduced Damage(was 50% in Balance Round 1)
		case 14:
			return float(InDamage) * 0.25; // 40% reduced Damage(was 50% in Balance Round 1)
		case 15:
			return float(InDamage) * 0.20; // 40% reduced Damage(was 50% in Balance Round 1)
		case 16:
			return float(InDamage) * 0.15; // 40% reduced Damage(was 50% in Balance Round 1)
		case 17:
			return float(InDamage) * 0.15; // 40% reduced Damage(was 50% in Balance Round 1)
		case 18:
			return float(InDamage) * 0.15; // 40% reduced Damage(was 50% in Balance Round 1)
		case 19:
			return float(InDamage) * 0.15; // 40% reduced Damage(was 50% in Balance Round 1)
		case 20:
			return float(InDamage) * 0.15; // 40% reduced Damage(was 50% in Balance Round 1)
		case 21:
			return float(InDamage) * 0.15; // 40% reduced Damage(was 50% in Balance Round 1)
		case 22:
			return float(InDamage) * 0.15; // 40% reduced Damage(was 50% in Balance Round 1)
		case 23:
			return float(InDamage) * 0.15; // 40% reduced Damage(was 50% in Balance Round 1)
		case 24:
			return float(InDamage) * 0.15; // 40% reduced Damage(was 50% in Balance Round 1)
		case 25:
			return float(InDamage) * 0.15; // 40% reduced Damage(was 50% in Balance Round 1)
		case 26:
			return float(InDamage) * 0.15; // 40% reduced Damage(was 50% in Balance Round 1)
		case 27:
			return float(InDamage) * 0.15; // 40% reduced Damage(was 50% in Balance Round 1)
		case 28:
			return float(InDamage) * 0.15; // 40% reduced Damage(was 50% in Balance Round 1)
		case 29:
			return float(InDamage) * 0.15; // 40% reduced Damage(was 50% in Balance Round 1)
		case 30:
			return float(InDamage) * 0.10; // 40% reduced Damage(was 50% in Balance Round 1)
	}

	return float(InDamage) * 0.10 - (0.0002 * float(KFPRI.ClientVeteranSkillLevel)); // 40% reduced Damage(was 50% in Balance Round 1)
}

static function bool CanBeGrabbed(KFPlayerReplicationInfo KFPRI, KFMonster Other)
{
	return !Other.IsA('ZombieClot');
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	return 1.05 + (0.35 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 35% faster reload speed
}



// Set number times Zed Time can be extended
static function int ZedTimeExtensions(KFPlayerReplicationInfo KFPRI)
{
	return KFPRI.ClientVeteranSkillLevel;
}

static function float GetBodyArmorDamageModifier(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel <= 30 )
		return 0.50 - (0.01 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 50% improvement of Body Armor
	return 0.20 - (0.0002 * float(KFPRI.ClientVeteranSkillLevel)); // Level 6 - 75% Better Body Armor
}


// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'ChainsawPickup' || Item == class'KatanaPickup' || Item == class'WHammerPickup' || Item == class'WTFEquipBanHammerPickup' || Item == class'WTFEquipSelfDestructPickup' || Item == class'ClaymoreSwordPickup')
		return FMax(0.255 - (0.001 * float(KFPRI.ClientVeteranSkillLevel)),0.1); // Up to 70% discount on Melee Weapons
	return 1.0;
}

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	// If Level 5 or 6, give them Chainsaw
	if ( KFPRI.ClientVeteranSkillLevel == 5 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.ClaymoreSword", GetCostScaling(KFPRI, class'ClaymoreSwordPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 6 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.ClaymoreSword", GetCostScaling(KFPRI, class'ClaymoreSwordPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 7 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.ClaymoreSword", GetCostScaling(KFPRI, class'ClaymoreSwordPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 8 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.ClaymoreSword", GetCostScaling(KFPRI, class'ClaymoreSwordPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 9 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.ClaymoreSword", GetCostScaling(KFPRI, class'ClaymoreSwordPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 10 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.ClaymoreSword", GetCostScaling(KFPRI, class'ClaymoreSwordPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 11 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.ClaymoreSword", GetCostScaling(KFPRI, class'ClaymoreSwordPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 12 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.ClaymoreSword", GetCostScaling(KFPRI, class'ClaymoreSwordPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 13 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.ClaymoreSword", GetCostScaling(KFPRI, class'ClaymoreSwordPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 14 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.ClaymoreSword", GetCostScaling(KFPRI, class'ClaymoreSwordPickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 15 )
		KFHumanPawn(P).CreateInventoryVeterancy("WhiskyHammer.WHammer", GetCostScaling(KFPRI, class'WHammerPickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 20 )
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipBanHammer", GetCostScaling(KFPRI, class'WTFEquipBanHammerPickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 25 )
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipSelfDestruct", GetCostScaling(KFPRI, class'WTFEquipSelfDestructPickup'));

	// If Level 6, give them Body Armor(Removed from Suicidal and HoE in Balance Round 7)
	if ( KFPRI.ClientVeteranSkillLevel >= 6 )
		P.ShieldStrength = 100;
}


static function string GetCustomLevelInfo( byte Level )
{
	local string S;

	S = Default.CustomLevelInfo;
	ReplaceText(S,"%s",GetPercentStr(0.05 * float(Level)-0.05));
	ReplaceText(S,"%d",GetPercentStr(0.1+FMin(0.1 * float(Level),0.8f)));
	ReplaceText(S,"%r",GetPercentStr(0.7 + 0.05*float(Level)));
	ReplaceText(S,"%l",GetPercentStr(FMin(0.05*float(Level),0.65f)));
	return S;
}

defaultproperties
{
     CustomLevelInfo="%r extra melee damage|%s faster melee attacks|20% faster melee movement|80% less damage from Bloat Bile|%l resistance to all damage|%d discount on Katana/Chainsaw/Sword|Spawn with a Chainsaw and Body Armor|Can't be grabbed by Clots|Up to 4 Zed-Time Extensions"
     SRLevelEffects(0)="10% extra melee damage|5% faster melee movement|10% less damage from Bloat Bile|10% discount on Katana/Chainsaw/Sword|Can't be grabbed by Clots"
     SRLevelEffects(1)="20% extra melee damage|5% faster melee attacks|10% faster melee movement|25% less damage from Bloat Bile|5% resistance to all damage|20% discount on Katana/Chainsaw/Sword|Can't be grabbed by Clots"
     SRLevelEffects(2)="40% extra melee damage|10% faster melee attacks|15% faster melee movement|35% less damage from Bloat Bile|10% resistance to all damage|30% discount on Katana/Chainsaw/Sword|Can't be grabbed by Clots|Zed-Time can be extended by killing an enemy while in slow motion"
     SRLevelEffects(3)="60% extra melee damage|10% faster melee attacks|20% faster melee movement|50% less damage from Bloat Bile|15% resistance to all damage|40% discount on Katana/Chainsaw/Sword|Can't be grabbed by Clots|Up to 2 Zed-Time Extensions"
     SRLevelEffects(4)="80% extra melee damage|15% faster melee attacks|20% faster melee movement|65% less damage from Bloat Bile|20% resistance to all damage|50% discount on Katana/Chainsaw/Sword|Can't be grabbed by Clots|Up to 3 Zed-Time Extensions"
     SRLevelEffects(5)="100% extra melee damage|20% faster melee attacks|20% faster melee movement|75% less damage from Bloat Bile|30% resistance to all damage|60% discount on Katana/Chainsaw/Sword|Spawn with a Chainsaw|Can't be grabbed by Clots|Up to 4 Zed-Time Extensions"
     SRLevelEffects(6)="100% extra melee damage|25% faster melee attacks|30% faster melee movement|80% less damage from Bloat Bile|40% resistance to all damage|70% discount on Katana/Chainsaw/Sword|Spawn with a Chainsaw and Body Armor|Can't be grabbed by Clots|Up to 4 Zed-Time Extensions"
     PerkIndex=4
     OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_Berserker'
     OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Berserker_Gold'
     VeterancyName="Berserker"
     Requirements(0)="Deal %x damage with melee weapons"
}
