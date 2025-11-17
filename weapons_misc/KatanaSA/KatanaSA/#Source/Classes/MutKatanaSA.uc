class MutKatanaSA extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("KatanaSA.KatanaSA");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-KatanaSA"
     FriendlyName="Katana Mutator"
     Description="Adds the Katana."
}
