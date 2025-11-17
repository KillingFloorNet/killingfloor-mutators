class CBMMutator extends Mutator;

function PostBeginPlay() {
    if (KFGameType(Level.Game) == none) {
        Destroy();
        return;
    }
    if (Level.NetMode != NM_Standalone)
        AddToPackageMap("CustomBuyMenu");
}

simulated function Tick(float DeltaTime) {
    local PlayerController PC;

    PC= Level.GetLocalPlayerController();
    if (PC != none) {
        if (KF_StoryGRI(PC.GameReplicationInfo) == none) {
            PC.Player.InteractionMaster.AddInteraction("CustomBuyMenu.CBMInteractionVanilla", PC.Player);
            log("CBMMutator - Using vanilla interaction");
        } else {
            PC.Player.InteractionMaster.AddInteraction("CustomBuyMenu.CBMInteraction_Story", PC.Player);
            log("CBMMutator - Using story interaction");
        }
    }
    Disable('Tick');
}

defaultproperties {
    GroupName="KFCustomBuyMenu"
    FriendlyName="Custom Buy Menu v1.3"
    Description="Filters weapons by perk to reduce the clutter in the trader buy menu"
    
    RemoteRole= ROLE_SimulatedProxy
    bAlwaysRelevant= true
}
