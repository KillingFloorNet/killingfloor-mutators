class MutAssaultRifle extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("AssaultRifleUnreal2k4.AssaultRifle");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-AssaultRifle"
     FriendlyName="AssaultRifle Mutator"
     Description="Adds the Assault Rifle."
}
