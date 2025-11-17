Class DoomBeginGameTel extends Teleporter
	Config(DoomPawnsKF);

var globalconfig string UseMutators,UseGameType;

function PostTouch( actor Other )
{
	// Teleport to a level on the net.
	if( (Pawn(Other) != None) && Pawn(Other).IsHumanControlled() )
	{
		if( Len(UseMutators)==0 )
			Level.Game.SendPlayer(PlayerController(Pawn(Other).Controller), URL$"?Game="$UseGameType);
		else Level.Game.SendPlayer(PlayerController(Pawn(Other).Controller), URL$"?Game="$UseGameType$"?Mutator="$UseMutators);
	}
}

defaultproperties
{
     UseGameType="DoomPawnsKF.DoomGameType"
}
