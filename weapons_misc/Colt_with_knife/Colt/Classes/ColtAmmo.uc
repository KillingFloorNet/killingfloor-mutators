//=============================================================================
// Deagle Ammo.
//=============================================================================
class ColtAmmo extends KFAmmunition;

#EXEC OBJ LOAD FILE=InterfaceContent.utx

defaultproperties
{
     MaxAmmo=84
     InitialAmount=28
     AmmoPickupAmount=14
     PickupClass=Class'Colt.ColtAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=338,Y1=40,X2=393,Y2=79)
     ItemName="Colt bullets"
}
