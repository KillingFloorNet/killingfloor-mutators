/*
https://web.archive.org/web/20170725114546/http://killingfloor.ru/xforum/threads/zapis-demo-ot-admina.2341/

Мутатор позволяет автоматически писать демо на сервере

Подобная демка позволяет смотреть запись от лица каждого игрока или в режиме свободного полёта, что бесценно для разрешения спорных ситуаций админом впоследствии.
По сути мутатор вызывает команду "demorec Имя_Демки" выполненную от админа в нужное время в нужном формате.

История и проблемы

Месяца 3 назад написал я этот мутатор. Всё бы хорошо, но вот драйвер записи демок работает очень нестабильно и иногда крашит игру.
Если кто-то сталкивался с данной проблемой и знает решение (возможно параметры драйвера в KillingFloor.ini), то очень приятно было бы его узнать...
Из-за достаточно произвольного краша не рискуем использовать этот мутатор для записи демок с турнира. Как и вообще использовать команду записи от админа на турнире...

Основной вылет происходит в начале каждой волны, когда спавнятся много разных зомбиков. Вначале решением проблемы казался следующий подход - пишем начиная с некоторой секунды после начала волны (чтобы основная масса монстров уже заспавнилась) и останавливаем запись в конце трейдера. То есть поволновая запись. Вылеты стали гораздо реже, но всё равно бывают...
Параметры (в ini файле и в WebAdmin.Rules):
demoRecEnabled - используем мутатор или нет
eachWaveRec - пишем каждую волну в отдельную демку или нет
demoRecStartTime - если пишем каждую волну, то через сколько секунд после начала волны начинаем писать
demoRecStopTime - если пишем каждую волну, то за сколько секунд до конца трейдера заканчиваем писать
frequency - частота срабатывания таймера в котором мы проверяем пора ли остановить запись, пора ли начать запись
prefix - префикс перед названием файла демки

Вообще выходной формат демо файла следующий:

prefix_Год_Месяц_День__Час_Минута_Секунда__НазваниеКартыНомерВолны
*/

// Файлы с демо сохраняются в папке сервера Demos.
// Если надо посмотреть демку, то кидаем её в папку Demos клиента и используем консольную команду "demoplay Имя_Демки".
// Добавлять в виде DemoRecMut.DemoRecMut
class DemoRecMut extends Mutator config(DemoRecMut);

var() config bool demoRecEnabled;
var() config bool eachWaveRec;
var() config int demoRecStartTime;
var() config int demoRecStopTime;
var() config int frequency;
var() config string prefix;

var bool isRecording;
var float demoStartTime;
var bool firstTimerTickInWave;

event PreBeginPlay()
{
	SetTimer(frequency,true);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.RulesGroup, "demoRecEnabled", "DemoRec enabled", 1, 0, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "eachWaveRec", "DemoRec each wave", 1, 0, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "demoRecStartTime", "DemoRec StartTime", 1, 1,"Text");
	PlayInfo.AddSetting(default.RulesGroup, "demoRecStopTime", "DemoRec StopTime", 1, 1,"Text");
	PlayInfo.AddSetting(default.RulesGroup, "frequency", "DemoRec timer frequency", 1, 1,"Text");
	PlayInfo.AddSetting(default.RulesGroup, "prefix", "DemoRec prefix", 1, 1,"Text");
}

	static function string GetDescriptionText(string PropName)
	{
		switch (PropName)
		{
			case "demoRecEnabled":		return "Is recording enabled?";
			case "eachWaveRec":			return "Wave by wave, cutting it in trader time?";
			case "demoRecStartTime":	return "Seconds from the beginning of the wave, if they passed - we start recording";
			case "demoRecStopTime":		return "Seconds before the end of Trader time we stop the record";
			case "frequency":			return "Timer frequency - how often we check the situation";
			case "prefix":				return "Prefix of the demo filename";
		}
		return "";
	}

function Timer()
{
	local  KFGameReplicationInfo KFGRI;
//Если не позволена запись демки - выходим
	if(!demoRecEnabled) return;

	KFGRI=KFGameReplicationInfo(Level.Game.GameReplicationInfo);
	if(KFGRI==None) 
	{
		Log("DemoRecMut.Error");
		return;
	}
//Первый тик таймера в волне? Устанавливаем минимальное время старта записи
	if(KFGameType(Level.Game).bWaveInProgress && firstTimerTickInWave)
	{
		demoStartTime = Level.TimeSeconds + demoRecStartTime;
		firstTimerTickInWave=false;
	}
//Кончилась волна? Сбрасываем значение переменной проверяющей 1 тик
	if(!KFGameType(Level.Game).bWaveInProgress && !firstTimerTickInWave)
	{
		firstTimerTickInWave=true;
	}

//Если демка ещё не пишется, время больше минимального времени записи, установленного выше,
//и идёт волна, то пишем демку
	if( !isRecording && 
		Level.TimeSeconds>demoStartTime &&
		KFGameType(Level.Game).bWaveInProgress
		)
	{
//В формате Prefix_Дата_Карта_ВолнаНаКоторойНачаласьЗапись
		ConsoleCommand("Demorec "$prefix$"_"$Level.Year$"_"$Level.Month$"_"$Level.Day$"__"$Level.Hour$"_"$Level.Minute$"_"$Level.Second$"__"$Level.Title$string(KFGameType(Level.Game).WaveNum+1));
		isRecording=true;
	}
//Если пишем демку по волнам, а не целиком всю карту, если сейчас время трейдера и 
//настало время останавливать запись, то это и делаем
	if( eachWaveRec && isRecording && 
		!KFGameType(Level.Game).bWaveInProgress && 
		KFGRI.TimeToNextWave<demoRecStopTime
		)
	{
		ConsoleCommand("StopDemo");
		isRecording=false;
	}
}

defaultproperties
{
	demoRecEnabled=True
	eachWaveRec=True
	demoRecStartTime=10
	demoRecStopTime=15
	Frequency=6
	Prefix="Demo_1_"
	demoStartTime=999999995904.000000
	firstTimerTickInWave=True
	GroupName="DemoRecMut"
	FriendlyName="DemoRecMut"
	Description="Auto Demo Recording"
}