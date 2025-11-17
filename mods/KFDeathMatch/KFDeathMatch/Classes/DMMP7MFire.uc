//=============================================================================
// MP7M Standard Fire
//=============================================================================
class DMMP7MFire extends MP7MFire;

function DoTrace(Vector Start, Rotator Dir)
{
	Class'DMSingleFire'.Static.DoDMTrace(Self,Start,Dir);
}

defaultproperties
{
}
