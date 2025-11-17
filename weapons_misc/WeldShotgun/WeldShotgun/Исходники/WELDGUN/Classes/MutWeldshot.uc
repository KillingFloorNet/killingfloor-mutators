class MutWeldshot extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("Weldgun.Weldshot");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-Weldshot"
     FriendlyName="Weldshot Mutator"
     Description="Adds the Weldshot."
}
