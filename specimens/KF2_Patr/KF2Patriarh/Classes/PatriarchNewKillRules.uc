class PatriarchNewKillRules extends GameRules;

function PostBeginPlay()
{
	NextGameRules = Level.Game.GameRulesModifiers;
	Level.Game.GameRulesModifiers = Self;
}

function ScoreKill(Controller Killer, Controller Killed)
{
	if( PlayerController(Killer)!=None && ZombieKf2BossBase(Killed.Pawn)!=None )
	{
		BroadcastLocalizedMessage(Class'MessageKill',,Killer.PlayerReplicationInfo);
	}
	Super.ScoreKill(Killer,Killed);
}

defaultproperties
{
}
