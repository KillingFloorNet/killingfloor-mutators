class MutAddFlaresToInventory extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("Flares.FlareHandheld");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-Flares"
     FriendlyName="Flares Mutator"
     Description="Adds the Emergency Flares to your starting inventory"
}
