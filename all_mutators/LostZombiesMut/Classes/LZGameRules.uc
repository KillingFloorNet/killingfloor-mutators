class LZGameRules extends GameRules;

var float LastMosterKillTime;

function PostBeginPlay()
{
	if( Level.Game.GameRulesModifiers==None )
		Level.Game.GameRulesModifiers = Self;
	else
		Level.Game.GameRulesModifiers.AddGameRules(Self);
}

function AddGameRules(GameRules GR)
{
	if ( GR!=Self )
		Super.AddGameRules(GR);
}

// Запоминаем время последнего убийства
function ScoreKill (Controller killer , Controller killed)
{
	if(killer!=None && killer.IsA('PlayerController'))
		LastMosterKillTime=Level.TimeSeconds;
	if (nextGameRules != none)
		nextGameRules.scoreKill (killer , killed);
}

defaultproperties
{
}