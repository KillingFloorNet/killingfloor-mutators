//В данной версии реализовано оживление всех после всеобщей смерти 1 раз за карту
class SecondChanceRules extends GameRules;

var bool bActivated;

function PostBeginPlay()
{
	if(Level.Game.GameRulesModifiers == none)
		Level.Game.GameRulesModifiers = self;
	else
		Level.Game.GameRulesModifiers.AddGameRules(self);
}

function AddGameRules(GameRules GR)
{
	if(GR != self)
		super.AddGameRules(GR);
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	if(!bActivated)
	{
		ResurrectPlayers();
		bActivated=true;
		return false;
	}
	if ( NextGameRules != None )
		return NextGameRules.CheckEndGame(Winner,Reason);
	return true;
}

//Приходится чуток поизвращаться. Тут почему то не прокатывает стандартное оживление из той же админки
function ResurrectPlayers()
{
	local Controller C;
	local Pawn tmpPawn;
	tmpPawn=Spawn(class'Pawn');
	//Flame. В KFGameType есть проверка на bWaveInProgress
	KFGameType(Level.Game).bWaveInProgress = false;
	//
	for( C = Level.ControllerList; C != None; C = C.nextController ) 
	{
		if(C.IsA('PlayerController') && C.PlayerReplicationInfo.PlayerID>0)
		{
			//Flame. В KFGameType есть проверка на bOutOfLives и на C.Pawn!=none. Эти две строчки позволят обойти это
			C.PlayerReplicationInfo.bOutOfLives=false;
			C.Pawn = tmpPawn;
			//
			Level.Game.RestartPlayer(C);
		}
	}
	KFGameType(Level.Game).bWaveInProgress = true;
	tmpPawn.Destroy();
}