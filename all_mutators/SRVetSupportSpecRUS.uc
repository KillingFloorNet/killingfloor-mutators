class SRVetSupportSpec extends SRVeterancyTypes
    abstract;
  

static function int GetPerkProgressInt( ClientPerkRepLink StatOther, out int FinalInt, byte CurLevel, byte ReqNum )
{
    switch( CurLevel )
    {
    case 0:
        if( ReqNum==0 )
            FinalInt = 10000;
        else FinalInt = 25000;
        break;
    case 1:
        if( ReqNum==0 )
            FinalInt = 20000;
        else FinalInt = 100000;
        break;
    case 2:
        if( ReqNum==0 )
            FinalInt = 45000;
        else FinalInt = 500000;
        break;
    case 3:
        if( ReqNum==0 )
            FinalInt = 100000;
        else FinalInt = 1500000;
        break;
    case 4:
        if( ReqNum==0 )
            FinalInt = 200000;
        else FinalInt = 3500000;
        break;
    case 5:
        if( ReqNum==0 )
            FinalInt = 310000;
        else FinalInt = 5500000;
        break;
    case 6:
        if( ReqNum==0 )
            FinalInt = 450000;
        else FinalInt = 9000000;
        break;
    case 7:
        if( ReqNum==0 )
            FinalInt = 600000;
        else FinalInt = 13000000;
        break;
    case 8:
        if( ReqNum==0 )
            FinalInt = 800000;
        else FinalInt = 24000000;
        break;
    case 9:
        if( ReqNum==0 )
            FinalInt = 1100000;
        else FinalInt = 34000000;
        break;
    case 10:
        if( ReqNum==0 )
            FinalInt = 1700000;
        else FinalInt = 45000000;
        break;      
    case 11:
        if( ReqNum==0 )
            FinalInt = 2500000;
        else FinalInt = 60000000;
        break;
    case 12:
        if( ReqNum==0 )
            FinalInt = 3400000;
        else FinalInt = 80000000;
        break;      
    case 13:
        if( ReqNum==0 )
            FinalInt = 4500000;
        else FinalInt = 120000000;
        break;
    case 14:
        if( ReqNum==0 )
            FinalInt = 450000000;
        else FinalInt = 2147483640;
        break;
    default:
        if( ReqNum==0 )
            FinalInt = 370000+GetDoubleScaling(CurLevel,35000);
        else FinalInt = 5500000+GetDoubleScaling(CurLevel,500000);
        break;
    }
    if( ReqNum==0 )
        return Min(StatOther.RWeldingPointsStat,FinalInt);
    return Min(StatOther.RShotgunDamageStat,FinalInt);
}


///////////////////////Переносимый вес///////////////////////
static function int AddCarryMaxWeight(KFPlayerReplicationInfo KFPRI)
{
        if ( KFPRI.ClientVeteranSkillLevel == 0 )
            return 2.0;
        return 2.0 + (3.0 * float(KFPRI.ClientVeteranSkillLevel));  
}
///////////////////////Переносимый вес///////////////////////


///////////////////////Скорость сварки///////////////////////
static function float GetWeldSpeedModifier(KFPlayerReplicationInfo KFPRI)
{
        if ( KFPRI.ClientVeteranSkillLevel == 0 )
            return 1.10;
        return 1.10 + (0.3 * float(KFPRI.ClientVeteranSkillLevel));  
}
///////////////////////Скорость сварки///////////////////////


///////////////////////Дополнительный патроны///////////////////////
static function float AddExtraAmmoFor(KFPlayerReplicationInfo KFPRI, Class<Ammunition> AmmoType)
{

    if( class<SRAmmunition>(AmmoType) != none && class<SRAmmunition>(AmmoType).default.bIsPowerAmmo )
    {

        if ( KFPRI.ClientVeteranSkillLevel == 0 )
            return 1.10;
        return 1.10 + (0.15 * float(KFPRI.ClientVeteranSkillLevel));
    }
    return 1.0;
}
///////////////////////Дополнительный патроны///////////////////////


///////////////////////скидка на патроны///////////////////////
static function float GetAmmoCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
        if( class<KFWeaponPickup>(Item) != none && class<KFWeaponPickup>(Item).default.CorrespondingPerkIndex == 1)
        {
        if ( KFPRI.ClientVeteranSkillLevel == 0 )
            return 0.95;
        return FMax (0.95 - (0.06 * float(KFPRI.ClientVeteranSkillLevel)),0.05); // 89% скидка на gfnhjys
        }                      
    return 1.0;
}
///////////////////////скидка на патроны///////////////////////


