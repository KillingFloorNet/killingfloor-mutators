class SRVetSupportSpec extends SRVeterancyTypes
	abstract;

static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	switch( CurLevel )
	{
	case 0:
		if( ReqNum==0 )
			FinalInt = 1000;
		else FinalInt = 1000;
		break;
	case 1:
		if( ReqNum==0 )
			FinalInt = 2000;
		else FinalInt = 5000;
		break;
	case 2:
		if( ReqNum==0 )
			FinalInt = 7000;
		else FinalInt = 100000;
		break;
	case 3:
		if( ReqNum==0 )
			FinalInt = 35000;
		else FinalInt = 500000;
		break;
	case 4:
		if( ReqNum==0 )
			FinalInt = 120000;
		else FinalInt = 1500000;
		break;
	case 5:
		if( ReqNum==0 )
			FinalInt = 200000;
		else FinalInt = 3500000;
		break;
	case 6:
		if( ReqNum==0 )
			FinalInt = 300000;
		else FinalInt = 5500000;
		break;
	case 7:
		if( ReqNum==0 )
			FinalInt = 400000;
		else FinalInt = 7500000;
		break;
	case 8:
		if( ReqNum==0 )
			FinalInt = 500000;
		else FinalInt = 9500000;
		break;
	case 9:
		if( ReqNum==0 )
			FinalInt = 600000;
		else FinalInt = 11500000;
		break;
	case 10:
		if( ReqNum==0 )
			FinalInt = 700000;
		else FinalInt = 13500000;
		break;
	case 11:
		if( ReqNum==0 )
			FinalInt = 800000;
		else FinalInt = 15500000;
		break;
	case 12:
		if( ReqNum==0 )
			FinalInt = 900000;
		else FinalInt = 16500000;
		break;
	case 13:
		if( ReqNum==0 )
			FinalInt = 1000000;
		else FinalInt = 17500000;
		break;
	case 14:
		if( ReqNum==0 )
			FinalInt = 1100000;
		else FinalInt = 18500000;
		break;
	case 15:
		if( ReqNum==0 )
			FinalInt = 1200000;
		else FinalInt = 19500000;
		break;
	case 16:
		if( ReqNum==0 )
			FinalInt = 1300000;
		else FinalInt = 20500000;
		break;
	case 17:
		if( ReqNum==0 )
			FinalInt = 1400000;
		else FinalInt = 21500000;
		break;
	case 18:
		if( ReqNum==0 )
			FinalInt = 1500000;
		else FinalInt = 22500000;
		break;
	case 19:
		if( ReqNum==0 )
			FinalInt = 1600000;
		else FinalInt = 23500000;
		break;
	case 20:
		if( ReqNum==0 )
			FinalInt = 1700000;
		else FinalInt = 24500000;
		break;
	case 21:
		if( ReqNum==0 )
			FinalInt = 1800000;
		else FinalInt = 25500000;
		break;
	case 22:
		if( ReqNum==0 )
			FinalInt = 1900000;
		else FinalInt = 26500000;
		break;
	case 23:
		if( ReqNum==0 )
			FinalInt = 2000000;
		else FinalInt = 27500000;
		break;
	case 24:
		if( ReqNum==0 )
			FinalInt = 2100000;
		else FinalInt = 28500000;
		break;
	case 25:
		if( ReqNum==0 )
			FinalInt = 2200000;
		else FinalInt = 29000000;
		break;
	case 26:
		if( ReqNum==0 )
			FinalInt = 2300000;
		else FinalInt = 30000000;
		break;
	case 27:
		if( ReqNum==0 )
			FinalInt = 2400000;
		else FinalInt = 31000000;
		break;
	case 28:
		if( ReqNum==0 )
			FinalInt = 2500000;
		else FinalInt = 32000000;
		break;
	case 29:
		if( ReqNum==0 )
			FinalInt = 2600000;
		else FinalInt = 33000000;
		break;
	case 30:
		if( ReqNum==0 )
			FinalInt = 2700000;
		else FinalInt = 70000000;
		break;
	default:
		if( ReqNum==0 )
			FinalInt = 2700000 + ( 50000 * (CurLevel - 30 ));
		else FinalInt = 70000000 + ( 2500000 * (CurLevel - 30 ));
		break;
	}
	if( ReqNum==0 )
		return Min(StatOther.RWeldingPointsStat,FinalInt);
	return Min(StatOther.RShotgunDamageStat,FinalInt);
}

