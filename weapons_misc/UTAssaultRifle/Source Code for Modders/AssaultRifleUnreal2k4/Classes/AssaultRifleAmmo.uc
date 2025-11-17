class AssaultRifleAmmo extends KFAmmunition;

#EXEC OBJ LOAD FILE=InterfaceContent.utx

defaultproperties
{
     MaxAmmo=600
     InitialAmount=200
     AmmoPickupAmount=100
     PickupClass=Class'AssaultRifleUnreal2k4.AssaultRifleAmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=338,Y1=40,X2=393,Y2=79)
     ItemName="Assault Rifle bullets"
}
