class ACTION_SpawnActorWDeathEvent extends ACTION_SpawnActor;

var(Action)   name    DeathEvent;

function bool InitActionFor(ScriptedController C)
{
	local vector loc;
	local rotator rot;
	local actor a;

	if ( bOffsetFromScriptedPawn )
	{
		loc = C.Pawn.Location + LocationOffset;
		rot = C.Pawn.Rotation + RotationOffset;
	}
	else
	{
		loc = C.SequenceScript.Location + LocationOffset;
		rot = C.SequenceScript.Rotation + RotationOffset;
	}
	a = C.Spawn(ActorClass,,,loc,rot);
	a.Instigator = C.Pawn;
	if ( ActorTag != 'None' )
		a.Tag = ActorTag;
	if ( DeathEvent != 'None' )
		a.Event = DeathEvent;
	return false;
}

defaultproperties
{
}
