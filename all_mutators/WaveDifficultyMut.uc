/*
Простенький мутатор, созданный на основе мутатора (непомню точного исходного).
Написан на "каленке".

Есть возможность выдачи хп и умножения выдачи хп за игрока.
Работает без GT (GameType).
*/
//**************************************//
//*********Create by STaJIKeR***********//
//****************2018******************//
//**************************************//

class DifficultyMut extends Mutator
    config (DifficultyMut);

var() globalconfig int PerPlayerHealt, PerPlayerHeadHealt,PatPerPlayerHealt, PatPerPlayerHeadHealt;
var() globalconfig int MultiHealt, MultiHealtMax, MultiHeadHealt;
var() globalconfig int PatMultiHealt, PatMultiHealtMax, PatMultiHeadHealt;

static function FillPlayInfo(PlayInfo PlayInfo)
{
    Super.FillPlayInfo(PlayInfo);
    PlayInfo.AddSetting(default.GameGroup, "PerPlayerHealt", "PerPlayerHealt", 0, 0, "Text",   "1;0.1:10");
    PlayInfo.AddSetting(default.GameGroup, "PerPlayerHeadHealt", "PerPlayerHeadHealt", 0, 0, "Text",   "1;0.1:10");
    PlayInfo.AddSetting(default.GameGroup, "PatPerPlayerHealt", "PatPerPlayerHealt", 0, 0, "Text",   "1;0.1:10");
    PlayInfo.AddSetting(default.GameGroup, "PatPerPlayerHeadHealt", "PatPerPlayerHeadHealt", 0, 0, "Text",   "1;0.1:10");
    PlayInfo.AddSetting(default.GameGroup, "MultiHealt", "MultiHealt", 0, 0, "Text",   "1;0.1:10");
    PlayInfo.AddSetting(default.GameGroup, "MultiHealtMax", "MultiHealtMax", 0, 0, "Text",   "1;0.1:10");
    PlayInfo.AddSetting(default.GameGroup, "MultiHeadHealt", "MultiHeadHealt", 0, 0, "Text",   "1;0.1:10");
    PlayInfo.AddSetting(default.GameGroup, "PatMultiHealt", "PatMultiHealt", 0, 0, "Text",   "1;0.1:10");
    PlayInfo.AddSetting(default.GameGroup, "PatMultiHealtMax", "PatMultiHealtMax", 0, 0, "Text",   "1;0.1:10");
    PlayInfo.AddSetting(default.GameGroup, "PatMultiHeadHealt", "PatMultiHeadHealt", 0, 0, "Text",   "1;0.1:10");
}

