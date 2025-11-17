//=============================================================================
 //AK47 Fire
//=============================================================================
class DMAK47Fire extends AK47Fire;

function DoTrace(Vector Start, Rotator Dir)
{
	Class'DMSingleFire'.Static.DoDMTrace(Self,Start,Dir);
}

defaultproperties
{
}
