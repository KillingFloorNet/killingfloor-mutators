//======================================================================
// Doom pawns			-Written by Marco
//======================================================================
class DoomPawns extends KFMonster
	Abstract;

// Import meshes and parent packages..
#exec obj load file="Models\DoomMeshes.usx" package="DoomPawnsKF"

// Should not be modifyed druing gameplay
var() editconst const class<DPawnDisplay> RenderingClass;
var DPawnDisplay Render;
var() editconst const texture WalkTextures[8],ShootTextures[8],DieTexture;
var() editconst const material DeadEndTexture;
var() editconst const float DeathSpeed,DieSizeChange;
var() class<Projectile> RangedProjectile;
var() class<Pickup> DropWhenKilled;
var() class<DamageType> MeleeDamageType;
var() int PawnHealth;
var(Sounds) sound Acquire2,Die2,Roam,Die,Acquire,Fear,Threaten,HitSound1,HitSound2;
// Idle texture??!! hmm... they dont have one.
// Replicated animation number variable...
var byte AnimChange;
var byte LastRotation;
var bool bDidDied,bCarcassMe,bNotFirstTimer,bFastMonster,bForceUnlit;
var Actor FirstOrder;
struct IntRange
{
	var() int Min,Max;
};
var(DoomCombat) IntRange NumFiresAtOnce,DeMeleeDamage;
var(DoomCombat) bool bConstFiring,bHasMelee,bHasRangedAttack,bArchCanRes,bCanPreformFF;
var(DoomCombat) float PauseAfterShooting,StartMeleeRange;
var(DoomPistol) class<Effects> WallHitEffect;
var(DoomPistol) float RefireSpeed;
var(DoomPistol) IntRange HitDamage;
var(Filter) bool bOnEasy,bOnMedium,bOnHard;
var class<DamageType> ShotDamageType;
var DemonTeleport TeleportList;
var InitialPose InitPose;
var byte OldAnimStuff;
var bool bWasValidController,bAllowedToFire,bClientIsFiring,bAllowNetNotify,bHandelShading,bIsOnShader,bClientSideFiring,bRespawnMe;
var Controller OldControllers;
var float OldClientDrawScale;
var Material OldOverlaySkin;
var array<Material> OrginalSkins;
var Controller MyRealController;

replication
{
	// Things the server should send to the client.
	unreliable if( bNetDirty && Role==ROLE_Authority )
		AnimChange,bDidDied,bFastMonster;
	reliable if( Role<ROLE_Authority )
		PlayerFired,ServerStopFiring;
}

function RemoveHead();
function PlayMoverHitSound();
function int PickNumFires()
{
	Return GetFromRange(NumFiresAtOnce);
}
function int GetFromRange( IntRange R )
{
	if( R.Min>=R.Max )
		Return R.Min;
	Return R.Min+(R.Max-R.Min)*FRand();
}
simulated function ProcessHitFX();
simulated function PostBeginPlay() // Called on both server and client side.
{
	if( Level.NetMode!=NM_Client && KFSPGameType(Level.Game)!=None )
	{
		// Difficulty level filtering.
		if( (!bOnEasy && Level.Game.GameDifficulty<2)
		 || (!bOnMedium && Level.Game.GameDifficulty>=2 && Level.Game.GameDifficulty<4)
		 || (!bOnHard && Level.Game.GameDifficulty>=4) )
		{
			Destroy();
			return;
		}
		if( Level.Game.GameDifficulty>=6 )
		{
			bFastMonster = true;
			bRespawnMe = true;
		}
	}
	SetDrawType(DT_Mesh);
	Render = Spawn(RenderingClass,Self,,Location,Rotation);
	if( Render==None && Level.NetMode!=NM_Client )
	{
		Error("Failed spawn"@RenderingClass);
		Return;
	}
	OldClientDrawScale = DrawScale;
	Render.Renderer = Self;
	Render.Initialized();
	Super.PostBeginPlay();
	if( Level.NetMode!=NM_Client )
	{
		if( PawnHealth!=Default.PawnHealth )
			Health = PawnHealth;
		if( Level.Game.IsA('Invasion') && !Level.Game.IsA('KFSPGameType') && DoomController(Controller)!=None )
			DoomController(Controller).bActLikeInv = True;
		if( DoomController(Controller)!=None && DoomController(Controller).bActLikeInv )
			InitInvasionMode();
		if( Level.bStartUp )
			AssignInitialStartup();
	}
}
function AssignInitialStartup()
{
	local InitialPose I;

	I = Spawn(class'InitialPose',,,Location,Rotation);
	if( I==None )
		Return;
	I.Event = Event;
	I.Tag = Tag;
	I.InitialHealth = Health;
	I.PawnClass = Class;
	I.TeleportList = TeleportList;
	InitPose = I;
}
function Reset()
{
	Destroy();
}
function InitInvasionMode()
{
	JumpZ = FMax(JumpZ,350.f);
	bCanDodgeDoubleJump = True;
	MaxMultiJump = 2;
	bCanWallDodge = True;
	DamageScaling = 0.3; // Reduce damage for Invasion
}
function bool IsPlayerPawn()
{
	if( Controller!=None && DoomController(Controller)!=None && DoomController(Controller).bActLikeInv )
		Return True;
	Return False;
}
simulated function Destroyed()
{
	ResetShaderSkin();
	if( Render!=None )
	{
		Render.Renderer = None; // Make sure no loops happen.
		Render.Destroy();
		Render = None;
	}
	Super.Destroyed();
}
// Notify on client and server host about animation change.
simulated function NotifyAnimation( byte AnimNum )
{
	if( AnimNum==2 )
		Render.SetAnimatedTime(2,1);
	else
	{
		Render.TimeLeft = 0;
		Render.LastCheckB = 9;
	}
}

