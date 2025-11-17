//=============================================================================
// KillsRules.
//=============================================================================
class KillsRulesEx extends GameRules;

function PostBeginPlay()
{
	NextGameRules = Level.Game.GameRulesModifiers;
	Level.Game.GameRulesModifiers = Self;
}

function ScoreKill(Controller Killer, Controller Killed)
{
	if( PlayerController(Killer)!=None && Monster(Killed.Pawn)!=None )
		PlayerController(Killer).ReceiveLocalizedMessage(Class'KillsMessageEx',,,,Killed.Pawn.Class);
	Super.ScoreKill(Killer,Killed);
}

defaultproperties
{
}
