//=============================================================================
 //M14EBR Fire
//=============================================================================
class DMM14EBRFire extends M14EBRFire;

function DoTrace(Vector Start, Rotator Dir)
{
	Class'DMSingleFire'.Static.DoDMTrace(Self,Start,Dir);
}

defaultproperties
{
}
