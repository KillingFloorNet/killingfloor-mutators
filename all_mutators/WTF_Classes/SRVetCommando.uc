class SRVetCommando extends SRVeterancyTypes
	abstract;

static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	switch( CurLevel )
	{
	case 0:
		if( ReqNum==0 )
			FinalInt = 10;
		else FinalInt = 10000;
		break;
	case 1:
		if( ReqNum==0 )
			FinalInt = 30;
		else FinalInt = 25000;
		break;
	case 2:
		if( ReqNum==0 )
			FinalInt = 100;
		else FinalInt = 100000;
		break;
	case 3:
		if( ReqNum==0 )
			FinalInt = 350;
		else FinalInt = 500000;
		break;
	case 4:
		if( ReqNum==0 )
			FinalInt = 500;
		else FinalInt = 1500000;
		break;
	case 5:
		if( ReqNum==0 )
			FinalInt = 1250;
		else FinalInt = 3500000;
		break;
	case 6:
		if( ReqNum==0 )
			FinalInt = 1500;
		else FinalInt = 5500000;
		break;
	case 7:
		if( ReqNum==0 )
			FinalInt = 1750;
		else FinalInt = 7500000;
		break;
	case 8:
		if( ReqNum==0 )
			FinalInt = 2000;
		else FinalInt = 9500000;
		break;
	case 9:
		if( ReqNum==0 )
			FinalInt = 2250;
		else FinalInt = 11500000;
		break;
	case 10:
		if( ReqNum==0 )
			FinalInt = 2500;
		else FinalInt = 13500000;
		break;
	case 11:
		if( ReqNum==0 )
			FinalInt = 3750;
		else FinalInt = 15500000;
		break;
	case 12:
		if( ReqNum==0 )
			FinalInt = 4000;
		else FinalInt = 16500000;
		break;
	case 13:
		if( ReqNum==0 )
			FinalInt = 4250;
		else FinalInt = 17500000;
		break;
	case 14:
		if( ReqNum==0 )
			FinalInt = 4500;
		else FinalInt = 18500000;
		break;
	case 15:
		if( ReqNum==0 )
			FinalInt = 4750;
		else FinalInt = 19500000;
		break;
	case 16:
		if( ReqNum==0 )
			FinalInt = 5000;
		else FinalInt = 20500000;
		break;
	case 17:
		if( ReqNum==0 )
			FinalInt = 5250;
		else FinalInt = 21500000;
		break;
	case 18:
		if( ReqNum==0 )
			FinalInt = 5500;
		else FinalInt = 22500000;
		break;
	case 19:
		if( ReqNum==0 )
			FinalInt = 5750;
		else FinalInt = 23500000;
		break;
	case 20:
		if( ReqNum==0 )
			FinalInt = 6000;
		else FinalInt = 24500000;
		break;
	case 21:
		if( ReqNum==0 )
			FinalInt = 6250;
		else FinalInt = 25500000;
		break;
	case 22:
		if( ReqNum==0 )
			FinalInt = 6500;
		else FinalInt = 26500000;
		break;
	case 23:
		if( ReqNum==0 )
			FinalInt = 6750;
		else FinalInt = 27500000;
		break;
	case 24:
		if( ReqNum==0 )
			FinalInt = 7000;
		else FinalInt = 28500000;
		break;
	case 25:
		if( ReqNum==0 )
			FinalInt = 7250;
		else FinalInt = 29000000;
		break;
	case 26:
		if( ReqNum==0 )
			FinalInt = 7500;
		else FinalInt = 30000000;
		break;
	case 27:
		if( ReqNum==0 )
			FinalInt = 7750;
		else FinalInt = 31000000;
		break;
	case 28:
		if( ReqNum==0 )
			FinalInt = 8000;
		else FinalInt = 32000000;
		break;
	case 29:
		if( ReqNum==0 )
			FinalInt = 8250;
		else FinalInt = 33000000;
		break;
	case 30:
		if( ReqNum==0 )
			FinalInt = 10000;
		else FinalInt = 70000000;
		break;
	default:
		if( ReqNum==0 )
			FinalInt = 10000 + ( 200 * (CurLevel - 30 ));
		else FinalInt = 70000000 + ( 2500000 * (CurLevel - 30 ));
	}
	if( ReqNum==0 )
		return Min(StatOther.RStalkerKillsStat,FinalInt);
	return Min(StatOther.RBullpupDamageStat,FinalInt);
}

