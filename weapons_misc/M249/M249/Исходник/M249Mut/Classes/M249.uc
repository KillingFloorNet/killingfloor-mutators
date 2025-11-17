class M249 extends KFWeapon
	config(user);

#exec OBJ LOAD FILE="m249_A.ukx"

var         m249LaserDot                    Spot;                       // The first person laser site dot
var()       float                       SpotProjectorPullback;      // Amount to pull back the laser dot projector from the hit location
var         bool                        bLaserActive;               // The laser site is active
var         m249LaserBeamEffect             Beam;                       // Third person laser beam effect

var()		class<InventoryAttachment>	LaserAttachmentClass;      // First person laser attachment class
var 		Actor 	
					LaserAttachment;           // First person laser attachment
 replication
{
	reliable if(Role < ROLE_Authority)
		ServerChangeFireMode,ServerSetLaserActive;
}

// Use alt fire to switch fire modes
simulated function AltFire(float F)
{
    if(ReadyToFire(0))
    {
        DoToggle();
        ToggleLaser();
    }
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if (Role == ROLE_Authority)
	{
		if (Beam == None)
		{
			Beam = Spawn(class'm249LaserBeamEffect');
		}
	}
}

simulated function WeaponTick(float dt)
{
	local Vector StartTrace, EndTrace, X,Y,Z;
	local Vector HitLocation, HitNormal;
	local Actor Other;
	local vector MyEndBeamEffect;
	local coords C;

	super.WeaponTick(dt);

	if( Role == ROLE_Authority && Beam != none )
	{
		if( bIsReloading && WeaponAttachment(ThirdPersonActor) != none )
		{
			C = WeaponAttachment(ThirdPersonActor).GetBoneCoords('LightBone');
			X = C.XAxis;
			Y = C.YAxis;
			Z = C.ZAxis;
		}
		else
		{
			GetViewAxes(X,Y,Z);
		}

		// the to-hit trace always starts right in front of the eye
		StartTrace = Instigator.Location + Instigator.EyePosition() + X*Instigator.CollisionRadius;

		EndTrace = StartTrace + 65535 * X;

		Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

		if (Other != None && Other != Instigator && Other.Base != Instigator )
		{
			MyEndBeamEffect = HitLocation;
		}
		else
		{
			MyEndBeamEffect = EndTrace;
		}

		Beam.EndBeamEffect = MyEndBeamEffect;
		Beam.EffectHitNormal = HitNormal;
	}
}

simulated function Destroyed()
{
	if (Spot != None)
		Spot.Destroy();

	if (Beam != None)
		Beam.Destroy();

	if (LaserAttachment != None)
		LaserAttachment.Destroy();

	super.Destroyed();
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);

	if (Role == ROLE_Authority)
	{
		if (Beam == None)
		{
			Beam = Spawn(class'm249LaserBeamEffect');
		}
	}

	if (bLaserActive)
		TurnOnLaser();
}

simulated function DetachFromPawn(Pawn P)
{
	TurnOffLaser();

	Super.DetachFromPawn(P);

	if (Beam != None)
	{
		Beam.Destroy();
	}
}

simulated function bool PutDown()
{
	if (Beam != None)
	{
		Beam.Destroy();
	}

	TurnOffLaser(true); 

	return super.PutDown();
}

