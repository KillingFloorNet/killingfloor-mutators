//=============================================================================
// WMediShot Inventory class
//=============================================================================
class WeldShot extends KFWeaponShotgun;
//////////////////////
#exec OBJ LOAD FILE=KF_Weapons_Trip_T.utx
var () float AmmoRegenRate;
var float AmmoRegenCount;
// Scripted Nametag vars
var ScriptedTexture  ScriptedScreen;
var Shader ShadedScreen;
var Material   ScriptedScreenBack;
//Font/Color/stuff
var Font NameFont;
var font SmallNameFont;                           // Used when the name is to big too fit
var color NameColor;                                // Colors
var Color BackColor;
var float ScreenWeldPercent;
var bool bNoTarget;  // Not close enough to door to get reading
var int FireModeArray;

// Speech
var	bool	bJustStarted;
var	float	LastWeldingMessageTime;
var	float	WeldingMessageDelay;


//////////////////////
var ()      float       AmmoRegenRate3;  // How quickly the healing charge regenerates
var ()      int         HealBoostAmount3;// How much we heal a player by default with the heal dart
Const MaxAmmoCount=500;                 // Maximum healing charge count
var         float       RegenTimer;     // Tracks regeneration
var         int         HealAmmoCharge3; // Current healing charger
var localized   string  SuccessfulHealMessage3;
var()   HudBase.NumericWidget           MedicGunDigits;
var()   HudBase.NumericWidget           SyringeDigits;
var()   HudBase.SpriteWidget            MedicGunIcon;
var()   HudBase.SpriteWidget            MedicGunBG;

var()   HudBase.DigitSet                DigitsSmall;

var globalconfig		bool				bLightHud;


function byte BestMode()
{
	return 1;
}

simulated function float RateSelf()
{
	return -100;
}

simulated function Destroyed()
{
	Super.Destroyed();
	if( ScriptedScreen!=None )
	{
		ScriptedScreen.SetSize(256,256);
		ScriptedScreen.FallBackMaterial = None;
		ScriptedScreen.Client = None;
		Level.ObjectPool.FreeObject(ScriptedScreen);
		ScriptedScreen = None;
	}
	if( ShadedScreen!=None )
	{
		ShadedScreen.Diffuse = None;
		ShadedScreen.Opacity = None;
		ShadedScreen.SelfIllumination = None;
		ShadedScreen.SelfIlluminationMask = None;
		Level.ObjectPool.FreeObject(ShadedScreen);
		ShadedScreen = None;
		skins[3] = None;
	}
}

replication
{
    // Things the server should send to the client.
    reliable if( Role==ROLE_Authority )
        HealAmmoCharge3;
/*
 	reliable if( Role == ROLE_Authority )
		ClientSuccessfulHeal3;*/
}
/*
// The server lets the client know they successfully healed someone

simulated function ClientSuccessfulHeal3(String HealedName)
{
    if( PlayerController(Instigator.Controller) != none )
    {
        PlayerController(Instigator.controller).ClientMessage(SuccessfulHealMessage3@HealedName, 'CriticalEvent');
    }
}
*/

// Destroy this stuff when the level changes
simulated function PreTravelCleanUp()
{
	if( ScriptedScreen!=None )
	{
		ScriptedScreen.SetSize(256,256);
		ScriptedScreen.FallBackMaterial = None;
		ScriptedScreen.Client = None;
		Level.ObjectPool.FreeObject(ScriptedScreen);
		ScriptedScreen = None;
	}

	if( ShadedScreen!=None )
	{
		ShadedScreen.Diffuse = None;
		ShadedScreen.Opacity = None;
		ShadedScreen.SelfIllumination = None;
		ShadedScreen.SelfIlluminationMask = None;
		Level.ObjectPool.FreeObject(ShadedScreen);
		ShadedScreen = None;
		skins[3] = None;
	}
}

