// https://web.archive.org/web/20220819070812/http://killingfloor.ru/xforum/threads/replacetradermut.2422/

/*
По сути вопрос сводится к 3 проблемам
1. Замена модели
2. Замена портрета
3. Замена или отключение голосовых сообщений трейдера

1. Заменяем модель:

Можно поставить абсолютно любую модельку в качестве трейдера, например, написать
Mesh=SkeletalMesh'KF_Soldier_Trip.Priest'
Результат
Для данного примера, так как KF_Soldier_Trip это анимация из стандартного набора, то нет необходимости прописывать мутатор в KillingFloor.ini
Так же можно, небось, добавить анимацию какую-нибудь. Чтобы не стоял истуканом
Но эт всё позже...

2. Портрет.

3.1 Убираем реплики трейдера.

Просто добавляем в KFPCServ фунцию ClientLocationalVoiceMessage из KFMod.KFPlayerController
и добавляем 1 строчку: 

if ( MessageType == 'TRADER' ) return;

Итоговая функция выглядит так:

function ClientLocationalVoiceMessage(PlayerReplicationInfo Sender,

PlayerReplicationInfo Recipient,

name MessageType, byte MessageID,

optional Pawn SenderPawn, optional vector SenderLocation)

{

local VoicePack Voice;

local ShopVolume Shop;



if ( Sender == none || Sender.VoiceType == none || Player.Console == none || Level.NetMode == NM_DedicatedServer )

{

return;

}

if ( MessageType == 'TRADER' ) return;

Voice = Spawn(Sender.VoiceType, self);

if ( KFVoicePack(Voice) != none )

{

if ( MessageType == 'TRADER' )

{

if ( Pawn != none && MessageID >= 4 )

{

foreach Pawn.TouchingActors(Class'ShopVolume', Shop)

{

SenderLocation = Shop.MyTrader.Location;



// Only play the 30 Seconds remaining messages come across as Locational Speech if we're in the Shop

if ( MessageID == 4 )

{

return;

}

else if ( MessageID == 5 )

{

MessageID = 999;

}



break;

}

}



// Only play the 10 Seconds remaining message if we are in the Shop

// and only play the 30 seconds remaning message if we haven't been to the Shop

if ( MessageID == 5 || (MessageID == 4 && bHasHeardTraderWelcomeMessage) )

{

return;

}

else if ( MessageID == 999 )

{

MessageID = 5;

}



// Store the fact that we've heard the Trader's Welcome message on the client

if ( MessageID == 7 )

{

bHasHeardTraderWelcomeMessage = true;

}

// If we're hearing the Shop's Closed Message, reset the Trader's Welcome message flag

else if ( MessageID == 6 )

{

bHasHeardTraderWelcomeMessage = false;

}



KFVoicePack(Voice).ClientInitializeLocational(Sender, Recipient, MessageType, MessageID, SenderPawn, SenderLocation);



if ( MessageID > 6 /*&& bBuyMenuIsOpen*/ )

{

// TODO: Show KFVoicePack(Voice).GetClientParsedMessage() in the Buy Menu

}

else if ( KFVoicePack(Voice).GetClientParsedMessage() != "" )

{

// Radio commands print to Text

TeamMessage(Sender, KFVoicePack(Voice).GetClientParsedMessage(), 'Trader');

}

}

else

{

KFVoicePack(Voice).ClientInitializeLocational(Sender, Recipient, MessageType, MessageID, SenderPawn, SenderLocation);



if ( KFVoicePack(Voice).GetClientParsedMessage() != "" )

{

TeamMessage(Sender, KFVoicePack(Voice).GetClientParsedMessage(), 'Voice');

}

}

}

else if ( Voice != None )

{

Voice.ClientInitialize(Sender, Recipient, MessageType, MessageID);

}

}

После такой реализации отпадает необходимость в пункте 2, т.к. портрет и не появится раз реплик нет...
Хотя можно сделать так, чтобы сообщения писались, но не озвучивались, тогда портрет пригодится...

