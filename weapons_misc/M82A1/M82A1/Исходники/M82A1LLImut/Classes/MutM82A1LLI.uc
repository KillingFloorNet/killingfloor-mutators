class MutM82A1LLI extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("M82A1LLImut.M82A1LLI");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-M82A1LLI"
     FriendlyName="M82A1LLI Mutator"
     Description="Adds the M82A1."
}
