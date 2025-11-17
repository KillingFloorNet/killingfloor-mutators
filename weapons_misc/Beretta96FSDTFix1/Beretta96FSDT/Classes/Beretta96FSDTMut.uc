class Beretta96FSDTMut extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("Beretta96FSDT.Beretta96FSDT");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-Beretta96FS"
     FriendlyName="Beretta96FS Mutator"
     Description="Adds the Beretta96FS."
}