Теперь надо ещё в одном месте звуки отключить. В SRBuyMenuSaleList. Реплики, что не хватает веса или денег.
Например, закомментируем кусок кода отвечающий за это...

function IndexChanged(GUIComponent Sender)

{

/*

if ( CanBuys[Index]==0 )

{

if ( ForSaleBuyables[Index-SelectionOffset].ItemCost > PlayerOwner().PlayerReplicationInfo.Score )

PlayerOwner().Pawn.DemoPlaySound(TraderSoundTooExpensive, SLOT_Interface, 2.0);

else if ( ForSaleBuyables[Index-SelectionOffset].ItemWeight + KFHumanPawn(PlayerOwner().Pawn).CurrentWeight > KFHumanPawn(PlayerOwner().Pawn).MaxCarryWeight )

PlayerOwner().Pawn.DemoPlaySound(TraderSoundTooHeavy, SLOT_Interface, 2.0);

}

*/

Super(GUIVertList).IndexChanged(Sender);

}

Всё. Теперь трейдер стал очень молчаливый.

3.2 Заменяем озвучку.

Сразу хочу заметить - мне эта реализация не очень нравится, но остальные, которые у меня получались - ещё хуже )) Потом может сделаю по-другому...
Итак, вновь как и в пункте 3.1 работаем с теми же классами и функциями. Теперь мы добавим в KFPCServ следующие строчки:
В начало файла:

var SoundGroup TraderSound[12];

var sound TraderRadioBeep;

в секцию Defaults

TraderSound(0)=SoundGroup'RE4Merchant_SN.Radio_Moving'

TraderSound(1)=SoundGroup'RE4Merchant_SN.Radio_AlmostOpen'

TraderSound(2)=SoundGroup'RE4Merchant_SN.Radio_ShopsOpen'

TraderSound(3)=SoundGroup'RE4Merchant_SN.Radio_LastWave'

TraderSound(4)=SoundGroup'RE4Merchant_SN.Radio_ThirtySeconds'

TraderSound(5)=SoundGroup'RE4Merchant_SN.Radio_TenSeconds'

TraderSound(6)=SoundGroup'RE4Merchant_SN.Radio_Closed'

TraderSound(7)=SoundGroup'RE4Merchant_SN.Welcome'

TraderSound(8)=SoundGroup'RE4Merchant_SN.TooExpensive'

TraderSound(9)=SoundGroup'RE4Merchant_SN.TooHeavy'

TraderSound(10)=SoundGroup'RE4Merchant_SN.ThirtySeconds'

TraderSound(11)=SoundGroup'RE4Merchant_SN.TenSeconds'

TraderRadioBeep=Sound'RE4Merchant_SN.Walkie_Beep'

А в функцию ClientLocationalVoiceMessage добавляем вот это

local int i;

...

Voice = Spawn(Sender.VoiceType, self);



if ( MessageType == 'TRADER' )

{

if ( KFVoicePack(Voice) != none )

{

for(i=0;i<12;i++)

{

KFVoicePack(Voice).TraderSound[i]=default.TraderSound[i];

}

KFVoicePack(Voice).TraderRadioBeep=default.TraderRadioBeep;

}

else if ( KFVoicePackTwo(Voice) != none )

{

for(i=0;i<12;i++)

{

KFVoicePackTwo(Voice).TraderSound[i]=default.TraderSound[i];

}

KFVoicePackTwo(Voice).TraderRadioBeep=default.TraderRadioBeep;

}

}

То есть мы получаем VoicePack объект и тупо меняем ему дефолтные значения.
Итоговая функция такая:

function ClientLocationalVoiceMessage(PlayerReplicationInfo Sender,

PlayerReplicationInfo Recipient,

name MessageType, byte MessageID,

optional Pawn SenderPawn, optional vector SenderLocation)

