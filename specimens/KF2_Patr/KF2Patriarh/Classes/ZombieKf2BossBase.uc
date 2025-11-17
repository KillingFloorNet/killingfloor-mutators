// Zombie Monster for KF Invasion gametype
class ZombieKf2BossBase extends KFMonster
    abstract;

#exec OBJ LOAD FILE=KFPatch2.utx

var(Anims) name DeathAnims[4];
var name MeleeAnims[5];

#exec OBJ LOAD FILE=KFPatch2.utx
#exec OBJ LOAD FILE=KF_Specimens_Trip_T.utx

var bool bChargingPlayer,bClientCharg,bFireAtWill,bMinigunning,bIsBossView;
var float RageStartTime,LastChainGunTime,LastMissileTime,LastSneakedTime;

var bool bClientMiniGunning;

var name ChargingAnim;		// How he runs when charging the player.
var byte SyringeCount,ClientSyrCount;

var int MGFireCounter;

var vector TraceHitPos;
var Emitter mTracer,mMuzzleFlash;
var bool bClientCloaked;
var float LastCheckTimes;
var int HealingLevels[3],HealingAmount;

var(Sounds)     sound   RocketFireSound;    // The sound of the rocket being fired
var(Sounds)     sound   MiniGunFireSound;   // The sound of the minigun being fired
var(Sounds)     sound   MiniGunSpinSound;   // The sound of the minigun spinning
var(Sounds)     sound   MeleeImpaleHitSound;// The sound of melee impale attack hitting the player

var             float   MGFireDuration;     // How long to fire for this burst
var             float   MGLostSightTimeout; // When to stop firing because we lost sight of the target
var()           float   MGDamage;           // How much damage the MG will do

var()           float   ClawMeleeDamageRange;// How long his arms melee strike is
var()           float   ImpaleMeleeDamageRange;// How long his spike melee strike is

var             float   LastChargeTime;     // Last time the patriarch charged
var             float   LastForceChargeTime;// Last time patriarch was forced to charge
var             int     NumChargeAttacks;   // Number of attacks this charge
var             float   ChargeDamage;       // How much damage he's taken since the last charge
var             float   LastDamageTime;     // Last Time we took damage

// Sneaking
var             float   SneakStartTime;     // When did we start sneaking
var             int     SneakCount;         // Keep track of the loop that sends the boss to initial hunting state

// PipeBomb damage
var()           float   PipeBombDamageScale;// Scale the pipe bomb damage over time

replication
{
	reliable if( Role==ROLE_Authority )
		bChargingPlayer,SyringeCount,TraceHitPos,bMinigunning,bIsBossView;
}		

