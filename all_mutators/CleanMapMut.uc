Class CleanMapMut extends Mutator config(CleanMapMut);
var() globalconfig array<string> ActorsForDestroy;
var() globalconfig bool TimerEnabled;
var() globalconfig int TimerInterval;

/*
В CleanMapMut.ini можно задать список классов, объекты которых мы хотим удалить до начала или во время игры.
Переменные настройки мутатора

TimerEnabled = true / false (хотим ли мы чтобы объекты удалялись во время игры или нет)
TimerInterval = 5 (как часто с карты удаляются объекты, если TimerEnabled == true)
ActorsForDestroy=KFMod.KFAmmoPickup (указание на класс объекты которого мы хотим удалить)
таких ActorsForDestroy может быть сколько угодно
Например, при таких настройках

TimerEnabled=True
TimerInterval=5
ActorsForDestroy=KFMod.KFAmmoPickup
ActorsForDestroy=KFMod.SinglePickup
ActorsForDestroy=KFMod.KnifePickup

мы удаляем перед стартом все разбросанные по карте пистолеты 9мм, ножи и патроны и потом, каждые 5 секунд, удаляем эти объекты, если они появляются на карте (кто то умирает с ножом в руке или выкидывает пистолет)
Так как указывать можно любые классы, то мутатор можно использовать для удаления, например, оружия из рук игроков, или каких-то монстров, или проджектайлов (например, можно убирать все мины или светящиеся палочки)
В общем тут всё зависит от воображения...

Замечания:
1. Можно ещё добавить проверку if(!a.bStatic), чтобы избежать вылетов при случайном указании на не динамический объект
2. Всегда надо задавать полный путь. Если задать не Engine.Pickup, а Pickup - ничем хорошим это не закончится...
*/

function PreBeginPlay()
{
	SaveConfig();
	CleanMap();
	if(TimerEnabled) SetTimer(TimerInterval,true);
	Super.PreBeginPlay();
}

function Timer()
{
	CleanMap();
}

function CleanMap()
{
	local class<Actor> aClass;
	local Actor a;
	local int i;
	for(i=0;i<ActorsForDestroy.Length;i++)
	{
		aClass = class<Actor>(DynamicLoadObject(ActorsForDestroy[i], class'Class'));
		foreach AllActors(aClass, a)
		{
			a.Destroy();
		}
	}
}

defaultproperties
{
	ActorsForDestroy(0)="Engine.Pickup"
	TimerEnabled=true;
	TimerInterval=5;
	GroupName="KF-CleanMap"
	FriendlyName="CleanMapMut"
	Description="Wipes actors from the map"
	bAddToServerPackages=True
}