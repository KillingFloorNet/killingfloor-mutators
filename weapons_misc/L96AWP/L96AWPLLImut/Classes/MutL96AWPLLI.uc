class MutL96AWPLLI extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("L96AWPLLImut.L96AWPLLI");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-L96AWPLLI"
     FriendlyName="L96AWPLLI Mutator"
     Description="Adds the L96AWPLLI."
}
