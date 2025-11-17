class MutScarHSAAssaultRifle extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("ScarHSAMut.ScarHSAAssaultRifle");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-ScarHSA"
     FriendlyName="ScarHSA Mutator"
     Description="Adds the ScarHSA."
}
