class PuppetKnifeRandom extends PuppetKnife;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	Velocity = Speed * VRand();
	if( PhysicsVolume.bWaterVolume )
		Velocity*=0.65;
}

defaultproperties
{
}
