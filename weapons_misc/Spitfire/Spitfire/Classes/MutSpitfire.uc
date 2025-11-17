class MutSpitfire extends Mutator
	hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

function ModifyPlayer(Pawn Player)
{
	super.ModifyPlayer(Player);
	Player.GiveWeapon("Spitfire.Spitfire");
}

defaultproperties
{
	bAddToServerPackages=true
	GroupName="KF-MutSpitfire"
	FriendlyName="Spitfire Mutator"
	Description="Makin' Bacon"
}