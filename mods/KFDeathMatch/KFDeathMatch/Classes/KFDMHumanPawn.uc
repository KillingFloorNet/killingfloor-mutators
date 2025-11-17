//=============================================================================
// KFDMHumanPawn
//=============================================================================
class KFDMHumanPawn extends KFHumanPawn;

simulated function PostBeginPlay()
{
	Super(UnrealPawn).PostBeginPlay();
	AssignInitialPose();

	if( bActorShadows && bPlayerShadows && (Level.NetMode!=NM_DedicatedServer) )
	{
		if( bDetailedShadows )
			PlayerShadow = Spawn(class'KFShadowProject',Self,'',Location);
		else PlayerShadow = Spawn(class'ShadowProjector',Self,'',Location);
		PlayerShadow.ShadowActor = self;
		PlayerShadow.bBlobShadow = bBlobShadow;
		PlayerShadow.LightDirection = Normal(vect(1,1,3));
		PlayerShadow.InitShadow();
	}
}

function TossWeapon(Vector TossVel)
{
	local Vector X,Y,Z;
	local WeaponPickup W;

	Weapon.Velocity = TossVel;
	GetAxes(Rotation,X,Y,Z);
	X = Location + 0.8 * CollisionRadius * X - 0.5 * CollisionRadius * Y;
	Weapon.DropFrom(X);
	foreach CollidingActors(Class'WeaponPickup',W,100,X)
		if( W.bDropped )
			W.LifeSpan = 10.f; // Make sure it gets destroyed.
}

function AddDefaultInventory()
{
	local Frag F;

	Super.AddDefaultInventory();
	F = Frag(FindInventoryType(Class'Frag'));
	if( F!=None )
	{
		if( KFDM(Level.Game).InitGrenadesCount<3 )
			F.ConsumeAmmo(0,3-KFDM(Level.Game).InitGrenadesCount,true);
		else if( KFDM(Level.Game).InitGrenadesCount>3 )
			F.AddAmmo(KFDM(Level.Game).InitGrenadesCount-3,0);
	}
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local LavaDeath LD;
	local MiscEmmiter BE;

	if( Adjuster!=None )
		Adjuster.Destroy();
	bHasFootAdjust = False;
	AmbientSound = None;
	bCanTeleport = false; // sjs - fix karma going crazy when corpses land on teleporters
	bReplicateMovement = false;
	bTearOff = true;
	bPlayedDeath = true;
	//bFrozenBody = true;

	SafeMesh = Mesh;

	if (CurrentCombo != None)
		CurrentCombo.Destroy();

	HitDamageType = DamageType; // these are replicated to other clients
	TakeHitLocation = HitLoc;

	if ( DamageType != None )
	{
		if ( DamageType.default.bSkeletize )
		{
			SetOverlayMaterial(DamageType.Default.DamageOverlayMaterial, 4.0, true);
			if (!bSkeletized)
			{
				if ( (Level.NetMode != NM_DedicatedServer) && DamageType.default.bLeaveBodyEffect )
				{
					BE = spawn(class'MiscEmmiter',self);
					if ( BE != None )
					{
						BE.DamageType = DamageType;
						BE.HitLoc = HitLoc;
						bFrozenBody = true;
					}
				}
				if (Physics == PHYS_Walking)
					Velocity = Vect(0,0,0);
				SetTearOffMomemtum(GetTearOffMomemtum() * 0.25);
				bSkeletized = true;
				if ( (Level.NetMode != NM_DedicatedServer) && (DamageType == class'FellLava') )
				{
					LD = spawn(class'LavaDeath', , , Location + vect(0, 0, 10), Rotation );
					if ( LD != None )
						LD.SetBase(self);
					PlaySound( sound'Inf_Weapons.F1.f1_explode01', SLOT_None, 1.5*TransientSoundVolume ); // KFTODO: Replace this sound
				}
			}
		}
		else if ( DamageType.Default.DeathOverlayMaterial != None )
			SetOverlayMaterial(DamageType.Default.DeathOverlayMaterial, DamageType.default.DeathOverlayTime, true);
		else if ( (DamageType.Default.DamageOverlayMaterial != None) && (Level.DetailMode != DM_Low) && !Level.bDropDetail )
			SetOverlayMaterial(DamageType.Default.DamageOverlayMaterial, 2*DamageType.default.DamageOverlayTime, true);
	}

	// stop shooting
	AnimBlendParams(1, 0.0);
	FireState = FS_None;
	LifeSpan = 60.f;

	GotoState('Dying');
	if ( BE != None )
		return;

	PlayDyingAnimation(DamageType, HitLoc);
}
function PlayDyingAnimation(class<DamageType> DamageType, vector HitLoc)
{
	local vector shotDir, hitLocRel, deathAngVel, shotStrength;
	local float maxDim;
	local string RagSkelName;
	local KarmaParamsSkel skelParams;
	local bool PlayersRagdoll;
	local PlayerController pc;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		// Is this the local player's ragdoll?
		if(OldController != None)
			pc = PlayerController(OldController);
		if( pc != none && pc.ViewTarget == self )
			PlayersRagdoll = true;

		// Try and obtain a rag-doll setup. Use optional 'override' one out of player record first, then use the species one.
		if( RagdollOverride != "")
			RagSkelName = RagdollOverride;
		else if(Species != None)
			RagSkelName = Species.static.GetRagSkelName( GetMeshName() );
		else RagSkelName = "Male1"; // Otherwise assume it is Male1 ragdoll were after here.

		KMakeRagdollAvailable();

		if( KIsRagdollAvailable() && RagSkelName != "" )
		{
			skelParams = KarmaParamsSkel(KParams);
			skelParams.KSkeleton = RagSkelName;

			// Stop animation playing.
			StopAnimating(true);

			if( DamageType != None )
			{
				if ( DamageType.default.bLeaveBodyEffect )
					TearOffMomentum = vect(0,0,0);

				if( DamageType.default.bKUseOwnDeathVel )
				{
					RagDeathVel = DamageType.default.KDeathVel;
					RagDeathUpKick = DamageType.default.KDeathUpKick;
				}
			}

			// Set the dude moving in direction he was shot in general
			shotDir = Normal(GetTearOffMomemtum());
			shotStrength = RagDeathVel * shotDir;

			// Calculate angular velocity to impart, based on shot location.
			hitLocRel = TakeHitLocation - Location;

			// We scale the hit location out sideways a bit, to get more spin around Z.
			hitLocRel.X *= RagSpinScale;
			hitLocRel.Y *= RagSpinScale;

			// If the tear off momentum was very small for some reason, make up some angular velocity for the pawn
			if( VSize(GetTearOffMomemtum()) < 0.01 )
			{
				//Log("TearOffMomentum magnitude of Zero");
				deathAngVel = VRand() * 18000.0;
			}
			else deathAngVel = RagInvInertia * (hitLocRel Cross shotStrength);

			// Set initial angular and linear velocity for ragdoll.
			// Scale horizontal velocity for characters - they run really fast!
			if ( DamageType.Default.bRubbery )
				skelParams.KStartLinVel = vect(0,0,0);
			if ( Damagetype.default.bKUseTearOffMomentum )
				skelParams.KStartLinVel = GetTearOffMomemtum() + Velocity;
			else
			{
				skelParams.KStartLinVel.X = 0.6 * Velocity.X;
				skelParams.KStartLinVel.Y = 0.6 * Velocity.Y;
				skelParams.KStartLinVel.Z = 1.0 * Velocity.Z;
				skelParams.KStartLinVel += shotStrength;
			}
			// If not moving downwards - give extra upward kick
			if( !DamageType.default.bLeaveBodyEffect && !DamageType.Default.bRubbery && (Velocity.Z > -10) )
				skelParams.KStartLinVel.Z += RagDeathUpKick;

			if ( DamageType.Default.bRubbery )
			{
				Velocity = vect(0,0,0);
				skelParams.KStartAngVel = vect(0,0,0);
			}
			else
			{
				skelParams.KStartAngVel = deathAngVel;

				// Set up deferred shot-bone impulse
				maxDim = Max(CollisionRadius, CollisionHeight);

				skelParams.KShotStart = TakeHitLocation - (1 * shotDir);
				skelParams.KShotEnd = TakeHitLocation + (2*maxDim*shotDir);
				skelParams.KShotStrength = RagShootStrength;
			}

			// If this damage type causes convulsions, turn them on here.
			if(DamageType != None && DamageType.default.bCauseConvulsions)
			{
				RagConvulseMaterial=DamageType.default.DamageOverlayMaterial;
				skelParams.bKDoConvulsions = true;
			}

			// Turn on Karma collision for ragdoll.
			KSetBlockKarma(true);

			// Set physics mode to ragdoll.
			// This doesn't actaully start it straight away, it's deferred to the first tick.
			SetPhysics(PHYS_KarmaRagdoll);

			// If viewing this ragdoll, set the flag to indicate that it is 'important'
			if( PlayersRagdoll )
				skelParams.bKImportantRagdoll = true;

			skelParams.bRubbery = DamageType.Default.bRubbery;
			bRubbery = DamageType.Default.bRubbery;

			skelParams.KActorGravScale = RagGravScale;

			return;
		}
		// jag
	}

	// non-ragdoll death fallback
	Velocity += GetTearOffMomemtum();
	BaseEyeHeight = Default.BaseEyeHeight;
	SetTwistLook(0, 0);
	SetInvisibility(0.0);
	SetCollision(false);
	SetPhysics(PHYS_Falling);
	LifeSpan = 3.f;
}

