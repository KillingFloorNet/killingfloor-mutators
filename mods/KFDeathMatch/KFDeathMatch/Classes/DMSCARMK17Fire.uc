//=============================================================================
 //SCARMK17 Fire
//=============================================================================
class DMSCARMK17Fire extends SCARMK17Fire;

function DoTrace(Vector Start, Rotator Dir)
{
	Class'DMSingleFire'.Static.DoDMTrace(Self,Start,Dir);
}

defaultproperties
{
}
