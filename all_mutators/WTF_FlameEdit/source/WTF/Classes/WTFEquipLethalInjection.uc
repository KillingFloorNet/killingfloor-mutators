class WTFEquipLethalInjection extends KFMeleeGun;



defaultproperties
{
     weaponRange=90.000000
     HudImage=Texture'KillingFloorHUD.WeaponSelect.syring_unselected'
     SelectedHudImage=Texture'KillingFloorHUD.WeaponSelect.Syringe'
     Weight=1.000000
     bConsumesPhysicalAmmo=False
     StandardDisplayFOV=85.000000
     FireModeClass(0)=Class'WTFEquipLethalInjectionFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     AIRating=-2.000000
     AmmoCharge(0)=500
     AmmoClass(0)=Class'WTFEquipLethalInjectionAmmo'
     Description="A deadly weapon"
     DisplayFOV=85.000000
     Priority=6
     GroupOffset=4
     PickupClass=Class'WTFEquipLethalInjectionPickup'
     BobDamping=8.000000
     AttachmentClass=Class'WTFEquipLethalInjectionAttachment'
     IconCoords=(X1=169,Y1=39,X2=241,Y2=77)
     ItemName="Lethal Injection"
     Mesh=SkeletalMesh'KF_Weapons_Trip.Syringe_Trip'
     Skins(0)=Texture'WTF_A.Lethalinjection.Lethalinjection'
     AmbientGlow=2
}
