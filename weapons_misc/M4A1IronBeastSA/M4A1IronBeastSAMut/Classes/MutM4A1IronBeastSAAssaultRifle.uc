class MutM4A1IronBeastSAAssaultRifle extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("M4A1IronBeastSAMut.M4A1IronBeastSAAssaultRifle");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-M4A1IronBeast"
     FriendlyName="M4A1IronBeast Mutator"
     Description="Adds the M4A1IronBeast."
}
