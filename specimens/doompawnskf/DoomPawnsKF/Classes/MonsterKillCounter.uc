// Trigger whenever all monsters with specific event has been killed.
Class MonsterKillCounter extends Triggers;

event Trigger( Actor Other, Pawn EventInstigator )
{
	local Controller C;

	for( C=Level.ControllerList; C!=None; C=C.nextController )
	{
		if( C.Pawn!=None && C.Pawn!=Other && C.Pawn.Event==Tag && C.Pawn.Health>0 )
			return;
	}
	TriggerEvent(Event,Other,EventInstigator);
}

defaultproperties
{
}
