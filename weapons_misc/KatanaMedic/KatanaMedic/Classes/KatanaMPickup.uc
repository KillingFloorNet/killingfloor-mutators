//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KatanaMPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=2.000000
     cost=1000
     PowerValue=1
     SpeedValue=30
     RangeValue=-21
     Description="An incredibly katana Medic."
     ItemName="Katana Medic"
     ItemShortName="Katana Medic"
     InventoryType=Class'KatanaMedic.KatanaM'
     PickupMessage="You got the Katana Medic."
     PickupSound=Sound'KF_AxeSnd.Axe_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_pickups_Trip.melee.Katana_pickup'
     Skins(0)=Shader'KatanaMedicT.KatanaMedic_Cmb'
     CollisionRadius=27.000000
     CollisionHeight=5.000000
}
