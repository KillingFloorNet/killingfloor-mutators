//=============================================================================
// SG550 By Secret_Agent[AZE]
// Операция ы
//=============================================================================
class EVOproSAAssaultRifle extends KFWeapon
	config(user);

#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=KillingFloorHUD.utx
#exec OBJ LOAD FILE=Inf_Weapons_Foley.uax
#exec OBJ LOAD FILE=EVOproSA_A.ukx

// Use alt fire to switch fire modes
simulated function AltFire(float F)
{
    if(ReadyToFire(0))
    {
        DoToggle();
    }
}

function bool RecommendRangedAttack()
{
	return true;
}

//TODO: LONG ranged?
function bool RecommendLongRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}

exec function SwitchModes()
{
	DoToggle();
}

function float GetAIRating()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	return AIRating;
}

function byte BestMode()
{
	return 0;
}

simulated function SetZoomBlendColor(Canvas c)
{
	local Byte    val;
	local Color   clr;
	local Color   fog;

	clr.R = 255;
	clr.G = 255;
	clr.B = 255;
	clr.A = 255;

	if( Instigator.Region.Zone.bDistanceFog )
	{
		fog = Instigator.Region.Zone.DistanceFogColor;
		val = 0;
		val = Max( val, fog.R);
		val = Max( val, fog.G);
		val = Max( val, fog.B);
		if( val > 128 )
		{
			val -= 128;
			clr.R -= val;
			clr.G -= val;
			clr.B -= val;
		}
	}
	c.DrawColor = clr;
}

defaultproperties
{
     MagCapacity=50
     ReloadRate=3.380000
     ReloadAnim="Reload"
     ReloadAnimRate=1.000000
     WeaponReloadAnim="Reload_Bullpup"
     Weight=3.000000
     bHasAimingMode=True
     IdleAimAnim="Idle"
     StandardDisplayFOV=57.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'EVOproSA_A.Protex.EvoProTrader'
     bIsTier2Weapon=True
     Mesh=SkeletalMesh'EVOproSA_A.EVOproSA_Mesh'
     Skins(0)=Combiner'EvoProSA_A.ProTex.EvoProCol_cmb'
	 Skins(1)=Combiner'EvoProSA_A.ProTex.EvoProScope_cmb'
	 Skins(2)=Texture'EvoProSA_A.ProTex.EvoProScreen'
	 Skins(3)=Texture'EvoProSA_A.ProTex.EvoProScopeAdd'
	 Skins(4)=Combiner'KF_Weapons_Trip_T.hands.hands_1stP_military_cmb'
	 SleeveNum=4
	 SelectSound=Sound'EvoProSA_A.PROSND.EvoProSelect'
     HudImage=Texture'EvoProSA_A.Protex.EvoProUnselect'
     SelectedHudImage=Texture'EvoProSA_A.Protex.EvoProSelect'
     PlayerIronSightFOV=65.000000
     ZoomedDisplayFOV=32.000000
     FireModeClass(0)=Class'EvoProSAMut.EvoProSAFire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="Put_Down"
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.550000
     CurrentRating=0.550000
     bShowChargingBar=True
     Description="EvoPro From CoD Ghosts. "
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=57.000000
     Priority=95
     CustomCrosshair=11
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
     InventoryGroup=3
     GroupOffset=7
     PickupClass=Class'EvoProSAMut.EvoProSAPickup'
     PlayerViewOffset=(X=9.000000,Y=9.000000,Z=-1.000000)
     BobDamping=6.000000
     AttachmentClass=Class'EvoProSAMut.EvoProSAAttachment'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="EVOPRO-A2 INDUSTRIES"
     TransientSoundVolume=1.250000
}
