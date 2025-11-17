Class Lineage2Monster extends KFMonster
	abstract;

var() bool bLeadTarget;
var() float AimingError;
var() class<Projectile> RangedProjectile;
var() class<Actor> GibbedEffect;
var() array<Sound> GibbedSounds;
var() Sound ThumpSound;
var transient float LastFireTime;
var byte ClientFire[2];
var bool bFreezeMovement,bLockMotion,bClientAllowAnim;
var Sound AttackSound; 

replication
{
	reliable if( Role<ROLE_Authority )
		ServerStartFire,ServerStopFire;
	reliable if( Role==ROLE_Authority )
		ClientPlayAnim;
}

function PostNetReceive();
function Setup(xUtil.PlayerRecord rec, optional bool bLoadNow);
function DoDamageFX( Name boneName, int Damage, class<DamageType> DamageType, Rotator r );
function ProcessHitFX();
function RemoveHead();

function bool ReadyToAttack( Actor A )
{
	return false;
}
function Projectile FireProjectileX( vector Offset )
{
	local vector X,Y,Z;

	if( Level.NetMode==NM_Client )
		return None;
	if( LastFireTime!=Level.TimeSeconds )
	{
		PlaySound(FireSound,SLOT_Misc);
		LastFireTime = Level.TimeSeconds;
	}
	if( RangedProjectile==None )
		return None;
	GetAxes(Rotation,X,Y,Z);
	Offset = Location + Offset.X*X*CollisionRadius + Offset.Y*Y*CollisionRadius + Offset.Z*Z*CollisionHeight;

	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = class'LAWAmmo';
		SavedFireProperties.ProjectileClass = RangedProjectile;
		SavedFireProperties.WarnTargetPct = 0.2f;
		SavedFireProperties.MaxRange = RangedProjectile.Static.GetRange();
		SavedFireProperties.bTossed = (RangedProjectile.Default.Physics==PHYS_Falling);
		SavedFireProperties.bTrySplash = (RangedProjectile.Default.DamageRadius>50.f);
		SavedFireProperties.bLeadTarget = bLeadTarget;
		SavedFireProperties.bInstantHit = false;
		SavedFireProperties.bInitialized = true;
	}
	if( Controller==None )
		return Spawn(RangedProjectile,,,Offset);
	return Spawn(RangedProjectile,,,Offset,Controller.AdjustAim(SavedFireProperties,Offset,AimingError));
}
function float GetDesireability( Pawn Other )
{
	local float D;
	
	D = VSize(Other.Location-Location);
	if( Controller.LineOfSightTo(Other) )
		D*=0.35f;
	return D;
}
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	AmbientSound = None;
    bCanTeleport = false; // sjs - fix karma going crazy when corpses land on teleporters
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;

    if (CurrentCombo != None)
        CurrentCombo.Destroy();

	HitDamageType = DamageType; // these are replicated to other clients
    TakeHitLocation = HitLoc;

    // stop shooting
    AnimBlendParams(1, 0.0);
    FireState = FS_None;
	LifeSpan = RagdollLifeSpan;

    GotoState('ZombieDying');

	if( MyExtCollision!=None )
		MyExtCollision.Destroy();
		
	//if ( ((DamageType != None) && DamageType.default.bAlwaysGibs) || Health>(-Mass) )
	//	ChunkUp( Rotation, DamageType.default.GibPerterbation );
	//else PlayDyingAnimation(DamageType, HitLoc);
	PlayDyingAnimation(DamageType, HitLoc);
}
simulated function PlayDyingAnimation(class<DamageType> DamageType, vector HitLoc)
{
	local vector shotDir, hitLocRel, deathAngVel, shotStrength;
	local KarmaParamsSkel skelParams;

	if ( Level.NetMode!=NM_DedicatedServer && Level.PhysicsDetailLevel!=PDL_Low && RagdollOverride!="" )
	{
		KMakeRagdollAvailable();

		if( KIsRagdollAvailable() )
		{
			skelParams = KarmaParamsSkel(KParams);
			skelParams.KSkeleton = RagdollOverride;

			// Stop animation playing.
			StopAnimating(true);

			// StopAnimating() resets the neck bone rotation, we have to set it again
			// if the zed was decapitated the cute way
			if ( class'GameInfo'.static.UseLowGore() && NeckRot != rot(0,0,0) )
				SetBoneRotation('neck', NeckRot);

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
				skelParams.KShotStart = TakeHitLocation - (1 * shotDir);
				skelParams.KShotEnd = TakeHitLocation + (2*FMax(CollisionRadius, CollisionHeight)*shotDir);
				skelParams.KShotStrength = RagShootStrength;
			}

			//log("RagDeathVel = "$RagDeathVel$" KShotStrength = "$skelParams.KShotStrength$" RagDeathUpKick = "$RagDeathUpKick);

			// If this damage type causes convulsions, turn them on here.
			if(DamageType != none && DamageType.default.bCauseConvulsions)
			{
				RagConvulseMaterial=DamageType.default.DamageOverlayMaterial;
				skelParams.bKDoConvulsions = False;
			}

			// Turn on Karma collision for ragdoll.
			KSetBlockKarma(true);

			// Set physics mode to ragdoll.
			// This doesn't actaully start it straight away, it's deferred to the first tick.
			SetPhysics(PHYS_KarmaRagdoll);

			skelParams.bRubbery = DamageType.Default.bRubbery;
			bRubbery = DamageType.Default.bRubbery;

			skelParams.KActorGravScale = RagGravScale;

			return;
		}
		// jag
	}
	// non-ragdoll death fallback
	Velocity += GetTearOffMomemtum();
	if( VSizeSquared(Velocity)>250000.f )
		Velocity = Normal(Velocity)*500.f;
	BaseEyeHeight = Default.BaseEyeHeight;
	SetTwistLook(0, 0);
	SetInvisibility(0.0);
	PlayDyingAnim(DamageType,HitLoc);
	SetPhysics(PHYS_Falling);
}

