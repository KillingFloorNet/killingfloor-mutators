class CWPMut extends Mutator
	config(CWPMut);

/* Add the interaction. */
simulated function Tick(float DeltaTime) {
	local PlayerController PC;
	local CWPInteraction NewInteraction;

	PC = Level.GetLocalPlayerController();
	if (PC != None) {
		NewInteraction = CWPInteraction(PC.Player.InteractionMaster.AddInteraction("CWPMut.CWPInteraction", PC.Player));
		NewInteraction.InitLevelWeapons();
		Disable('Tick');
	}
}

defaultproperties {
	GroupName="KFCWP"
	FriendlyName="Custom Weapon Priorities"
	Description="Adds options to customize weapon priorities."
	bAddToServerPackages=True
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True
}
