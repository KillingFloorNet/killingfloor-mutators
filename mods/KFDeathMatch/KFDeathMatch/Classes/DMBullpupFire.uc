//=============================================================================
 //L85 Fire
//=============================================================================
class DMBullpupFire extends BullpupFire;

function DoTrace(Vector Start, Rotator Dir)
{
	Class'DMSingleFire'.Static.DoDMTrace(Self,Start,Dir);
}

defaultproperties
{
}