simulated final function ClientPlayAnim( name N )
{
	if( Level.NetMode!=NM_Client )
		return;
	bClientAllowAnim = true;
	SetAnimAction(N);
	bClientAllowAnim = false;
}

simulated event SetAnimAction(name NewAction)
{
	if( NewAction=='' )
		Return;
	if( Level.NetMode==NM_Client && !bClientAllowAnim && Level.GetLocalPlayerController()==Controller )
		return;

	ExpectingChannel = DoAnimAction(NewAction);

	if( AnimNeedsWait(NewAction) )
		bWaitForAnim = true;
	else bWaitForAnim = false;

	if( Level.NetMode!=NM_Client )
	{
		AnimAction = NewAction;
		bResetAnimAct = True;
		ResetAnimActTime = Level.TimeSeconds+0.15;
		
		if( PlayerController(Controller)!=None && NetConnection(PlayerController(Controller).Player)!=None )
			ClientPlayAnim(AnimAction);
	}
}

simulated function Fire( optional float F )
{
	ClientFire[0] = 1;
	ServerStartFire(0);
}
simulated function AltFire( optional float F )
{
	ClientFire[1] = 1;
	ServerStartFire(1);
}
function ServerStartFire( byte Mode )
{
	ClientFire[Mode] = 1;

	if( !bShotAnim )
		SetAttackAnim();
}
function SetAttackAnim();

function ServerStopFire( byte Mode )
{
	ClientFire[Mode] = 0;
}

simulated function int DoAnimAction( name AnimName )
{
	PlayAnim(AnimName,,0.1);
	return 0;
}

final function Actor GetBestMeleeTarget()
{
	local Actor A;
	local Pawn P;
	local float Aim,Dist;
	local vector Dir,HL,HN,StartPos;

	Aim = 0.6f;
	Dir = vector(Controller.Rotation);
	StartPos = Location+(Dir*CollisionRadius*0.9f);
	HN.X = CollisionRadius*0.75;
	HN.Y = HN.X;
	HN.Z = CollisionHeight*0.5;
	foreach TraceActors(Class'Pawn',P,HL,HN,Location+Dir*100.f,Location,HN)
		if( P.Health>0 && Monster(P)==None && FastTrace(Location,P.Location) )
			return P;
	P = Controller.PickTarget(Aim,Dist,Dir,Location,100.f);
	if( P!=None && FastTrace(Location,P.Location) )
		return P;
	StartPos = Location+(Dir*CollisionRadius*0.9f);
	A = Trace(HL,HN,StartPos+Dir*50.f,StartPos,true);
	if( Pawn(A)!=None || Mover(A)!=None )
		return A;
	return None;
}
final function Actor GetBestRangedTarget()
{
	local float Aim,Dist;
	local vector Dir;

	Aim = 0.6f;
	Dir = vector(Controller.Rotation);
	return Controller.PickTarget(Aim,Dist,Dir,Location,10000.f);
}

