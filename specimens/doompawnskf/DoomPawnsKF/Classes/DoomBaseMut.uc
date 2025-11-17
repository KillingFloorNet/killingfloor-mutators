// Written by Marco
Class DoomBaseMut extends KillingFloorMut
	HideDropDown
	CacheExempt;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if( Controller(Other)!=None )
		Controller(Other).PlayerReplicationInfoClass = Class'KFSPRIFixed';
	return true;
}
function Mutate(string MutateString, PlayerController Sender)
{
	if( MutateString=="JoinMonsters" && KFSPRIFixed(Sender.PlayerReplicationInfo)!=None )
		KFSPRIFixed(Sender.PlayerReplicationInfo).BecomeMonster();
	else if ( NextMutator != None )
		NextMutator.Mutate(MutateString, Sender);
}

defaultproperties
{
}
