class PatriarchOldKillRules extends GameRules;

function PostBeginPlay()
{
	NextGameRules = Level.Game.GameRulesModifiers;
	Level.Game.GameRulesModifiers = Self;
}

function ScoreKill(Controller Killer, Controller Killed)
{
	if( PlayerController(Killer)!=None && ZombieBossBase(Killed.Pawn)!=None )
	{
		BroadcastLocalizedMessage(Class'MessageKill',,Killer.PlayerReplicationInfo);
	}
	Super.ScoreKill(Killer,Killed);
}

defaultproperties
{
}
