Class DoomTeleporter extends Teleporter;

simulated function bool Accept( actor Incoming, Actor Source )
{
	local rotator newRot, oldRot;
	local float mag;
	local vector oldDir,OldPosition;
	local Controller P;

	if ( Incoming == None )
		return false;
		
	// Move the actor here.
	Disable('Touch');
	newRot = Incoming.Rotation;
	if (bChangesYaw)
	{
		oldRot = Incoming.Rotation;
		newRot.Yaw = Rotation.Yaw;
		if ( Source != None )
			newRot.Yaw += (32768 + Incoming.Rotation.Yaw - Source.Rotation.Yaw);
	}

	OldPosition = Incoming.Location;
	if ( Pawn(Incoming) != None )
	{
		//tell enemies about teleport
		if ( Role == ROLE_Authority )
			For ( P=Level.ControllerList; P!=None; P=P.NextController )
				if ( P.Enemy == Incoming )
					P.LineOfSightTo(Incoming); 

		if ( !Pawn(Incoming).SetLocation(Location) )
			return false;
		if ( (Role == ROLE_Authority)
			|| (Level.TimeSeconds - LastFired > 0.5) )
		{
			newRot.Roll = 0;
			Pawn(Incoming).SetRotation(newRot);
			Pawn(Incoming).SetViewRotation(newRot);
			Pawn(Incoming).ClientSetRotation(newRot);
			LastFired = Level.TimeSeconds;
		}
		if ( Pawn(Incoming).Controller != None )
		{
			Pawn(Incoming).Controller.MoveTimer = -1.0;
			Pawn(Incoming).Anchor = self;
			Pawn(Incoming).SetMoveTarget(self);
		}
		Incoming.PlayTeleportEffect(false, true);
	}
	else
	{
		if ( !Incoming.SetLocation(Location) )
		{
			Enable('Touch');
			return false;
		}
		if ( bChangesYaw )
			Incoming.SetRotation(newRot);
	}
	Spawn(class'TeleportEffects',,,Incoming.Location);
	Spawn(class'TeleportEffects',,,OldPosition);
	Enable('Touch');

	if (bChangesVelocity)
		Incoming.Velocity = TargetVelocity;
	else
	{
		if ( bChangesYaw )
		{
			if ( Incoming.Physics == PHYS_Walking )
				OldRot.Pitch = 0;
			oldDir = vector(OldRot);
			mag = Incoming.Velocity Dot oldDir;		
			Incoming.Velocity = Incoming.Velocity - mag * oldDir + mag * vector(Incoming.Rotation);
		} 
		if ( bReversesX )
			Incoming.Velocity.X *= -1.0;
		if ( bReversesY )
			Incoming.Velocity.Y *= -1.0;
		if ( bReversesZ )
			Incoming.Velocity.Z *= -1.0;
	}	
	return true;
}

defaultproperties
{
}
