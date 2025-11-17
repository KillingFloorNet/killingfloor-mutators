// TODO: Deprecated, use MutAllTheMods
// TODO: Missing Mutate function
class MutDoshWeapon extends Mutator;

var() config float DamageScale;

var config int DoshMinDropAmount;
var config int DoshMaxDropAmount;

function PostBeginPlay()
{
	if (KFGameType(Level.Game) == none)
	{
		Destroy();
		return;
	}

	if (Level.NetMode != NM_Standalone)
	{
		AddToPackageMap();
	}
}

simulated function Tick(float DeltaTime)
{
    local PlayerController PC;

    PC = Level.GetLocalPlayerController();

    if (PC != none)
	{
        // event Interaction AddInteraction(string InteractionName, optional Player AttachTo)
		PC.Player.InteractionMaster.AddInteraction("MutDoshWeapon.InteractionDoshWeapon", PC.Player);
    }

    Disable('Tick');
}

defaultproperties
{
	GroupName="KF-MutDoshWeapon"
	FriendlyName="MutDoshWeapon"
	Description=""
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=True

	DoshMinDropAmount=50
	DoshMaxDropAmount=50
	DamageScale=0.5 //1.0
}