static event string GetDescriptionText(string PropName)
{
    switch (PropName)
    {
        case "PerPlayerHealt":return "PerPlayerHealt";
        case "PerPlayerHeadHealt":return "PerPlayerHeadHealt";
        case "PatPerPlayerHealt":return "PatPerPlayerHealt";
        case "PatPerPlayerHeadHealt":return "PatPerPlayerHeadHealt";
        case "MultiHealt":return "MultiHealt";
        case "MultiHealtMax":return "MultiHealtMax";
        case "MultiHeadHealt":return "MultiHeadHealt";
        case "PatMultiHealt":return "PatMultiHealt";
        case "PatMultiHealtMax":return "PatMultiHealtMax";
        case "PatMultiHeadHealt":return "PatMultiHeadHealt";       
    }
    return Super.GetDescriptionText(PropName);
}
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if (ZombieClot(Other) != None)
    {
        ZombieClot(Other).HealthMax = 130 * MultiHealtMax;
        ZombieClot(Other).Health = 130 * MultiHealt;
        ZombieClot(Other).HeadHealth = 25 * MultiHeadHealt;
    }

    if (ZombieGoreFast(Other) != None)
    {
        ZombieGoreFast(Other).HealthMax = 250 * MultiHealtMax;
        ZombieGoreFast(Other).Health = 250 * MultiHealt;
        ZombieGoreFast(Other).HeadHealth = 25 * MultiHeadHealt;
            ZombieGoreFast(Other).PlayerCountHealthScale=0.150000 * PerPlayerHealt;
    }
   
    if (ZombieCrawler(Other) != None)
    {
        ZombieCrawler(Other).HealthMax = 70 * MultiHealtMax;
        ZombieCrawler(Other).Health = 70 * MultiHealt;
        ZombieCrawler(Other).HeadHealth = 25 * MultiHeadHealt;
    }

    if (ZombieBloat(Other) != None)
    {
        ZombieBloat(Other).HealthMax = 525 * MultiHealtMax;
        ZombieBloat(Other).Health = 525 * MultiHealt;
        ZombieBloat(Other).HeadHealth = 25 * MultiHeadHealt;
            ZombieBloat(Other).PlayerCountHealthScale=0.250000 * PerPlayerHealt;
    }

    if (ZombieSiren(Other) != None)
    {
        ZombieSiren(Other).HealthMax = 300 * MultiHealtMax;
        ZombieSiren(Other).Health = 300 * MultiHealt;
        ZombieSiren(Other).HeadHealth = 200 * MultiHeadHealt;
             ZombieSiren(Other).PlayerCountHealthScale=0.10000 * PerPlayerHealt;
            ZombieSiren(Other).PlayerNumHeadHealthScale=0.050000 * PerPlayerHeadHealt;
    }
   
    if (ZombieStalker(Other) != None)
    {
        ZombieStalker(Other).HealthMax = 100 * MultiHealtMax;
        ZombieStalker(Other).Health = 100 * MultiHealt;
        ZombieStalker(Other).HeadHealth = 25 * MultiHeadHealt;
    }

    if (ZombieHusk(Other) != None)
    {
        ZombieHusk(Other).HealthMax = 600 * MultiHealtMax;
        ZombieHusk(Other).Health = 600 * MultiHealt;
        ZombieHusk(Other).HeadHealth = 200 * MultiHeadHealt;
             ZombieHusk(Other).PlayerCountHealthScale=0.100000 * PerPlayerHealt;
            ZombieHusk(Other).PlayerNumHeadHealthScale=0.050000 * PerPlayerHeadHealt;
    }

    if (ZombieScrake(Other) != None)
    {
        ZombieScrake(Other).HealthMax = 1800 * MultiHealtMax;
        ZombieScrake(Other).Health = 1800 * MultiHealt;
        ZombieScrake(Other).HeadHealth = 1500 * MultiHeadHealt;
             ZombieScrake(Other).PlayerCountHealthScale=0.500000 * PerPlayerHealt;
        ZombieScrake(Other).PlayerNumHeadHealthScale=0.250000 * PerPlayerHeadHealt;
    }

    if (ZombieFleshPound(Other) != None)
    {
        ZombieFleshPound(Other).HealthMax = 2500 * MultiHealtMax;
        ZombieFleshPound(Other).Health = 2500 * MultiHealt;
        ZombieFleshPound(Other).HeadHealth = 2000 * MultiHeadHealt;
             ZombieFleshPound(Other).PlayerCountHealthScale=0.250000 * PerPlayerHealt;
        ZombieFleshPound(Other).PlayerNumHeadHealthScale=0.250000 * PerPlayerHeadHealt;
    }

    if (ZombieBoss(Other) != None)
    {
        ZombieBoss(Other).HealthMax = 60000 * PatMultiHealtMax;
        ZombieBoss(Other).Health = 60000 * PatMultiHealt;
        ZombieBoss(Other).HeadHealth = 25000 * PatMultiHeadHealt;
             ZombieBoss(Other).PlayerCountHealthScale=0.40 * PatPerPlayerHealt;
        ZombieBoss(Other).PlayerNumHeadHealthScale=0.40 * PatPerPlayerHeadHealt;
    }
   
    return Super.CheckReplacement(Other, bSuperRelevant);
}

defaultproperties
{
    MultiHealt=2
    MultiHealtMax=2
    MultiHeadHealt=2
    PerPlayerHealt=2
    PerPlayerHeadHealt=2
    PatMultiHealt=1
    PatMultiHealtMax=1
    PatMultiHeadHealt=1
    PatPerPlayerHealt=1
    PatPerPlayerHeadHealt=1
     bAddToServerPackages=True
     GroupName="DifficultyMut"
     FriendlyName="Difficulty Harder Specimens"
     Description="If you think suicidal isn't hard enough that's what you need!!"
     bAlwaysRelevant=True
}