// Display enemy health bars
static function SpecialHUDInfo(KFPlayerReplicationInfo KFPRI, Canvas C)
{
	local KFMonster KFEnemy;
	local HUDKillingFloor HKF;
	local float MaxDistance;

	if ( KFPRI.ClientVeteranSkillLevel > 0 )
	{
		HKF = HUDKillingFloor(C.ViewPort.Actor.myHUD);
		if ( HKF == none || Pawn(C.ViewPort.Actor.ViewTarget)==none || Pawn(C.ViewPort.Actor.ViewTarget).Health<=0 )
			return;

		switch ( KFPRI.ClientVeteranSkillLevel )
		{
			case 1:
				MaxDistance = 160; // 20% (160 units)
				break;
			case 2:
				MaxDistance = 320; // 40% (320 units)
				break;
			case 3:
				MaxDistance = 480; // 60% (480 units)
				break;
			case 4:
				MaxDistance = 640; // 80% (640 units)
				break;
			case 5:
				MaxDistance = 800; // 80% (640 units)
				break;
			case 6:
				MaxDistance = 900; // 80% (640 units)
				break;
			case 7:
				MaxDistance = 999; // 80% (640 units)
				break;
			case 8:
				MaxDistance = 999; // 80% (640 units)
				break;
			case 9:
				MaxDistance = 999; // 80% (640 units)
				break;
			case 10:
				MaxDistance = 999; // 80% (640 units)
				break;
			case 11:
				MaxDistance = 999; // 80% (640 units)
				break;
			case 12:
				MaxDistance = 999; // 80% (640 units)
				break;
			case 13:
				MaxDistance = 999; // 80% (640 units)
				break;
			case 14:
				MaxDistance = 999; // 80% (640 units)
				break;
			case 15:
				MaxDistance = 999; // 80% (640 units)
				break;
			case 16:
				MaxDistance = 1000; // 80% (640 units)
				break;
			case 17:
				MaxDistance = 1200; // 80% (640 units)
				break;
			case 18:
				MaxDistance = 1400; // 80% (640 units)
				break;
			case 19:
				MaxDistance = 1600; // 80% (640 units)
				break;
			case 20:
				MaxDistance = 1800; // 80% (640 units)
				break;
			case 21:
				MaxDistance = 2000; // 80% (640 units)
				break;
			case 22:
				MaxDistance = 2200; // 80% (640 units)
				break;
			case 23:
				MaxDistance = 2400; // 80% (640 units)
				break;
			case 24:
				MaxDistance = 2600; // 80% (640 units)
				break;
			case 25:
				MaxDistance = 2800; // 80% (640 units)
				break;
			case 26:
				MaxDistance = 3000; // 80% (640 units)
				break;
			case 27:
				MaxDistance = 3200; // 80% (640 units)
				break;
			case 28:
				MaxDistance = 3400; // 80% (640 units)
				break;
			case 29:
				MaxDistance = 3600; // 80% (640 units)
				break;
			case 30:
				MaxDistance = 4000; // 80% (640 units)
				break;
			default:
				MaxDistance = 4000 + (100 * (float(KFPRI.ClientVeteranSkillLevel) - 30)); // 100% (800 units)
				break;
		}

		foreach C.ViewPort.Actor.VisibleCollidingActors(class'KFMonster',KFEnemy,MaxDistance,C.ViewPort.Actor.CalcViewLocation)
		{
			if ( KFEnemy.Health > 0 && !KFEnemy.Cloaked() )
				HKF.DrawHealthBar(C, KFEnemy, KFEnemy.Health, KFEnemy.HealthMax , 50.0);
		}
	}
}

