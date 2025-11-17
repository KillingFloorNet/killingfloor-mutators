class MutBrowning extends Mutator
	hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

function ModifyPlayer(Pawn Player)
{
	super.ModifyPlayer(Player);
	Player.GiveWeapon("Browning.Browning");
}

defaultproperties
{
	bAddToServerPackages=true
	GroupName="KF-MutBrowning"
	FriendlyName="Browning Mutator"
	Description="You start the game with a Browning "
}