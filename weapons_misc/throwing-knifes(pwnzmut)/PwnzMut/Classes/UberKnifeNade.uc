class UberKnifeNade extends Nade;

simulated function Explode(vector HitLocation, vector HitNormal)
{
	bHasExploded = True;
	Destroy();
}

defaultproperties
{
	StaticMesh=StaticMesh'KF_pickups_Trip.Knife_pickup'
	ImpactSound=Sound'KF_KnifeSnd.Knife_HitFlesh'
	DrawScale=1.0
}
