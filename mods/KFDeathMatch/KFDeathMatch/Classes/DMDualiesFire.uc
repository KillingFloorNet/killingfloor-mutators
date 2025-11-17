//=============================================================================
// Dualies Fire
//=============================================================================
class DMDualiesFire extends DualiesFire;

function DoTrace(Vector Start, Rotator Dir)
{
	Class'DMSingleFire'.Static.DoDMTrace(Self,Start,Dir);
}

defaultproperties
{
}
