class ScrnThompsonDrum extends ThompsonDrumSMG
	config(user);

simulated function AltFire(float F) 
{
	// disable semi-auto mode
}	
	

defaultproperties
{
     ReloadRate=3.304348
     ReloadAnimRate=1.150000
     Weight=6.000000
     FireModeClass(0)=Class'ScrnBalanceSrv.ScrnThompsonDrumFire'
     PickupClass=Class'ScrnBalanceSrv.ScrnThompsonDrumPickup'
     AttachmentClass=Class'ScrnBalanceSrv.ScrnThompsonDrumAttachment'
     ItemName="RS Tommy Gun SE"
}
