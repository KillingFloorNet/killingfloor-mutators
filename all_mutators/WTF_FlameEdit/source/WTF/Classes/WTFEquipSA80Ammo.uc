//=============================================================================
// L85 Ammo.
//=============================================================================
class WTFEquipSA80Ammo extends KFAmmunition;

#EXEC OBJ LOAD FILE=KillingFloorHUD.utx

defaultproperties
{
     MaxAmmo=50
     InitialAmount=50
     PickupClass=Class'WTFEquipSA80AmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=336,Y1=82,X2=382,Y2=125)
     ItemName="SA80 bullets"
}
