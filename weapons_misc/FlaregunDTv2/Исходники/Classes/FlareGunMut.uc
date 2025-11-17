class FlareGunMut extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("FlaregunDTv2.FlareGun");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-FlaregunDTv2"
     FriendlyName="FlaregunDTv2 Mutator"
     Description="Adds the FlaregunDTv2."
}
