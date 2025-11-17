//=============================================================================
// Deagle Inventory class
//=============================================================================
class DMDeagle extends Deagle;

simulated function bool PutDown()
{
	if ( Instigator.PendingWeapon.class == class'DMDualDeagle' )
		bIsReloading = false;
	return super(KFWeapon).PutDown();
}

defaultproperties
{
     FireModeClass(0)=Class'KFDeathMatch.DMDeagleFire'
     PickupClass=Class'KFDeathMatch.DMDeaglePickup'
}
