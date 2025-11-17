class SRVetSharpshooter extends SRVeterancyTypes
	abstract;

static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
	switch( CurLevel )
	{
	case 0:
		FinalInt = 10;
		break;
	case 1:
		FinalInt = 30;
		break;
	case 2:
		FinalInt = 100;
		break;
	case 3:
		FinalInt = 700;
		break;
	case 4:
		FinalInt = 1000;
		break;
	case 5:
		FinalInt = 3000;
		break;
	case 6:
		FinalInt = 5000;
		break;
	case 7:
		FinalInt = 7000;
		break;
	case 8:
		FinalInt = 9000;
		break;
	case 9:
		FinalInt = 11000;
		break;
	case 10:
		FinalInt = 13000;
		break;
	case 11:
		FinalInt = 15000;
		break;
	case 12:
		FinalInt = 17000;
		break;
	case 13:
		FinalInt = 19000;
		break;
	case 14:
		FinalInt = 21000;
		break;
	case 15:
		FinalInt = 23000;
		break;
	case 16:
		FinalInt = 25000;
		break;
	case 17:
		FinalInt = 27000;
		break;
	case 18:
		FinalInt = 29000;
		break;
	case 19:
		FinalInt = 31000;
		break;
	case 20:
		FinalInt = 33000;
		break;
	case 21:
		FinalInt = 34000;
		break;
	case 22:
		FinalInt = 35000;
		break;
	case 23:
		FinalInt = 36000;
		break;
	case 24:
		FinalInt = 37000;
		break;
	case 25:
		FinalInt = 38000;
		break;
	case 26:
		FinalInt = 39000;
		break;
	case 27:
		FinalInt = 40000;
		break;
	case 28:
		FinalInt = 41000;
		break;
	case 29:
		FinalInt = 42000;
		break;
	case 30:
		FinalInt = 43000;
		break;
	default:
		FinalInt = 43000 + ( 1000 * (CurLevel - 30 ));
	}
	return Min(StatOther.RHeadshotKillsStat,FinalInt);
}

static function float GetHeadShotDamMulti(KFPlayerReplicationInfo KFPRI, class<DamageType> DmgType)
{
	local float ret;

	// Removed extra SS Crossbow headshot damage in Round 1(added back in Round 2) and Removed Single/Dualies Damage for Hell on Earth in Round 6
	// Added Dual Deagles back in for Balance Round 7
	if ( DmgType == class'DamTypeCrossbow' || DmgType == class'DamTypeCrossbowHeadShot' || DmgType == class'DamTypeWinchester' ||
		 DmgType == class'DamTypeDeagle' || DmgType == class'DamTypeDualDeagle' || DmgType == class'DamTypeM14EBR' ||
		  DmgType == class'DamTypeMagnum44Pistol' || DmgType == class'DamTypeDual44Magnum' ||
		 (DmgType == class'DamTypeDualies' && KFPRI.Level.Game.GameDifficulty < 7.0) )
	{
		if ( KFPRI.ClientVeteranSkillLevel <= 3 )
		{
			ret = 1.05 + (0.05 * float(KFPRI.ClientVeteranSkillLevel));
		}
		else if ( KFPRI.ClientVeteranSkillLevel == 4 )
		{
			ret = 1.30;
		}
		else if ( KFPRI.ClientVeteranSkillLevel == 5 )
		{
			ret = 1.50;
		}
		else if ( KFPRI.ClientVeteranSkillLevel >= 6 )
		{
			ret = 1.5 + (0.05 * float(KFPRI.ClientVeteranSkillLevel));
		}
		else
		{
			ret = 1.3 + (0.05 * float(KFPRI.ClientVeteranSkillLevel));
		}
	}
	// Reduced extra headshot damage for Single/Dualies in Hell on Earth difficulty(added in Balance Round 6)
	else if ( DmgType == class'DamTypeDualies' && KFPRI.Level.Game.GameDifficulty <= 1.0 )
	{
		return (1.0 + (0.08 * float(Min(KFPRI.ClientVeteranSkillLevel, 5)))); // 40% increase in Headshot Damage
	}
	else
	{
		ret = 1.0; // Fix for oversight in Balance Round 6(which is the reason for the Round 6 second attempt patch)
	}

	if ( KFPRI.ClientVeteranSkillLevel >= 6 )
	{
		return ret * (1.4 + (0.10 * float(Min(KFPRI.ClientVeteranSkillLevel, 5)))); // 50% increase in Headshot Damage
	}

	return ret * (1.0 + (0.10 * float(Min(KFPRI.ClientVeteranSkillLevel, 5)))); // 50% increase in Headshot Damage
}