simulated function AnimEnd(int Channel)
{
	bFreezeMovement = false;
	bLockMotion = false;
	if( Channel==0 )
		bWaitForAnim = false;
	Super.AnimEnd(Channel);
	if( Level.NetMode!=NM_Client && PlayerController(Controller)!=None && !bShotAnim && (ClientFire[0]!=0 || ClientFire[1]!=0) )
		SetAttackAnim();
}

function bool FlipOver()
{
	return false;
}

simulated function Tick( float Delta )
{
	Super.Tick(Delta);
	if( Health>=0 && PlayerController(Controller)!=None && Viewport(PlayerController(Controller).Player)!=None )
	{
		if( ClientFire[0]!=0 && Controller.bFire==0 )
		{
			ClientFire[0] = 0;
			ServerStopFire(0);
		}
		else if( ClientFire[1]!=0 && Controller.bAltFire==0 )
		{
			ClientFire[1] = 0;
			ServerStopFire(1);
		}
	}
}
simulated function RawInput(float DeltaTime,
							float aBaseX, float aBaseY, float aBaseZ, float aMouseX, float aMouseY,
							float aForward, float aTurn, float aStrafe, float aUp, float aLookUp)
{
	if( bFreezeMovement )
	{
		PlayerController(Controller).aForward = 0;
		PlayerController(Controller).aStrafe = 0;
		PlayerController(Controller).bPressedJump = false;
	}
	else if( bLockMotion )
	{
		PlayerController(Controller).bPressedJump = false;
		PlayerController(Controller).aStrafe = 0;
	}
}
simulated function PlayDyingAnim(class<DamageType> DamageType, vector HitLoc)
{
	PlayAnim(DeathAnim[Rand(4)]);
}

singular event BaseChange()
{
	if ( (base == None) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	// Pawns can only set base to non-pawns, or pawns which specifically allow it.
	// Otherwise we do some damage and jump off.
	else if ( Pawn(Base) != None && Base != DrivenVehicle )
	{
		if ( !Pawn(Base).bCanBeBaseForPawns )
		{
			Base.TakeDamage( (1-Velocity.Z/400)* Mass/Base.Mass, Self,Location,0.5 * Velocity , class'Crushed');
			JumpOffPawn();
		}
	}
	else if ( (Decoration(Base) != None) && (Velocity.Z < -400) )
		Base.TakeDamage((-2* Mass/FMax(Base.Mass, 1) * Velocity.Z/400), Self, Location, 0.5 * Velocity, class'Crushed');
}

final function bool InMeleeRange( Actor A, optional float AddedDist )
{
	local vector V;
	
	if( Pawn(A)==None )
		return true;
	AddedDist+=MeleeRange;
	V = A.Location-Location;
	return (V.Z<(CollisionHeight+A.CollisionHeight+AddedDist)
	 && (Square(V.X)+Square(V.Y))<Square(CollisionRadius+A.CollisionRadius+AddedDist));
}
function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
	if( Level.NetMode!=NM_Client && PlayerController(Controller)!=None )
		Controller.Target = GetBestMeleeTarget();

	if( Level.NetMode==NM_Client || Controller==None || Controller.Target==None )
		Return False; // Never should be done on client.

	if ( !Controller.Target.IsA('Pawn') || (InMeleeRange(Controller.Target,MeleeRange*0.4f) && FastTrace(Controller.Target.Location,Location)) )
	{
		Controller.Target.TakeDamage(hitdamage,Self,Normal(Controller.Target.Location-Location)*CollisionRadius+Location,pushdir,CurrentDamtype);
		Return True;
	}
	return false;
}

