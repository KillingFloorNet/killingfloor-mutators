class MutEvoProSA extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("EvoProSAMut.EvoProSAAssaultRifle");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-EVO-PRO"
     FriendlyName="EVO-PRO Mutator"
     Description="Adds the EVOPRO-A2 INDUSTRIES."
}
