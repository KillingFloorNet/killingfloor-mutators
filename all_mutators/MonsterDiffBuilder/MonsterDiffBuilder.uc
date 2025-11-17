//====== Author: Dr. Killjoy (Steklo)
/*
Представляю вашему вниманию мутатор, который настраивает параметры монстров, появляющихся на сервере. Знаю, многие недовольны той настройкой хп мобов, и остальных параметров, которые имеют монстры по умолчанию. Этот мутатор позволит настроить хп монстров, а так же его рост в зависимости от количества игроков, скорость, урон и другие параметры. Так же, вы можете самостоятельно настроить модификаторы хп, урона, скорости для каждой сложности, создав тем самым свою сложность. Таких функций не было в том же HarderMutator, а теперь вы можете поставить на свой сервер голосование за сложность, и настроить каждую сложность под себя.

Автор: Dr. Killjoy (Steklo)

Код для загрузки мутатора в .bat-файле или MutLoader:

MonsterDiffBuilder.MonsterDiffBuilder
Конфиг:

[MonsterDiffBuilder.MonsterDiffBuilder]
UpdateMaxHealthFrequency=1.00

Время, через которое выставляется правильное значение максимального хп монстров на клиентах. Лучше этот параметр не трогать.

Теперь на примере скрейка рассмотрим какие параметры можно настроить у конкретного моба.

[ScrakeSettings MonsterSettings]
Первое слово это название настройки. Само название не играет роль, но оно не должно повторяться, и начинаться с цифры.
MonsterClass="KFChar.ZombieScrake_STANDARD"
Класс монстра, для которого работает данная настройка.
bMonsterClassIsChild=false
Применять ли настройку к монстрам, чей класс наследует класс данного монстра.
Health=1000
Здоровье тела.
PerPlayerHealth=(Health=500,MinPlayers=2,MaxPlayers=8)
PerPlayerHealth=(Health=250,MinPlayers=9,MaxPlayers=16)
Количество хп, выдаваемое за каждого следующего игрока. Соотвественно MinPlayers и MaxPlayers это границы, в рамках которых будет даваться хп. Как видите PerPlayerHealth это массив, в данном примере он делает так что начиная с 2 игроков до 8, за каждого игрока добавляется скрейку 500 хп, а начиная с 9 до 16, - добавляется только 250. После 16 игроков хп скрейка уже не растёт. Если не хотите заморачиваться, оставьте одну строчку с PerPlayerHealth и поставьте увеличение с 2 до 100 игроков.
HeadHealth=650
Здоровье головы.
PerPlayerHeadHealth=(Health=195,MinPlayers=2,MaxPlayers=8)
PerPlayerHeadHealth=(Health=98,MinPlayers=9,MaxPlayers=16)
То же самое что и PerPlayerHealth, только работает для здоровья головы.
Speed=85.00
Скорость движения монстра.
Damage=20
Урон в ближнем бою монстра.
ScreamDamage=0
Урон криком (используется для таких мобов как сирена, баньши).
Mass=500.0
Масса. Влияет на отображение моба в KillMessage, а так же на то как он будет отлетать от различного физического воздействия. Именно изза маленькой массы сирены так летают от взрывчатки.
BombDanger=3.00
Уровень реакции мин на этого моба. Если он равен 1 или больше, мина взрывается.
ZapThreshold=1.25
Насколько быстро монстр поддаётся влиянию Zedgun'ов.
ZappedDamageMod=1.25
Дополнительный урон, который получает монстр будучи обработанным Zedgun'ом.
ScoringValue=75
Деньги, выдаваемые за монстра.
DifficultyUsed=(Min=0.00,Max=100.00)
Минимальное и максимальное значение сложности, при котором данная настройка сработает. Если мы просто настраиваем параметры конкретного моба, то желательно чтобы диапазон охватывал все возможные сложности. В KF обычно используются сложности от 1 до 7, но при настройках моба я на всякий случай поставил 100, вдруг кому ударит в голову поставить сложность больше 7. Вы всё ещё задаётесь вопросом, а зачем тогда вообще этот параметр в конфиге? Ниже я приведу пример другой настройки, которая позволит настроить параметры моба при определённой сложности.

[SuicidalSettings MonsterSettings]
MonsterClass="KFMod.KFMonster"
bMonsterClassIsChild=true
KFMonster - базовый класс всех монстров в KF. Если мы поставим переменную bMonsterClassIsChild=true, то настройка заработает на всех монстров, наследующих данный класс, в нашем случае это все монстры в KF.
HealthMod=1.55
На это число умножается хп тела монстра
HeadHealthMod=1.55
На это число умножается хп головы монстра
SpeedMod=1.22
На это число умножается скорость движения монстра
DamageMod=1.50
На это число умножается урон монстра в ближнем бою
ScreamDamageMod=1.50
На это число умножается урон монстра от крика
DifficultyUsed=(Min=5.00,Max=6.999)
Здесь мы задали сложность, на какой настройка будет работать. Получается начиная с 5 и до 6.999. Если вместо 6.999 поставить 7, то настройки сложности ад на земле перемножатся с настройками суицида, и монстры сделают вам очень больно.

Важно: для каждого используемого на вашем сервере моба должна быть прописана настройка в этом мутаторе. Если вы хотите чтобы у монстра росло хп в зависимости от количества человек, задайте это в его настройке, само по себе оно расти не будет.
*/

