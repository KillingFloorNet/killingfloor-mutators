class M4A1IronBeastSAAssaultRifle extends KFWeapon;
#exec OBJ LOAD FILE="M4A1IronBeastSA_A.ukx"
var() 		name 			ReloadShortAnim;
var() 		float 			ReloadShortRate;

simulated function AltFire(float F)
{
    if(ReadyToFire(0))
    {
        DoToggle();
    }
}
simulated function DoToggle ()
{
	local PlayerController Player;
	Player = Level.GetLocalPlayerController();
	if( IsFiring() )
	{
	   return;
	}
	if ( Player!=None )
	{
		FireMode[0].bWaitForRelease = !FireMode[0].bWaitForRelease;
		if ( FireMode[0].bWaitForRelease )
			Player.ReceiveLocalizedMessage(class'KFmod.BullpupSwitchMessage',0);
		else Player.ReceiveLocalizedMessage(class'KFmod.BullpupSwitchMessage',1);
	}
	PlayOwnedSound(ToggleSound,SLOT_None,2.0,,,,false);
	ServerChangeFireMode(FireMode[0].bWaitForRelease);
}
function ServerChangeFireMode(bool bNewWaitForRelease)
{
    FireMode[0].bWaitForRelease = bNewWaitForRelease;
}
function bool RecommendRangedAttack()
{
	return true;
}
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

exec function ReloadMeNow()
{
	local float ReloadMulti;
	if(!AllowReload())
		return;
	if ( bHasAimingMode && bAimingRifle )
	{
		FireMode[1].bIsFiring = False;

		ZoomOut(false);
		if( Role < ROLE_Authority)
			ServerZoomOut(false);
	}
	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
	}
	else
	{
		ReloadMulti = 1.0;
	}
	bIsReloading = true;
	ReloadTimer = Level.TimeSeconds;
	if (MagAmmoRemaining <= 0)
	{
		ReloadRate = Default.ReloadRate / ReloadMulti;
	}
	else if (MagAmmoRemaining >= 1)
	{
		ReloadRate = Default.ReloadShortRate / ReloadMulti;
	}
	if( bHoldToReload )
	{
		NumLoadedThisReload = 0;
	}
	ClientReload();
	Instigator.SetAnimAction(WeaponReloadAnim);
	if ( Level.Game.NumPlayers > 1 && KFGameType(Level.Game).bWaveInProgress && KFPlayerController(Instigator.Controller) != none &&
		Level.TimeSeconds - KFPlayerController(Instigator.Controller).LastReloadMessageTime > KFPlayerController(Instigator.Controller).ReloadMessageDelay )
	{
		KFPlayerController(Instigator.Controller).Speech('AUTO', 2, "");
		KFPlayerController(Instigator.Controller).LastReloadMessageTime = Level.TimeSeconds;
	}
}

simulated function ClientReload()
{
	local float ReloadMulti;
	if ( bHasAimingMode && bAimingRifle )
	{
		FireMode[1].bIsFiring = False;

		ZoomOut(false);
		if( Role < ROLE_Authority)
			ServerZoomOut(false);
	}
	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
	}
	else
	{
		ReloadMulti = 1.0;
	}
	bIsReloading = true;
	if (MagAmmoRemaining <= 0)
	{
		PlayAnim(ReloadAnim, ReloadAnimRate*ReloadMulti, 0.1);
	}
	else if (MagAmmoRemaining >= 1)
	{
		PlayAnim(ReloadShortAnim, ReloadAnimRate*ReloadMulti, 0.1);
	}
}

defaultproperties
{
	FlashBoneName="tip"
	MagCapacity=30
	ReloadRate=4.130000
	ReloadAnim="Reload_EmptySA"
	ReloadShortAnim="ReloadSA"
	ReloadShortRate=2.680000
	ReloadAnimRate=1.00000
	WeaponReloadAnim="Reload_M4"
	Weight=5.000000
	bHasAimingMode=True
	IdleAimAnim="Idle"
	StandardDisplayFOV=75.000000
	bModeZeroCanDryFire=True
	TraderInfoTexture=Texture'M4A1IronBeastSA_A.M4A1Iron_Tex.M4A1Trader'
	SleeveNum=0
	bIsTier2Weapon=True
	Mesh=SkeletalMesh'M4A1IronBeastSA_A.M4A1SA_Mesh'
	Skins(0)=Combiner'KF_Weapons_Trip_T.hands.hands_1stP_military_cmb'
	Skins(1)=Shader'M4A1IronBeastSA_A.M4A1Iron_Tex.M4A1Body_Cmb'
	BringUpTime=1.0
	SelectSound=Sound'M4A1IronBeastSA_A.M4A1Iron_SND.M4A1Select'
	HudImage=Texture'M4A1IronBeastSA_A.M4A1Iron_Tex.M4A1Unselect'
	SelectedHudImage=Texture'M4A1IronBeastSA_A.M4A1Iron_Tex.M4A1Select'
	PlayerIronSightFOV=65.000000
	ZoomedDisplayFOV=32.000000
	FireModeClass(0)=Class'M4A1IronBeastSAMut.M4A1IronBeastSAFire'
	FireModeClass(1)=Class'KFMod.NoFire'
	PutDownAnim="Put_Down"
	SelectForce="SwitchToAssaultRifle"
	AIRating=0.550000
	CurrentRating=0.550000
	bShowChargingBar=True
	Description="M4A1 IronBeast From CrossFire."
	EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
	DisplayFOV=75.000000
	Priority=145
	CustomCrosshair=11
	CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
	InventoryGroup=3
	GroupOffset=7
	PickupClass=Class'M4A1IronBeastSAMut.M4A1IronBeastSAPickup'
	PlayerViewOffset=(X=-3.000000,Y=16.000000,Z=-4.000000)
	BobDamping=6.000000
	AttachmentClass=Class'M4A1IronBeastSAMut.M4A1IronBeastSAAttachment'
	IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
	ItemName="M4A1 IronBeast"
	TransientSoundVolume=1.250000
}