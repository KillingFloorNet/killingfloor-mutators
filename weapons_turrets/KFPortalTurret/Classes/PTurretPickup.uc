//=============================================================================
// PTurretPickup.
//=============================================================================
class PTurretPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=1.000000
     cost=3000
     AmmoCost=3000
     BuyClipSize=1
     PowerValue=100
     SpeedValue=10
     RangeValue=25
     Description="A turret made by the Aperture Science."
     ItemName="Sentry Turret"
     ItemShortName="Sentry Turret"
     AmmoItemName="Sentry Turret"
     CorrespondingPerkIndex=3
     EquipmentCategoryID=3
     InventoryType=Class'KFPortalTurret.PTurret'
     PickupMessage="You got a Sentry bot."
     PickupSound=Sound'KF_AA12Snd.AA12_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KFPortalTurret.pickups.PTurretMesh'
     Skins(0)=Texture'KFPortalTurret.Skins.Turret_01_inactive'
     CollisionRadius=22.000000
     CollisionHeight=23.000000
}
