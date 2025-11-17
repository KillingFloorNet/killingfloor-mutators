//=============================================================================
// DoomShotgunAmmoPickup.
//=============================================================================
class DoomShotgunAmmoPickup extends DoomAmmoPickups;

defaultproperties
{
     AmmoAmount=4
     MaxDesireability=0.150000
     InventoryType=Class'DoomPawnsKF.DoomShotgunAmmo'
     PickupMessage="You picked up some shotgun shells."
     PickupForce="ShotgunAmmoPickup"
     Texture=Texture'DoomPawnsKF.Shotgun.SHELA0'
     DrawScale3D=(Y=0.500000)
     CollisionRadius=10.000000
}
