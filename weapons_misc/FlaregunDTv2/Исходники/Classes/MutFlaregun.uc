class MutFlaregun extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("FlaregunMut.Flaregun");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-Flaregun"
     FriendlyName="Flaregun Mutator"
     Description="Adds the Flaregun."
}
