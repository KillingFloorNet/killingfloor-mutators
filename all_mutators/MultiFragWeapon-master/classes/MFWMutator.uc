class MFWMutator extends Mutator;

function PostBeginPlay() {
    Level.Game.PlayerControllerClass= class'MultiFragWeapon.MFWPlayerController';
    Level.Game.PlayerControllerClassName= "MultiFragWeapon.MFWPlayerController";
    AddToPackageMap();
}

defaultproperties {
    GroupName="KFMultiFragWeapon"
    FriendlyName="Multiple Frag Weapon"
    Description="Proof of concept for grenade switching"
}
