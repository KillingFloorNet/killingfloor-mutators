class BTrapAttachment extends KnifeAttachment;

var bool bSetMask, bFPLayed;

simulated event ThirdPersonEffects()
{
	super.ThirdPersonEffects();

	bSetMask=true;
	KFPawn(Instigator).StopAnimating();
	KFPawn(Instigator).PlayAnim('Attack1_Knife',0.5, 0.0, 1);
		
	SetTimer(0.9,false);	
}

simulated function Timer()
{
	KFPawn(Instigator).StopAnimating();
	KFPawn(Instigator).PlayAnim('Idle_Knife',, 0.0, 1);
	return;	
}

defaultproperties
{
     Mesh=SkeletalMesh'BTrap.BTrapMesh3rd'
}