static function bool ShowStalkers(KFPlayerReplicationInfo KFPRI)
{
	return true;
}

static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel >= 0 )
		return 1;
	return 7+KFPRI.ClientVeteranSkillLevel; // 9 more carry slots
}


static function float GetStalkerViewDistanceMulti(KFPlayerReplicationInfo KFPRI)
{
	switch ( KFPRI.ClientVeteranSkillLevel )
	{
		case 0:
			return 0.0625; // 25%
		case 1:
			return 0.25; // 50%
		case 2:
			return 0.36; // 60%
		case 3:
			return 0.49; // 70%
		case 4:
			return 0.64; // 80%
		case 5:
			return 0.66; // 80%
		case 6:
			return 0.68; // 80%
		case 7:
			return 0.70; // 80%
		case 8:
			return 0.72; // 80%
		case 9:
			return 0.74; // 80%
		case 10:
			return 0.76; // 80%
		case 11:
			return 0.78; // 80%
		case 12:
			return 0.80; // 80%
		case 13:
			return 0.82; // 80%
		case 14:
			return 0.84; // 80%
		case 15:
			return 0.99; // 80%
		case 16:
			return 1.19; // 80%
		case 17:
			return 1.29; // 80%
		case 18:
			return 1.39; // 80%
		case 19:
			return 1.49; // 80%
		case 20:
			return 1.59; // 80%
		case 21:
			return 1.69; // 80%
		case 22:
			return 1.79; // 80%
		case 23:
			return 1.89; // 80%
		case 24:
			return 1.99; // 80%
		case 25:
			return 2.09; // 80%
		case 26:
			return 2.19; // 80%
		case 27:
			return 2.29; // 80%
		case 28:
			return 2.39; // 80%
		case 29:
			return 2.49; // 80%
		case 30:
			return 3.50; // 80%
	}

	return 3.50 + (0.01 * (float(KFPRI.ClientVeteranSkillLevel) - 30)); // 100% of Standard Distance(800 units or 16 meters)
}

static function float GetMagCapacityMod(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	if ( (Bullpup(Other) != none || AK47AssaultRifle(Other) != none || SCARMK17AssaultRifle(Other) != none || M4AssaultRifle(Other) != none)
		 && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 1 )
			return 1.10;
		else if ( KFPRI.ClientVeteranSkillLevel == 2 )
			return 1.20;
		else if ( KFPRI.ClientVeteranSkillLevel <= 5 )
			return 1.30;
		else if ( KFPRI.ClientVeteranSkillLevel >= 6 )
			return 1.00 + (0.10 * float(KFPRI.ClientVeteranSkillLevel));
		return 1.25; // 25% increase in assault rifle ammo carry
	}
	return 1.0;
}

