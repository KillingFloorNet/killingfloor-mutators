// Flame
// http://killingfloor.ru/xforum/threads/ideja-dlja-mutatora-riderekt.3479/#post-94595
Class RedirectMut extends Mutator Config(RedirectMut);

var config string NewAddress;
var int currentPort;

replication
{
	reliable if(Role == ROLE_Authority)
		currentPort;
}

//для клиента ставим таймер, чтобы запустить перенаправление на другой сервер
//через 5 секунд после присоединения
//для сервера ищем порт текущего сервака и реплицируем его на клиент
simulated function PostBeginPlay()
{
	if(Level.NetMode == NM_Client)
		SetTimer(5.0,false);
	else
		currentPort=Level.Game.GetServerPort();
}

//В таймере на клиенте получаем текущий адрес сервера, добавляем ему порт,
//полученный на сервере и реплицированный на клиента
//(не нашёл сходу функций для того, чтобы получить текущий порт из под клиента)
//Сравниваем текущий и новый адреса и если не совпадают - перенаправляем клиента
simulated function Timer()
{
	local string currentIP,currentAddress;
	local PlayerController PC;
	PC=Level.GetLocalPlayerController();
	if(PC==none) return;
	currentIP=PC.GetServerIP();
	currentAddress=currentIP$":"$currentPort;
	if(currentAddress!=NewAddress)
		PC.ConsoleCommand("open"@NewAddress);
}

defaultproperties
{
	NewAddress="127.0.0.1:7707"
	GroupName="KF-RedirectMut"
	FriendlyName="RedirectMut"
	Description="RedirectMut"
	bAddToServerPackages=True
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
}