//simulated function DrawHUD(Canvas Canvas)
simulated event RenderOverlays( Canvas Canvas )
{
/*    local PlayerController PC;	
    local vector CameraLocation;
    local rotator CameraRotation;
    local Actor ViewActor;

	

	if (IsLocallyControlled() && Gun != None && Gun.bCorrectAim)
	{
		Canvas.DrawColor = CrosshairColor;
		Canvas.DrawColor.A = 255;
		Canvas.Style = ERenderStyle.STY_Alpha;

		Canvas.SetPos(Canvas.SizeX*0.5-CrosshairX, Canvas.SizeY*0.5-CrosshairY);
		Canvas.DrawTile(CrosshairTexture, CrosshairX*2.0+1, CrosshairY*2.0+1, 0.0, 0.0, CrosshairTexture.USize, CrosshairTexture.VSize);

	}

    PC = PlayerController(Controller);
	if (PC != None && !PC.bBehindView && HUDOverlay != None)
	{
        if (!Level.IsSoftwareRendering())
        {
    		CameraRotation = PC.Rotation;
    		SpecialCalcFirstPersonView(PC, ViewActor, CameraLocation, CameraRotation);
    		HUDOverlay.SetLocation(CameraLocation + (HUDOverlayOffset >> CameraRotation));
    		HUDOverlay.SetRotation(CameraRotation);
    		Canvas.DrawActor(HUDOverlay, false, false, FClamp(HUDOverlayFOV * (PC.DesiredFOV / PC.DefaultFOV), 1, 170));
    	}
	}
	else
        ActivateOverlay(False);*/

	super.RenderOverlays( Canvas );	

//	if ( WMediShot(PawnOwner.Weapon) != none )
//	{
                MedicGunDigits.Value = ChargeBar() * 100;

            	if ( MedicGunDigits.Value < 50 )
            	{
            		MedicGunDigits.Tints[0].R = 128;
            		MedicGunDigits.Tints[0].G = 128;
            		MedicGunDigits.Tints[0].B = 128;

            		MedicGunDigits.Tints[1] = SyringeDigits.Tints[0];
            	}
            	else if ( MedicGunDigits.Value < 100 )
            	{
            		MedicGunDigits.Tints[0].R = 192;
            		MedicGunDigits.Tints[0].G = 96;
            		MedicGunDigits.Tints[0].B = 96;

            		MedicGunDigits.Tints[1] = SyringeDigits.Tints[0];
            	}
            	else
            	{
            		MedicGunDigits.Tints[0].R = 255;
            		MedicGunDigits.Tints[0].G = 64;
            		MedicGunDigits.Tints[0].B = 64;

            		MedicGunDigits.Tints[1] = MedicGunDigits.Tints[0];
            	}

		if ( !bLightHud )
		{
			HUDKillingFloor(PlayerController(Instigator.Controller).myHud).DrawSpriteWidget(Canvas, MedicGunBG);
		}

		HUDKillingFloor(PlayerController(Instigator.Controller).myHud).DrawSpriteWidget(Canvas, MedicGunIcon);
		HUDKillingFloor(PlayerController(Instigator.Controller).myHud).DrawNumericWidget(Canvas, MedicGunDigits, DigitsSmall);
//	}
}


// Return a float value representing the current healing charge amount
simulated function float ChargeBar()
{
	return FClamp(float(HealAmmoCharge3)/float(MaxAmmoCount),0,1);
}
/*
simulated function float ChargeBar()
{
	return FMin(1, (AmmoAmount(0))/(FireMode[0].AmmoClass.Default.MaxAmmo));
}
*/
simulated function MaxOutAmmo()
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] != None )
			AmmoCharge[0] = MaxAmmo(0);
		return;
	}
	if ( Ammo[0] != None )
		Ammo[0].AmmoAmount = Ammo[0].MaxAmmo;

	HealAmmoCharge3 = MaxAmmoCount;
}

simulated function SuperMaxOutAmmo()
{
   HealAmmoCharge3 = 999;

	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] != None )
			AmmoCharge[0] = 999;
		return;
	}
	if ( Ammo[0] != None )
		Ammo[0].AmmoAmount = 999;
}

simulated function int MaxAmmo(int mode)
{
    if( Mode == 1 )
    {
	   return MaxAmmoCount;
	}
	else
	{
	   return super.MaxAmmo(mode);
	}
}