class MonsterDiffBuilder extends Mutator
    config(MonsterDiffBuilder);
    
var    config    float    UpdateMaxHealthFrequency;
var            float    UpdateMaxHealthTime;
    
var    array<KFMonster>    PendingMonsters;

var    array<MonsterSettings>    MonsterRules;
    
function PostBeginPlay()
{
    local int i,n;
    //local MDBGameRules GR;
    local class<KFMonster> KFMClass;
    local array<string> Names;
    
    Super.PostBeginPlay();
    /*GR = spawn(class'MDBGameRules');
    GR.MutatorOwner = Self;
    if ( Level.Game.GameRulesModifiers == None ) Level.Game.GameRulesModifiers = GR;
    else Level.Game.GameRulesModifiers.AddGameRules(GR);*/
    // Изза того что резист, вводимый с помощью GameRules, работает только на урон не в голову, я решил отказаться от настройки резиста в этом мутаторе
    Names = class'MonsterSettings'.Static.GetPerObjectNames("MonsterDiffBuilder");
    n = Names.Length;
    for(i=0; i<n; i++)
    {
        MonsterRules[i] = new (None,Names[i]) class'MonsterSettings';
    }
    n = MonsterRules.Length;
    for(i=0; i<n; i++)
    {
        KFMClass = class<KFMonster>(DynamicLoadObject(MonsterRules[i].MonsterClass,class'class'));
        if ( KFMClass != none )
            MonsterRules[i].LoadedMonsterClass = KFMClass;
    }
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if ( KFMonster(Other) != none )
    {
        PendingMonsters.Insert(0,1);
        PendingMonsters[0] = KFMonster(Other);
        SetTimer(0.1,false);
    }
    return Super.CheckReplacement(Other,bSuperRelevant);
}

simulated function Timer()
{
    local int i,n;
    
    n = PendingMonsters.Length;
    for(i=0; i<n; i++)
    {
        if ( PendingMonsters[i] != none && PendingMonsters[i].Health > 0 && !PendingMonsters[i].bDeleteMe )
            InitMonster(PendingMonsters[i]);
    }
    PendingMonsters.Remove(0,n);
}

