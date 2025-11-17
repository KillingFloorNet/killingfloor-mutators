//=============================================================================
// DoomBFG.				Coded by .:..:
//=============================================================================
class DoomBFG extends DoomWeapon;

var() texture BeamTex[2];

simulated function RenderWeapon( Canvas C, int YPos, int XPos, Material M, float Scale )
{
	if( CurrentAnim==3 )
	{
		if( CurrentFireAnim==0 )
		{
			C.SetPos(XPos-(M.MaterialUSize()*Scale/2)+85*Scale,YPos+26*Scale);
			C.DrawIcon(BeamTex[0],Scale);
		}
		else if( CurrentFireAnim==1 )
		{
			C.SetPos(XPos-(M.MaterialUSize()*Scale/2),YPos+7*Scale);
			C.DrawIcon(BeamTex[1],Scale);
		}
	}
	C.SetPos(int(XPos-(M.MaterialUSize()*Scale/2)),YPos);
	C.DrawTile(M,int(M.MaterialUSize()*Scale),int(M.MaterialVSize()*Scale),0,1,M.MaterialUSize(),(M.MaterialVSize()-1));
}

simulated State WeaponIsFiring
{
Ignores ClientStartFire;

Begin:
	Sleep(RefiringSpeed/3*2);
	if( Level.NetMode!=NM_Client )
		FireShot();
	if( Level.NetMode==NM_Client || bUseStartEndReplic || !IsNetworkClient() )
		Sleep(RefiringSpeed/3);
	else Sleep(RefiringSpeed/3*0.9); // Just to help to make sure it dosent get off sync.
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
		{
			SetClientAnim(4);
			if( !HasTheNeededAmmo() )
				DoAutoSwitch();
			else if( Instigator!=None && Instigator.PendingWeapon != None )
				PutDown();
		}
		GoToState('');
	}
}
simulated function DoFireWeapon( bool bFirstFire )
{
	bGunIsFiring = True;
	if( Instigator.IsLocallyControlled() )
		SetClientAnim(2);
	MakeFireSound();
	if( Level.NetMode==NM_Client )
	{
		if( !bUseStartEndReplic )
			ServerFireWeapon();
		else if( bFirstFire )
			ServerBeginFireW();
	}
}

defaultproperties
{
     BeamTex(0)=Texture'DoomPawnsKF.BFG.BFGFA0'
     BeamTex(1)=Texture'DoomPawnsKF.BFG.BFGFB0'
     IdleAnimTex=Texture'DoomPawnsKF.BFG.BFGGA0'
     FireAnim(0)=Texture'DoomPawnsKF.BFG.BFGGB0'
     FireAnim(1)=Texture'DoomPawnsKF.BFG.BFGGB0'
     FireAnim(2)=Texture'DoomPawnsKF.BFG.BFGGC0'
     RefiringSpeed=1.400000
     ProjectileClass=Class'DoomPawnsKF.BFGPlasma'
     FireOffset=(X=20.000000,Z=-10.000000)
     YPosModifier=24.000000
     AmmoPerFire=40
     FireSound=Sound'DoomPawnsKF.BFG.DSBFG'
     MagCapacity=40
     HudImage=TexScaler'DoomPawnsKF.Icons.BFGIcon'
     SelectedHudImage=TexScaler'DoomPawnsKF.Icons.BFGIcon'
     Weight=7.000000
     TraderInfoTexture=Texture'DoomPawnsKF.BFG.BFUGA0'
     FireModeClass(0)=Class'DoomPawnsKF.PlasmaNullFireMode'
     AIRating=1.500000
     AmmoClass(0)=Class'DoomPawnsKF.DoomPlasmaAmmo'
     Description="BFG 9000: The 'Big Fucking Gun'. Somewhat counterintuitive to operate at first, but kills almost any monster in one shot."
     Priority=7
     HudColor=(B=100,R=100)
     CustomCrosshair=6
     CustomCrossHairColor=(G=150,R=150,A=150)
     CustomCrossHairScale=0.850000
     CustomCrossHairTextureName="Crosshairs.Hud.Crosshair_Pointer"
     InventoryGroup=4
     PickupClass=Class'DoomPawnsKF.DoomBFGPickup'
     AttachmentClass=Class'DoomPawnsKF.DBFGAttachment'
     IconMaterial=Texture'DoomPawnsKF.BFG.BFUGA0'
     IconCoords=(X2=128,Y2=64)
     ItemName="BFG9000"
}