simulated function FillToInitialAmmo()
{
	if ( bNoAmmoInstances )
	{
		if ( AmmoClass[0] != None )
			AmmoCharge[0] = Max(AmmoCharge[0], AmmoClass[0].Default.InitialAmount);
        HealAmmoCharge3 = MaxAmmoCount;
		return;
	}

	if ( Ammo[0] != None )
        Ammo[0].AmmoAmount = Ammo[0].AmmoAmount;

    HealAmmoCharge3 = MaxAmmoCount;
}

simulated function int AmmoAmount(int mode)
{
    if( Mode == 1 )
    {
	   return HealAmmoCharge3;
	}
	else
	{
	   return super.AmmoAmount(mode);
	}
}

simulated function bool AmmoMaxed(int mode)
{
    if( Mode == 1 )
    {
	   return HealAmmoCharge3>=MaxAmmoCount;
	}
	else
	{
	   return super.AmmoMaxed(mode);
	}
}

simulated function float AmmoStatus(optional int Mode) // returns float value for ammo amount
{
    if( Mode == 1 )
    {
	   return float(HealAmmoCharge3)/float(MaxAmmoCount);
	}
	else
	{
	   return super.AmmoStatus(Mode);
	}
}

simulated function bool ConsumeAmmo(int Mode, float load, optional bool bAmountNeededIsMax)
{
    if( Mode == 1 )
    {
        if( Load>HealAmmoCharge3 )
        {
            return false;
        }

    	HealAmmoCharge3-=Load;
    	Return True;
	}
	else
	{
	   return super.ConsumeAmmo(Mode, load, bAmountNeededIsMax);
	}
}

function bool AddAmmo(int AmmoToAdd, int Mode)
{
    if( Mode == 1 )
    {
    	if( HealAmmoCharge3<MaxAmmoCount )
    	{
    		HealAmmoCharge3+=AmmoToAdd;
    		if( HealAmmoCharge3>MaxAmmoCount )
    		{
    			HealAmmoCharge3 = MaxAmmoCount;
    		}
    	}
        return true;
    }
    else
    {
        return super.AddAmmo(AmmoToAdd,Mode);
    }
}

simulated function bool HasAmmo()
{
    if( HealAmmoCharge3 > 0 )
    {
        return true;
    }

	if ( bNoAmmoInstances )
	{
    	return ( (AmmoClass[0] != none && FireMode[0] != none && AmmoCharge[0] >= FireMode[0].AmmoPerFire) );
	}
    return (Ammo[0] != none && FireMode[0] != none && Ammo[0].AmmoAmount >= FireMode[0].AmmoPerFire);
}

simulated function CheckOutOfAmmo()
{
    return;
}
/*
simulated function InitMaterials()
{
	if( ScriptedScreen==None )
	{
		ScriptedScreen = ScriptedTexture(Level.ObjectPool.AllocateObject(class'ScriptedTexture'));
        ScriptedScreen.SetSize(256,256);
		ScriptedScreen.FallBackMaterial = ScriptedScreenBack;
		ScriptedScreen.Client = Self;
	}

	if( ShadedScreen==None )
	{
		ShadedScreen = Shader(Level.ObjectPool.AllocateObject(class'Shader'));
		ShadedScreen.Diffuse = ScriptedScreen;
		ShadedScreen.SelfIllumination = ScriptedScreen;
		skins[3] = ShadedScreen;
	}
}
*/