static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel == 0 )
		return 1;
	else if ( KFPRI.ClientVeteranSkillLevel <= 4 )
		return 2 + KFPRI.ClientVeteranSkillLevel;
	else if ( KFPRI.ClientVeteranSkillLevel == 5 )
		return 10; // 8 more carry slots
	else if ( KFPRI.ClientVeteranSkillLevel == 6 )
		return 14; // 8 more carry slots
	else if ( KFPRI.ClientVeteranSkillLevel == 25 )
		return 40; // 8 more carry slots
	else if ( KFPRI.ClientVeteranSkillLevel == 26 )
		return 41; // 8 more carry slots
	else if ( KFPRI.ClientVeteranSkillLevel == 27 )
		return 42; // 8 more carry slots
	else if ( KFPRI.ClientVeteranSkillLevel == 28 )
		return 43; // 8 more carry slots
	else if ( KFPRI.ClientVeteranSkillLevel == 29 )
		return 44; // 8 more carry slots
	else if ( KFPRI.ClientVeteranSkillLevel == 30 )
		return 50; // 8 more carry slots
	return 20+KFPRI.ClientVeteranSkillLevel; // 9 more carry slots
}

static function float GetWeldSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel <= 3 )
		return 1.0 + (0.25 * float(KFPRI.ClientVeteranSkillLevel));
	if ( KFPRI.ClientVeteranSkillLevel >= 6 )
		return 3.0 + (0.25 * float(KFPRI.ClientVeteranSkillLevel));
	return 4.5; // 150% increase in speed
}

static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	if ( AmmoType == class'FragAmmo' )
		// Up to 6 extra Grenades
		return 1.0 + (0.25 * float(KFPRI.ClientVeteranSkillLevel));
	else if ( AmmoType == class'ShotgunAmmo' || AmmoType == class'DBShotgunAmmo' || AmmoType == class'AA12Ammo'
		 || AmmoType == class'BenelliAmmo' )
	{
		if ( KFPRI.ClientVeteranSkillLevel > 0 )
		{
			if ( KFPRI.ClientVeteranSkillLevel == 1 )
				return 1.10;
			else if ( KFPRI.ClientVeteranSkillLevel == 2 )
				return 1.20;
			else if ( KFPRI.ClientVeteranSkillLevel >= 6 )
				return 0.8 + (0.20 * float(KFPRI.ClientVeteranSkillLevel));
			return 1.25; // 25% increase in shotgun ammo carried
		}
	}
	return 1.0;
}

static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	if ( DmgType == class'DamTypeShotgun' || DmgType == class'DamTypeDBShotgun' || DmgType == class'DamTypeAA12Shotgun'
		 || DmgType == class'DamTypeBenelli' )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
			return float(InDamage) * 1.10;
		if ( KFPRI.ClientVeteranSkillLevel == 6 )
			return float(InDamage) * 2.00;
		if ( KFPRI.ClientVeteranSkillLevel >= 7 )
			return float(InDamage) * (3.5 + (0.1 * float(KFPRI.ClientVeteranSkillLevel)));
		return InDamage * (1.00 + (0.15 * float(KFPRI.ClientVeteranSkillLevel))); // Up to 60% more damage with Shotguns
	}
	else if ( DmgType == class'DamTypeFrag' && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 1 )
			return float(InDamage) * 1.05;
		return float(InDamage) * (0.90 + (0.15 * float(KFPRI.ClientVeteranSkillLevel))); // Up to 50% more damage with Nades
	}
	return InDamage;
}

// Reduce Penetration damage with Shotgun slower
static function float GetShotgunPenetrationDamageMulti(KFPlayerReplicationInfo KFPRI, float DefaultPenDamageReduction)
{
	local float PenDamageInverse;

	PenDamageInverse = 1.0 - FMax(0,DefaultPenDamageReduction);

	if ( KFPRI.ClientVeteranSkillLevel == 0 )
		return DefaultPenDamageReduction + (PenDamageInverse / 10.0);
	if ( KFPRI.ClientVeteranSkillLevel == 1 )
		return DefaultPenDamageReduction + (PenDamageInverse / 20.0);
	if ( KFPRI.ClientVeteranSkillLevel == 2 )
		return DefaultPenDamageReduction + (PenDamageInverse / 30.0);
	if ( KFPRI.ClientVeteranSkillLevel == 3 )
		return DefaultPenDamageReduction + (PenDamageInverse / 40.0);
	if ( KFPRI.ClientVeteranSkillLevel == 4 )
		return DefaultPenDamageReduction + (PenDamageInverse / 50.0);
	if ( KFPRI.ClientVeteranSkillLevel == 5 )
		return DefaultPenDamageReduction + (PenDamageInverse / 60.0);
	if ( KFPRI.ClientVeteranSkillLevel == 6 )
		return DefaultPenDamageReduction + (PenDamageInverse / 70.0);
	if ( KFPRI.ClientVeteranSkillLevel == 7 )
		return DefaultPenDamageReduction + (PenDamageInverse / 80.0);
	if ( KFPRI.ClientVeteranSkillLevel == 8 )
		return DefaultPenDamageReduction + (PenDamageInverse / 90.0);
	if ( KFPRI.ClientVeteranSkillLevel >= 9 )
		return DefaultPenDamageReduction + (PenDamageInverse / 99.0);

	return DefaultPenDamageReduction + ((PenDamageInverse / 5.5555) * float(Min(KFPRI.ClientVeteranSkillLevel, 5)));
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'ShotgunPickup' || Item == class'BoomstickPickup' || Item == class'WTFEquipAFS12Pickup' || Item == class'AA12Pickup' || Item == class'BenelliPickup' )
		return FMax(0.255 - (0.001 * float(KFPRI.ClientVeteranSkillLevel)),0.1f); // Up to 70% discount on Shotguns
	return 1.0;
}