function DoorAttack(Actor A)
{
	RangedAttack(A);
}
function HandleBumpGlass()
{
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, optional int HitIndex )
{
	local bool bIsHeadshot;
	local KFPlayerReplicationInfo KFPRI;
	local float HeadShotCheckScale;

	LastDamagedBy = instigatedBy;
	LastDamagedByType = damageType;
	HitMomentum = VSize(momentum);
	LastHitLocation = hitlocation;
	LastMomentum = momentum;

	if ( KFPawn(instigatedBy)!=none && instigatedBy.PlayerReplicationInfo != none )
		KFPRI = KFPlayerReplicationInfo(instigatedBy.PlayerReplicationInfo);

	// Scale damage if the Zed has been zapped
    if( bZapped )
        Damage *= ZappedDamageMod;

	// Zeds and fire dont mix.
	if ( class<KFWeaponDamageType>(damageType)!=None && class<KFWeaponDamageType>(damageType).default.bDealBurningDamage )
    {
        if( BurnDown<=0 || Damage > LastBurnDamage )
        {
			 // LastBurnDamage variable is storing last burn damage (unperked) received,
			// which will be used to make additional damage per every burn tick (second).
			LastBurnDamage = Damage;

			// FireDamageClass variable stores damage type, which started zed's burning
			// and will be passed to this function again every next burn tick (as damageType argument)
			FireDamageClass = damageType;
        }
		if ( class<DamTypeMAC10MPInc>(damageType) == none )
            Damage *= 1.5; // Increase burn damage 1.5 times, except MAC10.

        // BurnDown variable indicates how many ticks are remaining for zed to burn.
        // It is 0, when zed isn't burning (or stopped burning).
        // So all the code below will be executed only, if zed isn't already burning
        if( BurnDown<=0 )
        {
            if( HeatAmount>4 || Damage >= 15 )
            {
                bBurnified = true;
                BurnDown = 10; // Inits burn tick count to 10
                SetGroundSpeed(GroundSpeed *= 0.80); // Lowers movement speed by 20%
                BurnInstigator = instigatedBy;
                SetTimer(1.0,false); // Sets timer function to be executed each second
            }
            else HeatAmount++;
        }
    }

	if ( !bDecapitated && class<KFWeaponDamageType>(damageType)!=none && class<KFWeaponDamageType>(damageType).default.bCheckForHeadShots )
	{
		HeadShotCheckScale = 1.0;

		// Do larger headshot checks if it is a melee attach
		if( class<DamTypeMelee>(damageType) != none )
			HeadShotCheckScale *= 1.25;

		bIsHeadShot = IsHeadShot(hitlocation, normal(momentum), HeadShotCheckScale);
	}

	if ( KFPRI!=none && KFPRI.ClientVeteranSkill != none )
		Damage = KFPRI.ClientVeteranSkill.Static.AddDamage(KFPRI, self, KFPawn(instigatedBy), Damage, DamageType);

	if ( LastDamagedBy!=none && LastDamagedBy.IsPlayerPawn() && LastDamagedBy.Controller!=none )
	{
		if ( KFMonsterController(Controller) != none )
			KFMonsterController(Controller).AddKillAssistant(LastDamagedBy.Controller, FMin(Health, Damage));
	}

	if ( bIsHeadShot && class<DamTypeBurned>(DamageType) == none && class<DamTypeFlamethrower>(DamageType) == none )
	{
		if(class<KFWeaponDamageType>(damageType)!=none)
			Damage = Damage * class<KFWeaponDamageType>(damageType).default.HeadShotDamageMult;

		if ( class<DamTypeMelee>(damageType) == none && KFPRI != none &&
			 KFPRI.ClientVeteranSkill != none )
		{
            Damage = float(Damage) * KFPRI.ClientVeteranSkill.Static.GetHeadShotDamMulti(KFPRI, KFPawn(instigatedBy), DamageType);
		}

		LastDamageAmount = Damage;
	}

	if( class<DamTypeVomit>(DamageType)!=none ) // Same rules apply to zombies as players.
	{
		BileCount=7;
		BileInstigator = instigatedBy;
		if(NextBileTime< Level.TimeSeconds )
			NextBileTime = Level.TimeSeconds+BileFrequency;
	}

	if ( KFPRI != none && Health-Damage <= 0 && KFPRI.ClientVeteranSkill != none && KFPRI.ClientVeteranSkill.static.KilledShouldExplode(KFPRI, KFPawn(instigatedBy)) )
	{
		Super(Monster).TakeDamage(Damage + 600, instigatedBy, hitLocation, momentum, damageType);
		HurtRadius(500, 1000, class'DamTypeFrag', 100000, Location);
	}
	else Super(Monster).takeDamage(Damage, instigatedBy, hitLocation, momentum, damageType);
	bBackstabbed = false;
}