function InitMonster(KFMonster KFM)
{
    local int i,n,j,m,NumPlayers,AddPlayers;
    local float CurrentDiff;
    local float Speed,AddHealth,AddHeadHealth,HealthMod,HeadHealthMod,SpeedMod,DamageMod,ScreamDamageMod;
    local bool bLoadedHealth;
    
    //log("InitMonster entry. KFM = " $ KFM $ ", KFM.Class = " $ KFM.Class);
    CurrentDiff = Level.Game.GameDifficulty;
    //log("CurrentDiff = " $ CurrentDiff);
    NumPlayers = GetNumPlayers();
    //log("NumPlayers = " $ NumPlayers);
    HealthMod = 1.00;
    HeadHealthMod = 1.00;
    SpeedMod = 1.00;
    DamageMod = 1.00;
    ScreamDamageMod = 1.00;
    n = MonsterRules.Length;
    //log("for i = 0 to n = " $ n);
    for(i=0; i<n; i++)
    {
        //log("i = " $ i);
        //log("MonsterRules[" $ i $ "].Name = " $ MonsterRules[i].Name);
        //log("LoadedMonsterClass = " $ MonsterRules[i].LoadedMonsterClass);
        //log("MonsterRules[i].bMonsterClassIsChild = " $ MonsterRules[i].bMonsterClassIsChild);
        //log("KFM.Class != MonsterRules[i].LoadedMonsterClass = " $ string(KFM.Class != MonsterRules[i].LoadedMonsterClass));
        //log("!ClassIsChildOf(KFM.Class,MonsterRules[i].LoadedMonsterClass) = " $ string(!ClassIsChildOf(KFM.Class,MonsterRules[i].LoadedMonsterClass)));
        //if ( MonsterRules[i].DifficultyUsed.Min > 0 )
            //log("MinDiff = " $ MonsterRules[i].DifficultyUsed.Min);
        //if ( MonsterRules[i].DifficultyUsed.Max > 0 )
            //log("MaxDiff = " $ MonsterRules[i].DifficultyUsed.Max);
        //log("CurrentDiff < MonsterRules[i].DifficultyUsed.Min = " $ string(CurrentDiff < MonsterRules[i].DifficultyUsed.Min));
        //log("CurrentDiff > MonsterRules[i].DifficultyUsed.Max = " $ string(CurrentDiff > MonsterRules[i].DifficultyUsed.Max));
        if ( KFM.Class != MonsterRules[i].LoadedMonsterClass && !MonsterRules[i].bMonsterClassIsChild
            || !ClassIsChildOf(KFM.Class,MonsterRules[i].LoadedMonsterClass) && MonsterRules[i].bMonsterClassIsChild
            || CurrentDiff < MonsterRules[i].DifficultyUsed.Min || CurrentDiff > MonsterRules[i].DifficultyUsed.Max )
        continue;
        //log("KFM.Health = " $ KFM.Health);
        //log("KFM.HeadHealth = " $ KFM.HeadHealth);
        if ( !bLoadedHealth )
        {
            //log("Loaded Health");
            bLoadedHealth = true;
            KFM.Health = KFM.default.Health;
            KFM.HealthMax = KFM.default.HealthMax;
            KFM.HeadHealth = KFM.default.HeadHealth;
        }
        //log("KFM.Health = " $ KFM.Health);
        //log("KFM.HeadHealth = " $ KFM.HeadHealth);
        if ( MonsterRules[i].Health > 0 )
            KFM.Health = MonsterRules[i].Health;
        if ( MonsterRules[i].HeadHealth > 0 )
            KFM.HeadHealth = MonsterRules[i].HeadHealth;
        if ( MonsterRules[i].StunDamage > 0 )
            KFM.default.Health = MonsterRules[i].StunDamage * 1.5;
        if ( MonsterRules[i].Speed > 0 )
            Speed = MonsterRules[i].Speed;
        if ( MonsterRules[i].Damage > 0 )
            KFM.MeleeDamage = MonsterRules[i].Damage;
        if ( MonsterRules[i].ScreamDamage > 0 )
            KFM.ScreamDamage = MonsterRules[i].ScreamDamage;
        if ( MonsterRules[i].HealthMod > 0 )
            HealthMod *= MonsterRules[i].HealthMod;
        if ( MonsterRules[i].HeadHealthMod > 0 )
            HeadHealthMod *= MonsterRules[i].HeadHealthMod;
        if ( MonsterRules[i].SpeedMod > 0 )
            SpeedMod *= MonsterRules[i].SpeedMod;
        if ( MonsterRules[i].DamageMod > 0 )
            DamageMod *= MonsterRules[i].DamageMod;
        if ( MonsterRules[i].ScreamDamageMod > 0 )
            ScreamDamageMod *= MonsterRules[i].ScreamDamageMod;
        if ( MonsterRules[i].Mass > 0 )
            KFM.Mass = MonsterRules[i].Mass;
        if ( MonsterRules[i].ZapThreshold > 0 )
            KFM.ZapThreshold = MonsterRules[i].ZapThreshold;
        if ( MonsterRules[i].ZappedDamageMod > 0 )
            KFM.ZappedDamageMod = MonsterRules[i].ZappedDamageMod;
        if ( MonsterRules[i].BombDanger > 0 )
            KFM.MotionDetectorThreat = MonsterRules[i].BombDanger;
        if ( MonsterRules[i].ScoringValue > 0 )
            KFM.ScoringValue = MonsterRules[i].ScoringValue;
        m = MonsterRules[i].PerPlayerHealth.Length;
        for(j=0; j<m; j++)
        {
            if ( NumPlayers >= MonsterRules[i].PerPlayerHealth[j].MinPlayers )
            {
                AddPlayers = Min(NumPlayers-MonsterRules[i].PerPlayerHealth[j].MinPlayers+1,MonsterRules[i].PerPlayerHealth[j].MaxPlayers-MonsterRules[i].PerPlayerHealth[j].MinPlayers+1);
                AddHealth += MonsterRules[i].PerPlayerHealth[j].Health * AddPlayers;
            }
        }
        m = MonsterRules[i].PerPlayerHeadHealth.Length;
        for(j=0; j<m; j++)
        {
            if ( NumPlayers >= MonsterRules[i].PerPlayerHeadHealth[j].MinPlayers )
            {
                AddPlayers = Min(NumPlayers-MonsterRules[i].PerPlayerHeadHealth[j].MinPlayers+1,MonsterRules[i].PerPlayerHeadHealth[j].MaxPlayers-MonsterRules[i].PerPlayerHeadHealth[j].MinPlayers+1);
                AddHeadHealth += MonsterRules[i].PerPlayerHeadHealth[j].Health * AddPlayers;
            }
        }
        //log("HealthMod = " $ HealthMod);
        //log("HeadHealthMod = " $ HeadHealthMod);
    }
    //log("End interation");
    KFM.Health += AddHealth;
    KFM.HeadHealth += AddHeadHealth;
    KFM.Health = float(KFM.Health) * HealthMod;
    KFM.HeadHealth = KFM.HeadHealth * HeadHealthMod;
    KFM.MeleeDamage = float(KFM.MeleeDamage) * DamageMod;
    KFM.ScreamDamage = float(KFM.ScreamDamage) * ScreamDamageMod;
    Speed *= SpeedMod;
    KFM.OriginalGroundSpeed = Speed;
    KFM.GroundSpeed = Speed;
    KFM.WaterSpeed = Speed;
    KFM.AirSpeed = Speed;
    KFM.HealthMax = KFM.Health;
    //log("KFM.Health = " $ KFM.Health);
    //log("KFM.HeadHealth = " $ KFM.HeadHealth);
}

