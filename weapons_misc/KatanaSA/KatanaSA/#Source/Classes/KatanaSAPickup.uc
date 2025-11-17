//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KatanaSAPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=3.000000
     PowerValue=60
     SpeedValue=60
     RangeValue=-21
     Description="An incredibly sharp katana sword."
     ItemName="Katana SA"
     ItemShortName="KatanaSA"
     CorrespondingPerkIndex=4
     InventoryType=Class'KatanaSA.KatanaSA'
     PickupMessage="You got the KatanaSA."
     PickupSound=Sound'KF_AxeSnd.Axe_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KatanaSA_A.Katana_Static.KatanaSA_Pickup'
     CollisionRadius=27.000000
     CollisionHeight=5.000000
}
