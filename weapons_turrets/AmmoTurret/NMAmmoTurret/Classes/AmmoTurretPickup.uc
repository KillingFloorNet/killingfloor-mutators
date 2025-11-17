class AmmoTurretPickup extends KFWeaponPickup;

defaultproperties
{
     Weight=0.000000
     cost=1000
     AmmoCost=0
     SpeedValue=20
     RangeValue=10
     Description="An ammo supply turret."
     ItemName="Torreta de Municion"
     ItemShortName="Torreta de Municion"
     AmmoItemName="Torreta de Municion"
     CorrespondingPerkIndex=1
     EquipmentCategoryID=3
     SellValue=0
     InventoryType=Class'NMAmmoTurret.ATurret'
     PickupMessage="You got an ammo turret."
     PickupSound=Sound'KF_AA12Snd.AA12_Pickup'
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'AmmoTurret2_SM.ammocrate2smesh'
     Skins(0)=Combiner'AmmoTurret2_T.Box_cmb'
     CollisionRadius=22.000000
     CollisionHeight=23.000000
}
