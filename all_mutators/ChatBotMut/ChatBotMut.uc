class ChatBotMut extends Mutator
    Config(ChatBotConfig);

var array<PlayerController> PendingPlayers; // Массив игроков
var config array<string> InfoLineRus; // Информация для российского контингента
var config array<string> InfoLineEng; // Информация для западного контингента

// Отлавливаем появление игрока на сервере
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if(PlayerController(Other)!=None)
    {
        PendingPlayers[PendingPlayers.Length]=PlayerController(Other);
        SetTimer(0.1, False);
    }
    Return True;
}

// Выдаём ему айтем, который будет спамить сообщения
function Timer()
{
    local PlayerController PC;
    local int i;
    for(i=PendingPlayers.Length-1; i>=0; i--)
    {
        PC=PendingPlayers[i];
        if(PC!=None && PC.PlayerReplicationInfo.PlayerID>0)
            Spawn(Class'ChatBotItem',PC).Mut=Self;
    }
    PendingPlayers.Length=0;
}

defaultproperties
{
    bAddToServerPackages=True
    GroupName="KF-ChatBotMut"
    FriendlyName="Chat Bot"
    Description="Chat Bot gives you the ability to display news (or what ever kind of messages you want) on your server. Players will see these messages in their chat console. It's also possible to display so called "Admin messages"."
}