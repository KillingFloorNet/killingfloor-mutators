class AxeEboniteMut extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("AxeEboniteMut.AxeEbonite");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-AxeEbonite"
     FriendlyName="AxeEbonite"
     Description="Adds the AxeEbonite."
}
