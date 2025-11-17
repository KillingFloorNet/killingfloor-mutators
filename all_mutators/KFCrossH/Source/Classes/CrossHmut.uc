class CrossHmut extends Mutator config(CrossHmut);

var config bool bAffectSpectators; // If this is set to true, an interaction will be created for spectators
var config bool bAffectPlayers; // If this is set to true, an interaction will be created for players
var bool bHasInteraction;

function PreBeginPlay()
{
	SaveConfig();
	if (KFGameType(Level.Game) == none) 
	{
		Destroy();
		return;
	}
	AddToPackageMap("KFCrossH");
}

simulated function Tick(float DeltaTime)
{
	local PlayerController PC;
	// If the player has an interaction already, exit function.
	if (bHasInteraction)
		return;
	//if( Level.NetMode==NM_DedicatedServer )
	//	return;
	PC = Level.GetLocalPlayerController();
	// Run a check to see whether this mutator should create an interaction for the player
	if	(
			PC != none &&
			(
				PC.PlayerReplicationInfo.bIsSpectator && bAffectSpectators || 
				bAffectPlayers && !PC.PlayerReplicationInfo.bIsSpectator
			)
		)
	{
		PC.Player.InteractionMaster.AddInteraction("KFCrossH.CrossH_interaction", PC.Player);
		bHasInteraction = True; // Set the variable so this lot isn't called again
	}
}

defaultproperties
{
	bAffectSpectators=True
	bAffectPlayers=True
	GroupName="KF-CrossH"
	FriendlyName="CrossHair v1.0"
	Description="Displays a CrossHair on the player's screen"
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
}