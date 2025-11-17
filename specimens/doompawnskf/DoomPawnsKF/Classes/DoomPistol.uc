//=============================================================================
// DoomPistol.				Coded by .:..:
//=============================================================================
class DoomPistol extends DoomWeapon;

#exec obj load file=DoomWeps.utx package=DoomPawnsKF

defaultproperties
{
     IdleAnimTex=Texture'DoomPawnsKF.pistol.PISGA0'
     FireAnim(0)=Texture'DoomPawnsKF.pistol.PISGB0'
     FireAnim(1)=Texture'DoomPawnsKF.pistol.PISGC0'
     FireAnim(2)=Texture'DoomPawnsKF.pistol.PISGD0'
     RefiringSpeed=0.400000
     InstaHitDamage=(Min=5,Max=15)
     bUseInstantHit=True
     FireSound=Sound'DoomPawnsKF.Marine.DSPISTOL'
     MagCapacity=40
     HudImage=TexScaler'DoomPawnsKF.Icons.PistolIcon'
     SelectedHudImage=TexScaler'DoomPawnsKF.Icons.PistolIcon'
     TraderInfoTexture=Texture'DoomPawnsKF.pistol.PISGF0'
     FireModeClass(0)=Class'DoomPawnsKF.PistolNullFireMode'
     AIRating=0.250000
     AmmoClass(0)=Class'DoomPawnsKF.DoomPistolAmmo'
     Description="Pistol: The default long-range weapon. Not too effective."
     Priority=2
     HudColor=(B=255,G=150,R=150)
     CustomCrosshair=6
     CustomCrossHairColor=(B=121,G=188)
     CustomCrossHairTextureName="Crosshairs.Hud.Crosshair_Pointer"
     InventoryGroup=2
     PickupClass=Class'DoomPawnsKF.DoomPistolPickup'
     AttachmentClass=Class'DoomPawnsKF.DPistolAttachment'
     IconMaterial=Texture'DoomPawnsKF.pistol.PISGF0'
     IconCoords=(X2=64,Y2=32)
     ItemName="Pistol"
     DrawScale3D=(Y=2.000000)
}
