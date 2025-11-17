class SentryBotGunAttachment extends PipeBombAttachment;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	TweenAnim('Folded',0.01f);
}

defaultproperties
{
	Mesh=SkeletalMesh'SentryBot_A.SentryMesh'
}