simulated function PlayDyingAnimation(class<DamageType> DamageType, vector HitLoc)
{
	local vector shotDir, hitLocRel, deathAngVel, shotStrength;
	local float maxDim;
	//local string RagSkelName;
	local KarmaParamsSkel skelParams;
	local bool PlayersRagdoll;
	local PlayerController pc;

	if( MyExtCollision!=None )
		MyExtCollision.Destroy();
	if ( Level.NetMode != NM_DedicatedServer && Class'Kf2Boss_karma'.Static.UseRagdoll() && Len(RagdollOverride)>0  )
	{
		// Is this the local player's ragdoll?
		if(OldController != None)
			pc = PlayerController(OldController);
		if( pc != None && pc.ViewTarget == self )
			PlayersRagdoll = true;

		// In low physics detail, if we were not just controlling this pawn,
		// and it has not been rendered in 3 seconds, just destroy it.

		if( Level.NetMode == NM_ListenServer )
		{
			// For a listen server, use LastSeenOrRelevantTime instead of render time so
			// monsters don't disappear for other players that the host can't see - Ramm
			if( Level.PhysicsDetailLevel != PDL_High && !PlayersRagdoll && (Level.TimeSeconds-LastSeenOrRelevantTime)>3 || bGibbed )
			{
				Destroy();
				return;
			}
		}
		else if( Level.PhysicsDetailLevel!=PDL_High && !PlayersRagdoll && (Level.TimeSeconds-LastRenderTime)>3 ||	bGibbed)
		{
			Destroy();
			return;
		}

		KMakeRagdollAvailable();
		if( KIsRagdollAvailable())
		{
			skelParams = KarmaParamsSkel(KParams);
			skelParams.KSkeleton = RagdollOverride;

			// Stop animation playing.
			StopAnimating(true);

			// StopAnimating() resets the neck bone rotation, we have to set it again
			// if the zed was decapitated the cute way
			if ( class'GameInfo'.static.UseLowGore() && NeckRot != rot(0,0,0) )
			{
				SetBoneRotation(NeckBone, NeckRot);
			}

			if( DamageType != none )
			{
				if ( DamageType.default.bLeaveBodyEffect )
					TearOffMomentum = vect(0,0,0);

				if ( DamageType.default.bKUseOwnDeathVel )
				{
					RagDeathVel = DamageType.default.KDeathVel;
					RagDeathUpKick = DamageType.default.KDeathUpKick;
					RagShootStrength = DamageType.default.KDamageImpulse;
				}
			}

			// Set the dude moving in direction he was shot in general
			shotDir = Normal(GetTearOffMomemtum());
			shotStrength = RagDeathVel * shotDir;

			// Calculate angular velocity to impart, based on shot location.
			hitLocRel = TakeHitLocation - Location;

			if( DamageType.default.bLocationalHit )
			{
				hitLocRel.X *= RagSpinScale;
				hitLocRel.Y *= RagSpinScale;

				if( Abs(hitLocRel.X)  > RagMaxSpinAmount )
				{
					if( hitLocRel.X < 0 )
					{
						hitLocRel.X = FMax((hitLocRel.X * RagSpinScale), (RagMaxSpinAmount * -1));
					}
					else
					{
						hitLocRel.X = FMin((hitLocRel.X * RagSpinScale), RagMaxSpinAmount);
					}
				}

				if( Abs(hitLocRel.Y)  > RagMaxSpinAmount )
				{
					if( hitLocRel.Y < 0 )
					{
						hitLocRel.Y = FMax((hitLocRel.Y * RagSpinScale), (RagMaxSpinAmount * -1));
					}
					else
					{
						hitLocRel.Y = FMin((hitLocRel.Y * RagSpinScale), RagMaxSpinAmount);
					}
				}

			}
			else
			{
				// We scale the hit location out sideways a bit, to get more spin around Z.
				hitLocRel.X *= RagSpinScale;
				hitLocRel.Y *= RagSpinScale;
			}

			//log("hitLocRel.X = "$hitLocRel.X$" hitLocRel.Y = "$hitLocRel.Y);
			//log("TearOffMomentum = "$VSize(GetTearOffMomemtum()));

			// If the tear off momentum was very small for some reason, make up some angular velocity for the pawn
			if( VSize(GetTearOffMomemtum()) < 0.01 )
			{
				//Log("TearOffMomentum magnitude of Zero");
				deathAngVel = VRand() * 18000.0;
			}
			else
			{
				deathAngVel = RagInvInertia * (hitLocRel cross shotStrength);
			}

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

			//log("RagDeathVel = "$RagDeathVel$" KShotStrength = "$skelParams.KShotStrength$" RagDeathUpKick = "$RagDeathUpKick);

			// If this damage type causes convulsions, turn them on here.
			if(DamageType != none && DamageType.default.bCauseConvulsions)
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
	PlayDirectionalDeath(HitLoc);
	SetPhysics(PHYS_Falling);
}

simulated function PlayDirectionalDeath(Vector HitLoc)
{
	if( Level.NetMode==NM_DedicatedServer )
	{
		SetCollision(false, false, false);
		return;
	}
	SetCollision(false, false, false);
 	PlayDeathAnim();
	// lame hack, but it is better than leaving her staying for those, who have no karma data
	// -- PooSH
	//SetCollision(false, false, false);
	//bHidden = true;
}

simulated function PlayDeathAnim()
{
	PlayAnim(DeathAnims[Rand(4)]);
}

defaultproperties
{
     ChargingAnim="RunF"
     HealingLevels(0)=3000
     HealingLevels(1)=4000
     HealingLevels(2)=5000
     HealingAmount=7500
     MGDamage=1.000000
     ClawMeleeDamageRange=85.000000
     ImpaleMeleeDamageRange=65.000000
     ZapThreshold=10.000000
     ZappedDamageMod=1.250000
     ZapResistanceScale=1.000000
     bHarpoonToHeadStuns=False
     bHarpoonToBodyStuns=False
     DamageToMonsterScale=10.000000
     ZombieFlag=3
     MeleeDamage=50
     damageForce=170000
     bFatAss=True
     KFRagdollName=""
     bMeleeStunImmune=True
     CrispUpThreshhold=1
     bCanDistanceAttackDoors=True
     bUseExtendedCollision=True
     ColOffset=(Z=65.000000)
     ColRadius=27.000000
     ColHeight=25.000000
     SeveredArmAttachScale=1.100000
     SeveredLegAttachScale=1.200000
     SeveredHeadAttachScale=1.500000
     PlayerCountHealthScale=0.750000
     BurningWalkFAnims(0)="WalkF"
     BurningWalkFAnims(1)="WalkF"
     BurningWalkFAnims(2)="WalkF"
     BurningWalkAnims(0)="WalkF"
     BurningWalkAnims(1)="WalkF"
     BurningWalkAnims(2)="WalkF"
     OnlineHeadshotOffset=(X=28.000000,Z=70.000000)
     OnlineHeadshotScale=1.500000
     MotionDetectorThreat=10.000000
     bOnlyDamagedByCrossbow=True
     bBoss=True
     ScoringValue=500
     IdleHeavyAnim="BossIdle"
     IdleRifleAnim="BossIdle"
     RagDeathVel=80.000000
     RagDeathUpKick=100.000000
     MeleeRange=10.000000
     GroundSpeed=110.000000
     WaterSpeed=100.000000
     HealthMax=15000.000000
     Health=15000
     HeadScale=1.500000
     MenuName="Patriarch KF2"
     MovementAnims(0)="WalkF"
     MovementAnims(1)="WalkF"
     MovementAnims(2)="WalkF"
     MovementAnims(3)="WalkF"
     AirAnims(0)="JumpInAir"
     AirAnims(1)="JumpInAir"
     AirAnims(2)="JumpInAir"
     AirAnims(3)="JumpInAir"
     TakeoffAnims(0)="JumpTakeOff"
     TakeoffAnims(1)="JumpTakeOff"
     TakeoffAnims(2)="JumpTakeOff"
     TakeoffAnims(3)="JumpTakeOff"
     LandAnims(0)="JumpLanded"
     LandAnims(1)="JumpLanded"
     LandAnims(2)="JumpLanded"
     LandAnims(3)="JumpLanded"
     AirStillAnim="JumpInAir"
     TakeoffStillAnim="JumpTakeOff"
     IdleCrouchAnim="BossIdle"
     IdleWeaponAnim="BossIdle"
     IdleRestAnim="BossIdle"
     DrawScale=1.150
     PrePivot=(Z=-43.000000)
     SoundVolume=100
     bNetNotify=False
     Mass=1500.000000
     RotationRate=(Yaw=36000,Roll=0)
	 DeathAnims(0)="Dead"
     DeathAnims(1)="Dead"
     DeathAnims(2)="Dead"
     DeathAnims(3)="Dead"
	 
	 RagdollLifeSpan=30.000000	
     Intelligence=BRAINS_Mammal	 
	 CollisionRadius=40.0
	 CollisionHeight=40.0
	 ExtCollAttachBoneName="Root"	
	 MeleeAnims(0)="MeleeClaw"
     MeleeAnims(1)="MeleeNoga"
     MeleeAnims(2)="MeleePlecho"
	 MeleeAnims(3)="MeleeImpale"
	 MeleeAnims(4)="RadialAttack"
	 NeckBone="neck"
	 RootBone="Root"
     HeadBone="head"
	 LeftFArmBone="LeftForearm"
	 RightThighBone="RightLeg"
//	 FireRootBone="Spine1"
	 FootstepVolume=2.000000
	 AmbientGlow=0	 
}
