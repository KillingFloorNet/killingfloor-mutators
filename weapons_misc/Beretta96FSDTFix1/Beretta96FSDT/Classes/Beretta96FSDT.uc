class Beretta96FSDT extends KFWeapon;
//Flame, 3xzet
#exec OBJ LOAD FILE=Beretta96FS_DT_A.ukx //package=Beretta96FSDT

var		LaserDot						Spot;						// The first person laser site dot
var		float							SpotProjectorPullback;		// Amount to pull back the laser dot projector from the hit location
var		bool							bLaserActive;				// The laser site is active
var		Beretta96FSDTLaserBeamEffect	Beam;	// Third person laser beam effect
var		class<InventoryAttachment>		LaserAttachmentClass;      // First person laser attachment class
var		Actor							LaserAttachment;           // First person laser attachment
var		name							IdleAimEmptyAnim;
var		name							IdleEmptyAnim;
var 	name							ReloadEmptyAnim;
var 	float							ReloadEmptyRate;
var 	name							ModeSwitchEmptyAnim;
var 	name							PutDownEmptyAnim;
var 	name							SelectEmptyAnim;
var		name							SilencerOnEmptyAnim;
var		name							SilencerOffEmptyAnim;
var		name							SilencerOnAnim;
var		name							SilencerOffAnim;
var		float							SilencerSwitchTime;
var		float							SilencerNextSwitchTime;
var		name							altFlashBoneName;
var		bool							bSilencerSwitch;
var		bool							bSilencerOn;
var		name							SilencerSelectAnim;
var		int								ClientMagAmmoRemaining;
var		Beretta96FSDTAttachment			WA;
var		bool							bSilencerOnNotify;
replication
{
	reliable if(Role<Role_Authority)
		ServerSetLaserActive, TransferMagAmmoRemaining, ServerSetSilencerActive;
	reliable if(Role==Role_Authority)
		bSilencerOn,bLaserActive;
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	SetBoneScale(0, 0.0, 'supp');
	//ThirdPersonSilencer();
	if(Role == ROLE_Authority)
	{
		if(Beam == None)
			Beam = Spawn(class'Beretta96FSDTLaserBeamEffect');
	}
}

//Flame
function TransferMagAmmoRemaining(int N)
{
	Beretta96FSDTAttachment(ThirdPersonActor).ClientMagAmmoRemaining=N;
	////Log("Weapon.TransferMagAmmoRemaining.0"@Beretta96FSDTAttachment(ThirdPersonActor).ClientMagAmmoRemaining);
}
//

simulated function Fire(float F)
{
	if(!bIsReloading)
	{
		ClientMagAmmoRemaining=MagAmmoRemaining;
		ClientMagAmmoRemaining--;
	}
	super.Fire(F);
}

simulated function PlayIdle()
{
	WA = Beretta96FSDTAttachment(ThirdPersonActor);
	ClientMagAmmoRemaining=Max(ClientMagAmmoRemaining,MagAmmoRemaining);
	if( bAimingRifle )
	{
		if(ClientMagAmmoRemaining > 0) //заменяем MagAmmoRemaining
		{
			if( WA.WIdleAnim != 'none' )
				WA.PlayAnim(WA.WIdleAnim, 1.0, 0.0);
			LoopAnim(IdleAimAnim, IdleAnimRate, 0.2);
		}
		else 
		{
			if( WA.WIdleAnim != 'none' )
				WA.PlayAnim(WA.WIdleEmptyAnim, 1.0, 0.0);
			LoopAnim(IdleAimEmptyAnim, IdleAnimRate, 0.2);
		}
	}
	else
	{
		if(ClientMagAmmoRemaining > 0) //заменяем MagAmmoRemaining
		{
			if( WA.WIdleAnim != 'none' )
				WA.PlayAnim(WA.WIdleAnim, 1.0, 0.0);
			LoopAnim(IdleAnim, IdleAnimRate, 0.2);
		}
		else 
		{
			if( WA.WIdleAnim != 'none' )
				WA.PlayAnim(WA.WIdleEmptyAnim, 1.0, 0.0);
			LoopAnim(IdleEmptyAnim, IdleAnimRate, 0.2);
		}
	}
}

