// Written by Marco
Class KFDMBaseMut extends KillingFloorMut
	HideDropDown
	CacheExempt;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if( Controller(Other)!=None )
		Controller(Other).PlayerReplicationInfoClass = Class'KFDMPRI';
	return true;
}

defaultproperties
{
}