///////////////////////подбор патронов///////////////////////
static function float GetAmmoPickupMod(KFPlayerReplicationInfo KFPRI, KFAmmunition Other)
{
return 1.05 + (0.10 * float(KFPRI.ClientVeteranSkillLevel)); // на 130% больше подбираеся патронов с коробки
}
///////////////////////подбор патронов///////////////////////


///////////////////////Урон+///////////////////////
static function int AddDamage(KFPlayerReplicationInfo KFPRI, KFMonster Injured, KFPawn DamageTaker, int InDamage, class<DamageType> DmgType)
{
    if( class<KFWeaponDamageType>(DmgType) != none && class<KFWeaponDamageType>(DmgType).default.bIsPowerWeapon)
    {
        if ( KFPRI.ClientVeteranSkillLevel == 0 )
            return float(InDamage) * 1.02;
        return float(InDamage) * (1.02 + (0.07 * float(KFPRI.ClientVeteranSkillLevel)));
    }
    if (DmgType != none && DmgType.Name != 'none' &&  DmgType.Name == 'DamTypeFrag' )
    {
        if ( KFPRI.ClientVeteranSkillLevel == 0 )
            return float(InDamage) * 1.05;
        return float(InDamage) * (1.0 + (0.10 * float(KFPRI.ClientVeteranSkillLevel))); //  на 110% больше наносимый урон гранатами на 11 лвл
    }
    return InDamage;
}
///////////////////////Урон+///////////////////////


///////////////////////пробивная способность дроби///////////////////////
static function float GetShotgunPenetrationDamageMulti(KFPlayerReplicationInfo KFPRI, float DefaultPenDamageReduction)
{
    local float PenDamageInverse;

    PenDamageInverse = 1.0 - FMax(0,DefaultPenDamageReduction);

    if ( KFPRI.ClientVeteranSkillLevel == 0 )
        return DefaultPenDamageReduction + (PenDamageInverse / 10.0);

    return DefaultPenDamageReduction + ((PenDamageInverse / 5.5555) * float(Min(KFPRI.ClientVeteranSkillLevel, 7)));
}
///////////////////////пробивная способность дроби///////////////////////


///////////////////////скидка на оружие///////////////////////
static function float GetCostScaling(KFPlayerReplicationInfo KFPRI, class<Pickup> Item)
{
    if( class<KFWeaponPickup>(Item) != none && class<KFWeaponPickup>(Item).default.CorrespondingPerkIndex == 1)
        return FMax(1.0 - (0.07 * float(KFPRI.ClientVeteranSkillLevel)),0.10); // Up to 70% discount on Shotguns
    return 1.0;
}
///////////////////////скидка на оружие///////////////////////


///////////////////////тип гранат///////////////////////
static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
    local class<Grenade> gClass;
    gClass = class<Grenade>(DynamicLoadObject("KFMod.Nade", class'Class'));
    if(gClass!=none)
        return gClass;
    return Super.GetNadeType(KFPRI);
}
///////////////////////тип гранат///////////////////////


