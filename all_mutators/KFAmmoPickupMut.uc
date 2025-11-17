Class KFAmmoPickupMut extends Mutator config(KFAmmoPickupMut);
var globalconfig int TimerInterval;
var globalconfig float AmmoPercent;
var globalconfig int MinAmmo;
var Array<KFAmmoPickup> ammoList;

/*
Параметры:
TimerInterval - частота таймера
AmmoPercent - количество видимых коробок в процентах
MinAmmo - минимальное обязательное количество появляющихся коробок

То есть если задать TimerInterval=30, а AmmoPercent=10, то одновременно в игре будет 10% (от вообще доступных ящиков)
И каждые 30 секунд коробки будут меняться
Но так как не всегда известно количество коробок на карте, то добавил переменную MinAmmo
Теперь, если задать MinAmmo=2, то по крайней мере 2 коробки будут появляться каждые 30 секунд где-то

p.s. Настройки сложности игры при работе с этим мутатором не влияют больше на количество KFAmmoPickup
Полезно будет знать настройки по-умолчанию для разных уровней сложности:
Easy - 65%
Normal - 50%
Hard - 35%
Suicide - 10%
HOE - 10%

Если MinAmmo не используется, то можно MinAmmo=0 написать, например...
Можно вообще написать AmmoPercent=0.0, MinAmmo=1 и поставить интервал таймера 10 секунд
И каждые десять секунд коробка с патронами будет скакать по карте ) (ну если на карте есть хотя бы 2 точки спавна KFAmmoPickup)
*/

function PostBeginPlay()
{
SaveConfig();
HideAll();
ShowSome();
}

function MatchStarting()
{
SetTimer(TimerInterval,true);
}

function Timer()
{
HideAll();
ShowSome();
}

function HideAll()
{
local KFAmmoPickup p;
ammoList.Length=0;
foreach DynamicActors(class'KFMod.KFAmmoPickup', p)
{
//переводим коробку в невидимое "спящее" состояние
if(!p.bSleeping)
p.GotoState('Sleeping', 'Begin');
ammoList[ammoList.Length]=p;
}
}

function ShowSome()
{
local int i;
local int randomNeed;
local int randomDone;
//исправляем возможную ошибку пользователя при задании процента. загоняем число в рамки от 0 до 100
AmmoPercent=Clamp(AmmoPercent,0,100);
//получаем сколько коробок с патронами должны быть активными в данный момент
randomNeed=(ammoList.Length * AmmoPercent) / 100.0;
randomNeed=Clamp(randomNeed,MinAmmo,ammoList.Length);
//первый проход по массиву коробок - пытаемся случайным образом выбрать нужные коробки
for(i=0;i<ammoList.Length;i++)
{
if(ammoList[i].bSleeping && Rand(ammoList.Length/randomNeed)==0)
{
//переводим коробку в видимое состояние
ammoList[i].GotoState('Pickup');
randomDone++;
if(randomDone>=randomNeed) break;
}
}
//если так вдруг оказалось, что мы выбрали меньше чем нужно, то добираем необходимое кол-во
//при этом добавлена страховка от бесконечного цикла (ammoList.Length>i)
i=0;
while(randomDone<randomNeed && ammoList.Length>i)
{
if(ammoList[i].bSleeping)
{
//переводим коробку в видимое состояние
ammoList[i].GotoState('Pickup');
randomDone++;
}
i++;
}
}

defaultproperties
{
TimerInterval=30
MinAmmo=1
AmmoPercent=30
GroupName="KF-Ammo"
FriendlyName="KFAmmoPickupMut"
Description="Randomly shifts ammo boxes"
bAddToServerPackages=True
}