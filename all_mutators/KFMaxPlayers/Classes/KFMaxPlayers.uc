Class KFMaxPlayers extends Info
	Config(KFMaxPlayers);

var() globalconfig int ForcedMaxPlayers;

function Tick( float Delta )
{
	Log("Forcing server max players from"@Level.Game.MaxPlayers@"to"@ForcedMaxPlayers,Class.Outer.Name);
	Level.Game.MaxPlayers = ForcedMaxPlayers;
	Level.Game.Default.MaxPlayers = ForcedMaxPlayers;
	Destroy();
}

defaultproperties
{
     ForcedMaxPlayers=16
}