// Give Extra Items as Default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	// If Level 5, give them Assault Shotgun
	if ( KFPRI.ClientVeteranSkillLevel >= 5 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Shotgun", GetCostScaling(KFPRI, class'ShotgunPickup'));
	// If Level 6, give them Hunting Shotgun
	if ( KFPRI.ClientVeteranSkillLevel >= 6 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.BoomStick", GetCostScaling(KFPRI, class'BoomStickPickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 15 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.AA12AutoShotgun", GetCostScaling(KFPRI, class'AA12Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 20 )
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipAFS12a", GetCostScaling(KFPRI, class'WTFEquipAFS12Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 25 )
		P.ShieldStrength = 100;
}

static function string GetCustomLevelInfo( byte Level )
{
	local string S;

	S = Default.CustomLevelInfo;
	ReplaceText(S,"%s",GetPercentStr(0.1 * float(Level)));
	ReplaceText(S,"%g",GetPercentStr(0.1*float(Level)-0.1f));
	ReplaceText(S,"%d",GetPercentStr(0.1+FMin(0.1 * float(Level),0.8f)));
	return S;
}

defaultproperties
{
     CustomLevelInfo="%s more damage with Shotguns|90% better Shotgun penetration|30% extra shotgun ammo|%g more damage with Grenades|120% increase in grenade capacity|%s increased carry weight|150% faster welding/unwelding|%d discount on Shotguns|Spawn with a Hunting Shotgun"
     SRLevelEffects(0)="10% more damage with Shotguns|10% better Shotgun penetration|10% faster welding/unwelding|10% discount on Shotguns"
     SRLevelEffects(1)="10% more damage with Shotguns|18% better Shotgun penetration|10% extra shotgun ammo|5% more damage with Grenades|20% increase in grenade capacity|15% increased carry weight|25% faster welding/unwelding|20% discount on Shotguns"
     SRLevelEffects(2)="20% more damage with Shotguns|36% better Shotgun penetration|20% extra shotgun ammo|10% more damage with Grenades|40% increase in grenade capacity|20% increased carry weight|50% faster welding/unwelding|30% discount on Shotguns"
     SRLevelEffects(3)="30% more damage with Shotguns|54% better Shotgun penetration|25% extra shotgun ammo|20% more damage with Grenades|60% increase in grenade capacity|25% increased carry weight|75% faster welding/unwelding|40% discount on Shotguns"
     SRLevelEffects(4)="40% more damage with Shotguns|72% better Shotgun penetration|25% extra shotgun ammo|30% more damage with Grenades|80% increase in grenade capacity|30% increased carry weight|100% faster welding/unwelding|50% discount on Shotguns"
     SRLevelEffects(5)="50% more damage with Shotguns|90% better Shotgun penetration|25% extra shotgun ammo|40% more damage with Grenades|100% increase in grenade capacity|50% increased carry weight|150% faster welding/unwelding|60% discount on Shotguns|Spawn with a Shotgun"
     SRLevelEffects(6)="60% more damage with Shotguns|90% better Shotgun penetration|30% extra shotgun ammo|50% more damage with Grenades|120% increase in grenade capacity|60% increased carry weight|150% faster welding/unwelding|70% discount on Shotguns|Spawn with a Hunting Shotgun"
     NumRequirements=2
     PerkIndex=1
     OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_Support'
     OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Support_Gold'
     VeterancyName="Support Specialist"
     Requirements(0)="Weld %x door hitpoints"
     Requirements(1)="Deal %x damage with shotguns"
}