// Toggle the laser on and off
simulated function ToggleLaser()
{
	if( Instigator.IsLocallyControlled() )
	{
		if( Role < ROLE_Authority  )
		{
			ServerSetLaserActive(!bLaserActive);
		}

		bLaserActive = !bLaserActive;

		if( Beam != none )
		{
			Beam.SetActive(bLaserActive);
		}

		if( bLaserActive )
		{
			if ( LaserAttachment == none )
			{
				LaserAttachment = Spawn(LaserAttachmentClass,,,,);
				AttachToBone(LaserAttachment,'LightBone');
			}
			LaserAttachment.bHidden = false;

			if (Spot == None)
			{
				Spot = Spawn(class'm249LaserDot', self);
			}
		}
		else
		{
			LaserAttachment.bHidden = true;
			if (Spot != None)
			{
				Spot.Destroy();
			}
		}
	}
}
//--------------------------------------------------------------------------------------------------
// TurnOnLaser
simulated function TurnOnLaser()
{
	if( Instigator.IsLocallyControlled() )
	{
		if( Role < ROLE_Authority  )
		{
			ServerSetLaserActive(true);
		}

		bLaserActive = true;

		if( Beam != none )
		{
			Beam.SetActive(true);
		}

		if ( LaserAttachment == none )
		{
			LaserAttachment = Spawn(LaserAttachmentClass,,,,);
			AttachToBone(LaserAttachment,'LightBone');
		}
		LaserAttachment.bHidden = false;
		if (Spot == None)
		{
			Spot = Spawn(class'm249LaserDot', self);
		}
	}
}
//--------------------------------------------------------------------------------------------------
simulated function TurnOffLaser(optional bool bPutDown)
{
	if( Instigator.IsLocallyControlled() )
	{
		if( Role < ROLE_Authority  )
		{
			ServerSetLaserActive(false);
		}

		if (!bPutDown)
			bLaserActive = false;
		LaserAttachment.bHidden = true;

		if( Beam != none )
		{
			Beam.SetActive(false);
		}

		if (Spot != None)
		{
			Spot.Destroy();
		}
	}
}

// Set the new fire mode on the server
function ServerSetLaserActive(bool bNewWaitForRelease)
{
	if( Beam != none )
	{
		Beam.SetActive(bNewWaitForRelease);
	}

	if( bNewWaitForRelease )
	{
		bLaserActive = true;
		if (Spot == None)
		{
			Spot = Spawn(class'm249LaserDot', self);
		}
	}
	else
	{
		bLaserActive = false;
		if (Spot != None)
		{
			Spot.Destroy();
		}
	}
}

simulated event RenderOverlays( Canvas Canvas )
{
	local int m;
	local Vector StartTrace, EndTrace;
	local Vector HitLocation, HitNormal;
	local Actor Other;
	local vector X,Y,Z;
	local coords C;

	if (Instigator == None)
		return;

	if ( Instigator.Controller != None )
		Hand = Instigator.Controller.Handedness;

	if ((Hand < -1.0) || (Hand > 1.0))
		return;

	// draw muzzleflashes/smoke for all fire modes so idle state won't
	// cause emitters to just disappear
	for (m = 0; m < NUM_FIRE_MODES; m++)
	{
		if (FireMode[m] != None)
		{
			FireMode[m].DrawMuzzleFlash(Canvas);
		}
	}

	SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
	SetRotation( Instigator.GetViewRotation() + ZoomRotInterp);

	// Handle drawing the laser beam dot
	if (Spot != None)
	{
		StartTrace = Instigator.Location + Instigator.EyePosition();
		GetViewAxes(X, Y, Z);

		if( bIsReloading && Instigator.IsLocallyControlled() )
		{
			C = GetBoneCoords('LightBone');
			X = C.XAxis;
			Y = C.YAxis;
			Z = C.ZAxis;
		}

		EndTrace = StartTrace + 65535 * X;

		Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);

		if (Other != None && Other != Instigator && Other.Base != Instigator )
		{
			EndBeamEffect = HitLocation;
		}
		else
		{
			EndBeamEffect = EndTrace;
		}

		Spot.SetLocation(EndBeamEffect - X*SpotProjectorPullback);

		if(  Pawn(Other) != none )
		{
			Spot.SetRotation(Rotator(X));
			Spot.SetDrawScale(Spot.default.DrawScale * 0.5);
		}
		else if( HitNormal == vect(0,0,0) )
		{
			Spot.SetRotation(Rotator(-X));
			Spot.SetDrawScale(Spot.default.DrawScale);
		}
		else
		{
			Spot.SetRotation(Rotator(-HitNormal));
			Spot.SetDrawScale(Spot.default.DrawScale);
		}
	}

	//PreDrawFPWeapon();	// Laurent -- Hook to override things before render (like rotation if using a staticmesh)

	bDrawingFirstPerson = true;
	Canvas.DrawActor(self, false, false, DisplayFOV);
	bDrawingFirstPerson = false;
}