static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
	if ( KFPRI.ClientVeteranSkillLevel >= 0 )
		return 1;
	return 7+KFPRI.ClientVeteranSkillLevel; // 9 more carry slots
}


static function float ModifyRecoilSpread(KFPlayerReplicationInfo KFPRI, WeaponFire Other, out float Recoil)
{
	if ( Crossbow(Other.Weapon) != none || Winchester(Other.Weapon) != none ||
		 Deagle(Other.Weapon) != none || M14EBRBattleRifle(Other.Weapon) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 1)
			Recoil = 0.75;
		else if ( KFPRI.ClientVeteranSkillLevel == 2 )
			Recoil = 0.50;
		else if ( KFPRI.ClientVeteranSkillLevel == 3 )
			Recoil = 0.25;
		else if ( KFPRI.ClientVeteranSkillLevel == 4 )
			Recoil = 0.25;
		else if ( KFPRI.ClientVeteranSkillLevel == 5 )
			Recoil = 0.25;
		else if ( KFPRI.ClientVeteranSkillLevel == 6 )
			Recoil = 0.25;
		else if ( KFPRI.ClientVeteranSkillLevel == 7 )
			Recoil = 0.25;
		else if ( KFPRI.ClientVeteranSkillLevel == 8 )
			Recoil = 0.25;
		else if ( KFPRI.ClientVeteranSkillLevel == 9 )
			Recoil = 0.25;
		else if ( KFPRI.ClientVeteranSkillLevel == 10 )
			Recoil = 0.25;
		else if ( KFPRI.ClientVeteranSkillLevel == 11 )
			Recoil = 0.25;
		else if ( KFPRI.ClientVeteranSkillLevel == 12 )
			Recoil = 0.25;
		else if ( KFPRI.ClientVeteranSkillLevel == 13 )
			Recoil = 0.25;
		else if ( KFPRI.ClientVeteranSkillLevel == 14 )
			Recoil = 0.25;
		else if ( KFPRI.ClientVeteranSkillLevel >= 15 )
			Recoil = 0.01;
		else Recoil = 0.10; // 75% recoil reduction with Crossbow/Winchester/Handcannon
		return Recoil;
	}
	Recoil = 1.0;
	Return Recoil;
}

// Modify fire speed
static function float GetFireSpeedMod(KFPlayerReplicationInfo KFPRI, Weapon Other)
{
	if ( Winchester(Other) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
			return 1.0;
		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% faster fire rate with Winchester
	}
	return 1.0;
}

static function float GetReloadSpeedModifier(KFPlayerReplicationInfo KFPRI, KFWeapon Other)
{
	if ( Crossbow(Other) != none || Winchester(Other) != none ||
		 Deagle(Other) != none || M14EBRBattleRifle(Other) != none )
	{
		if ( KFPRI.ClientVeteranSkillLevel == 0 )
			return 1.0;
		return 1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // Up to 60% faster reload with Crossbow/Winchester/Handcannon
	}
	return 1.0;
}

// Change the cost of particular items
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'DeaglePickup' || Item == class'DualDeaglePickup'
		 || Item == class'Magnum44Pickup' || Item == class'Dual44MagnumPickup' || Item == class'B94Pickup' || Item == class'M14EBRPickup' )
		return FMax(0.255 - (0.001 * float(KFPRI.ClientVeteranSkillLevel)),0.1); // Up to 70% discount on Handcannon/Dual Handcannons/EBR
	return 1.0;
}

static function float GetAmmoCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
	if ( Item == class'CrossbowPickup' )
		return FMax(0.255 - (0.001 * float(KFPRI.ClientVeteranSkillLevel)),0.1f); // Up to 42% discount on Crossbow Bolts(Added in Balance Round 4 at 30%, increased to 42% in Balance Round 7)
	return 1.0;
}

