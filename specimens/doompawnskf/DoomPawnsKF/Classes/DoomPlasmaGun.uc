//=============================================================================
// DoomPlasmaGun.				Coded by .:..:
//=============================================================================
class DoomPlasmaGun extends DoomWeapon;

var() Material RechargingTex;

simulated function RenderWeapon( Canvas C, int YPos, int XPos, Material M, float Scale )
{
	local float Pos;

	if( CurrentAnim==5 )
		Pos = 0.7;
	else Pos = 0.5;
	C.SetPos(int(XPos-(M.MaterialUSize()*Scale*Pos)),YPos);
	C.DrawTile(M,int(M.MaterialUSize()*Scale),int(M.MaterialVSize()*Scale),0,1,M.MaterialUSize(),(M.MaterialVSize()-1));
}
simulated function Material GetCurrentAnimTex()
{
	if( CurrentAnim==5 )
		Return RechargingTex;
	else if( CurrentAnim!=3 )
		Return IdleAnimTex;
	Return FireAnim[CurrentFireAnim];
}
simulated function SetClientAnim( float Num )
{
	AnimTime = Level.TimeSeconds;
	CurrentAnim = Num+1;
	bDoCalculateSwing = (Num==1);
}
simulated State WeaponIsFiring
{
Ignores ClientStartFire;

Begin:
	Sleep(RefiringSpeed);
	if( KeepFiring() )
	{
		DoFireWeapon(False);
		BeginState(); // To reset firing animation.
		GoTo'Begin';
	}
	else
	{
		bGunIsFiring = False;
		if( Instigator.IsLocallyControlled() )
			SetClientAnim(4);
		if( Level.NetMode==NM_Client && bUseStartEndReplic )
			ServerEndFireW();
		if( Level.NetMode==NM_Client || !IsNetworkClient() )
			Sleep(RefiringSpeed*7); // Dont recharge on serverside, on network client to avoid it from going off sync.
		if( Instigator.IsLocallyControlled() )
		{
			SetClientAnim(1);
			if( !HasTheNeededAmmo() )
				DoAutoSwitch();
			else if( Instigator!=None && Instigator.PendingWeapon != None )
				PutDown();
		}
		GoToState('');
	}
}

defaultproperties
{
     RechargingTex=Texture'DoomPawnsKF.PlasmaGun.PLSGB0'
     bUseStartEndReplic=True
     IdleAnimTex=Texture'DoomPawnsKF.PlasmaGun.PLSGA0'
     FireAnim(0)=Texture'DoomPawnsKF.PlasmaGun.PLSFA0'
     FireAnim(1)=Texture'DoomPawnsKF.PlasmaGun.PLSFB0'
     RefiringSpeed=0.075000
     ProjectileClass=Class'DoomPawnsKF.PGPlasma'
     FireOffset=(X=20.000000,Z=-10.000000)
     FireSound=Sound'DoomPawnsKF.Spider.DSPLASMA'
     MagCapacity=40
     HudImage=TexScaler'DoomPawnsKF.Icons.PlasmaGunIcon'
     SelectedHudImage=TexScaler'DoomPawnsKF.Icons.PlasmaGunIcon'
     Weight=4.000000
     TraderInfoTexture=Texture'DoomPawnsKF.PlasmaGun.PLASA0'
     FireModeClass(0)=Class'DoomPawnsKF.PlasmaNullFireMode'
     AIRating=0.570000
     AmmoClass(0)=Class'DoomPawnsKF.DoomPlasmaAmmo'
     Description="Plasma gun: Shoots pulses of blue-hot plasma at high speed, which can take down groups of incoming enemies easily — if aimed properly."
     Priority=6
     HudColor=(B=255,G=100,R=100)
     CustomCrosshair=6
     CustomCrossHairColor=(G=150,R=150,A=150)
     CustomCrossHairScale=0.850000
     CustomCrossHairTextureName="Crosshairs.Hud.Crosshair_Pointer"
     InventoryGroup=4
     PickupClass=Class'DoomPawnsKF.DoomPlasmaPickup'
     AttachmentClass=Class'DoomPawnsKF.DPlasmaAttachment'
     IconMaterial=Texture'DoomPawnsKF.PlasmaGun.PLASA0'
     IconCoords=(X2=64,Y2=32)
     ItemName="Plasma Gun"
}
