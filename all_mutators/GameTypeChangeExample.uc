/*
В SetupWave вначале инициализируется локальная временная переменная NewMaxMonsters

А именно
Берётся массив Waves из KillingFloor.ini (из секции [KFMod.KFGameType], либо если есть секция для своего геймтайпа - оттуда)
Для текущей волны выбирается соответсвующий элемент массива - это структура
У этой структуры смотрится свойство WaveMaxMonsters

Далее это число умножается на модификатор сложности и на модификатор количества игроков
NewMaxMonsters = NewMaxMonsters * DifficultyMod * NumPlayersMod;

Далее инициализируется глобальная переменная из KFGameType - TotalMaxMonsters
TotalMaxMonsters - это максимально возможное в течении волны количество монстров (не одновременно, а вообще)
Получается оно так:
TotalMaxMonsters = Clamp(NewMaxMonsters,5,800); //у тебя 1100 вместо 800 прописано
Функция Clamp(x,n,m) возвращает число x, если оно принадлежит отрезку [n,m], если x<n - возвращается n,
если x>m возвращается m
То есть TotalMaxMonsters это число в пределах от 5 до 800 (у тебя до 1100)

Далее идёт инициализация переменной MaxMonsters - числа одновременно доступных зомби
MaxMonsters = Clamp(TotalMaxMonsters,5,MaxZombiesOnce);
Опять же это число, которое лежит в пределах от 5 до MaxZombiesOnce, а так как TotalMaxMonsters у тебя
почти наверняка больше MaxZombiesOnce, то и по сути MaxMonsters=MaxZombiesOnce
MaxZombiesOnce - задаётся в KillingFloor.ini в секции [KFMod.KFGameType]
Далее важно:
И задаётся именно в этой секции. Попытки поменять эту переменную в условной секции [ServerPerks.SRGameType] ни к чему не приведут
Переменная определена как globalconfig и значит её можно править только в секции того класса в котором она определена

Поэтому количество одновременно доступных зомби задаётся с помощью MaxZombiesOnce, если надо прописать
общее число зомби на волне, то надо править TotalMaxMonsters = Clamp(NewMaxMonsters,5,800);

Насчёт задержек между спавнами зомби
Поглядим на стейт MatchInProgress
Функцию Timer

Код после
else if(bWaveInProgress)
{
Так. Ладно. Этот пункт вечером распишу - сейчас не успею) Заодно может в качестве статьи это всё оформлю.
Сам пока погляди)

upd. А. Ты хочешь изменить код так, чтобы настройки не зависили от того, что в инишнике? )
Ну всё нужное я опять же написал - думай
Заодно поясни что ты под этим имел в виду)
*/

Class YourMutator extends Mutator
    Config(YourMutator);

var() globalconfig int        KFGameLength;
var() globalconfig float    WaveStartSpawnPeriod;
var() globalconfig int        StartingCash,MinRespawnCash;
var() globalconfig bool        bUseEndGameBoss,bRespawnOnBoss;
var() globalconfig int        TimeBetweenWaves;
var() globalconfig int        InitialWave;
var() globalconfig int        FinalWave;

var() globalconfig array<Invasion.WaveInfo>            Waves[16];
var() globalconfig array<string>                    MonsterSquad;
var() globalconfig array<KFGameType.MClassTypes>    MonsterClasses;

function PostBeginPlay()
{
    SetTimer(0.1,False);
}

function Timer()
{
    local KFGameType KF;
    local int i;

    KF = KFGameType(Level.Game);
    if ( KF!=None )
    {
        KF.KFGameLength                        = KFGameLength;
        KF.bCustomGameLength                = true;
        KF.UpdateGameLength();

        KF.WaveStartSpawnPeriod                = WaveStartSpawnPeriod;
        KF.StartingCash                        = StartingCash;
        KF.MinRespawnCash                    = MinRespawnCash;
        KF.bUseEndGameBoss                    = bUseEndGameBoss;
        KF.bRespawnOnBoss                    = bRespawnOnBoss;
        KF.TimeBetweenWaves                    = TimeBetweenWaves;

        KF.InitialWave                        = InitialWave;
        KF.WaveNum                            = InitialWave;
        KF.FinalWave                        = FinalWave;
        KFGameReplicationInfo(Level.Game.GameReplicationInfo).FinalWave = FinalWave;

        for( i=0; i<FinalWave; i++ )
        {
            KF.Waves[i] = Waves[i];
        }

        KF.MonsterClasses.Length = 0;
        KF.MonsterClasses = MonsterClasses;

        KF.MonsterSquad.Length = 0;
        KF.MonsterSquad = MonsterSquad;
        KF.LoadUpMonsterList();
    }

    Destroy();
}