// Set rotation of animation, aswell called when playing some framed animation.
simulated function UpdateAnimation( byte MyRot, optional int FrameNum )
{
	if( AnimChange==0 )
		UpdateSkin(WalkTextures[MyRot]);
	else if( AnimChange==1 )
		UpdateSkin(ShootTextures[MyRot]);
	else UpdateSkin(DieTexture);
}
// Should mirror the image?
simulated function bool MirrorMe( byte Dir )
{
	Return False;
}
// Return the anim lenght time in seconds.
// 'Walk' may also be used at when floating and moving.
function float PlayMyAnim( name MyAnimName )
{
	if( MyAnimName=='Walk' || MyAnimName=='Fall' )
	{
		AnimChange = 0;
		Return 0;
	}
	else if( MyAnimName=='Still' )
	{
		AnimChange = 1;
		Return 0.5;
	}
	else if( MyAnimName=='Fire' || MyAnimName=='Melee' )
	{
		AnimChange = 2;
		Return 1;
	}
}
// A second timer function...
function CallTimer( float Seconds, bool bLooping )
{
	if( bFastMonster )
		Render.SetTimer(Seconds/2,bLooping);
	else Render.SetTimer(Seconds,bLooping);
}
function StopTimer()
{
	Render.SetTimer(0,False);
}
function TimedReply();

function NotifyDead()
{
	if( !bDeleteMe )
		Destroy();
}

