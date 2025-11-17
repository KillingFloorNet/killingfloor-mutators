//=============================================================================
// DoomChaingun.				Coded by .:..:
//=============================================================================
class DoomChaingun extends DoomWeapon;

defaultproperties
{
     bUseStartEndReplic=True
     IdleAnimTex=Texture'DoomPawnsKF.Chaingun.CHGGA0'
     FireAnim(0)=Texture'DoomPawnsKF.Chaingun.CHGGB0'
     FireAnim(1)=Texture'DoomPawnsKF.Chaingun.CHGGC0'
     RefiringSpeed=0.125000
     InstaHitDamage=(Min=5,Max=15)
     bUseInstantHit=True
     Spreading(0)=500.000000
     Spreading(1)=500.000000
     YPosModifier=24.000000
     FireSound=Sound'DoomPawnsKF.Marine.DSPISTOL'
     MagCapacity=40
     HudImage=TexScaler'DoomPawnsKF.Icons.ChaingunIcon'
     SelectedHudImage=TexScaler'DoomPawnsKF.Icons.ChaingunIcon'
     Weight=3.000000
     TraderInfoTexture=Texture'DoomPawnsKF.Chaingun.MGUNA0'
     FireModeClass(0)=Class'DoomPawnsKF.PistolNullFireMode'
     AIRating=0.350000
     AmmoClass(0)=Class'DoomPawnsKF.DoomPistolAmmo'
     Description="Chaingun: Very good against large crowds, but uses up a lot of ammo if not handled carefully."
     Priority=4
     HudColor=(B=255,G=150,R=150)
     CustomCrosshair=6
     CustomCrossHairColor=(B=150,G=150,R=150,A=150)
     CustomCrossHairScale=0.850000
     CustomCrossHairTextureName="Crosshairs.Hud.Crosshair_Pointer"
     InventoryGroup=3
     PickupClass=Class'DoomPawnsKF.DoomChaingunPickup'
     AttachmentClass=Class'DoomPawnsKF.DChainGAttachment'
     IconMaterial=Texture'DoomPawnsKF.Chaingun.MGUNA0'
     IconCoords=(X2=64,Y2=32)
     ItemName="Chaingun"
}
