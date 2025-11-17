class AutoChangeMapMut extends Mutator config(AutoChangeMapMut);
var config int waitingInterval;
var int startWaiting;
var bool playersCanConnect;

function PostBeginPlay()
{
	startWaiting=Level.TimeSeconds;
	playersCanConnect=false;
	SetTimer(60.0,true);
}

function Timer()
{
	local int playersN;
	
	//Если хотя бы 1 игрок смог подключиться, то больше не заходим в таймер
	if(playersCanConnect)
		return;	
	//Если идёт игра - не заходим в таймер (в принципе ненужная проверка)
	if (!Level.Game.bWaitingToStartMatch)
		return;
	
	//Проверка сколько игроков (+зрителей) присоединено к серверу
	playersN=PlayersNumber();
	if(playersN>0)
	{
		playersCanConnect=true;
		return;
	}

	//Если истекло время - меняем карту
	if(Level.TimeSeconds-startWaiting>=waitingInterval)
	{
		Level.Game.bChangeLevels=true;
		Level.Game.bAlreadyChanged=false;
		Level.Game.RestartGame();
	}

}

function int PlayersNumber()
{
	local int N;
	local Controller C;
	N=0;
	for( C = Level.ControllerList; C != None; C = C.nextController ) 
	{
		if( C.IsA('PlayerController') && C.PlayerReplicationInfo.PlayerID>0 )
		{
			N++;
		}
	}
	return N;
}

defaultproperties
{
     waitingInterval=7200
     bAddToServerPackages=True
     GroupName="AutoChangeMapMut"
     FriendlyName="AutoChangeMapMut"
     Description="Changes the map if nobody plays on current map for a period of time"
}