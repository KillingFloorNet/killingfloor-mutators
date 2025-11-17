/*
Я по прежнему являюсь противником всяких випов, но задрали одно и тож спрашивать
Поэтому буду как и раньше рассматривать Vip доступ как подарок игроку на день рождения)

Итак, суть мутатора в следующем:
Игроку из Vip списка вручается некий предмет VipItem в момент появления его тушки (KFHumanPawn) в игре

Сам по себе мутатор ничего полезного не делает - он просто добавляет предмет в инвентарь.
Проверка наличия этого предмета впоследствии используется в другом коде.
Поэтому в конце поста будет обновляемый список ссылок на практическое применение этого мутатора

Мутатор самый простейший, никаких усложнений мутатора или Vip элемента я намеренно не делал

Алгоритм:
1. Игрок заходит в игру, у него создаётся тело KFHumanPawn - это отлавливается в CheckReplacement
2. Если тело есть в вип списке - создаётся объект VipItem и кладётся в Inventory игрока
*/

class VipItem extends Inventory;

defaultproperties
{
    bOnlyRelevantToOwner=False
    bAlwaysRelevant=True
    bReplicateInstigator=True
}

// ====================================================


class VipItemMut extends Mutator config(VipItemMut);

//Поле PlayerName никак в коде не используется. Добавил его для удобства пользования - чтобы не вспоминать что за игрок по его ID
struct VipPlayersStruct
{
    var config string ID;
    var config string PlayerName;
};
var config array<VipPlayersStruct> VipPlayers;

var array<KFHumanPawn> PendingPlayers;

//SaveConfig тут для удобства - чтобы не создавать руками ini файл
function PostBeginPlay()
{
    SaveConfig();
}

//Отлавливаем появление тела игрока
function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if (Other.IsA('KFHumanPawn'))
    {
        PendingPlayers[PendingPlayers.Length] = KFHumanPawn(Other);
        SetTimer(0.1,false);
    }
    return Super.CheckReplacement(Other, bSuperRelevant);
}

//В таймере основной код. Если игрок в вип списке - даём ему экземпляр VipItem
function Timer()
{
    local VipItem vItem;
    local int i;
    for(i=(PendingPlayers.Length-1);i>=0;--i)
    {
        if(PlayerInVipList(PendingPlayers[i]))
        {
            vItem = spawn(class'VipItem');
            vItem.GiveTo(PendingPlayers[i]);
        }
    }
    PendingPlayers.Length = 0;
}

//Принадлежность Vip списку
function bool PlayerInVipList(KFHumanPawn KFHP)
{
    local int i;
    if(KFHP==none || PlayerController(KFHP.Controller)==none)
        return false;
    for(i=0;i<VipPlayers.Length;i++)
    {
        if(VipPlayers[i].ID~=PlayerController(KFHP.Controller).GetPlayerIDHash())
            return true;
    }
    return false;
}

defaultproperties
{
    bAddToServerPackages=True
    VipPlayers(0)=(PlayerName="Flame",ID="76561198051378449")
    GroupName="VipItemMut"
    FriendlyName="VipItemMut"
    Description="Gives Vip Item to player"
}