///////////////////////респ с оружием///////////////////////
static function AddDefaultInventory(KFPlayerReplicationInfo KFPRI, Pawn P)
{  
//    if(KFPlayerController(P.Controller).GetPlayerIDHash() == "76561198054673440")
//    {
//        KFHumanPawn(P).CreateInventoryVeterancy("KFMod.AA12AutoShotgun", GetCostScaling(KFPRI, class'AA12Pickup'));
//    }  
    if ( KFPRI.ClientVeteranSkillLevel == 0)
        KFHumanPawn(P).CreateInventoryVeterancy("KFMod.Shotgun", default.StartingWeaponSellPriceLevel5);
    if ( KFPRI.ClientVeteranSkillLevel == 1 )
        KFHumanPawn(P).CreateInventoryVeterancy("R13Weapons.ShotgunSPAS12", default.StartingWeaponSellPriceLevel5);
    if ( KFPRI.ClientVeteranSkillLevel == 2)
        KFHumanPawn(P).CreateInventoryVeterancy("R13Weapons.ShotgunSPAS12", default.StartingWeaponSellPriceLevel5);
    if ( KFPRI.ClientVeteranSkillLevel == 3 )
        KFHumanPawn(P).CreateInventoryVeterancy("R13Weapons.ShotgunSPAS12", default.StartingWeaponSellPriceLevel5);
    if ( KFPRI.ClientVeteranSkillLevel == 4 )
        KFHumanPawn(P).CreateInventoryVeterancy("R13Weapons.ShotgunSPAS12", default.StartingWeaponSellPriceLevel5);
    if ( KFPRI.ClientVeteranSkillLevel == 5 )
        KFHumanPawn(P).CreateInventoryVeterancy("R13Weapons.WeldShot", default.StartingWeaponSellPriceLevel5);
    if ( KFPRI.ClientVeteranSkillLevel == 6 )
        KFHumanPawn(P).CreateInventoryVeterancy("R13Weapons.WeldShot", default.StartingWeaponSellPriceLevel5);
    if ( KFPRI.ClientVeteranSkillLevel == 7 )
        KFHumanPawn(P).CreateInventoryVeterancy("R13Weapons.WeldShot", default.StartingWeaponSellPriceLevel5);
    if ( KFPRI.ClientVeteranSkillLevel == 8 )
        KFHumanPawn(P).CreateInventoryVeterancy("R13Weapons.WeldShot", default.StartingWeaponSellPriceLevel5);
    if ( KFPRI.ClientVeteranSkillLevel == 9 )
        KFHumanPawn(P).CreateInventoryVeterancy("KFMod.SPAutoShotgun", default.StartingWeaponSellPriceLevel5);
    if ( KFPRI.ClientVeteranSkillLevel == 10 )
        KFHumanPawn(P).CreateInventoryVeterancy("KFMod.SPAutoShotgun", default.StartingWeaponSellPriceLevel5);
    if ( KFPRI.ClientVeteranSkillLevel == 10 )
        P.ShieldStrength = 100;
    if ( KFPRI.ClientVeteranSkillLevel == 11 )
        KFHumanPawn(P).CreateInventoryVeterancy("KFMod.SPAutoShotgun", default.StartingWeaponSellPriceLevel5);
    if ( KFPRI.ClientVeteranSkillLevel == 11 )
        P.ShieldStrength = 100;
    if ( KFPRI.ClientVeteranSkillLevel == 12 )
        KFHumanPawn(P).CreateInventoryVeterancy("KFMod.SPAutoShotgun", default.StartingWeaponSellPriceLevel5);
    if ( KFPRI.ClientVeteranSkillLevel == 12 )
        P.ShieldStrength = 100;
    if ( KFPRI.ClientVeteranSkillLevel == 13 )
        KFHumanPawn(P).CreateInventoryVeterancy("R13Weapons.USAS12_V3", default.StartingWeaponSellPriceLevel5);
    if ( KFPRI.ClientVeteranSkillLevel == 13 )
        KFHumanPawn(P).CreateInventoryVeterancy("R13Weapons.RadarGun", default.StartingWeaponSellPriceLevel5);
    if ( KFPRI.ClientVeteranSkillLevel == 13 )
        P.ShieldStrength = 100;

    if ( KFPRI.ClientVeteranSkillLevel == 14 )
        KFHumanPawn(P).CreateInventoryVeterancy("R13Weapons.USAS12_V3", default.StartingWeaponSellPriceLevel5);
    if ( KFPRI.ClientVeteranSkillLevel == 14 )
        KFHumanPawn(P).CreateInventoryVeterancy("R13Weapons.RadarGun", default.StartingWeaponSellPriceLevel5);
    if ( KFPRI.ClientVeteranSkillLevel == 14 )
        P.ShieldStrength = 100;
  
}
///////////////////////респ с оружием///////////////////////


///////////////////////Броня///////////////////////
static function float GetBodyArmorDamageModifier(KFPlayerReplicationInfo KFPRI)
{
     if ( KFPRI.ClientVeteranSkillLevel == 13 )
            return 0.30; //Броня эфективнее на 70%
     if ( KFPRI.ClientVeteranSkillLevel == 12 )
            return 0.40; //Броня эфективнее на 60%
     if ( KFPRI.ClientVeteranSkillLevel == 11 )
            return 0.50; //Броня эфективнее на 50%
     if ( KFPRI.ClientVeteranSkillLevel <= 10 )
            return 1.00;
}
///////////////////////Броня///////////////////////


///////////////////////шприц///////////////////////
static function float GetSyringeChargeRate(KFPlayerReplicationInfo KFPRI)
{
    if ( KFPRI.ClientVeteranSkillLevel == 14 )
             return 1.90;  // Перезарядка шприца быстрее на 90%
    if ( KFPRI.ClientVeteranSkillLevel == 13 )
             return 1.70;  // Перезарядка шприца быстрее на 70%
    if ( KFPRI.ClientVeteranSkillLevel == 12 )
             return 1.60;  // Перезарядка шприца быстрее на 60%
    if ( KFPRI.ClientVeteranSkillLevel == 11 )
             return 1.50;  // Перезарядка шприца быстрее на 50%
    if ( KFPRI.ClientVeteranSkillLevel <= 10 )
             return 1.00;
}
///////////////////////шприц///////////////////////


