class AssaultRifleAmmoPickup extends KFAmmoPickup;

#exec OBJ LOAD FILE=AssaultRifleU_SM.usx

defaultproperties
{
     KFPickupImage=Texture'KillingFloorHUD.ClassMenu.Deagle'
     AmmoAmount=100
     InventoryType=Class'AssaultRifleUnreal2k4.AssaultRifleAmmo'
     PickupMessage="Rounds (.300 JHP)"
     PickupForce="AssaultAmmoPickup"
     DrawType=DT_StaticMesh
     StaticMesh=none
}