simulated function Timer()
{
	local int Mode;
	local float OldDownDelay;

	OldDownDelay = DownDelay;
	DownDelay = 0;
	//ThirdPersonSilencer();
	if(ClientState == WS_BringUp)
	{
		for( Mode = 0; Mode < NUM_FIRE_MODES; Mode++ )
		FireMode[Mode].InitEffects();
		PlayIdle();
		ClientState = WS_ReadyToFire;
		if(bPendingFlashlight && bTorchEnabled)
		{
			if(Level.NetMode != NM_Client)
				LightFire();
			else
				ClientStartFire(1);
			bPendingFlashlight = false;
		}
	}
	else if(ClientState == WS_PutDown)
	{
		if(OldDownDelay > 0)
		{
			if(HasAnim(PutDownAnim))
			{
				if(MagAmmoRemaining > 0)
					PlayAnim(PutDownAnim, PutDownAnimRate, 0.0);
				else
					PlayAnim(PutDownEmptyAnim, PutDownAnimRate, 0.0);
			}
			SetTimer(PutDownTime, false);
			return;
		}
		if(Instigator.PendingWeapon == None)
		{
			if(ClientGrenadeState == GN_TempDown)
			{
				if(KFPawn(Instigator)!=none)
					KFPawn(Instigator).WeaponDown();
			}
			else
				PlayIdle();
			ClientState = WS_ReadyToFire;
		}
		else
		{
			if(FlashLight!=none)
				Tacshine.Destroy();
			ClientState = WS_Hidden;
			Instigator.ChangedWeapon();
			if(Instigator.Weapon == self)
			{
				PlayIdle();
				ClientState = WS_ReadyToFire;
			}
			else
			{
				for(Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
					FireMode[Mode].DestroyEffects();
			}
		}
	}
}

simulated function bool AllowReload()
{
	UpdateMagCapacity(Instigator.PlayerReplicationInfo);
	if(Level.TimeSeconds < SilencerNextSwitchTime)
		return false;
	if	(
			KFInvasionBot(Instigator.Controller) != none
			&&	!bIsReloading
			&&	MagAmmoRemaining < MagCapacity
			&&	AmmoAmount(0) > MagAmmoRemaining
		)
	{
		return true;
	}
	if	(
			KFFriendlyAI(Instigator.Controller) != none
			&&	!bIsReloading
			&&	MagAmmoRemaining < MagCapacity
			&&	AmmoAmount(0) > MagAmmoRemaining
		)
	{
		return true;
	}
	if	(
			FireMode[0].IsFiring()
			||	FireMode[1].IsFiring()
			||	bIsReloading
			||	MagAmmoRemaining >= MagCapacity
			||	ClientState == WS_BringUp
			||	AmmoAmount(0) <= MagAmmoRemaining
			||	FireMode[0].NextFireTime - Level.TimeSeconds > 0.1
		)
	{
		return false;
	}
	return true;
}

// Set the new fire mode on the server
function ServerSetLaserActive(bool bL)
{
	//Log("Weapon.ServerSetLaserActive.0"@bL);
	SilencerNextSwitchTime = level.TimeSeconds + SilencerSwitchTime;
	if(Beam != none)
		Beam.SetActive(bL);
	if(bL)
	{
		bLaserActive = true;
		if(Spot == None)
			Spot = Spawn(class'LaserDot', self);
	}
	else
	{
		bLaserActive = false;
		if(Spot != None)
			Spot.Destroy();
	}
}
function ServerSetSilencerActive(bool bS)
{
	//Log("Weapon.ServerSetSilencerActive.0"@bS);
	if(bS)
	{
		//Flame
		//Log("Weapon.ServerSetLaserActive.1"@bSilencerOn);
		bSilencerOn=true;
		//Log("Weapon.ServerSetLaserActive.2"@bSilencerOn);
		Beretta96FSDTAttachment(ThirdPersonActor).bSilencerOn=bSilencerOn;
		//
	}
	else
	{
		//Flame
		bSilencerOn=false;
		Beretta96FSDTAttachment(ThirdPersonActor).bSilencerOn=bSilencerOn;
		//Log("Weapon.ServerSetLaserActive.3");
		//
	}
}

simulated function Destroyed()
{
	if(Spot != None)
		Spot.Destroy();
	if(Beam != None)
		Beam.Destroy();
	if(LaserAttachment != None)
		LaserAttachment.Destroy();
	super.Destroyed();
}

simulated function WeaponTick(float dt)
{
	local Vector StartTrace, EndTrace, X,Y,Z;
	local Vector HitLocation, HitNormal;
	local Actor Other;
	local vector MyEndBeamEffect;
	local coords C;
	local float LastSeenSeconds,ReloadMulti;

	//ThirdPersonSilencer();
	//Flame
	////Log("WeaponTick.0"@Role@Level.NetMode@IsLocallyControlled());
	//if(IsLocallyControlled())//Role<ROLE_Authority)
	if(Level.NetMode != NM_DedicatedServer)
		TransferMagAmmoRemaining(ClientMagAmmoRemaining);
	//
	if(Role == ROLE_Authority && Beam != none)
	{
		if(bIsReloading && WeaponAttachment(ThirdPersonActor) != none)
		{
			C = WeaponAttachment(ThirdPersonActor).GetBoneCoords('LightBone');
			X = C.XAxis;
			Y = C.YAxis;
			Z = C.ZAxis;
		}
		else
			GetViewAxes(X,Y,Z);
		// the to-hit trace always starts right in front of the eye
		StartTrace = Instigator.Location + Instigator.EyePosition() + X*Instigator.CollisionRadius;
		EndTrace = StartTrace + 65535 * X;
		Other = Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
		if(Other != None && Other != Instigator && Other.Base != Instigator)
			MyEndBeamEffect = HitLocation;
		else
			MyEndBeamEffect = EndTrace;
		Beam.EndBeamEffect = MyEndBeamEffect;
		Beam.EffectHitNormal = HitNormal;
	}
	if(bHasAimingMode)
	{
		if(bForceLeaveIronsights)
		{
			if(bAimingRifle)
			{
				ZoomOut(true);
				if(Level.NetMode != NM_DedicatedServer) //?
					ServerZoomOut(false);
			}
			bForceLeaveIronsights = false;
		}
		if(ForceZoomOutTime > 0)
		{
			if(bAimingRifle)
			{
				if(Level.TimeSeconds - ForceZoomOutTime > 0)
				{
					ForceZoomOutTime = 0;
					ZoomOut(true);
					if(Level.NetMode != NM_DedicatedServer)
						ServerZoomOut(false);
				}
			}
			else
				ForceZoomOutTime = 0;
		}
	}
	if	(
			Level.NetMode == NM_Client
			||	Instigator == None
			||	KFFriendlyAI(Instigator.Controller) == none && Instigator.PlayerReplicationInfo == None
		)
	{
		return;
	}
	// Turn it off on death  / battery expenditure
	if(FlashLight != none)
	{
		// Keep the 1Pweapon client beam up to date.
		AdjustLightGraphic();
		if(FlashLight.bHasLight)
		{
			if	(
					Instigator.Health <= 0
					||	KFHumanPawn(Instigator).TorchBatteryLife <= 0
					||	Instigator.PendingWeapon != none
				)
			{
				////Log("Killing Light...you're out of batteries, or switched / dropped weapons");
				KFHumanPawn(Instigator).bTorchOn = false;
				ServerSpawnLight();
			}
		}
	}
	UpdateMagCapacity(Instigator.PlayerReplicationInfo);
	if(!bIsReloading)
	{
		if(!Instigator.IsHumanControlled())
		{
			LastSeenSeconds = Level.TimeSeconds - Instigator.Controller.LastSeenTime;
			if	(
					MagAmmoRemaining == 0
					||	(
							(LastSeenSeconds >= 5 || LastSeenSeconds > MagAmmoRemaining)
							&&	MagAmmoRemaining < MagCapacity
						)
				)
			{
				ReloadMeNow();
			}
		}
	}
	else
	{
		if(Level.TimeSeconds - ReloadTimer >= ReloadRate)
		{
			if(AmmoAmount(0) <= MagCapacity && !bHoldToReload)
			{
				MagAmmoRemaining = AmmoAmount(0);
				ActuallyFinishReloading();
			}
			else
			{
				if	(
						KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none
						&&	KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none
					)
				{
					ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
				}
				else
					ReloadMulti = 1.0;
				AddReloadedAmmo();
				if(bHoldToReload)
					NumLoadedThisReload++;
				if(MagAmmoRemaining < MagCapacity && MagAmmoRemaining < AmmoAmount(0) && bHoldToReload)
					ReloadTimer = Level.TimeSeconds;
				if	(
						MagAmmoRemaining >= MagCapacity
						||	MagAmmoRemaining >= AmmoAmount(0)
						||	!bHoldToReload
						||	bDoSingleReload
					)
				{
					ActuallyFinishReloading();
				}
				else if(Level.NetMode!=NM_Client)
					Instigator.SetAnimAction(WeaponReloadAnim);
			}
		}
		else if(bIsReloading && !bReloadEffectDone && Level.TimeSeconds - ReloadTimer >= ReloadRate / 2)
		{
			bReloadEffectDone = true;
			ClientReloadEffects();
		}
	}
}
/*
simulated function Tick(float dt)
{
	//Log("Tick.0"@bSilencerOn@bLaserActive);
	Super.Tick(dt);
}
*/
simulated function BringUp(optional Weapon PrevWeapon)
{
	local int Mode;
	HandleSleeveSwapping();
	if(Role == ROLE_Authority)
	{
		if(Beam == None)
			Beam = Spawn(class'Beretta96FSDTLaserBeamEffect');
	}
	if(KFHumanPawn(Instigator) != none)
		KFHumanPawn(Instigator).SetAiming(false);
	bAimingRifle = false;
	bIsReloading = false;
	IdleAnim = default.IdleAnim;
	//Super.BringUp(PrevWeapon);
	if(bSilencerOn)
		ToggleLaser(true,true);
	//ThirdPersonSilencer();
	// From Weapon.uc
	if	(
			ClientState == WS_Hidden
			||	ClientGrenadeState == GN_BringUp
			||	KFPawn(Instigator).bIsQuickHealing > 0
		)
	{
		PlayOwnedSound(SelectSound, SLOT_Interact,,,,, false);
		ClientPlayForceFeedback(SelectForce);  // jdf
		if(Instigator.IsLocallyControlled())
		{
			if(Mesh!=None && HasAnim(SelectAnim))
			{
				if(ClientGrenadeState == GN_BringUp || KFPawn(Instigator).bIsQuickHealing > 0)
				{
					if( bSilencerOn )
					{
						if(MagAmmoRemaining > 0)
							PlayAnim(SilencerSelectAnim, SelectAnimRate * (BringUpTime/QuickBringUpTime), 0.0);
						else
							PlayAnim(SelectEmptyAnim, SelectAnimRate * (BringUpTime/QuickBringUpTime), 0.0);
					}
					else
					{
						if(MagAmmoRemaining > 0)
							PlayAnim(SelectAnim, SelectAnimRate * (BringUpTime/QuickBringUpTime), 0.0);
						else
							PlayAnim(SelectEmptyAnim, SelectAnimRate * (BringUpTime/QuickBringUpTime), 0.0);
					}
				}
				else
				{
					if(bSilencerOn)
					{
						if(MagAmmoRemaining > 0)
							PlayAnim(SilencerSelectAnim, SelectAnimRate, 0.0);
						else PlayAnim(SelectEmptyAnim, SelectAnimRate, 0.0);
					}
					else
					{
						if(MagAmmoRemaining > 0)
							PlayAnim(SelectAnim, SelectAnimRate, 0.0);
						else
							PlayAnim(SelectEmptyAnim, SelectAnimRate, 0.0);
					}
				}
			}
		}
		ClientState = WS_BringUp;
		if(ClientGrenadeState == GN_BringUp || KFPawn(Instigator).bIsQuickHealing > 0)
		{
			ClientGrenadeState = GN_None;
			SetTimer(QuickBringUpTime, false);
		}
		else
			SetTimer(BringUpTime, false);
	}
	for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
	{
		FireMode[Mode].bIsFiring = false;
		FireMode[Mode].HoldTime = 0.0;
		FireMode[Mode].bServerDelayStartFire = false;
		FireMode[Mode].bServerDelayStopFire = false;
		FireMode[Mode].bInstantStop = false;
	}
	if(PrevWeapon != None && PrevWeapon.HasAmmo() && !PrevWeapon.bNoVoluntarySwitch)
		OldWeapon = PrevWeapon;
	else
		OldWeapon = None;
}

exec function ReloadMeNow()
{
	local float ReloadMulti;
	if(!AllowReload())
		return;
	if(bHasAimingMode && bAimingRifle)
	{
		FireMode[1].bIsFiring = False;
		ZoomOut(false);
		if(Level.NetMode != NM_DedicatedServer)
			ServerZoomOut(false);
	}
	if	(
			KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none
			&&	KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none
		)
	{
		ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
	}
	else
		ReloadMulti = 1.0;
	bIsReloading = true;
	ReloadTimer = Level.TimeSeconds;
	if(MagAmmoRemaining <= 0)
		ReloadRate = Default.ReloadRate / ReloadMulti;
	else if(MagAmmoRemaining >= 1)
		ReloadRate = Default.ReloadEmptyRate / ReloadMulti;
	if(bHoldToReload)
		NumLoadedThisReload = 0;
	ClientReload();
	Instigator.SetAnimAction(WeaponReloadAnim);
	if	(
			Level.Game.NumPlayers > 1
			&&	KFGameType(Level.Game).bWaveInProgress
			&&	KFPlayerController(Instigator.Controller) != none
			&&	Level.TimeSeconds - KFPlayerController(Instigator.Controller).LastReloadMessageTime > KFPlayerController(Instigator.Controller).ReloadMessageDelay
		)
	{
		KFPlayerController(Instigator.Controller).Speech('AUTO', 2, "");
		KFPlayerController(Instigator.Controller).LastReloadMessageTime = Level.TimeSeconds;
	}
}

simulated function ClientReload()
{
	local float ReloadMulti;

	WA = Beretta96FSDTAttachment(ThirdPersonActor);
	if(bHasAimingMode && bAimingRifle)
	{
		FireMode[1].bIsFiring = False;
		ZoomOut(false);
		if(Level.NetMode != NM_DedicatedServer)
			ServerZoomOut(false);
	}
	if	(
			KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none
			&&	KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none
		)
	{
		ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
	}
	else
		ReloadMulti = 1.0;
	bIsReloading = true;
	if(MagAmmoRemaining <= 0)
	{
		//3xzet. Анимация перезарядки от третьего лица.
		//Flame. Надо звать серверную функцию, из неё функцию на аттачменте, иначе сторонние наблюдатели не увидят
		if(WA.WReloadAnim != 'none')
			WA.PlayAnim(WA.WReloadEmptyAnim, 1.1, 0.0);
		//
		PlayAnim(ReloadAnim, ReloadAnimRate*ReloadMulti, 0.1);
	}
	else if(MagAmmoRemaining >= 1)
	{
		//3xzet. Анимация перезарядки от третьего лица.
		if(WA.WReloadAnim != 'none')
			WA.PlayAnim(WA.WReloadAnim, 1.1, 0.0);
		//
		PlayAnim(ReloadEmptyAnim, ReloadAnimRate*ReloadMulti, 0.1);
	}
	//Flame. Чтобы Idle анимация была правильная
	ClientMagAmmoRemaining=Min(default.MagCapacity,Ammo[0].AmmoAmount);
	//
}

simulated function DetachFromPawn(Pawn P)
{
	TurnOffLaser();
	Super.DetachFromPawn(P);
	if(Beam != None)
		Beam.Destroy();
}

simulated function bool PutDown()
{
	local int Mode;

	if(bSilencerSwitch)
		return false;
	if(Beam != None)
		Beam.Destroy();
	TurnOffLaser();
	InterruptReload();
	if(bIsReloading)
		return false;
	if(bAimingRifle)
		ZoomOut(False);

	// From Weapon.uc
	if(ClientState == WS_BringUp || ClientState == WS_ReadyToFire)
	{
		if(Instigator.PendingWeapon != None && !Instigator.PendingWeapon.bForceSwitch)
		{
			for(Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
			{
				if(FireMode[Mode] == none)
					continue;
				if ( FireMode[Mode].bFireOnRelease && FireMode[Mode].bIsFiring )
					return false;
				if ( FireMode[Mode].NextFireTime > Level.TimeSeconds + FireMode[Mode].FireRate*(1.f - MinReloadPct))
					DownDelay = FMax(DownDelay, FireMode[Mode].NextFireTime - Level.TimeSeconds - FireMode[Mode].FireRate*(1.f - MinReloadPct));
			}
		}

		if (Instigator.IsLocallyControlled())
		{
			for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
			{
				// if _RO_
				if( FireMode[Mode] == none )
					continue;
				// End _RO_

				if ( FireMode[Mode].bIsFiring )
					ClientStopFire(Mode);
			}

			if (  DownDelay <= 0  || KFPawn(Instigator).bIsQuickHealing > 0)
			{
				if ( ClientState == WS_BringUp || KFPawn(Instigator).bIsQuickHealing > 0 )
				{
					if(MagAmmoRemaining > 0)
						TweenAnim(SelectAnim,PutDownTime);
					else TweenAnim(SelectEmptyAnim,PutDownTime);
				}
				else if ( HasAnim(PutDownAnim) )
				{
					if( ClientGrenadeState == GN_TempDown || KFPawn(Instigator).bIsQuickHealing > 0)
					{
						if (MagAmmoRemaining > 0)
							PlayAnim(PutDownAnim, PutDownAnimRate * (PutDownTime/QuickPutDownTime), 0.0);
						else PlayAnim(PutDownEmptyAnim, PutDownAnimRate * (PutDownTime/QuickPutDownTime), 0.0);
					}
					else
					{
						if (MagAmmoRemaining > 0)
							PlayAnim(PutDownAnim, PutDownAnimRate, 0.0);
						else PlayAnim(PutDownEmptyAnim, PutDownAnimRate, 0.0);
					}

				}
			}
		}
		ClientState = WS_PutDown;
		if ( Level.GRI.bFastWeaponSwitching )
			DownDelay = 0;
		if ( DownDelay > 0 )
		{
			SetTimer(DownDelay, false);
		}
		else
		{
			if( ClientGrenadeState == GN_TempDown )
			{
				SetTimer(QuickPutDownTime, false);
			}
			else
			{
				SetTimer(PutDownTime, false);
			}
		}
	}
	for (Mode = 0; Mode < NUM_FIRE_MODES; Mode++)
	{
		// if _RO_
		if( FireMode[Mode] == none )
			continue;
		// End _RO_

		FireMode[Mode].bServerDelayStartFire = false;
		FireMode[Mode].bServerDelayStopFire = false;
	}
	Instigator.AmbientSound = None;
	OldWeapon = None;
	return true; // return false if preventing weapon switch
}

// Use alt fire to switch fire modes
simulated function AltFire(float F)
{
	SilencerNextSwitchTime = Level.TimeSeconds + SilencerSwitchTime;
	/*
	WA = Beretta96FSDTAttachment(ThirdPersonActor);
	if( bLaserActive ) WA.SetBoneScale (0, 1.0, 'supp');
	else  WA.SetBoneScale (0, 0.0, 'supp');
	*/
	//ThirdPersonSilencer();
	//Log("Weapon.AltFire.0"@!bSilencerSwitch@!bIsReloading);
	if(/*ReadyToFire(0) && */!bSilencerSwitch && !bIsReloading)
	{
		ToggleLaser(!bLaserActive,!bSilencerOn);
	}
}

simulated function vector GetEffectStart()
{
	local Vector FlashLoc, altFlashLoc;

	// jjs - this function should actually never be called in third person views
	// any effect that needs a 3rdp weapon offset should figure it out itself

	// 1st person
	altFlashLoc = GetBoneCoords(default.altFlashBoneName).Origin;
	FlashLoc = GetBoneCoords(default.FlashBoneName).Origin;
	if (Instigator.IsFirstPerson())
	{
		if ( WeaponCentered() )
			return CenteredEffectStart();

		if( bLaserActive )
		{
	//	Log ("bLaserActive"@bLaserActive);
			return altFlashLoc;
		}
		else
		{
	//	Log ("bLaserActive"@bLaserActive);
			return FlashLoc;
		}
	}
	// 3rd person
	else
	{
		return (Instigator.Location +
			Instigator.EyeHeight*Vect(0,0,0.5) +
			Vector(Instigator.Rotation) * 40.0);
	}
}

// Toggle the laser on and off
simulated function ToggleLaser(bool bLaserActiveL, bool bSilencerOnL)
{
	//ThirdPersonSilencer();
	//Log("Weapon.ToggleLaser.0"@bLaserActive@bLaserActiveL@bSilencerOn@bSilencerOnL);
	if(Instigator.IsLocallyControlled())
	{
		bSilencerOnNotify=bSilencerOnL;
		ServerSetSilencerActive(bSilencerOnL);
		ServerSetLaserActive(bLaserActiveL);
		//Flame. Не хотим этого кода в одиночной игре и на ждущем сервере
		//if(Role<Role_Authority)
		//	bLaserActive = !bLaserActive;
		//
		if(Beam != none)
			Beam.SetActive(bLaserActiveL);
		//Log("Weapon.ToggleLaser.1"@bLaserActive@bLaserActiveL@bSilencerOn@bSilencerOnL);
		if(bLaserActiveL)
		{
			if(!FireMode[0].bIsFiring && !bIsReloading)
			{
				if(LaserAttachment == none)
				{
					LaserAttachment = Spawn(LaserAttachmentClass,,,,);
					AttachToBone(LaserAttachment,'LightBone');
				}
				LaserAttachment.bHidden = false;
				if(Spot == None)
					Spot = Spawn(class'LaserDot', self);
				//KFFire(FireMode[0]).DamageMax = class'Beretta96FSDTFire'.default.DamageMaxS; //спасибо Тело =) //Спасибо то ему спасибо, но это надо звать на сервере, а не на клиенте). Flame
					//bSilencerOn = True;
				if(MagAmmoRemaining > 0)//?
					PlayAnim(SilencerOnAnim,FireMode[0].FireAnimRate,FireMode[0].TweenTime);
				else
					PlayAnim(SilencerOnEmptyAnim,FireMode[0].FireAnimRate,FireMode[0].TweenTime);
			}
		}
		else
		{
			if(!FireMode[0].bIsFiring && !bIsReloading)
			{
				if(LaserAttachment!=none)
					LaserAttachment.bHidden = true;
				if(Spot != None)
					Spot.Destroy();
				KFFire(Firemode[0]).DamageMax = KFFire(Firemode[0]).default.DamageMax; //спасибо Тело =)
				//bSilencerOn = False;
				if(MagAmmoRemaining > 0)
					PlayAnim(SilencerOffAnim,FireMode[0].FireAnimRate,FireMode[0].TweenTime);
				else
					PlayAnim(SilencerOffEmptyAnim,FireMode[0].FireAnimRate,FireMode[0].TweenTime);
			}
		}
	}
}

simulated function TurnOffLaser()
{
	//Log("TurnOffLaser.0");
	if(Instigator.IsLocallyControlled())
	{
		ServerSetLaserActive(false);
		//bLaserActive = false;
		if(LaserAttachment!=none)
			LaserAttachment.bHidden = true;
		if(Beam != none)
			Beam.SetActive(false);
		if(Spot != None)
			Spot.Destroy();
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

	if(Instigator == None)
		return;

	if(Instigator.Controller != None)
		Hand = Instigator.Controller.Handedness;

	if(Hand < -1.0 || Hand > 1.0)
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
		if(Other != None && Other != Instigator && Other.Base != Instigator)
			EndBeamEffect = HitLocation;
		else
			EndBeamEffect = EndTrace;
		Spot.SetLocation(EndBeamEffect - X*SpotProjectorPullback);
		if(Pawn(Other) != none)
		{
			Spot.SetRotation(Rotator(X));
			Spot.SetDrawScale(Spot.default.DrawScale * 0.5);
		}
		else if(HitNormal == vect(0,0,0))
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

function bool RecommendRangedAttack()
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
	if(B == None || B.Enemy == None)
		return AIRating;
	return AIRating;
}

function byte BestMode()
{
	return 0;
}

simulated function Notify_ShowSilencer()
{
	//Log("Weapon.Notify_ShowSilencer.0"@bSilencerOn@bSilencerOnNotify);
	if(bSilencerOnNotify)
		SetBoneScale(0, 1.0, 'supp');
	else
		SetBoneScale(0, 0.0, 'supp');
}

simulated function Notify_SilencerSwitchStart ()
{
	bSilencerSwitch = true;
}
simulated function Notify_SilencerSwitchEnd ()
{
	bSilencerSwitch = false;
}
simulated function Notify_SilencerOn ()
{
	//bSilencerOn = True;
}
simulated function Notify_SilencerOff ()
{
	//bSilencerOn = False;
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
	SilencerOnEmptyAnim="Silencer_on_Empty"
	SilencerOffEmptyAnim="Silencer_off_Empty"
	IdleAimEmptyAnim="Idle_Empty"
	IdleEmptyAnim="Idle_Empty"
	PutDownEmptyAnim="PutDown_Empty"
	ReloadEmptyAnim="Reload"
	ReloadEmptyRate=2.200000
	altFlashBoneName="tip"
	FlashBoneName="tip_S"
	SilencerSelectAnim="SelectS"
	SelectAnim="Select" //"Select"
	SelectEmptyAnim="Select_Empty"
	SilencerOnAnim="Silencer_on"
	SilencerOffAnim="Silencer_off"
	SilencerSwitchTime=2.5
	BringUpTime=0.530000
	SpotProjectorPullback=1.000000
	LaserAttachmentClass=Class'KFMod.LaserAttachmentFirstPerson'
	FirstPersonFlashlightOffset=(X=-20.000000,Y=-22.000000,Z=8.000000)
	MagCapacity=15
	ReloadRate=2.700000
	ReloadAnim="Reload_Empty"
	ReloadAnimRate=1.000000
	WeaponReloadAnim="Reload_Single9mm"
	HudImage=Texture'Beretta96FS_DT_A.Beretta96FS_DT_T.Beretta96FS_Unselected'
	SelectedHudImage=Texture'Beretta96FS_DT_A.Beretta96FS_DT_T.Beretta96FS_Selected'
	Weight=3.000000
	//bKFNeverThrow=True
	bTorchEnabled=True
	bHasAimingMode=True
	IdleAimAnim="Iron_Idle"
	StandardDisplayFOV=70.000000
	bModeZeroCanDryFire=True
	TraderInfoTexture=Texture'Beretta96FS_DT_A.Beretta96FS_DT_T.Beretta96FS_Trader'
	ZoomedDisplayFOV=65.000000
	FireModeClass(0)=Class'Beretta96FSDTFire'
	FireModeClass(1)=Class'KFMod.NoFire' //Class'Beretta96FSDTALTFire'
	PutDownAnim="PutDown"
	SelectSound=Sound'KF_9MMSnd.9mm_Select'
	AIRating=0.250000
	CurrentRating=0.250000
	bShowChargingBar=True
	Description="Beretta 96 SF"
	DisplayFOV=70.000000
	Priority=60
	InventoryGroup=2
	GroupOffset=1
	PickupClass=Class'Beretta96FSDTPickup'
	PlayerViewOffset=(X=8.000000,Y=10.000000,Z=-5.000000)
	BobDamping=4.500000
	AttachmentClass=Class'Beretta96FSDTAttachment'
	IconCoords=(X1=434,Y1=253,X2=506,Y2=292)
	ItemName="Beretta 96 SF"
	SleeveNum=8
	Mesh=SkeletalMesh'Beretta96FS_DT_A.Beretta96FS_DT_Mesh'
	Skins(0)=Shader'Beretta96FS_DT_A.Beretta96FS_DT_T.frameDT_sh'
	Skins(1)=Shader'Beretta96FS_DT_A.Beretta96FS_DT_T.lamDT_sh'
	Skins(2)=Shader'Beretta96FS_DT_A.Beretta96FS_DT_T.compensatorDT_sh'
	Skins(3)=Shader'Beretta96FS_DT_A.Beretta96FS_DT_T.railDT_sh'
	Skins(4)=Shader'Beretta96FS_DT_A.Beretta96FS_DT_T.internalDT_sh'
	Skins(5)=Shader'Beretta96FS_DT_A.Beretta96FS_DT_T.slideDT_sh'
	Skins(6)=Shader'Beretta96FS_DT_A.Beretta96FS_DT_T.slideDT_sh'
	Skins(7)=Shader'Beretta96FS_DT_A.Beretta96FS_DT_T.silDT_sh'
}
