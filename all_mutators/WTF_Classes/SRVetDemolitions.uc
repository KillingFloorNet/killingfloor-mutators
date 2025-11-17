class SRVetDemolitions extends SRVeterancyTypes
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
		FinalInt = 34000000;
		break;
	case 30:
		FinalInt = 70000000;
		break;
	default:
		FinalInt = 70000000 + ( 2500000 * (CurLevel - 30 ));
	}
	return Min(StatOther.RExplosivesDamageStat,FinalInt);
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	if ( AmmoType == class'FragAmmo' )
		// Up to 6 extra Grenades
		return 1.0 + (0.20 * float(KFPRI.ClientVeteranSkillLevel));
	else if ( AmmoType == class'PipeBombAmmo' )
		// Up to 6 extra for a total of 8 Remote Explosive Devices
		return 1.0 + (0.5 * float(KFPRI.ClientVeteranSkillLevel));
	else if ( AmmoType == class'LAWAmmo' )
	{
		if ( KFPRI.ClientVeteranSkillLevel > 0 )
		{
			if ( KFPRI.ClientVeteranSkillLevel == 1 )
				return 1.10;
			else if ( KFPRI.ClientVeteranSkillLevel == 2 )
				return 1.20;
			else if ( KFPRI.ClientVeteranSkillLevel == 5 )
				return 2.30; // Level 6 - 30% increase
			else if ( KFPRI.ClientVeteranSkillLevel <= 29 )
				return 2.30 + (0.20 * float(KFPRI.ClientVeteranSkillLevel));
			else if ( KFPRI.ClientVeteranSkillLevel == 30 )
				return 9;
			return 3 + (0.20 * float(KFPRI.ClientVeteranSkillLevel));
		}
	}
	return 1.0;
}

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	if ( class<DamTypeFrag>(DmgType) != none || class<DamTypePipeBomb>(DmgType) != none ||
		 class<DamTypeM79Grenade>(DmgType) != none || class<DamTypeM32Grenade>(DmgType) != none
		 || class<DamTypeM203Grenade>(DmgType) != none || class<DamTypeRocketImpact>(DmgType) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
			return float(InDamage) * 1.05;
		if ( KFPRI.ClientVeteranSkillLevel <= 5 )
			return float(InDamage) * 2.50;
		if ( KFPRI.ClientVeteranSkillLevel >= 6 )
			return float(InDamage) * (3.8 + (0.10 * float(KFPRI.ClientVeteranSkillLevel))); //  Up to 60% extra damage
		return float(InDamage) * (1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel))); //  Up to 60% extra damage
	}

	return InDamage;
}

static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel <= 24 )
		return 1;
	return 5; // 9 more carry slots
}


static function int ReduceDamage(KFPlayerReplicationInfo KFPRI, KFPawn Injured, KFMonster DamageTaker, int InDamage, class<DamageType> DmgType)
{
	if ( class<DamTypeFrag>(DmgType) != none || class<DamTypePipeBomb>(DmgType) != none ||
		 class<DamTypeM79Grenade>(DmgType) != none || class<DamTypeM32Grenade>(DmgType) != none
		 || class<DamTypeM203Grenade>(DmgType) != none || class<DamTypeRocketImpact>(DmgType) != none )
		return float(InDamage) * (0.255 - 0.001 * float(KFPRI.ClientVeteranSkillLevel));
	return InDamage;
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'PipeBombPickup' )
		// Todo, this won't need to be so extreme when we set up the system to only allow him to buy it perhaps
		return FMax(0.255 - (0.001 * float(KFPRI.ClientVeteranSkillLevel)),0.1); // Up to 70% discount on Melee Weapons
	else if ( Item == class'M79Pickup' || Item == class'M32Pickup'
		 || Item == class'LAWPickup' || Item == class'WTFEquipM79CFPickup' || Item == class'WTF.WTFEquipSelfDestruct' || Item == class'WTFEquipAFS12Pickup' || Item == class'M4203Pickup' )
		return FMax(0.255 - (0.001 * float(KFPRI.ClientVeteranSkillLevel)),0.1); // Up to 70% discount on Melee Weapons
	return 1.0;
}

