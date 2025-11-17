class ScrnShotgun extends Shotgun;

defaultproperties
{
     MeshRef="KF_Weapons_Trip.Shotgun_Trip"
     SkinRefs(0)="KF_Weapons_Trip_T.Shotguns.shotgun_cmb"
     SelectSoundRef="KF_PumpSGSnd.SG_Select"
     HudImageRef="KillingFloorHUD.WeaponSelect.combat_shotgun_unselected"
     SelectedHudImageRef="KillingFloorHUD.WeaponSelect.combat_shotgun"
     FireModeClass(0)=Class'ScrnBalanceSrv.ScrnShotgunFire'
     PickupClass=Class'ScrnBalanceSrv.ScrnShotgunPickup'
     AttachmentClass=Class'ScrnBalanceSrv.ScrnShotgunAttachment'
     ItemName="Shotgun SE"
}
