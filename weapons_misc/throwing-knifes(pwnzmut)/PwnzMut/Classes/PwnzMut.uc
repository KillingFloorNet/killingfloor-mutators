class PwnzMut extends Mutator;

function ModifyPlayer(Pawn Other)
{
	Other.CreateInventory("PwnzMut.UberKnife");

	super.ModifyPlayer(Other);
}

Defaultproperties
{
	GroupName = "KF-PwnzMut"
	FriendlyName = "PWN SOME PEOPLE"
	Description = "Removes all those buggy things"
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
}
