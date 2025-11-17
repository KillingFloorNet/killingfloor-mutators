/*
Мутатор автоматически стартует игру (не дожидаясь пока все нажмут "готов") через определённый интервал времени.
Если хоть один игрок нажал кнопку и готов играть - начинается обратный отсчёт
Настройки:
TimeToWait - Время в секундах. Хоть один игрок нажал, что он готов и прошло TimeToWait секунд - игра начинается
*/
class ForceGameStartMut extends Mutator config(ForceGameStartMut);

var config int TimeToWait;

var float StartWaiting;
var bool bStartCountDown;

function PostBeginPlay()
{
    SetTimer(1.0,true);
    SaveConfig();
}

function Timer()
{
    local bool bWeHaveReadyPlayers;

    //Если игра началась - отключаем таймер
    if(!Level.Game.bWaitingToStartMatch)
        SetTimer(0.0,false);

    //Получим количество готовых к игре игроков
    bWeHaveReadyPlayers=WeHaveReadyPlayers();
    if(!bWeHaveReadyPlayers)
        return;

    //Хотя бы один игрок готов играть? Запускаем обратный отсчёт
    if(bWeHaveReadyPlayers && !bStartCountDown)
    {
        bStartCountDown=true;
        StartWaiting=Level.TimeSeconds;
        return;
    }

    if(Level.TimeSeconds-StartWaiting>=TimeToWait)
        Level.Game.StartMatch();
}

function bool WeHaveReadyPlayers()
{
    local Controller C;
    for(C=Level.ControllerList;C!=None;C=C.nextController)
    {
        if    (
                C.IsA('PlayerController')
                &&    C.PlayerReplicationInfo.PlayerID>0
                &&    C.PlayerReplicationInfo.bReadyToPlay
            )
        {
            return true;
        }
    }
    return false;
}

defaultproperties
{
    TimeToWait=180
    GroupName="ForceGameStartMut"
    FriendlyName="ForceGameStartMut"
    Description="Forces game start if some players are still not ready for a time period"
}