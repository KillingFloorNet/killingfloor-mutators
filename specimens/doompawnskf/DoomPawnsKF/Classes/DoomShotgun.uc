//=============================================================================
// DoomShotgun.				Coded by .:..:
//=============================================================================
class DoomShotgun extends DoomWeapon;

simulated function RenderWeapon( Canvas C, int YPos, int XPos, Material M, float Scale )
{
	local float Pos;

	Pos = 0.5;
	if( CurrentAnim==3 )
	{
		if( CurrentFireAnim<2 )
		{
			C.SetPos(XPos-(M.MaterialUSize()*Scale/2)+30*Scale,YPos-10*Scale);
			if( CurrentFireAnim==0 )
				C.DrawIcon(Texture'SHTFA0',Scale);
			else
			{
				C.CurY-=29*Scale;
				C.CurX+=Scale;
				C.DrawIcon(Texture'SHTFB0',Scale);
			}
		}
		else if( CurrentFireAnim==2 || CurrentFireAnim==6 )
			Pos = 0.7;
		else Pos = 1;
	}
	C.SetPos(int(XPos-(M.MaterialUSize()*Scale*Pos)),YPos);
	C.DrawTile(M,int(M.MaterialUSize()*Scale),int(M.MaterialVSize()*Scale),0,1,M.MaterialUSize(),(M.MaterialVSize()-1));
}

defaultproperties
{
     IdleAnimTex=Texture'DoomPawnsKF.Shotgun.SHTGA0'
     FireAnim(0)=Texture'DoomPawnsKF.Shotgun.SHTGA0'
     FireAnim(1)=Texture'DoomPawnsKF.Shotgun.SHTGA0'
     FireAnim(2)=Texture'DoomPawnsKF.Shotgun.SHTGB0'
     FireAnim(3)=Texture'DoomPawnsKF.Shotgun.SHTGC0'
     FireAnim(4)=Texture'DoomPawnsKF.Shotgun.SHTGD0'
     FireAnim(5)=Texture'DoomPawnsKF.Shotgun.SHTGC0'
     FireAnim(6)=Texture'DoomPawnsKF.Shotgun.SHTGB0'
     RefiringSpeed=1.000000
     InstaHitDamage=(Min=5,Max=15)
     NumShotsPerFire=(Min=5,Max=10)
     bUseInstantHit=True
     Spreading(0)=1200.000000
     Spreading(1)=500.000000
     FireSound=Sound'DoomPawnsKF.ChaingunBob.BobChaingun'
     MagCapacity=10
     HudImage=TexScaler'DoomPawnsKF.Icons.ShotgunIcon'
     SelectedHudImage=TexScaler'DoomPawnsKF.Icons.ShotgunIcon'
     Weight=2.000000
     TraderInfoTexture=Texture'DoomPawnsKF.Shotgun.SHOTA0'
     FireModeClass(0)=Class'DoomPawnsKF.ShotgunNullFireMode'
     AIRating=0.450000
     AmmoClass(0)=Class'DoomPawnsKF.DoomShotgunAmmo'
     Description="Shotgun: A good general-purpose weapon, especially at close range. Reload time is slightly longer than normal."
     Priority=3
     HudColor=(B=100)
     CustomCrosshair=10
     CustomCrossHairColor=(G=128,R=128)
     CustomCrossHairScale=0.500000
     CustomCrossHairTextureName="Crosshairs.Hud.Crosshair_Bracket1"
     InventoryGroup=3
     PickupClass=Class'DoomPawnsKF.DoomShotgunPickup'
     AttachmentClass=Class'DoomPawnsKF.DShotGAttachment'
     IconMaterial=Texture'DoomPawnsKF.Shotgun.SHOTA0'
     IconCoords=(X2=64,Y2=32)
     ItemName="Shotgun"
}