static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
	if ( (BullpupAmmo(Other) != none || AK47Ammo(Other) != none || SCARMK17Ammo(Other) != none || M4Ammo(Other) != none )
		 && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 1 )
			return 1.10;
		else if ( KFPRI.ClientVeteranSkillLevel == 2 )
			return 1.20;
		else if ( KFPRI.ClientVeteranSkillLevel <= 5 )
			return 1.30;
		else if ( KFPRI.ClientVeteranSkillLevel >= 6 )
			return 1.00 + (0.10 * float(KFPRI.ClientVeteranSkillLevel));
		return 1.25; // 25% increase in assault rifle ammo carry
	}
	return 1.0;
}
static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{
	if ( (AmmoType == class'BullpupAmmo' || AmmoType == class'AK47Ammo' || AmmoType == class'SCARMK17Ammo' || AmmoType == class'M4Ammo')
		 && KFPRI.ClientVeteranSkillLevel > 0 )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 1 )
			return 1.10;
		else if ( KFPRI.ClientVeteranSkillLevel == 2 )
			return 1.20;
		else if ( KFPRI.ClientVeteranSkillLevel <= 5 )
			return 1.30;
		else if ( KFPRI.ClientVeteranSkillLevel >= 6 )
			return 1.00 + (0.10 * float(KFPRI.ClientVeteranSkillLevel));
		return 1.25; // 25% increase in assault rifle ammo carry
	}
	return 1.0;
}
static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
	if ( DmgType == class'DamTypeBullpup' || DmgType == class'DamTypeAK47AssaultRifle'
		 || DmgType == class'DamTypeSCARMK17AssaultRifle' || DmgType == class'DamTypeM4AssaultRifle' )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
			return float(InDamage) * 1.10;
		if ( KFPRI.ClientVeteranSkillLevel == 1 )
			return float(InDamage) * 1.35;
		if ( KFPRI.ClientVeteranSkillLevel == 2 )
			return float(InDamage) * 1.55;
		if ( KFPRI.ClientVeteranSkillLevel == 3 )
			return float(InDamage) * 1.75;
		if ( KFPRI.ClientVeteranSkillLevel == 4 )
			return float(InDamage) * 1.95;
		if ( KFPRI.ClientVeteranSkillLevel == 5 )
			return float(InDamage) * 2.15;
		if ( KFPRI.ClientVeteranSkillLevel == 6 )
			return float(InDamage) * 2.35;
		if ( KFPRI.ClientVeteranSkillLevel == 7 )
			return float(InDamage) * 2.55;
		if ( KFPRI.ClientVeteranSkillLevel == 8 )
			return float(InDamage) * 2.75;
		if ( KFPRI.ClientVeteranSkillLevel == 9 )
			return float(InDamage) * 2.95;
		if ( KFPRI.ClientVeteranSkillLevel == 10 )
			return float(InDamage) * 3.15;
		if ( KFPRI.ClientVeteranSkillLevel == 11 )
			return float(InDamage) * 3.35;
		if ( KFPRI.ClientVeteranSkillLevel == 12 )
			return float(InDamage) * 3.55;
		if ( KFPRI.ClientVeteranSkillLevel == 13 )
			return float(InDamage) * 3.75;
		if ( KFPRI.ClientVeteranSkillLevel == 14 )
			return float(InDamage) * 3.95;
		if ( KFPRI.ClientVeteranSkillLevel == 15 )
			return float(InDamage) * 4.15;
		if ( KFPRI.ClientVeteranSkillLevel == 16 )
			return float(InDamage) * 4.35;
		if ( KFPRI.ClientVeteranSkillLevel == 17 )
			return float(InDamage) * 4.55;
		if ( KFPRI.ClientVeteranSkillLevel == 18 )
			return float(InDamage) * 4.75;
		if ( KFPRI.ClientVeteranSkillLevel == 19 )
			return float(InDamage) * 4.95;
		if ( KFPRI.ClientVeteranSkillLevel == 20 )
			return float(InDamage) * 5.15;
		if ( KFPRI.ClientVeteranSkillLevel == 21 )
			return float(InDamage) * 5.35;
		if ( KFPRI.ClientVeteranSkillLevel == 22 )
			return float(InDamage) * 5.55;
		if ( KFPRI.ClientVeteranSkillLevel == 23 )
			return float(InDamage) * 5.75;
		if ( KFPRI.ClientVeteranSkillLevel == 24 )
			return float(InDamage) * 5.95;
		if ( KFPRI.ClientVeteranSkillLevel == 25 )
			return float(InDamage) * 6.00;
		if ( KFPRI.ClientVeteranSkillLevel == 26 )
			return float(InDamage) * 6.10;
		if ( KFPRI.ClientVeteranSkillLevel == 27 )
			return float(InDamage) * 6.15;
		if ( KFPRI.ClientVeteranSkillLevel == 28 )
			return float(InDamage) * 6.20;
		if ( KFPRI.ClientVeteranSkillLevel == 29 )
			return float(InDamage) * 6.25;
		if ( KFPRI.ClientVeteranSkillLevel == 30 )
			return float(InDamage) * 6.50;
		return float(InDamage) * (6.50 + 0.01 * (float(KFPRI.ClientVeteranSkillLevel) - 30)); // Up to 50% increase in Damage with Bullpup
	}
	return InDamage;
}

