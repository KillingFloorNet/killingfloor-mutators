class MutMRWTF extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("MRLWTF.RocketLauncher");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-MRWTF"
     FriendlyName="WTF Rocket Launcher Mut"
     Description="Adds the WTF Rocket Launcher removed from WTF mod - By Mistery."
}
