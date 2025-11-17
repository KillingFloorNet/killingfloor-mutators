class MutV94LLI extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("V94LLImut.V94LLI");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-V94LLI"
     FriendlyName="V94LLI Mutator"
     Description="Adds the V-94 Volga."
}