static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Recoil)
{
	if ( Bullpup(Other.Weapon) != none || AK47AssaultRifle(Other.Weapon) != none
		 || SCARMK17AssaultRifle(Other.Weapon) != none || M4AssaultRifle(Other.Weapon) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel <= 3 )
			Recoil = 0.95 - (0.05 * float(KFPRI.ClientVeteranSkillLevel));
		else if ( KFPRI.ClientVeteranSkillLevel <= 4 )
			Recoil = 0.70;
		else if ( KFPRI.ClientVeteranSkillLevel <= 5 )
			Recoil = 0.30; // Level 6 - 40% recoil reduction
		else if ( KFPRI.ClientVeteranSkillLevel >= 6 )
			Recoil = 0.31 - (0.01 * float(KFPRI.ClientVeteranSkillLevel)); // Level 6 - 40% recoil reduction
		else Recoil = FMax(0.9 - (0.05 * float(KFPRI.ClientVeteranSkillLevel)),0.f);
		return Recoil;
	}
	Recoil = 1.0;
	return Recoil;
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	return 1.05 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 35% faster reload speed
}

// Set number times Zed Time can be extended
static function int ZedTimeExtensions(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel >= 3 )
		return KFPRI.ClientVeteranSkillLevel + 2; // Up to 4 Zed Time Extensions
	return 0;
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'BullpupPickup' || Item == class'AK47Pickup' || Item == class'WTFEquipAK48SPickup' || Item == class'WTFEquipSCAR19Pickup' || Item == class'SCARMK17Pickup' || Item == class'M4Pickup' )
		return FMax(0.255 - (0.001 * float(KFPRI.ClientVeteranSkillLevel)),0.1); // Up to 70% discount on Assault Rifles
	return 1.0;
}