simulated function SpawnGibs(Rotator HitRotation, float ChunkPerterbation)
{
	bGibbed = true;
	
	if( Level.NetMode!=NM_DedicatedServer )
	{
		Spawn(GibbedEffect);
		PlaySound(GibbedSounds[Rand(GibbedSounds.Length)],SLOT_Pain);
	}
	if( Level.NetMode==NM_Client || Level.NetMode==NM_StandAlone )
		Destroy();
	else
	{
		LifeSpan = 2.f;
		SetDrawType(DT_None);
		SetCollision(false,false,false);
	}
}

function bool DoJump( bool bUpdating )
{
	if ( !bIsCrouched && !bWantsToCrouch && ((Physics == PHYS_Walking) || (Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) )
	{
		PlayOwnedSound(JumpSound, SLOT_Pain, GruntVolume,,80);

		if ( Physics == PHYS_Spider )
			Velocity = JumpZ * Floor;
		else if ( Physics == PHYS_Ladder )
			Velocity.Z = 0;
		else if ( bIsWalking )
			Velocity.Z = Default.JumpZ;
		else Velocity.Z = JumpZ;

		if ( (Base != None) && !Base.bWorldGeometry )
			Velocity += Base.Velocity;
		if( bCanFly )
		{
			SetPhysics(PHYS_Flying);
			if( IsHumanControlled() )
				Controller.GoToState('PlayerFlying');
		}
		else SetPhysics(PHYS_Falling);
		return true;
	}
	return false;
}

function SetBurningBehavior()
{
	Intelligence = BRAINS_Retarded; // burning dumbasses!
	SetGroundSpeed(OriginalGroundSpeed * 0.8);

	// Make them less accurate while they are burning
	if( MonsterController(Controller) != none )
		MonsterController(Controller).Accuracy = -5;  // More chance of missing. (he's burning now, after all) :-D
}
simulated function UnSetBurningBehavior()
{
    // Don't turn off this behavior until the harpoon stun is over
    if( bHarpoonStunned )
        return;

	if ( Role == Role_Authority )
	{
		Intelligence = default.Intelligence;

		if( !bZapped )
    		SetGroundSpeed(GetOriginalGroundSpeed());

		// Set normal accuracy
		if ( MonsterController(Controller) != none )
			MonsterController(Controller).Accuracy = MonsterController(Controller).default.Accuracy;
	}

	bAshen = False;
}
function SetZappedBehavior()
{
	Intelligence = BRAINS_Retarded; // burning dumbasses!

	SetGroundSpeed(OriginalGroundSpeed * ZappedSpeedMod);

	// Make them less accurate while they are burning
	if( MonsterController(Controller) != none )
		MonsterController(Controller).Accuracy = -5;  // More chance of missing. (he's burning now, after all) :-D
}
function UnSetZappedBehavior()
{
	Intelligence = default.Intelligence;

	if( bBurnified )
		SetGroundSpeed(GetOriginalGroundSpeed() * 0.80);
	else SetGroundSpeed(GetOriginalGroundSpeed());

	// Set normal accuracy
	if ( MonsterController(Controller) != none )
		MonsterController(Controller).Accuracy = MonsterController(Controller).default.Accuracy;
}

function LandThump();
function StartDeRes();

simulated function ShrinkBodyCollision()
{
	SetCollisionSize(CollisionRadius,CollisionHeight/6);
}

State ZombieDying
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, Died, RangedAttack, Tick;

	simulated function Landed(vector HitNormal)
	{
		SetPhysics(PHYS_None);
		if ( !IsAnimating(0) )
			LandThump();
	}
	simulated function LandThump()
	{
		local float impact,dist,shake;
		local vector Momentum,Shk;
		local PlayerController PC;
		local Controller C;

		// animation notify - play sound if actually landed, and animation also shows it
		if( Physics == PHYS_None && !bThumped )
		{
			bThumped = true;
			if( bHidden || (PhysicsVolume!=None && PhysicsVolume.bWaterVolume) )
				Return;
				
			impact = 0.75 + Velocity.Z * 0.004;
			impact = Mass * impact * impact * 0.015;
			PlaySound(ThumpSound,SLOT_None,impact);
			if ( Mass >= 500 )
			{
				if( Level.NetMode!=NM_Client )
				{
					For( C=Level.ControllerList; C!=None; C=C.NextController )
					{
						if( C.Pawn==None || C.Pawn==Self || C.Pawn.Physics!=PHYS_Walking )
							Continue;
						dist = VSize(Location - C.Pawn.Location);
						if( dist>1500 )
							Continue;
						Momentum = -0.5 * C.Pawn.Velocity + 100 * VRand();
						Momentum.Z =  7000000.0/((0.4 * dist + 350) * C.Pawn.Mass);
						C.Pawn.AddVelocity(Momentum);
					}
				}
				if( Level.NetMode!=NM_DedicatedServer )
				{
					PC = Level.GetLocalPlayerController();
					if( PC==None )
						Return;
					dist = VSize(Location - PC.CalcViewLocation);
					shake = FMax(500, 1500 - dist);
					Shk.X = shake*(FRand()+0.5);
					if( FRand()<0.5 )
						Shk.X*=-1;
					Shk.Y = shake*(FRand()+0.5);
					if( FRand()<0.5 )
						Shk.Y*=-1;
					Shk.Z = shake*(FRand()+0.5);
					if( FRand()<0.5 )
						Shk.Z*=-1;
					PC.ShakeView(Shk,vect(8000,8000,8000),2.5,VRand()*shake*0.025,vect(9000,9000,9000),0.4);
				}
			}
			if( Level.NetMode==NM_DedicatedServer )
				LifeSpan = 1.f;
		}
	}
	simulated function Timer()
	{
		if ( (Level.TimeSeconds-LastRenderTime)>5 && LifeSpan<15 )
			Destroy();
 	}
	simulated function ReduceCylinder()
	{
		local float OlCH;
		local vector M;

		OlCH = CollisionHeight;
		ShrinkBodyCollision();
		if( OlCH!=CollisionHeight )
		{
			M.Z = (OlCH-(CollisionHeight/OlCH)*OlCH);
			PrePivot+=M;
			Move(-M);
		}
	}
	simulated function AnimEnd( int Channel )
	{
		ReduceCylinder();
		if( !bThumped )
			LandThump();
	}
	simulated function BeginState()
	{
		DesiredRotation = Rotation;
		DesiredRotation.Roll = 0;
		DesiredRotation.Pitch = 0;

		if( Level.NetMode==NM_DedicatedServer )
			SetCollision(false);
		else SetCollision(true,false,false);

        if( bDestroyNextTick )
        {
            // If we've flagged this character to be destroyed next tick, handle that
            if( TimeSetDestroyNextTickTime < Level.TimeSeconds )
                Destroy();
            else SetTimer(0.01, false);
        }
        else SetTimer(2.0, false);
 	}

	simulated function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex )
	{
		local Vector shotDir;
		local Vector PushLinVel, PushAngVel;

		if ( bFrozenBody || bRubbery )
			return;

		if( Physics == PHYS_KarmaRagdoll )
		{
			// Throw the body if its a rocket explosion or shock combo
			if( damageType.Default.bThrowRagdoll )
			{
				shotDir = Normal(Momentum);
				PushLinVel = (RagDeathVel * shotDir) +  vect(0, 0, 250);
				PushAngVel = Normal(shotDir Cross vect(0, 0, 1)) * -18000;
				KSetSkelVel( PushLinVel, PushAngVel );
			}
			else if( damageType.Default.bRagdollBullet )
			{
				if ( Momentum == vect(0,0,0) )
					Momentum = HitLocation - InstigatedBy.Location;
				if ( FRand() < 0.65 )
				{
					if ( Velocity.Z <= 0 )
						PushLinVel = vect(0,0,40);
					PushAngVel = Normal(Normal(Momentum) Cross vect(0, 0, 1)) * -8000 ;
					PushAngVel.X *= 0.5;
					PushAngVel.Y *= 0.5;
					PushAngVel.Z *= 4;
					KSetSkelVel( PushLinVel, PushAngVel );
				}
				PushLinVel = RagShootStrength*Normal(Momentum);
				KAddImpulse(PushLinVel, HitLocation);
				if ( (LifeSpan > 0) && (LifeSpan < DeResTime + 2) )
					LifeSpan += 0.2;
			}
			else
			{
				PushLinVel = RagShootStrength*Normal(Momentum);
				KAddImpulse(PushLinVel, HitLocation);
			}
		}

		if (Damage > 99999999999999 )
		{
			if( !bGibbed && (Health-=Damage)<(-Mass) )
				SpawnGibs(Rotation,2.f);

			// Actually do blood on a client
			PlayHit(Damage, InstigatedBy, hitLocation, damageType, Momentum);
		}
	}
}

defaultproperties
{
}