function int ModifyMonsterDamage(int Damage, KFMonster Injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{/*
    local int i,n,j,m;
    local float Modifer;
    local float CurrentDiff;
    local class<DamageType> ModDamageType;
    
    Modifer = 1.00;
    CurrentDiff = Level.Game.GameDifficulty;
    n = MonsterRules.Length;
    for(i=0; i<n; i++)
    {
        if ( Injured.Class != MonsterRules[i].LoadedMonsterClass && !MonsterRules[i].bMonsterClassIsChild
            || !ClassIsChildOf(Injured.Class,MonsterRules[i].LoadedMonsterClass) && MonsterRules[i].bMonsterClassIsChild
            || CurrentDiff < MonsterRules[i].DifficultyUsed.Min || CurrentDiff > MonsterRules[i].DifficultyUsed.Max )
        continue;
        m = MonsterRules[i].DamageModifer.Length;
        for(j=0; j<m; j++)
        {
            ModDamageType = class<DamageType>(DynamicLoadObject(MonsterRules[i].DamageModifer[j].DamageType,class'class'));
            if ( ModDamageType != DamageType && !MonsterRules[i].DamageModifer[j].bIsChild
                || !ClassIsChildOf(ModDamageType,DamageType) && MonsterRules[i].DamageModifer[j].bIsChild
                || CurrentDiff < MonsterRules[i].DamageModifer[j].DifficultyUsed.Min || CurrentDiff > MonsterRules[i].DamageModifer[j].DifficultyUsed.Max )
            continue;
            Modifer = MonsterRules[i].DamageModifer[j].Modifer;
        }
    }
    Damage = float(Damage) * Modifer;*/
    return Damage;
}

function int GetNumPlayers()
{
    local int Ret;
    local Controller C;
    
    For( C=Level.ControllerList; C!=None; C=C.NextController )
    {
        if( C.bIsPlayer && C.Pawn!=None && C.Pawn.Health > 0 && KFHumanPawn(C.Pawn) != none )
        {
            Ret++;
        }
    }
    return Ret;
}

simulated function Tick(float DT)
{
    local KFMonster KFM;
    
    Super.Tick(DT);
    if ( Level.NetMode == NM_DedicatedServer )
        return;
    if ( UpdateMaxHealthTime < Level.TimeSeconds )
    {
        UpdateMaxHealthTime = Level.TimeSeconds + UpdateMaxHealthFrequency;
        foreach DynamicActors(class'KFMonster',KFM)
        {
            if ( KFM.Health > KFM.HealthMax )
                KFM.HealthMax = KFM.Health;
        }
    }
}

defaultproperties
{
    UpdateMaxHealthFrequency=1.00
    
    bAddToServerPackages=true
    bAlwaysRelevant=true
    RemoteRole=ROLE_SimulatedProxy
    GroupName="KF-MonsterDiffBuilder"
    FriendlyName="MonsterDiffBuilder"
    Description="Set difficulty of monsters using different settings."
}