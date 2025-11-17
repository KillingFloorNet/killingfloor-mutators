class MutSVT40SA extends Mutator;

function ModifyPlayer(Pawn Player)
{
     Super.ModifyPlayer(Player);
     Player.GiveWeapon("SVT40SAMut.SVT40SABattleRifle");
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-SVT40"
     FriendlyName="SVT40 Mutator"
     Description="Adds the SVT40."
}