simulated function Tick(float dt)
{
	if ( Level.NetMode!=NM_Client && HealAmmoCharge3<MaxAmmoCount && RegenTimer<Level.TimeSeconds )
	{
		RegenTimer = Level.TimeSeconds + AmmoRegenRate3;
		HealAmmoCharge3 += 10;
/*
		if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			HealAmmoCharge3 += 10 * KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetWeldSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo));
		}
		else
		{
			HealAmmoCharge3 += 10;
		}
*/
		if ( HealAmmoCharge3 > MaxAmmoCount )
		{
			HealAmmoCharge3 = MaxAmmoCount;
		}
	}
}
/*
simulated function Tick(float dt)
{
	if (FireMode[0].bIsFiring)
		FireModeArray = 0;
	else if (FireMode[1].bIsFiring)
		FireModeArray = 1;
	else
		bJustStarted = true;

	if (WeldShotAltFire(FireMode[FireModeArray]).LastHitActor != none && VSize(WeldShotAltFire(FireMode[FireModeArray]).LastHitActor.Location - Owner.Location) <= (weaponRange * 1.5) )
	{
		bNoTarget = false;
		ScreenWeldPercent = ((WeldShotAltFire(FireMode[FireModeArray]).LastHitActor.WeldStrength) / (WeldShotAltFire(FireMode[FireModeArray]).LastHitActor.MaxWeld)) * 100;
		if( ScriptedScreen==None )
			InitMaterials();
		ScriptedScreen.Revision++;
		if( ScriptedScreen.Revision>10 )
			ScriptedScreen.Revision = 1;

		if ( Level.Game != none && Level.Game.NumPlayers > 1 && bJustStarted && Level.TimeSeconds - LastWeldingMessageTime > WeldingMessageDelay )
		{
			if ( FireMode[0].bIsFiring )
			{
				bJustStarted = false;
				LastWeldingMessageTime = Level.TimeSeconds;
				if( Instigator != none && Instigator.Controller != none && PlayerController(Instigator.Controller) != none )
				{
				    PlayerController(Instigator.Controller).Speech('AUTO', 0, "");
				}
			}
			else if ( FireMode[1].bIsFiring )
			{
				bJustStarted = false;
				LastWeldingMessageTime = Level.TimeSeconds;
				if( Instigator != none && Instigator.Controller != none && PlayerController(Instigator.Controller) != none )
				{
				    PlayerController(Instigator.Controller).Speech('AUTO', 1, "");
				}
			}
		}
	}
	else if (WeldShotAltFire(FireMode[FireModeArray]).LastHitActor == none || WeldShotAltFire(FireMode[FireModeArray]).LastHitActor != none && VSize(WeldShotAltFire(FireMode[FireModeArray]).LastHitActor.Location - Owner.Location) > (weaponRange * 1.5) && !bNoTarget  )
	{
		if( ScriptedScreen==None )
			InitMaterials();
		ScriptedScreen.Revision++;
		if( ScriptedScreen.Revision>10 )
			ScriptedScreen.Revision = 1;
		bNoTarget = true;
		if( ClientState != WS_Hidden && Level.NetMode != NM_DedicatedServer && Instigator != none && Instigator.IsLocallyControlled() )
		{
		  PlayIdle();
		}
	}
	if ( AmmoAmount(0) < FireMode[0].AmmoClass.Default.MaxAmmo)
	{
		AmmoRegenCount += (dT * AmmoRegenRate );
		ConsumeAmmo(0, -1*(int(AmmoRegenCount)));
		AmmoRegenCount -= int(AmmoRegenCount);
	}
}
*/
simulated function bool StartFire(int Mode)
{
	if( Mode == 1 )
		return super.StartFire(Mode);

	if( !super.StartFire(Mode) )  // returns false when mag is empty
	   return false;

	if( AmmoAmount(0) <= 0 )
	{
    	return false;
    }

	AnimStopLooping();

	if( !FireMode[Mode].IsInState('FireLoop') && (AmmoAmount(0) > 0) )
	{
		FireMode[Mode].StartFiring();
		return true;
	}
	else
	{
		return false;
	}

	return true;
}

simulated function AnimEnd(int channel)
{
    local name anim;
    local float frame, rate;

	if(!FireMode[0].IsInState('FireLoop'))
	{
        GetAnimParams(0, anim, frame, rate);

        if (ClientState == WS_ReadyToFire)
        {
             if ((FireMode[0] == None || !FireMode[0].bIsFiring) && (FireMode[1] == None || !FireMode[1].bIsFiring))
            {
                PlayIdle();
            }
        }
	}
}

simulated function bool CanZoomNow()
{
	Return (!FireMode[0].bIsFiring && Instigator!=None && Instigator.Physics!=PHYS_Falling);
}


simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	bNoTarget =  true;
	if( Level.NetMode==NM_DedicatedServer )
		Return;
}

