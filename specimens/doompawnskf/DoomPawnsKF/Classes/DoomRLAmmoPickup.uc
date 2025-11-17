//=============================================================================
// DoomRLAmmoPickup.
//=============================================================================
class DoomRLAmmoPickup extends DoomAmmoPickups;

defaultproperties
{
     AmmoAmount=1
     MaxDesireability=0.050000
     InventoryType=Class'DoomPawnsKF.DoomRLAmmo'
     PickupMessage="You picked up a rocket round."
     PickupForce="RocketAmmoPickup"
     Texture=Texture'DoomPawnsKF.RocketLauncher.ROCKA0'
     DrawScale=0.600000
     DrawScale3D=(Y=2.000000)
     CollisionRadius=3.000000
}
