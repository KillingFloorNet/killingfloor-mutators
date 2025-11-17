//=============================================================================
// Winchester Fire
//=============================================================================
class DMWinchesterFire extends WinchesterFire;

function DoTrace(Vector Start, Rotator Dir)
{
	Class'DMSingleFire'.Static.DoDMTrace(Self,Start,Dir);
}

defaultproperties
{
}
