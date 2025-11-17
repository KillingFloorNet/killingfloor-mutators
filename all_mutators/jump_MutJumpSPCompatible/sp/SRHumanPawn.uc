class SRHumanPawn extends KFHumanPawn_Story;

...

function bool DoJump( bool bUpdating )
{
	if(DoJumpXPawn(bUpdating))
	{
		if(KFWeapon(Weapon) != none && PhysicsVolume.Gravity.Z <= class'PhysicsVolume'.default.Gravity.Z)
			KFWeapon(Weapon).ForceZoomOutTime = Level.TimeSeconds + 0.01;
		return true;
	}
	return false;
}

function bool DoJumpXPawn( bool bUpdating )
{
	if(!bUpdating && CanDoubleJump()&& Abs(Velocity.Z) < 100)
	{
		if(PlayerController(Controller) != None)
			PlayerController(Controller).bDoubleJump = true;
		DoDoubleJump(bUpdating);
		MultiJumpRemaining -= 1;
		return true;
	}
	if(Super.DoJump(bUpdating))
	{
		if(!bUpdating)
			PlayOwnedSound(GetSound(EST_Jump), SLOT_Pain, GruntVolume,,80);
		return true;
	}
	return false;
}
...