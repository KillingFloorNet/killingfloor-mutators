class MutAddTCToInventory extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("TauC.TauCannon");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-TauCannon"
     FriendlyName="Tau Cannon Mutator"
     Description="Adds the Tau Cannon to your starting inventory"
}
