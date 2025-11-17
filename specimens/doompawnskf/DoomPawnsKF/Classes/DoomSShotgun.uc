//=============================================================================
// DoomSShotgun.				Coded by .:..:
//=============================================================================
class DoomSShotgun extends DoomShotgun;

var() Sound LoadingSounds[3];
var byte ClickSoundNum;
var float NextClickTime;

simulated function RenderWeapon( Canvas C, int YPos, int XPos, Material M, float Scale )
{
	Super(DoomWeapon).RenderWeapon(C,YPos,XPos,M,Scale);
}
simulated State WeaponIsFiring
{
Ignores ClientStartFire;

	simulated function BeginState()
	{
		Super.BeginState();
		ClickSoundNum = 0;
		NextClickTime = Level.TimeSeconds+(RefiringSpeed/3);
	}
	simulated event WeaponTick(float dt)
	{
		Global.WeaponTick(dt);
		if( ClickSoundNum<3 && NextClickTime<Level.TimeSeconds )
		{
			Instigator.PlayOwnedSound(LoadingSounds[ClickSoundNum],SLOT_Misc,TransientSoundVolume,,TransientSoundRadius,GetSoundPitch());
			ClickSoundNum++;
			NextClickTime = Level.TimeSeconds+(RefiringSpeed/4.75);
		}
	}
}

defaultproperties
{
     LoadingSounds(0)=Sound'DoomPawnsKF.SShotgun.DSDBOPN'
     LoadingSounds(1)=Sound'DoomPawnsKF.SShotgun.DSDBLOAD'
     LoadingSounds(2)=Sound'DoomPawnsKF.SShotgun.DSDBCLS'
     IdleAnimTex=Texture'DoomPawnsKF.SShotgun.SHT2A0'
     FireAnim(0)=Texture'DoomPawnsKF.SShotgun.SHT2J0'
     FireAnim(1)=Texture'DoomPawnsKF.SShotgun.SHT2I0'
     FireAnim(2)=Texture'DoomPawnsKF.SShotgun.SHT2B0'
     FireAnim(3)=Texture'DoomPawnsKF.SShotgun.SHT2C0'
     FireAnim(4)=Texture'DoomPawnsKF.SShotgun.SHT2D0'
     FireAnim(5)=Texture'DoomPawnsKF.SShotgun.SHT2E0'
     FireAnim(6)=Texture'DoomPawnsKF.SShotgun.SHT2F0'
     FireAnim(7)=Texture'DoomPawnsKF.SShotgun.SHT2D0'
     FireAnim(8)=Texture'DoomPawnsKF.SShotgun.SHT2C0'
     RefiringSpeed=1.750000
     NumShotsPerFire=(Min=18,Max=24)
     Spreading(0)=2200.000000
     Spreading(1)=900.000000
     AmmoPerFire=2
     FireSound=Sound'DoomPawnsKF.SShotgun.DSDSHTGN'
     HudImage=TexScaler'DoomPawnsKF.Icons.SShotgunIcon'
     SelectedHudImage=TexScaler'DoomPawnsKF.Icons.SShotgunIcon'
     Weight=4.000000
     TraderInfoTexture=Texture'DoomPawnsKF.SShotgun.SGN2A0'
     AIRating=0.850000
     Description="Super Shotgun: A double-barrelled, sawed-off shotgun which takes even longer to reload, but at close range is even more deadly than the regular shotgun."
     Priority=4
     CustomCrossHairColor=(B=128,G=255,R=255,A=200)
     PickupClass=Class'DoomPawnsKF.DoomSShotgunPickup'
     AttachmentClass=Class'DoomPawnsKF.DSShotGAttachment'
     IconMaterial=Texture'DoomPawnsKF.SShotgun.SGN2A0'
     ItemName="Super Shotgun"
}