exec function TossCash( int Amount )
{
	local Vector X,Y,Z;
	local CashPickup CashPickup ;
	local Vector TossVel;

	if( Amount<=0 )
		Amount = 50;
	Controller.PlayerReplicationInfo.Score = int(Controller.PlayerReplicationInfo.Score); // To fix issue with throwing 0 pounds.
	if( Controller.PlayerReplicationInfo.Score<=0 || Amount<=0 )
		return;
	Amount = Min(Amount,int(Controller.PlayerReplicationInfo.Score));

	GetAxes(Rotation,X,Y,Z);

	TossVel = Vector(GetViewRotation());
	TossVel = TossVel * ((Velocity Dot TossVel) + 500) + Vect(0,0,200);

	CashPickup = Spawn(class'CashPickup',,, Location + 0.8 * CollisionRadius * X - 0.5 * CollisionRadius * Y);

	if(CashPickup != none)
	{
		CashPickup.CashAmount = Amount;
		CashPickup.bDroppedCash = true;
		CashPickup.RespawnTime = 0;   // Dropped cash doesnt respawn. For obvious reasons.
		CashPickup.Velocity = TossVel;
		CashPickup.DroppedBy = Controller;
		CashPickup.InitDroppedPickupFor(None);
		Controller.PlayerReplicationInfo.Score -= Amount;

		if ( Level.Game.NumPlayers > 1 && Level.TimeSeconds - LastDropCashMessageTime > DropCashMessageDelay )
		{
			PlayerController(Controller).Speech('AUTO', 4, "");
		}
	}
}

defaultproperties
{
     RequiredEquipment(1)="KFDeathMatch.DMSingle"
     RequiredEquipment(3)="KFDeathMatch.DMSyringe"
     bNoTeamBeacon=True
     bScriptPostRender=False
     bBlockHitPointTraces=True
}
