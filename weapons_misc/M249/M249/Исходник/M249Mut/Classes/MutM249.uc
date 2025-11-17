class MutM249 extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("M249Mut.M249");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-M249"
     FriendlyName="M249 Mutator"
     Description="Adds the M249."
}
