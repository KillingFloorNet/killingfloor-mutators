//=============================================================================
// Thompson DrumMag Ammo.
//=============================================================================
class ScrnThompsonDrumAmmo extends ThompsonDrumAmmo;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

defaultproperties
{
     MaxAmmo=500
     InitialAmount=200
     PickupClass=Class'ScrnBalanceSrv.ScrnThompsonDrumAmmoPickup'
}