State Dying
{
Ignores MirrorMe,TimedReply,UpdateAnimation;

	function Timer();

	event Landed(vector HitNormal)
	{
		SetPhysics(PHYS_None);
	}

	function BeginState()
	{
		if( IsBeingControlled() )
			DeAttachPlayer();
		if( Level.NetMode==NM_Client )
			return;
		bDidDied = True;
		Render.LifeSpan = DeathSpeed;
		SetCollision(false,false,false);
		DropKillableStuff();
		if( bRespawnMe && InitPose!=None )
			InitPose.SetTimer(30,false);
	}
	function NotifyDead()
	{
		local DoomCarcass carc;

		Render = None;
		if( !bCarcassMe )
		{
			Destroy();
			Return;
		}
		carc = Spawn(class'DoomCarcass');
		if ( carc != None )
		{
			carc.Initfor(Class);
			if( InitPose!=None )
				InitPose.MyCarcass = carc;
		}
		if( !bDeleteMe )
			Destroy();
	}
}
function DropKillableStuff()
{
	local Pickup P;

	if( DropWhenKilled==None )
		Return;
	P = Spawn(DropWhenKilled);
	if( P==None )
		Return;
	DropWhenKilled = None;
	P.InitDroppedPickupFor(None);
	P.Velocity = VRand()*100;
	if( Ammo(P)!=None )
		Ammo(P).AmmoAmount/=2;
	else if( WeaponPickup(P)!=None && Class<Weapon>(P.InventoryType)!=None && Class<Weapon>(P.InventoryType).Default.AmmoClass[0]!=None )
		WeaponPickup(P).AmmoAmount[0] = Class<Weapon>(P.InventoryType).Default.AmmoClass[0].Default.InitialAmount/2; // Drop only a half clip
}
function PlayAcquisitionSound()
{
	if( Acquire2!=None && FRand()<0.5 )
		PlaySound(Acquire2, SLOT_Talk,, true); 
	else if (Acquire != None) 
		PlaySound(Acquire, SLOT_Talk,, true); 
}
event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	if( Die2!=None && FRand()<0.5 )
		PlaySound(Die2, SLOT_Talk, 2.5 * TransientSoundVolume);
	else if( Die!=None )
		PlaySound(Die, SLOT_Talk, 2.5 * TransientSoundVolume);
	AmbientSound = None;
	GotoState('Dying');
	Velocity += TearOffMomentum;
	SetPhysics(PHYS_Falling);
	bPlayedDeath = true;
	LightType = LT_None;
	if( Controller!=None )
	{
		Controller.Pawn = None;
		Controller.Destroy();
		Controller = None;
	}
}
simulated function SetOverlayMaterial( Material mat, float time, bool bOverride );
function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, optional int HI )
{
	if ( DamageType == None )
		return;
	if ( (Damage <= 0) && ((Controller == None) || !Controller.bGodMode) )
		return;
	PlayTakeHit(HitLocation,Damage,DamageType);
}
function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
	Spawn(class'BloodSplatEffect',,,HitLocation);
	if( Level.TimeSeconds<LastPainSound )
		return;

	LastPainSound = Level.TimeSeconds+MinTimeBetweenPainSounds;

	if( HitSound2!=None && FRand()<0.5 )
		PlaySound( HitSound2, SLOT_Pain,1.5*TransientSoundVolume );
	else PlaySound( HitSound1, SLOT_Pain,1.5*TransientSoundVolume );
	HandelDamageOverlay(DamageType);
}
simulated function HandelDamageOverlay( class<DamageType> Other )
{
	if( Other==None || Other.Default.DamageOverlayMaterial==None || Other.Default.DamageOverlayTime<=0 || Mass>500 ) Return;
	if( Level.NetMode!=NM_Client )
	{
		SetOverlayMaterial(Other.Default.DamageOverlayMaterial,Other.Default.DamageOverlayTime,true);
		if( Level.NetMode==NM_DedicatedServer )
			Return;
	}
	if( (Level.TimeSeconds-LastRenderTime)<1 )
	{
		OverlayMaterial = Other.Default.DamageOverlayMaterial;
		ClientOverlayCounter = Other.Default.DamageOverlayTime;
	}
}
function bool SameSpeciesAs(Pawn P)
{
	return (P.Class==Class);
}
function FirePistol(vector StartOffset, float Accuracy)
{
	local vector X,Y,Z, projStart, End,HitN,HitL;
	local Actor A;
	local rotator Adj;

	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = Class'SkaarjAmmo'; // Dosent really matter (just to avoid warnings or errors)!
		SavedFireProperties.ProjectileClass = RangedProjectile;
		SavedFireProperties.WarnTargetPct = 0.2;
		SavedFireProperties.MaxRange = 10000;
		SavedFireProperties.bTossed = False;
		SavedFireProperties.bTrySplash = False;
		SavedFireProperties.bLeadTarget = True;
		SavedFireProperties.bInstantHit = True;
		SavedFireProperties.bInitialized = true;
	}
	MakeNoise(0.5);
	GetAxes(Rotation,X,Y,Z);
	projStart = Location + StartOffset.X * CollisionRadius * X + StartOffset.Y * CollisionRadius * Y
	 + StartOffset.Z * CollisionRadius * Z;
	if( PlayerController(Controller)!=None || Controller.Target==None )
		Adj = Controller.AdjustAim(SavedFireProperties,projStart,100);
	else if( Mover(Controller.Target)!=None )
		Adj = rotator(DoomController(Controller).DoorAimingPosition-projStart);
	else Adj = rotator(Controller.Target.Location-(Controller.Target.Velocity*FRand()*2.f)-projStart);
	Adj.Yaw+=Accuracy*FRand()*2-Accuracy;
	Adj.Pitch+=(Accuracy*FRand()*2-Accuracy)/3.f;
	End = vector(Adj)*10000+projStart;
	A = Trace(HitL,HitN,End,projStart,True);
	if( A==None ) Return;
	if( (A.IsA('KFBulletWhipAttachment') || A.IsA('ExtendedZCollision')) && A.Owner!=None )
		A = A.Owner;
	if( !A.IsA('Pawn') )
		Spawn(WallHitEffect,,,HitL+HitN*10);
	if( A!=Level )
	{
		if( bFastMonster && bConstFiring )
			A.TakeDamage(GetFromRange(HitDamage)/1.5, Self, HitL, 3000.0*X, ShotDamageType); // Cut down damage or else it will be completly impossible
		else A.TakeDamage(GetFromRange(HitDamage), Self, HitL, 3000.0*X, ShotDamageType);
	}
}
event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex )
{
	local PhysicsVolume P;

	if( Momentum==vect(0,0,0) && EventInstigator==None )
	{
		ForEach TouchingActors(Class'PhysicsVolume',P)
		{
			if( P.Location==HitLocation )
				Return;
		}
	}
	if( !bCanPreformFF && EventInstigator!=None && EventInstigator.Class==Class )
		Return;
	Super.TakeDamage(Damage,EventInstigator,HitLocation,Momentum,DamageType,HitIndex);
}
event BreathTimer();
function bool IsHeadShot(vector loc, vector ray, float AdditionalScale)
{
	if( loc.Z>(Location.Z+CollisionHeight/5*4) )
		Return True;
	Return False;
}
simulated function PlayDoubleJump();
simulated function AnimEnd(int Channel);
function TakeFallingDamage();
function bool PerformDodge(eDoubleClickDir DoubleClickMove, vector Dir, vector Cross)
{
	local float VelocityZ;

	if ( Physics == PHYS_Falling )
	{
		if (Velocity.Z < -DodgeSpeedZ*0.5)
			Velocity.Z += DodgeSpeedZ*0.5;
	}

	VelocityZ = Velocity.Z;
	Velocity = DodgeSpeedFactor*GroundSpeed*Dir + (Velocity Dot Cross)*Cross;

	if ( !bCanDodgeDoubleJump )
		MultiJumpRemaining = 0;
	if ( bCanBoostDodge || (Velocity.Z < -100) )
		Velocity.Z = VelocityZ + DodgeSpeedZ;
	else
		Velocity.Z = DodgeSpeedZ;

	CurrentDir = DoubleClickMove;
	SetPhysics(PHYS_Falling);
	return true;
}
simulated function AssignInitialPose();
function bool CanAttackNow() // Hack for pain elemental
{
	Return True;
}
simulated function UpdateSkin( Material NewSkin )
{
	if( Render==None ) Return;
	if( bIsOnShader )
	{
		OrginalSkins[0] = NewSkin;
		if( Shader(Render.Skins[0])!=None )
		{
			Shader(Render.Skins[0]).Diffuse = NewSkin;
			Shader(Render.Skins[0]).SpecularityMask = NewSkin;
		}
	}
	else Render.Skins[0] = NewSkin;
}
simulated function ResetShaderSkin()
{
	local Shader S;

	if( !bIsOnShader || Render==None )
		Return;
	S = Shader(Render.Skins[0]);
	if( S!=None )
	{
		S.Diffuse = None;
		S.Specular = None;
		S.SpecularityMask = None;
		S.OutPutBlending = OB_Normal;
	}
	Level.ObjectPool.FreeObject(Render.Skins[0]);
	Render.Skins[0] = OrginalSkins[0];
	bIsOnShader = False;
}
simulated function SetShaderSkin( Material OverlayMat )
{
	local Shader S;

	if( Render==None )
		Return;
	if( Shader(OverlayMat)!=None )
		OverlayMat = Shader(OverlayMat).Specular;
	if( !bIsOnShader )
	{
		S = Shader(Level.ObjectPool.AllocateObject(Class'Shader'));
		S.Diffuse = Render.Skins[0];
		S.SpecularityMask = Render.Skins[0];
		S.OutputBlending = OB_Masked;
		OrginalSkins.Length = 1;
		OrginalSkins[0] = Render.Skins[0];
		bIsOnShader = True;
	}
	else S = Shader(Render.Skins[0]);
	if( S==None ) Return;
	S.Specular = OverlayMat;
	Render.Skins[0] = S;
}
simulated function Tick( float Delta )
{
	local bool bNeedsShader;

	if( bClientSideFiring )
	{
		if( Controller!=None && Controller.bFire==0 && Controller.bAltFire==0 )
		{
			bClientSideFiring = False;
			ServerStopFiring();
		}
		if( Controller==None )
			bClientSideFiring = False;
	}
	if( bHandelShading )
	{
		bNeedsShader = (OverlayMaterial!=None);
		if( bNeedsShader!=bIsOnShader )
		{
			if( bNeedsShader )
				SetShaderSkin(OverlayMaterial);
			else ResetShaderSkin();
			bIsOnShader = bNeedsShader;
		}
		else if( bNeedsShader && OverlayMaterial!=OldOverlaySkin )
		{
			OldOverlaySkin = OverlayMaterial;
			SetShaderSkin(OverlayMaterial);
		}
	}
	UpdateMovementAnim();
}
simulated function PostNetReceive()
{
	if( Level.NetMode!=NM_Client )
		Return;
	if( bAllowNetNotify )
	{
		if( OldClientDrawScale!=DrawScale )
		{
			OldClientDrawScale = DrawScale;
			Render.SetDrawScale(DrawScale);
		}
	}
}
simulated function PostNetBeginPlay()
{
	Super(Pawn).PostNetBeginPlay();
	bAllowNetNotify = True;
	bHandelShading = (Level.NetMode!=NM_DedicatedServer);
	HealthMax = Min(Max(Health,Default.Health),300); // To avoid near-death HUD overlay with weak pawns.
}
simulated final function bool IsBeingControlled()
{
	Return (Level.NetMode==NM_Client || !ValidControllerClass());
}
function UpdateMovementAnim()
{
	if( Level.NetMode==NM_Client || ValidControllerClass() )
		Return;
	if( VSize(Acceleration)>20 )
	{
		if( OldAnimStuff!=0 )
		{
			OldAnimStuff = 0;
			PlayMyAnim('Walk');
		}
	}
	else if( OldAnimStuff!=1 )
	{
		OldAnimStuff = 1;
		PlayMyAnim('Still');
	}
	if( bClientIsFiring )
		PlayerFired();
}
function bool ValidControllerClass()
{
	if( OldControllers!=Controller )
	{
		OldControllers = Controller;
		if( Controller==None )
			bWasValidController = False;
		else bWasValidController = Controller.IsA('DoomController');
	}
	Return bWasValidController;
}
function RangedAttack(Actor A)
{
	if ( !CanAttackNow() )
		return;
	if( bHasMelee && VSize(A.Location - Location) < MeleeRange + CollisionRadius + A.CollisionRadius )
	{
		GoToState('DoingAttack');
		if( Controller!=None )
			Controller.Target = A;
		SetTimer(PlayMyAnim('Melee'),False);
	}
	else if( bHasRangedAttack )
	{
		GoToState('DoingAttack');
		SetTimer(PlayMyAnim('Fire'),False);
	}
}
State DoingAttack
{
Ignores UpdateMovementAnim,RangedAttack;

	function BeginState()
	{
		Acceleration = vect(0,0,0);
		if( Physics==PHYS_Flying )
			Velocity = vect(0,0,0);
		bShotAnim = True;
		Controller.bPreparingMove = True;
	}
	function Timer()
	{
		bShotAnim = False;
		Controller.bPreparingMove = False;
		Controller.AnimEnd(0);
		if( bClientIsFiring && !IsBeingControlled() )
			bClientIsFiring = False; // no longer being controlled.
		GoToState('');
	}
	function EndState()
	{
		OldAnimStuff = 2;
	}

Begin:
	Sleep(3);
	Timer();
}
function PlayChallengeSound()
{
	if( Controller==None || !Controller.IsA('DoomController') )
		PlayAcquisitionSound();
}
function PlayerFired()
{
	local Actor A;
	local float bestAim, bestDist;

	bClientIsFiring = True; // Serverside.
	bestAim = 0.70;

	if( Controller==None || bShotAnim ) Return;
	A = Controller.PickTarget(bestAim,bestDist,vector(Rotation),Location,10000);
	if( A==None )
		A = GetClosestPawn();
	if( A!=None )
	{
		Controller.Target = A;
		Controller.Enemy = Pawn(A);
		RangedAttack(A);
	}
}
simulated function Fire( optional float F )
{
	if( IsBeingControlled() )
	{
		bClientSideFiring = True; // Client side.
		Enable('Tick');
		PlayerFired();
	}
}
final function Actor GetClosestPawn()
{
	local Controller C,BC;
	local float D,BD;

	For( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( C!=Controller && C.Pawn!=None )
		{
			D = VSize(C.Pawn.Location-Location);
			if( D<BD || BD==0 )
			{
				BD = D;
				BC = C;
			}
		}
	}
	if( BC!=None )
		Return BC.Pawn;
}
function ServerStopFiring()
{
	bClientIsFiring = False;
}
function DeAttachPlayer()
{
	if( Level.NetMode==NM_Client || !IsBeingControlled() ) Return;
	PlayerReplicationInfo = None;
	if( Controller!=None )
	{
		Controller.Pawn = None;
		if( Controller.bIsPlayer )
			Controller.PawnDied(None);
		else Controller.Destroy();
	}
	if( MyRealController!=None && MyRealController.Class!=ControllerClass )
	{
		MyRealController.Destroy();
		MyRealController = None;
	}
	if( MyRealController==None )
		MyRealController = Spawn(ControllerClass);
	PossessedBy(MyRealController);
	MyRealController.Pawn = Self;
	Controller = MyRealController;
	MyRealController.Reset();
	MyRealController = None;
}
function projectile FireProj( vector StartOffset )
{
	local vector X,Y,Z, projStart;
	local Projectile P;

	if( RangedProjectile==None || Level.NetMode==NM_Client ) Return None;
	MakeNoise(1.0);
	GetAxes(Rotation,X,Y,Z);
	projStart = Location + StartOffset.X * CollisionRadius * X + StartOffset.Y * CollisionRadius * Y + StartOffset.Z * CollisionRadius * Z;
	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = Class'SkaarjAmmo'; // Dosent really matter (just to avoid warnings or errors)!
		SavedFireProperties.ProjectileClass = RangedProjectile;
		SavedFireProperties.WarnTargetPct = 0.3;
		if( RangedProjectile.Default.LifeSpan==0 )
			SavedFireProperties.MaxRange = 10000;
		else SavedFireProperties.MaxRange = RangedProjectile.Default.LifeSpan*RangedProjectile.Default.Speed;
		SavedFireProperties.bTossed = (RangedProjectile.Default.Physics==PHYS_Falling);
		SavedFireProperties.bTrySplash = False;
		SavedFireProperties.bLeadTarget = false;
		SavedFireProperties.bInstantHit = False;
		SavedFireProperties.bInitialized = true;
	}
	P = Spawn(RangedProjectile,,,projStart,Controller.AdjustAim(SavedFireProperties,projStart,100));
	Return P;
}
function PlayDyingSound()
{
	if( Level.NetMode!=NM_Client )
	{
		if( Die2!=None && FRand()<0.5 )
			PlaySound(Die2, SLOT_Pain,1.30,true,525);
            else PlaySound(Die, SLOT_Pain,1.30,true,525);
	}
}
function bool MeleeDamageTarget(int hitdamage, vector pushdir)
{
	local vector HitLocation, HitNormal;
	local actor HitActor;
	
	if( Level.NetMode==NM_Client )
		Return False;
	// check if still in melee range
	if( Mover(Controller.target)!=None )
	{
		Controller.Target.TakeDamage(hitdamage, self,HitLocation, pushdir,MeleeDamageType);
		return true;
	}
	If ( (Controller.target != None) && (VSize(Controller.Target.Location - Location) <= MeleeRange * 1.4 + Controller.Target.CollisionRadius + CollisionRadius)
		&& ((Physics == PHYS_Flying) || (Physics == PHYS_Swimming) || (Abs(Location.Z - Controller.Target.Location.Z) 
			<= FMax(CollisionHeight, Controller.Target.CollisionHeight) + 0.5 * FMin(CollisionHeight, Controller.Target.CollisionHeight))) )
	{	
		HitActor = Trace(HitLocation, HitNormal, Controller.Target.Location, Location, false);
		if ( HitActor != None )
			return false;
		Controller.Target.TakeDamage(hitdamage, self,HitLocation, pushdir,MeleeDamageType);
		return true;
	}
	return false;
}
function float GetExposureTo(vector TestLocation)
{
	if( FastTrace(Location,TestLocation) )
		return 1.f; // Main damage
	else if( FastTrace(Location+vect(0,0,0.99f)*CollisionHeight,TestLocation) )
		return 0.8f; // Head only damage
	else if( FastTrace(Location-vect(0,0,0.99f)*CollisionHeight,TestLocation) )
		return 0.2f; // Feet damage
	return 0.f;
}
function Suicide()
{
	if( PlayerController(Controller)!=None )
		DeAttachPlayer();
	else KilledBy(self);
}
function bool DoJump( bool bUpdating )
{
	if( bCanFly )
	{
		if( Physics==PHYS_Flying )
			return false;
		SetPhysics(PHYS_Flying);
		Velocity.Z = JumpZ;
		if( !bUpdating && PlayerController(Controller)!=None && !Controller.IsInState('PlayerFlying') )
			Controller.GoToState('PlayerFlying');
		return true;
	}
	if ( (Physics == PHYS_Walking) || (Physics == PHYS_Ladder) || (Physics == PHYS_Spider) )
	{
		if( !bUpdating && JumpSound!=None )
			PlayOwnedSound(JumpSound, SLOT_Pain, GruntVolume,,80);
		if ( Role == ROLE_Authority )
		{
			if ( bCountJumps && (Inventory != None) )
				Inventory.OwnerEvent('Jumped');
		}
		if ( Physics == PHYS_Spider )
			Velocity += JumpZ * Floor;
		else if ( Physics == PHYS_Ladder )
			Velocity.Z = 0;
		else Velocity.Z = JumpZ;

		if ( (Base != None) && !Base.bWorldGeometry )
			Velocity += Base.Velocity;
		SetPhysics(PHYS_Falling);
		return true;
	}
	return false;
}
function bool EncroachingOn( actor Other )
{
	if ( Other.bWorldGeometry || Other.bBlocksTeleport || Vehicle(Other)!=None
	 || (!Class'Resurrecting'.Default.bIsRessurrecting && !Class'EnemyCreator'.Default.bHellSpawn && Pawn(Other)!=None) )
		return true;
	return false;
}
event EncroachedBy( actor Other )
{
	// Allow encroachment by Vehicles so they can push the pawn out of the way
	if ( Pawn(Other) != None && Vehicle(Other) == None && !Class'Resurrecting'.Default.bIsRessurrecting )
		gibbedBy(Other);
}
function UnSetBurningBehavior();
function SetBurningBehavior();
function PossessedBy(Controller C)
{
	if( bCanFly )
	{
		LandMovementState = 'PlayerFlying';
		if( Physics!=PHYS_Flying )
			SetPhysics(PHYS_Flying);
	}
	else LandMovementState = 'PlayerWalking';
	Super.PossessedBy(C);
}

defaultproperties
{
     RenderingClass=Class'DoomPawnsKF.DPawnDisplay'
     DeathSpeed=0.700000
     MeleeDamageType=Class'DoomPawnsKF.DoomMeleeDmg'
     bCarcassMe=True
     NumFiresAtOnce=(Min=1,Max=1)
     bArchCanRes=True
     WallHitEffect=Class'DoomPawnsKF.DoomSmokePuff'
     hitdamage=(Min=20,Max=20)
     bOnEasy=True
     bOnMedium=True
     bOnHard=True
     ShotDamageType=Class'DoomPawnsKF.ShotDmg'
     MinTimeBetweenPainSounds=0.700000
     PeripheralVision=0.700000
     ControllerClass=Class'DoomPawnsKF.DoomController'
     bPhysicsAnimUpdate=False
     DrawType=DT_Sprite
     bActorShadows=False
     DrawScale=0.500000
     ScaleGlow=1.800000
     Style=STY_Masked
     TransientSoundVolume=2.000000
     TransientSoundRadius=350.000000
     CollisionRadius=64.000000
     CollisionHeight=64.000000
}