// Toggle semi/auto fire
simulated function DoToggle ()
{
	local PlayerController Player;

	Player = Level.GetLocalPlayerController();
	if ( Player!=None )
	{
		//PlayOwnedSound(sound'Inf_Weapons_Foley.stg44_firemodeswitch01',SLOT_None,2.0,,,,false);
		FireMode[0].bWaitForRelease = !FireMode[0].bWaitForRelease;
		if ( FireMode[0].bWaitForRelease )
		{
			Player.ReceiveLocalizedMessage(class'KFmod.BullpupSwitchMessage',0);
			TurnOffLaser();
		}
		else
		{ 
			Player.ReceiveLocalizedMessage(class'KFmod.BullpupSwitchMessage',1);
			TurnOnLaser();
		}
		FireMode[0].AllowFire();
	}
	Super.DoToggle();

	ServerChangeFireMode(FireMode[0].bWaitForRelease);
}

// Set the new fire mode on the server
function ServerChangeFireMode(bool bNewWaitForRelease)
{
    FireMode[0].bWaitForRelease = bNewWaitForRelease;
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


simulated function Notify_ShowBullets ()
{
			SetBoneScale (0, 1.0, 'Bullet01b');
			SetBoneScale (1, 1.0, 'Bullet02b');
			SetBoneScale (2, 1.0, 'Bullet03b');
			SetBoneScale (3, 1.0, 'Bullet04b');
			SetBoneScale (4, 1.0, 'Bullet05b');
			SetBoneScale (5, 1.0, 'Bullet06b');
			SetBoneScale (6, 1.0, 'Bullet07b');
			SetBoneScale (7, 1.0, 'Bullet08b');
			SetBoneScale (8, 1.0, 'Bullet09b');
			SetBoneScale (9, 1.0, 'Bullet10b');
}

simulated function Notify_HideBullets ()
{
	if (MagAmmoRemaining == 0)
		{
			SetBoneScale (0, 0.0, 'Bullet01b');
			SetBoneScale (1, 0.0, 'Bullet02b');
			SetBoneScale (2, 0.0, 'Bullet03b');
			SetBoneScale (3, 0.0, 'Bullet04b');
			SetBoneScale (4, 0.0, 'Bullet05b');
			SetBoneScale (5, 0.0, 'Bullet06b');
			SetBoneScale (6, 0.0, 'Bullet07b');
			SetBoneScale (7, 0.0, 'Bullet08b');
			SetBoneScale (8, 0.0, 'Bullet09b');
			SetBoneScale (9, 0.0, 'Bullet10b');
		}
	else if (MagAmmoRemaining == 1)
		{
			SetBoneScale (0, 0.0, 'Bullet01b');
			SetBoneScale (1, 0.0, 'Bullet02b');
			SetBoneScale (2, 0.0, 'Bullet03b');
			SetBoneScale (3, 0.0, 'Bullet04b');
			SetBoneScale (4, 0.0, 'Bullet05b');
			SetBoneScale (5, 0.0, 'Bullet06b');
			SetBoneScale (6, 0.0, 'Bullet07b');
			SetBoneScale (7, 0.0, 'Bullet08b');
			SetBoneScale (8, 0.0, 'Bullet09b');
			SetBoneScale (9, 1.0, 'Bullet10b');
		}
	else if (MagAmmoRemaining == 2)
		{
			SetBoneScale (0, 0.0, 'Bullet01b');
			SetBoneScale (1, 0.0, 'Bullet02b');
			SetBoneScale (2, 0.0, 'Bullet03b');
			SetBoneScale (3, 0.0, 'Bullet04b');
			SetBoneScale (4, 0.0, 'Bullet05b');
			SetBoneScale (5, 0.0, 'Bullet06b');
			SetBoneScale (6, 0.0, 'Bullet07b');
			SetBoneScale (7, 0.0, 'Bullet08b');
			SetBoneScale (8, 1.0, 'Bullet09b');
			SetBoneScale (9, 1.0, 'Bullet10b');
		}
	else if (MagAmmoRemaining == 3)
		{
			SetBoneScale (0, 0.0, 'Bullet01b');
			SetBoneScale (1, 0.0, 'Bullet02b');
			SetBoneScale (2, 0.0, 'Bullet03b');
			SetBoneScale (3, 0.0, 'Bullet04b');
			SetBoneScale (4, 0.0, 'Bullet05b');
			SetBoneScale (5, 0.0, 'Bullet06b');
			SetBoneScale (6, 0.0, 'Bullet07b');
			SetBoneScale (7, 1.0, 'Bullet08b');
			SetBoneScale (8, 1.0, 'Bullet09b');
			SetBoneScale (9, 1.0, 'Bullet10b');
		}
	else if (MagAmmoRemaining == 4)
		{
			SetBoneScale (0, 0.0, 'Bullet01b');
			SetBoneScale (1, 0.0, 'Bullet02b');
			SetBoneScale (2, 0.0, 'Bullet03b');
			SetBoneScale (3, 0.0, 'Bullet04b');
			SetBoneScale (4, 0.0, 'Bullet05b');
			SetBoneScale (5, 0.0, 'Bullet06b');
			SetBoneScale (6, 1.0, 'Bullet07b');
			SetBoneScale (7, 1.0, 'Bullet08b');
			SetBoneScale (8, 1.0, 'Bullet09b');
			SetBoneScale (9, 1.0, 'Bullet10b');
		}
	else if (MagAmmoRemaining == 5)
		{
			SetBoneScale (0, 0.0, 'Bullet01b');
			SetBoneScale (1, 0.0, 'Bullet02b');
			SetBoneScale (2, 0.0, 'Bullet03b');
			SetBoneScale (3, 0.0, 'Bullet04b');
			SetBoneScale (4, 0.0, 'Bullet05b');
			SetBoneScale (5, 1.0, 'Bullet06b');
			SetBoneScale (6, 1.0, 'Bullet07b');
			SetBoneScale (7, 1.0, 'Bullet08b');
			SetBoneScale (8, 1.0, 'Bullet09b');
			SetBoneScale (9, 1.0, 'Bullet10b');
		}
	else if (MagAmmoRemaining == 6)
		{
			SetBoneScale (0, 0.0, 'Bullet01b');
			SetBoneScale (1, 0.0, 'Bullet02b');
			SetBoneScale (2, 0.0, 'Bullet03b');
			SetBoneScale (3, 0.0, 'Bullet04b');
			SetBoneScale (4, 1.0, 'Bullet05b');
			SetBoneScale (5, 1.0, 'Bullet06b');
			SetBoneScale (6, 1.0, 'Bullet07b');
			SetBoneScale (7, 1.0, 'Bullet08b');
			SetBoneScale (8, 1.0, 'Bullet09b');
			SetBoneScale (9, 1.0, 'Bullet10b');
		}
	else if (MagAmmoRemaining == 7)
		{
			SetBoneScale (0, 0.0, 'Bullet01b');
			SetBoneScale (1, 0.0, 'Bullet02b');
			SetBoneScale (2, 0.0, 'Bullet03b');
			SetBoneScale (3, 1.0, 'Bullet04b');
			SetBoneScale (4, 1.0, 'Bullet05b');
			SetBoneScale (5, 1.0, 'Bullet06b');
			SetBoneScale (6, 1.0, 'Bullet07b');
			SetBoneScale (7, 1.0, 'Bullet08b');
			SetBoneScale (8, 1.0, 'Bullet09b');
			SetBoneScale (9, 1.0, 'Bullet10b');
		}
	else if (MagAmmoRemaining == 8)
		{
			SetBoneScale (0, 0.0, 'Bullet01b');
			SetBoneScale (1, 0.0, 'Bullet02b');
			SetBoneScale (2, 1.0, 'Bullet03b');
			SetBoneScale (3, 1.0, 'Bullet04b');
			SetBoneScale (4, 1.0, 'Bullet05b');
			SetBoneScale (5, 1.0, 'Bullet06b');
			SetBoneScale (6, 1.0, 'Bullet07b');
			SetBoneScale (7, 1.0, 'Bullet08b');
			SetBoneScale (8, 1.0, 'Bullet09b');
			SetBoneScale (9, 1.0, 'Bullet10b');
		}
	else if (MagAmmoRemaining == 9)
		{
			SetBoneScale (0, 0.0, 'Bullet01b');
			SetBoneScale (1, 1.0, 'Bullet02b');
			SetBoneScale (2, 1.0, 'Bullet03b');
			SetBoneScale (3, 1.0, 'Bullet04b');
			SetBoneScale (4, 1.0, 'Bullet05b');
			SetBoneScale (5, 1.0, 'Bullet06b');
			SetBoneScale (6, 1.0, 'Bullet07b');
			SetBoneScale (7, 1.0, 'Bullet08b');
			SetBoneScale (8, 1.0, 'Bullet09b');
			SetBoneScale (9, 1.0, 'Bullet10b');
		}
				
	else
		{
			SetBoneScale (0, 1.0, 'Bullet01b');
			SetBoneScale (1, 1.0, 'Bullet02b');
			SetBoneScale (2, 1.0, 'Bullet03b');
			SetBoneScale (3, 1.0, 'Bullet04b');
			SetBoneScale (4, 1.0, 'Bullet05b');
			SetBoneScale (5, 1.0, 'Bullet06b');
			SetBoneScale (6, 1.0, 'Bullet07b');
			SetBoneScale (7, 1.0, 'Bullet08b');
			SetBoneScale (8, 1.0, 'Bullet09b');
			SetBoneScale (9, 1.0, 'Bullet10b');
		}
}

defaultproperties
{
     SpotProjectorPullback=1.000000
     LaserAttachmentClass=Class'M249Mut.m249LaserAttachmentFirstPerson'
     MagCapacity=100
     ReloadRate=5.000000
     ReloadAnim="Reload"
     ReloadAnimRate=1.00000
     WeaponReloadAnim="Reload_AK47"
     SelectAnimRate=1.000000
     Weight=9.000000
     bHasAimingMode=True
     IdleAimAnim="Iron_Idle"
     StandardDisplayFOV=65.000000
     bModeZeroCanDryFire=True
     TraderInfoTexture=Texture'm249_A.m249_Trader'
     SleeveNum=0
     bIsTier2Weapon=True
     Mesh=SkeletalMesh'm249_A.m249mesh'
     Skins(0)=Combiner'KF_Weapons_Trip_T.hands.hands_1stP_military_cmb'
     Skins(1)=Combiner'm249_A.m249_tex_1_cmb'
     Skins(2)=Combiner'm249_A.m249_tex_2_cmb'
     Skins(3)=Combiner'm249_A.m249_tex_3_cmb'
     Skins(4)=Combiner'm249_A.m249_tex_4_cmb'
     Skins(5)=Combiner'm249_A.m249_tex_5_cmb'
     Skins(6)=Combiner'm249_A.m249_tex_6_cmb'
     Skins(7)=Combiner'm249_A.m249_tex_7_cmb'
     Skins(8)=Combiner'm249_A.m249_tex_8_cmb'
     Skins(9)=Combiner'm249_A.m249_tex_9_cmb'
     Skins(10)=Combiner'm249_A.m249_tex_10_cmb'
     DrawScale=0.6
     SelectSound=Sound'm249_A.m249_select'
     HudImage=Texture'm249_A.m249_Unselected'
     SelectedHudImage=Texture'm249_A.m249_selected'
     PlayerIronSightFOV=65.000000
     ZoomedDisplayFOV=32.000000
     FireModeClass(0)=Class'M249Mut.M249Fire'
     FireModeClass(1)=Class'KFMod.NoFire'
     PutDownAnim="PutDown"
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.550000
     CurrentRating=0.550000
     bShowChargingBar=True
     Description="The M249 light machine gun (LMG), previously designated the M249 Squad Automatic Weapon (SAW), and formally written as Light Machine Gun, 5.56 mm, M249, is an American version of the Belgian FN Minimi, a light machine gun manufactured by the Belgian company FN Herstal (FN)."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=65.000000
     Priority=150
     CustomCrosshair=11
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross5"
     InventoryGroup=3
     GroupOffset=7
     PickupClass=Class'M249Mut.M249Pickup'
     PlayerViewOffset=(X=5.000000,Y=5.500000,Z=-3.000000)
     BobDamping=5.000000
     AttachmentClass=Class'M249Mut.M249Attachment'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="M249 SAW"
     TransientSoundVolume=1.250000
     LightRadius=0.000000
}
