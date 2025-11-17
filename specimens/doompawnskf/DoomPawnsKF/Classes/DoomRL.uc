//=============================================================================
// DoomRL.				Coded by .:..:
//=============================================================================
class DoomRL extends DoomWeapon;

defaultproperties
{
     IdleAnimTex=Texture'DoomPawnsKF.RocketLauncher.MISGA0'
     FireAnim(0)=Texture'DoomPawnsKF.RocketLauncher.MISFA0'
     FireAnim(1)=Texture'DoomPawnsKF.RocketLauncher.MISFB0'
     FireAnim(2)=Texture'DoomPawnsKF.RocketLauncher.MISFC0'
     FireAnim(3)=Texture'DoomPawnsKF.RocketLauncher.MISFD0'
     FireAnim(4)=Texture'DoomPawnsKF.RocketLauncher.MISGA0'
     ProjectileClass=Class'DoomPawnsKF.RLRocket'
     YPosModifier=20.000000
     FireSound=Sound'DoomPawnsKF.Cyborg.DSRLAUNC'
     MagCapacity=5
     HudImage=TexScaler'DoomPawnsKF.Icons.RLIcon'
     SelectedHudImage=TexScaler'DoomPawnsKF.Icons.RLIcon'
     Weight=5.000000
     TraderInfoTexture=Texture'DoomPawnsKF.RocketLauncher.LAUNA0'
     FireModeClass(0)=Class'DoomPawnsKF.RLNullFireMode'
     AIRating=0.550000
     AmmoClass(0)=Class'DoomPawnsKF.DoomRLAmmo'
     Description="Rocket launcher: Fires explosive rockets. Does a lot of damage, but can also seriously hurt the player if used indiscriminately at close range."
     Priority=5
     HudColor=(B=150,G=150,R=250)
     CustomCrosshair=6
     CustomCrossHairColor=(B=150,G=150,R=150,A=150)
     CustomCrossHairScale=0.850000
     CustomCrossHairTextureName="Crosshairs.Hud.Crosshair_Pointer"
     InventoryGroup=4
     PickupClass=Class'DoomPawnsKF.DoomRLPickup'
     AttachmentClass=Class'DoomPawnsKF.DRLAttachment'
     IconMaterial=Texture'DoomPawnsKF.RocketLauncher.LAUNA0'
     IconCoords=(X2=64,Y2=32)
     ItemName="Rocket Launcher"
}