// Give Extra Items as default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	// If Level 5, give them Bullpup
	if ( KFPRI.ClientVeteranSkillLevel == 5 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Bullpup", GetCostScaling(KFPRI, class'BullpupPickup'));
	// If Level 6, give them an AK47
	if ( KFPRI.ClientVeteranSkillLevel == 6 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.AK47AssaultRifle", GetCostScaling(KFPRI, class'AK47Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 7 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.AK47AssaultRifle", GetCostScaling(KFPRI, class'AK47Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 8 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.AK47AssaultRifle", GetCostScaling(KFPRI, class'AK47Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 9 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.AK47AssaultRifle", GetCostScaling(KFPRI, class'AK47Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 10 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.AK47AssaultRifle", GetCostScaling(KFPRI, class'AK47Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 11 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.AK47AssaultRifle", GetCostScaling(KFPRI, class'AK47Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 12 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.AK47AssaultRifle", GetCostScaling(KFPRI, class'AK47Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 13 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.AK47AssaultRifle", GetCostScaling(KFPRI, class'AK47Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 14 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.AK47AssaultRifle", GetCostScaling(KFPRI, class'AK47Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 15 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.SCARMK17AssaultRifle", GetCostScaling(KFPRI, class'SCARMK17Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 20 )
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipAK48S", GetCostScaling(KFPRI, class'WTFEquipAK48SPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 21 )
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipAK48S", GetCostScaling(KFPRI, class'WTFEquipAK48SPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 22 )
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipAK48S", GetCostScaling(KFPRI, class'WTFEquipAK48SPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 23 )
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipAK48S", GetCostScaling(KFPRI, class'WTFEquipAK48SPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 24 )
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipAK48S", GetCostScaling(KFPRI, class'WTFEquipAK48SPickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 25 )
		KFHumanPawn(P).CreateInventoryVeterancy("WTF.WTFEquipSCAR19a", GetCostScaling(KFPRI, class'WTFEquipSCAR19Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 25 )
		P.ShieldStrength = 100;

}

static function string GetCustomLevelInfo( byte Level )
{
	local string S;

	S = Default.CustomLevelInfo;
	ReplaceText(S,"%s",GetPercentStr(0.05 * float(Level)+0.05));
	ReplaceText(S,"%d",GetPercentStr(0.1+FMin(0.1 * float(Level),0.8f)));
	ReplaceText(S,"%z",string(Level-2));
	ReplaceText(S,"%r",GetPercentStr(FMin(0.05 * float(Level)+0.1,1.f)));
	return S;
}

defaultproperties
{
     CustomLevelInfo="50% more damage with Bullpup/AK47/SCAR/M4|%r less recoil with Bullpup/AK47/SCAR/M4|25% larger Bullpup/AK47/SCAR/M4 clip|%s faster reload with all weapons|%d discount on Bullpup/AK47/SCAR/M4|Spawn with an AK47|Can see cloaked Stalkers from 16m|Can see enemy health from 16m|Up to %z Zed-Time Extensions"
     SRLevelEffects(0)="5% more damage with Bullpup/AK47/SCAR/M4|5% less recoil with Bullpup/AK47/SCAR/M4|5% faster reload with all weapons|10% discount on Bullpup/AK47/SCAR/M4|Can see cloaked Stalkers from 4 meters"
     SRLevelEffects(1)="10% more damage with Bullpup/AK47/SCAR/M4|10% less recoil with Bullpup/AK47/SCAR/M4|10% larger Bullpup/AK47/SCAR/M4 clip|10% faster reload with all weapons|20% discount on Bullpup/AK47/SCAR/M4|Can see cloaked Stalkers from 8m|Can see enemy health from 4m"
     SRLevelEffects(2)="20% more damage with Bullpup/AK47/SCAR/M4|15% less recoil with Bullpup/AK47/SCAR/M4|20% larger Bullpup/AK47/SCAR/M4 clip|15% faster reload with all weapons|30% discount on Bullpup/AK47/SCAR/M4|Can see cloaked Stalkers from 10m|Can see enemy health from 7m"
     SRLevelEffects(3)="30% more damage with Bullpup/AK47/SCAR/M4|20% less recoil with Bullpup/AK47/SCAR/M4|25% larger Bullpup/AK47/SCAR/M4 clip|20% faster reload with all weapons|40% discount on Bullpup/AK47/SCAR/M4|Can see cloaked Stalkers from 12m|Can see enemy health from 10m|Zed-Time can be extended by killing an enemy while in slow motion"
     SRLevelEffects(4)="40% more damage with Bullpup/AK47/SCAR/M4|30% less recoil with Bullpup/AK47/SCAR/M4|25% larger Bullpup/AK47/SCAR/M4 clip|25% faster reload with all weapons|50% discount on Bullpup/AK47/SCAR/M4|Can see cloaked Stalkers from 14m|Can see enemy health from 13m|Up to 2 Zed-Time Extensions"
     SRLevelEffects(5)="50% more damage with Bullpup/AK47/SCAR/M4|30% less recoil with Bullpup/AK47/SCAR/M4|25% larger Bullpup/AK47/SCAR/M4 clip|30% faster reload with all weapons|60% discount on Bullpup/AK47/SCAR/M4|Spawn with a Bullpup|Can see cloaked Stalkers from 16m|Can see enemy health from 16m|Up to 3 Zed-Time Extensions"
     SRLevelEffects(6)="50% more damage with Bullpup/AK47/SCAR/M4|40% less recoil with Bullpup/AK47/SCAR/M4|25% larger Bullpup/AK47/SCAR/M4 clip|35% faster reload with all weapons|70% discount on Bullpup/AK47/SCAR/M4|Spawn with an AK47|Can see cloaked Stalkers from 16m|Can see enemy health from 16m|Up to 4 Zed-Time Extensions"
     NumRequirements=2
     PerkIndex=3
     OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_Commando'
     OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_Commando_Gold'
     VeterancyName="Commando"
     Requirements(0)="Kill %x Stalkers with Bullpup/AK47/SCAR/M4"
     Requirements(1)="Deal %x damage with Bullpup/AK47/SCAR/M4"
}