// Give Extra Items as Default
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{
	// If Level 5, give them a  Lever Action Rifle
	if ( KFPRI.ClientVeteranSkillLevel == 5 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Winchester", GetCostScaling(KFPRI, class'DualDeaglePickup'));

	// If Level 6, give them a Crossbow
	if ( KFPRI.ClientVeteranSkillLevel == 6 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Crossbow", GetCostScaling(KFPRI, class'CrossbowPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 7 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Crossbow", GetCostScaling(KFPRI, class'CrossbowPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 8 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Crossbow", GetCostScaling(KFPRI, class'CrossbowPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 9 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Crossbow", GetCostScaling(KFPRI, class'CrossbowPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 10 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Crossbow", GetCostScaling(KFPRI, class'CrossbowPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 11 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Crossbow", GetCostScaling(KFPRI, class'CrossbowPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 12 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Crossbow", GetCostScaling(KFPRI, class'CrossbowPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 13 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Crossbow", GetCostScaling(KFPRI, class'CrossbowPickup'));
	if ( KFPRI.ClientVeteranSkillLevel == 14 )
		KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Crossbow", GetCostScaling(KFPRI, class'CrossbowPickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 15 )
		KFHumanPawn(P).CreateInventoryVeterancy("B94Mut.B94", GetCostScaling(KFPRI, class'B94Pickup'));
	if ( KFPRI.ClientVeteranSkillLevel >= 20 )
		P.ShieldStrength = 100;
}

static function string GetCustomLevelInfo( byte Level )
{
	local string S;

	S = Default.CustomLevelInfo;
	ReplaceText(S,"%s",GetPercentStr((1.1 + (0.05 * float(Level)))));
	ReplaceText(S,"%p",GetPercentStr(0.1 * float(Level)));
	ReplaceText(S,"%d",GetPercentStr(0.1+FMin(0.1 * float(Level),0.8f)));
	return S;
}

defaultproperties
{
     CustomLevelInfo="%s more damage with Pistols, Rifle, Crossbow, and M14|75% less recoil with Pistols, Rifle, Crossbow, and M14|%p faster reload with Pistols, Rifle, Crossbow, and M14|50% extra headshot damage|%d discount on Handcannon/44 Magnum/M14|Spawn with a Crossbow"
     SRLevelEffects(0)="5% more damage with Pistols, Rifle, Crossbow, and M14|5% extra Headshot damage with all weapons|10% discount on Handcannon/M14"
     SRLevelEffects(1)="10% more damage with Pistols, Rifle, Crossbow, and M14|25% less recoil with Pistols, Rifle, Crossbow, and M14|10% faster reload with Pistols, Rifle, Crossbow, and M14|10% extra headshot damage|20% discount on Handcannon/44 Magnum/M14"
     SRLevelEffects(2)="15% more damage with Pistols, Rifle, Crossbow, and M14|50% less recoil with Pistols, Rifle, Crossbow, and M14|20% faster reload with Pistols, Rifle, Crossbow, and M14|20% extra headshot damage|30% discount on Handcannon/44 Magnum/M14"
     SRLevelEffects(3)="20% more damage with Pistols, Rifle, Crossbow, and M14|75% less recoil with Pistols, Rifle, Crossbow, and M14|30% faster reload with Pistols, Rifle, Crossbow, and M14|30% extra headshot damage|40% discount on Handcannon/44 Magnum/M14"
     SRLevelEffects(4)="30% more damage with Pistols, Rifle, Crossbow, and M14|75% less recoil with Pistols, Rifle, Crossbow, and M14|40% faster reload with Pistols, Rifle, Crossbow, and M14|40% extra headshot damage|50% discount on Handcannon/44 Magnum/M14"
     SRLevelEffects(5)="50% more damage with Pistols, Rifle, Crossbow, and M14|75% less recoil with Pistols, Rifle, Crossbow, and M14|50% faster reload with Pistols, Rifle, Crossbow, and M14|50% extra headshot damage|60% discount on Handcannon/44 Magnum/M14|Spawn with a Lever Action Rifle"
     SRLevelEffects(6)="60% more damage with Pistols, Rifle, Crossbow, and M14|75% less recoil with Pistols, Rifle, Crossbow, and M14|60% faster reload with Pistols, Rifle, Crossbow, and M14|50% extra headshot damage|70% discount on Handcannon/44 Magnum/M14|Spawn with a Crossbow"
     PerkIndex=2
     OnHUDIcon=Texture'KillingFloorHUD.Perks.Perk_SharpShooter'
     OnHUDGoldIcon=Texture'KillingFloor2HUD.Perk_Icons.Perk_SharpShooter_Gold'
     VeterancyName="Sharpshooter"
     Requirements(0)="Get %x headshot kills with Pistols, Rifle, Crossbow, or M14"
}
