// Класс, который будет выполняться на сервере и клиенте
// В Auto State RepList (состояние по умолчанию для данного объекта - его код начинает выполняться при создании объекта)
// Выполняются действия на сервере и заполняется массив на клиенте. Все остальные функции выполняются на клиенте
Class ChatBotItem extends Info
    Config(ChatBotConfig);

var array<string> InfoLine; // Массив сообщений
var config float MsgDelay; // Задержка между сообщениями, в секундах
var const float InitTime; // Время, через которое сообщения начнут передаваться на клиент
var string RussianText; // Строка для проверки локализации
var ChatBotMut Mut; // Ссылка на мут
var bool bUseRus; // Использовать ли русский язык
var int NumLines; // Количество сообщений
var int CurPos; // Текущая позиция
var int Index; // Итератор

replication
{
    // Добавляем репликацию функций с сервера на клиент
    reliable if (Role == ROLE_Authority)
        ReplicateLine, CheckLanguage, ClientFinishSetup;
    // Настройка находится на сервере, а используется на клиенте
    reliable if (Role == ROLE_Authority)
        MsgDelay;
    // Добавляем репликацию функции с клиента на сервер
    reliable if(Role < ROLE_Authority)
        ReplicateTranslation;
}

// С помощью этой функции мы передаём сообщение с сервера на клиент
// Это просто механизм заполнить массив на клиенте, так как мы не можем реплицировать динамический массив
simulated function ReplicateLine(string S)
{
    InfoLine[InfoLine.Length]=S;
    NumLines++;
}

// Выполняется на сервере, на клиенте PlayerController(Owner)==None
// Поочерёдно реплицируем значения массива строк, взятых из ini
Auto State RepList
{
Begin:
    Sleep(1.0);
    CheckLanguage();
    Sleep(InitTime);
    if(PlayerController(Owner)!=None)
    {
        if(bUseRus)
        {
            for(Index=0;Index<Mut.InfoLineRus.Length;Index++)
            {
                ReplicateLine(Mut.InfoLineRus[Index]);
                Sleep(0.1);
            }
        }
        else
        {
            for(Index=0;Index<Mut.InfoLineEng.Length;Index++)
            {
                ReplicateLine(Mut.InfoLineEng[Index]);
                Sleep(0.1);
            }
        }
    }
    ClientFinishSetup();
    GoToState(InitialState);
}

// Проверяем, использовать ли нам русский язык или нет
simulated function CheckLanguage()
{
    if(Localize("Errors","Unknown","Core")~=RussianText)
    {
        bUseRus=True;
        ReplicateTranslation(bUseRus);
    }
}

// Просто реплицировать переменную с клиента на сервер не удалось
// Поэтому делаем это с помощью функции
function ReplicateTranslation(bool bNewUseRus)
{
    bUseRus=bNewUseRus;
}

// Сообщения реплицированны на клиент, начинаем спамить
simulated function ClientFinishSetup()
{
    SetTimer(MsgDelay, True);
}

// Посылаем клиенту сообщения
simulated function Timer()
{
    local PlayerController PC;
    if(CurPos>=NumLines) CurPos=0;
    PC=Level.GetLocalPlayerController();
    if(PC!=None) PC.ClientMessage(InfoLine[CurPos], 'Chat Bot');
    CurPos++;
}

defaultproperties
{
    InitTime=60.0 // 1-ой минуты должно хватить, как бы ни был загружен сервер
    MsgDelay=120.0
    RussianText="Неизвестная ошибка"
    bOnlyRelevantToOwner=True
    RemoteRole=ROLE_SimulatedProxy
}