// Change the cost of particular ammo
static function float GetAmmoCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'PipeBombPickup' )
		// Todo, this won't need to be so extreme when we set up the system to only allow him to buy it perhaps
		return FMax(0.255 - (0.001 * float(KFPRI.ClientVeteranSkillLevel)),0.1); // Up to 70% discount on Melee Weapons
	return 1.0;
}

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	// If Level 5, give them a pipe bomb
	if ( KFPRI.ClientVeteranSkillLevel >= 5 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.PipeBombExplosive", GetCostScaling(KFPRI, class'PipeBombPickup'));
	// If Level 6, give them a M79Grenade launcher and pipe bomb
	if ( KFPRI.ClientVeteranSkillLevel == 6 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.M79GrenadeLauncher", GetCostScaling(KFPRI, class'M79Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 7 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.M79GrenadeLauncher", GetCostScaling(KFPRI, class'M79Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 8 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.M79GrenadeLauncher", GetCostScaling(KFPRI, class'M79Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 9 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.M79GrenadeLauncher", GetCostScaling(KFPRI, class'M79Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 10 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.M32GrenadeLauncher", GetCostScaling(KFPRI, class'M32Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 11 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.M32GrenadeLauncher", GetCostScaling(KFPRI, class'M32Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 12 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.M32GrenadeLauncher", GetCostScaling(KFPRI, class'M32Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 13 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.M32GrenadeLauncher", GetCostScaling(KFPRI, class'M32Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 14 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.M32GrenadeLauncher", GetCostScaling(KFPRI, class'M32Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 15 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.LAW", GetCostScaling(KFPRI, class'LAWPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 16 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.LAW", GetCostScaling(KFPRI, class'LAWPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 17 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.LAW", GetCostScaling(KFPRI, class'LAWPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 18 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.LAW", GetCostScaling(KFPRI, class'LAWPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 19 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.LAW", GetCostScaling(KFPRI, class'LAWPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 20 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.LAW", GetCostScaling(KFPRI, class'LAWPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 21 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.LAW", GetCostScaling(KFPRI, class'LAWPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 22 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.LAW", GetCostScaling(KFPRI, class'LAWPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 23 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.LAW", GetCostScaling(KFPRI, class'LAWPickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 24 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.LAW", GetCostScaling(KFPRI, class'LAWPickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 25 )
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipM79CF", GetCostScaling(KFPRI, class'WTFEquipM79CFPickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 25 )
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipSelfDestruct", GetCostScaling(KFPRI, class'WTFEquipSelfDestructPickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 25 )
		P.ShieldStrength = 100;
}

static function string GetCustomLevelInfo( byte Level )
{
	local string S;

	S = Default.CustomLevelInfo;
	ReplaceText(S,"%s",GetPercentStr(0.1 * float(Level)));
	ReplaceText(S,"%r",GetPercentStr(FMin(0.25f+0.05*float(Level),0.95f)));
	ReplaceText(S,"%d",GetPercentStr(0.75+FMin(0.03 * float(Level),0.24f)));
	ReplaceText(S,"%x",string(2+Level));
	ReplaceText(S,"%y",GetPercentStr(0.1+FMin(0.1 * float(Level),0.8f)));
	return S;
}

defaultproperties
{
     CustomLevelInfo="%s extra Explosives damage|%r resistance to Explosives|120% increase in grenade capacity|Can carry %x Remote Explosives|%y discount on Explosives|%d off Remote Explosives|Spawn with an M79 and Pipe Bomb"
     SRLevelEffects(0)="5% extra Explosives damage|25% resistance to Explosives|10% discount on Explosives|75% off Remote Explosives"
     SRLevelEffects(1)="10% extra Explosives damage|30% resistance to Explosives|20% increase in grenade capacity|Can carry 3 Remote Explosives|20% discount on Explosives|78% off Remote Explosives"
     SRLevelEffects(2)="20% extra Explosives damage|35% resistance to Explosives|40% increase in grenade capacity|Can carry 4 Remote Explosives|30% discount on Explosives|81% off Remote Explosives"
     SRLevelEffects(3)="30% extra Explosives damage|40% resistance to Explosives|60% increase in grenade capacity|Can carry 5 Remote Explosives|40% discount on Explosives|84% off Remote Explosives"
     SRLevelEffects(4)="40% extra Explosives damage|45% resistance to Explosives|80% increase in grenade capacity|Can carry 6 Remote Explosives|50% discount on Explosives|87% off Remote Explosives"
     SRLevelEffects(5)="50% extra Explosives damage|50% resistance to Explosives|100% increase in grenade capacity|Can carry 7 Remote Explosives|60% discount on Explosives|90% off Remote Explosives|Spawn with a Pipe Bomb"
     SRLevelEffects(6)="60% extra Explosives damage|55% resistance to Explosives|120% increase in grenade capacity|Can carry 8 Remote Explosives|70% discount on Explosives|93% off Remote Explosives|Spawn with an M79 and Pipe Bomb"
     PerkIndex=6
     OnHUDIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Demolition'
     OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Demolition_Gold'
     VeterancyName="Demolitions"
     Requirements(0)="Deal %x damage with the Explosives"
}
