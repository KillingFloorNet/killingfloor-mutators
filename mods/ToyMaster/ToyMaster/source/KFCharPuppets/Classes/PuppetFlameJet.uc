//-----------------------------------------------------------
//
//-----------------------------------------------------------
class PuppetFlameJet extends BileJet;

simulated function timer()
{
	local vector X,Y,Z;
	local int i;
	local rotator R;

	GetAxes(Rotation,X,Y,Z);

    // Randomly chuch out vomit globs
    for (i = 0; i < 4; i++)
    {
        R.Yaw = BileRotation.Yaw * FRand();
        R.Pitch = BileRotation.Pitch;
        R.Roll = BileRotation.Roll;
        Spawn(Class'KFMod.FlameTendril',,,Location,Rotator(X >> R));
    }

}

defaultproperties
{
}