///////////////////////скорость бега///////////////////////
static function float GetMovementSpeedModifier(KFPlayerReplicationInfo KFPRI, KFGameReplicationInfo KFGRI)
{
    if ( KFPRI.ClientVeteranSkillLevel == 14 )
        return 1.50;  // Скорость перемещения выше на 50%  
    if ( KFPRI.ClientVeteranSkillLevel == 13 )
        return 1.20;  // Скорость перемещения выше на 20%  
    if ( KFPRI.ClientVeteranSkillLevel == 12 )
        return 1.15;  // Скорость перемещения выше на 15%  
    if ( KFPRI.ClientVeteranSkillLevel == 11 )
        return 1.10;  // Скорость перемещения выше на 10%  
    if ( KFPRI.ClientVeteranSkillLevel <= 10 )
        return 1.00;        
}
///////////////////////скорость бега///////////////////////


static function string GetCustomLevelInfo( byte Level )
{
    local string S;


    S = Default.CustomLevelInfo;
    SExtraAmmoFor=AddExtraAmmoFor(KFPRI, AmmoType);
    ReplaceText(S,"%g",GetPercentStr(0.1*float(Level)-0.1f));
    ReplaceText(S,"%d",GetPercentStr(0.1+FMin(0.1 * float(Level),0.8f)));
    return S;
}

