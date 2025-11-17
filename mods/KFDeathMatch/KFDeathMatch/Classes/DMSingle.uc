//=============================================================================
// Tac 9mm SP only  (Dual Possible)
//=============================================================================
class DMSingle extends Single;

simulated function bool PutDown()
{
	if (  Instigator.PendingWeapon != none && Instigator.PendingWeapon.class == class'DMDualies' )
		bIsReloading = false;
	return super(KFWeapon).PutDown();
}

defaultproperties
{
     FireModeClass(0)=Class'KFDeathMatch.DMSingleFire'
     PickupClass=Class'KFDeathMatch.DMSinglePickup'
}