{

local VoicePack Voice;

local ShopVolume Shop;

local int i;



if ( Sender == none || Sender.VoiceType == none || Player.Console == none || Level.NetMode == NM_DedicatedServer )

{

return;

}

Voice = Spawn(Sender.VoiceType, self);



if ( MessageType == 'TRADER' )

{

if ( KFVoicePack(Voice) != none )

{

for(i=0;i<12;i++)

{

KFVoicePack(Voice).TraderSound[i]=default.TraderSound[i];

}

KFVoicePack(Voice).TraderRadioBeep=default.TraderRadioBeep;

}

else if ( KFVoicePackTwo(Voice) != none )

{

for(i=0;i<12;i++)

{

KFVoicePackTwo(Voice).TraderSound[i]=default.TraderSound[i];

}

KFVoicePackTwo(Voice).TraderRadioBeep=default.TraderRadioBeep;

}

}





if ( KFVoicePack(Voice) != none )

{

if ( MessageType == 'TRADER' )

{

if ( Pawn != none && MessageID >= 4 )

{

foreach Pawn.TouchingActors(Class'ShopVolume', Shop)

{

SenderLocation = Shop.MyTrader.Location;



// Only play the 30 Seconds remaining messages come across as Locational Speech if we're in the Shop

if ( MessageID == 4 )

{

return;

}

else if ( MessageID == 5 )

{

MessageID = 999;

}



break;

}

}



// Only play the 10 Seconds remaining message if we are in the Shop

// and only play the 30 seconds remaning message if we haven't been to the Shop

if ( MessageID == 5 || (MessageID == 4 && bHasHeardTraderWelcomeMessage) )

{

return;

}

else if ( MessageID == 999 )

{

MessageID = 5;

}



// Store the fact that we've heard the Trader's Welcome message on the client

if ( MessageID == 7 )

{

bHasHeardTraderWelcomeMessage = true;

}

// If we're hearing the Shop's Closed Message, reset the Trader's Welcome message flag

else if ( MessageID == 6 )

{

bHasHeardTraderWelcomeMessage = false;

}



KFVoicePack(Voice).ClientInitializeLocational(Sender, Recipient, MessageType, MessageID, SenderPawn, SenderLocation);



if ( MessageID > 6 /*&& bBuyMenuIsOpen*/ )

{

// TODO: Show KFVoicePack(Voice).GetClientParsedMessage() in the Buy Menu

}

else if ( KFVoicePack(Voice).GetClientParsedMessage() != "" )

{

// Radio commands print to Text

TeamMessage(Sender, KFVoicePack(Voice).GetClientParsedMessage(), 'Trader');

}

}

else

{

KFVoicePack(Voice).ClientInitializeLocational(Sender, Recipient, MessageType, MessageID, SenderPawn, SenderLocation);



if ( KFVoicePack(Voice).GetClientParsedMessage() != "" )

{

TeamMessage(Sender, KFVoicePack(Voice).GetClientParsedMessage(), 'Voice');

}

}

}

else if ( Voice != None )

{

Voice.ClientInitialize(Sender, Recipient, MessageType, MessageID);

}

}

Теперь идём в класс SRBuyMenuSaleList и добавляем 2 строчки в defaultproperties

TraderSoundTooExpensive=SoundGroup'RE4Merchant_SN.TooExpensive'

TraderSoundTooHeavy=SoundGroup'RE4Merchant_SN.TooHeavy'

Всё. Трейдер говорит нужным нам голосом
*/

class ReplaceTraderMut extends Mutator;

function PreBeginPlay()
{
    local WeaponLocker wl;
    foreach AllActors (class'WeaponLocker', wl)
    {
        wl.LinkMesh(default.Mesh, true);
    }
    Class'SRHUDKillingFloor'.default.TraderPortrait=default.Texture;
    Super.PreBeginPlay();
}

defaultproperties
{
    Mesh=SkeletalMesh'RE4Merchant_A.ShopKeeper_Trip'
    Texture=Texture'RE4Merchant_T.Trader_portrait'
    GroupName="KF-ReplaceTrader"
    FriendlyName="ReplaceTraderMut"  
    Description="ReplaceTraderMut"
    bAddToServerPackages=True
}