defaultproperties
{
     AmmoRegenRate=40.000000
     ScriptedScreenBack=FinalBlend'KillingFloorWeapons.Welder.WelderWindowFinal'
     SmallNameFont=Font'ROFonts.ROBtsrmVr12'
     BackColor=(B=128,G=128,R=128,A=255)
     WeldingMessageDelay=10.000000
     AmmoRegenRate3=0.300000
     HealBoostAmount3=20
     HealAmmoCharge3=500
     SuccessfulHealMessage3="You healed "
     MedicGunDigits=(RenderStyle=STY_Alpha,TextureScale=0.300000,PosX=0.731000,PosY=0.950000,Tints[0]=(B=64,G=64,R=255,A=255),Tints[1]=(B=64,G=64,R=255,A=255))
     SyringeDigits=(RenderStyle=STY_Alpha,TextureScale=0.300000,PosX=0.875000,PosY=0.950000,Tints[0]=(B=64,G=64,R=255,A=255),Tints[1]=(B=64,G=64,R=255,A=255))
     MedicGunIcon=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Lightning_Bolt',RenderStyle=STY_Alpha,TextureCoords=(X2=64,Y2=64),TextureScale=0.200000,PosX=0.707500,PosY=0.945000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     MedicGunBG=(WidgetTexture=Texture'KillingFloorHUD.HUD.Hud_Box_128x64',RenderStyle=STY_Alpha,TextureCoords=(X2=128,Y2=64),TextureScale=0.350000,PosX=0.705000,PosY=0.935000,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     DigitsSmall=(DigitTexture=Texture'KillingFloorHUD.Generic.HUD',TextureCoords[0]=(X1=8,Y1=6,X2=36,Y2=38),TextureCoords[1]=(X1=50,Y1=6,X2=68,Y2=38),TextureCoords[2]=(X1=83,Y1=6,X2=113,Y2=38),TextureCoords[3]=(X1=129,Y1=6,X2=157,Y2=38),TextureCoords[4]=(X1=169,Y1=6,X2=197,Y2=38),TextureCoords[5]=(X1=206,Y1=6,X2=235,Y2=38),TextureCoords[6]=(X1=241,Y1=6,X2=269,Y2=38),TextureCoords[7]=(X1=285,Y1=6,X2=315,Y2=38),TextureCoords[8]=(X1=318,Y1=6,X2=348,Y2=38),TextureCoords[9]=(X1=357,Y1=6,X2=388,Y2=38),TextureCoords[10]=(X1=390,Y1=6,X2=428,Y2=38))
     MagCapacity=6
     ReloadRate=0.700000
     ReloadAnim="Reload"
     ReloadAnimRate=1.740000
     FlashBoneName="Muzzle"
     WeaponReloadAnim="Reload_Shotgun"
     HudImage=Texture'MRS138DT.MRS138_unselected'
     SelectedHudImage=Texture'MRS138DT.MRS138_selected'
     Weight=5.000000
     bHasAimingMode=True
     IdleAimAnim="Iron_Idle"
     StandardDisplayFOV=55.000000
     bModeZeroCanDryFire=True
     SleeveNum=0
     TraderInfoTexture=Texture'MRS138DT.BigIcon_MRS138'
     PlayerIronSightFOV=65.000000
     ZoomedDisplayFOV=45.000000
     FireModeClass(0)=Class'Weldgun.WeldShotFire'
     FireModeClass(1)=Class'Weldgun.WeldShotAltFire'
     PutDownAnim="putaway"
     SelectSound=Sound'KF_MP7Snd.MP7_Select'
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.550000
     CurrentRating=0.550000
     bShowChargingBar=True
     Description="A Compact Shotgun. Modified to fire healing darts."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=55.000000
     Priority=10
     InventoryGroup=3
     GroupOffset=8
     PickupClass=Class'Weldgun.WeldShotPickup'
     PlayerViewOffset=(X=45.000000,Y=20.000000,Z=-6.000000)
     BobDamping=6.000000
     AttachmentClass=Class'Weldgun.WeldShotAttachment'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="WSG80 Welder Gun"
     Mesh=SkeletalMesh'WeldShotgun_A.MRS138Shotgun'
     Skins(0)=Texture'KF_Weapons2_Trip_T.hands.Foundry1_soldier_1stP'
     Skins(1)=Shader'MRS138DT.MRS138Shiney'
     Skins(2)=Shader'MRS138DT.MRS138HeatShiney'
     Skins(3)=Texture'MRS138DT.MRS138Shell'
     TransientSoundVolume=1.250000
}