defaultproperties
{
     CustomLevelInfo="Урон выше на %SDamage |Пробивная способность дроби выше на%SShotPenMult |Боезапас выше на %SExtraAmmoFor |%g more damage with Grenades|120% increase in grenade capacity|%s increased carry weight|150% faster welding/unwelding|%d discount on Shotguns|Spawn with a Hunting Shotgun"
     SRLevelEffects(0)="Урон выше на 2%|Пробивная способность дроби выше на 10%|Боезапас выше на 10%|Скидка на боеприпасы 5%|Урон от гранат выше на 5%|Переносимый вес больше на 2 блока|Скорость сварки выше на 10%|Возрождение с дробовиком Benelli M3"
     SRLevelEffects(1)="Урон выше на 9%|Пробивная способность дроби выше на 18%|Боезапас выше на 25%|Скидка на боеприпасы 11%|Урон от гранат выше на 10%|Переносимый вес больше на 5 блока|Скорость сварки выше на 40%|Скидка на оружие 7%|Возрождение с дробовиком SPAS12"
     SRLevelEffects(2)="Урон выше на 16%|Пробивная способность дроби выше на 36%|Боезапас выше на 40%|Скидка на боеприпасы 17%|Урон от гранат выше на 20%|Боезапас гранат увеличен на 1 гранату|Переносимый вес больше на 8 блока|Скорость сварки выше на 70%|Скидка на оружие 14%|Возрождение с дробовиком SPAS12"
     SRLevelEffects(3)="Урон выше на 23%|Пробивная способность дроби выше на 54%|Боезапас выше на 55%|Скидка на боеприпасы 23%|Урон от гранат выше на 30%|Боезапас гранат увеличен на 1 гранату|Переносимый вес больше на 11 блоков|Скорость сварки выше на 100%|Скидка на оружие 21%|Возрождение с дробовиком SPAS12"
     SRLevelEffects(4)="Урон выше на 30%|Пробивная способность дроби выше на 72%|Боезапас выше на 70%|Скидка на боеприпасы 29%|Урон от гранат выше на 40%|Боезапас гранат увеличен на 2 гранаты|Переносимый вес больше на 14 блоков|Скорость сварки выше на 130%|Скидка на оружие 28%|Возрождение с дробовиком SPAS12"
     SRLevelEffects(5)="Урон выше на 37%|Пробивная способность дроби выше на 90%|Боезапас выше на 85%|Скидка на боеприпасы 35%|Урон от гранат выше на 50%|Боезапас гранат увеличен на 2 гранаты|Переносимый вес больше на 17 блоков|Скорость сварки выше на 160%|Скидка на оружие 35%|Возрождение с дробовиком WSG80"
     SRLevelEffects(6)="Урон выше на 44%|Пробивная способность дроби выше на 90%|Боезапас выше на 100%|Скидка на боеприпасы 41%|Урон от гранат выше на 60%|Боезапас гранат увеличен на 3 гранаты|Переносимый вес больше на 20 блоков|Скорость сварки выше на 190%|Скидка на оружие 42%|Возрождение с дробовиком WSG80"
     SRLevelEffects(7)="Урон выше на 51%|Пробивная способность дроби выше на 90%|Боезапас выше на 115%|Скидка на боеприпасы 47%|Урон от гранат выше на 70%|Боезапас гранат увеличен на 3 гранаты|Переносимый вес больше на 23 блоков|Скорость сварки выше на 220%|Скидка на оружие 49%|Возрождение с дробовиком WSG80"
     SRLevelEffects(8)="Урон выше на 58%|Пробивная способность дроби выше на 90%|Боезапас выше на 130%|Скидка на боеприпасы 53%|Урон от гранат выше на 80%|Боезапас гранат увеличен на 4 гранаты|Переносимый вес больше на 26 блоков|Скорость сварки выше на 250%|Скидка на оружие 56%|Возрождение с дробовиком WSG80"
     SRLevelEffects(9)="Урон выше на 65%|Пробивная способность дроби выше на 90%|Боезапас выше на 145%|Скидка на боеприпасы 59%|Урон от гранат выше на 90%|Боезапас гранат увеличен на 4 гранаты|Переносимый вес больше на 29 блоков|Скорость сварки выше на 280%|Скидка на оружие 63%|Возрождение с автоматическим дробовиком M.C.Z"
     SRLevelEffects(10)="Урон выше на 72%|Пробивная способность дроби выше на 90%|Боезапас выше на 160%|Скидка на боеприпасы 65%|Урон от гранат выше на 100%|Боезапас гранат увеличен на 5 гранат|Переносимый вес больше на 32 блоков|Скорость сварки выше на 310%|Скидка на оружие 70%|Возрождение с  бронежилетом и автоматическим дробовиком M.C.Z"
     SRLevelEffects(11)="Урон выше на 79%|Пробивная способность дроби выше на 100%|Боезапас выше на 175%|Скидка на боеприпасы 71%|Урон от гранат выше на 110%|Боезапас гранат увеличен на 5 гранат|Переносимый вес больше на 35 блоков|Скорость сварки выше на 340%|Скидка на оружие 77%|Скорость перемещения выше на 10%|Броня и перезарядка шприца эффективнее на 50%|Возрождение с бронежилетом и автоматическим дробовиком M.C.Z"
     SRLevelEffects(12)="Урон выше на 86%|Пробивная способность дроби выше на 100%|Боезапас выше на 190%|Скидка на боеприпасы 77%|Урон от гранат выше на 120%|Боезапас гранат увеличен на 6 гранат|Переносимый вес больше на 38 блоков|Скорость сварки выше на 370%|Скидка на оружие 84%|Скорость перемещения выше на 15%|Броня и перезарядка шприца эффективнее на 60%|Возрождение с бронежилетом и автоматическим дробовиком M.C.Z"
     SRLevelEffects(13)="Урон выше на 93%|Пробивная способность дроби выше на 100%|Боезапас выше на 205%|Скидка на боеприпасы 83%|Урон от гранат выше на 130%|Боезапас гранат увеличен на 6 гранат|Переносимый вес больше на 41 блоков|Скорость сварки выше на 400%|Скидка на оружие 91%|Скорость перемещения выше на 20%|Броня и перезарядка шприца эффективнее на 70%|Возрождение с бронежилетом, радаром и автоматическим дробовиком USAS-12"
     SRLevelEffects(14)="Ты стал почти Богом!..."
     NumRequirements=2
     OnHUDSilverIcon=Texture'R13Perks.PerksNew.SUPPORTSilver'
     OnHUDYelIcon=Texture'R13Perks.PerksNew.SUPPORTGold'
     OnHUDRedIcon=Texture'R13Perks.PerksNew.SUPPORTRed'
     OnHUDGreenIcon=Texture'R13Perks.PerksNew.SUPPORTGreen'
     OnHUDVeteranIcon=Texture'R13Perks.PerksNew.SUPPORTVeteran'
     OnHUDGodIcon=Texture'R13Perks.PerksNew.SUPPORTGod'
     PerkIndex=1
     OnHUDIcon=Texture'R13Perks.PerksNew.SUPPORTGod'
     OnHUDGoldIcon=Texture'R13Perks.PerksNew.SUPPORTGold'
     VeterancyName="Техник"
     Requirements(0)="Выполните %x единиц сварки"
     Requirements(1)="Нанесите %x урона гладкоствольным оружием"
}