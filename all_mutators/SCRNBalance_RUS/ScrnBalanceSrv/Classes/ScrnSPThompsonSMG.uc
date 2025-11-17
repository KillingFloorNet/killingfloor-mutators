class ScrnSPThompsonSMG extends SPThompsonSMG
	config(user);

simulated function AltFire(float F) 
{
	// disable semi-auto mode
}

defaultproperties
{
     ReloadRate=3.304348
     ReloadAnimRate=1.150000
     FireModeClass(0)=Class'ScrnBalanceSrv.ScrnSPThompsonFire'
     PickupClass=Class'ScrnBalanceSrv.ScrnSPThompsonPickup'
     AttachmentClass=Class'ScrnBalanceSrv.ScrnSPThompsonAttachment'
     ItemName="Dr. T's Lead Delivery System SE"
}
