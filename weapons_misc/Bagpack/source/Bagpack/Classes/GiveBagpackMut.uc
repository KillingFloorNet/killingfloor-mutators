class GiveBagpackMut extends Mutator;

function ModifyPlayer(Pawn Player)
{
	Super.ModifyPlayer(Player);
	Player.GiveWeapon("Bagpack.Bagpack");
}

defaultproperties
{
	bAddToServerPackages=True
	GroupName="KF-GiveBagpack"
	FriendlyName="GiveBagpack"
	Description="Adds bagpack"
}
