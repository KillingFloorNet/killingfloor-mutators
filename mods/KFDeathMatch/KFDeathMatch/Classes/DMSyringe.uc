//=============================================================================
// Syringe Inventory class
//=============================================================================
class DMSyringe extends Syringe;

simulated function PostBeginPlay()
{
	Super(KFWeapon).PostBeginPlay(); // No additional health boost.
}

defaultproperties
{
     FireModeClass(0)=Class'KFDeathMatch.DMSyringeFire'
     PickupClass=Class'KFDeathMatch.DMSyringePickup'
}
