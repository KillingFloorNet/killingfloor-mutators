Не совсем про этот мутатор речь (просьба перенести в нужную тему, если она есть)
Даже совсем не про этот )
Но что-то я не нашёл на форуме темки про тот, что нужно
Только на основной страничке - мутатор "Сообщения при убийстве со звуками"
Попросили меня его поправить - я поправил
Так что пусть тут будет

1. SRHUDKillingFloor при компиляции использовался из пакета GrozaPerk, поправил на пакет ServerPerks
2. Добавил "хак" (tmpSound), чтобы при добавлении мутатора не надо было добавлять его в ServerPackages
Ссылка 1 или Ссылка 2

В архиве сам мутатор, поправленный SRHUDKillingFloor.uc и уже окомпилированный вариант ServerPerks
В общем инструкция для ленивых: поставить мутатор, заменить ServerPerks.u, для остальных мутатор + авторская инструкция как править класс SRHUDKillingFloor
Перескажу её своими словами:
Спойлер
Отредактировать PostBeginPlay():
Добавить вызов таймера:
SetTimer(1,true);
Для SP 6.01 эта функция будет выглядеть так
Код:
simulated function PostBeginPlay()
{
	local Font MyFont;

	Super(HudBase).PostBeginPlay();
	SetHUDAlpha();

	foreach DynamicActors(class'KFSPLevelInfo', KFLevelRule)
		Break;

	Hint_45_Time = 9999999;

	MyFont = LoadWaitingFont(0);
	MyFont = LoadWaitingFont(1);

	bUseBloom = bool(ConsoleCommand("get ini:Engine.Engine.ViewportManager Bloom"));
	bUseMotionBlur = Class'KFHumanPawn'.Default.bUseBlurEffect;

	SetTimer(1,true);
}
Добавить функции
Код:
function Timer()
{
	local int i, j;
	super.Timer();

	for( i=0; i<8; ++i )
	{
		if(Level.TimeSeconds > LocalMessages[i].EndOfLife && Class<Monster>(LocalMessages[j].OptionalObject) != None)
		{
			for(j=i; j<8; ++j)
			{
				LocalMessages[j] = LocalMessages[j+1];
			}
			LocalMessages[7].StringMessage = " ";
			LocalMessages[7].Switch = 0;
			LocalMessages[7].EndOfLife = 0;
			LocalMessages[7].OptionalObject = none;
			return;
		}
	}
}

function HudLocalizedMessage GetLocalMessage(int i)
{
	return LocalMessages[i];
}

function SetLocalMessage(HudLocalizedMessage hudmessage, int i)
{
	LocalMessages[0] = hudmessage;
}
Кроме того не забывайте данный факт насчёт декомпиляции-компиляции SP6