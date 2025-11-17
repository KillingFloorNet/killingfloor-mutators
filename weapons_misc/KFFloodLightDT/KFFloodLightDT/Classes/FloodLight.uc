// Written by Marco
// модификация 3xzet
Class FloodLight extends SVehicle // Gay hack, but has to be done.
	Placeable
	Config(KFFloorLight)
	CacheExempt;

//#exec obj load file="KF_LAWSnd.uax"
#exec obj load file="KF_FY_ZEDV2SND.uax"
#exec obj load file="FloodLightDT_A.ukx" //package="KFFloodLightDT"


var	array<HeadlightCorona>	HeadlightCorona;
var()	array<vector>	HeadlightCoronaOffset;
var()	Material	HeadlightCoronaMaterial;
var()	float			HeadlightCoronaMaxSize;

var FLProjector	FLProjector;
var()	Material	HeadlightProjectorMaterial; // If null, do not create projector.
var()	vector		HeadlightProjectorOffset;
var()	rotator		HeadlightProjectorRotation;
var()	float			HeadlightProjectorScale;


var()		class<InventoryAttachment>	TacShineClass;
var 		Actor 						TacShine;
var()	float			TacShineScale;

var	ZedBeamSparks	Sparks;


///////////////////////////////////////////////
var KRigidBodyState UpdatingPosition;
var rotator CurrentRot,RotSpeed;
var float NextKPackSt,NextFlipCheckTime;
var() globalconfig int FloodLightHealth;
var() globalconfig float FloodLightDmgScale;
var() class<DamageType> HitDgeType;
var transient Font HUDFontz[2];
var Pawn OwnerPawn;
var FLight WeaponOwner;


// Bitmasks
var bool bNeedsKUpdate,bIsCurrentlyFlipped;
var() bool bNoAutoDestruct,bEvilTurret,bHasGodMode;

replication
{
	// Variables the server should send to the client.
	reliable if( Role == ROLE_Authority )
		UpdatingPosition,FloodLightHealth,bIsCurrentlyFlipped;
}

final function SetOwningPlayer( Pawn Other, FLight Wep )
{
	OwnerPawn = Other;
	PlayerReplicationInfo = Other.PlayerReplicationInfo;
	WeaponOwner = Wep;
	bScriptPostRender = true;
}

event bool EncroachingOn( actor Other )
{
	if ( Other.bWorldGeometry || Other.bBlocksTeleport )
		return true;
	if ( Pawn(Other) != None )
		return true;
	return false;
}

event RanInto(Actor Other)
{
	local vector Momentum;
	local float Speed;

	if (Pawn(Other) == None || Vehicle(Other) != None || Other == Instigator || Other.Role != ROLE_Authority)
		return;

	Speed = VSize(Velocity);
	if (Speed > MinRunOverSpeed)
	{
		Momentum = Velocity * 0.25 * Other.Mass;

		if (Controller != None && Controller.SameTeamAs(Pawn(Other).Controller))
			Momentum += Speed * 0.25 * Other.Mass * Normal(Velocity cross vect(0,0,1));
		if (RanOverSound != None)
			PlaySound(RanOverSound,,TransientSoundVolume*2.5);

	   		Other.TakeDamage(int(Speed * FloodLightDmgScale), Instigator, Other.Location, Momentum, RanOverDamageType);
	}
}

event HeadVolumeChange(PhysicsVolume newHeadVolume)
{
	if ( (Level.NetMode == NM_Client) || (Controller == None) )
		return;
	if ( HeadVolume!=none && HeadVolume.bWaterVolume )
	{
		if (!newHeadVolume.bWaterVolume)
		{
			if ( Controller.bIsPlayer && (BreathTime > 0) && (BreathTime < 8) )
				Gasp();
			BreathTime = -1.0;
		}
	}
	else if ( newHeadVolume.bWaterVolume )
		BreathTime = UnderWaterTime;
}

function UsedBy( Pawn user );

function bool TryToDrive(Pawn P)
{
	Return False;
}

simulated function PostNetReceive()
{
	bScriptPostRender = (PlayerReplicationInfo!=None);

	if( Physics==PHYS_Karma /*&& UpdatingPosition.Position!=vect(0,0,0)*/ )
	{
		if( !KIsAwake() )
			KWake();
		bNeedsKUpdate = True;
	}
}

final function PackState()
{
	KGetRigidBodyState(UpdatingPosition);
}

simulated event bool KUpdateState(out KRigidBodyState newState)
{
	if( !bNeedsKUpdate )
		Return False;
	newState = UpdatingPosition;
	bNeedsKUpdate = False;
	Return True;
}

simulated final function rotator GetActualDirection()
{
	local vector X,Y,Z;

	GetAxes(CurrentRot,X,Y,Z);
	X = X>>Rotation;
	Y = Y>>Rotation;
	Z = Z>>Rotation;
	return OrthoRotation(X,Y,Z);
}

simulated final function int FixedTurn( int current, int desired, int deltaRate )
{
	current = current & 65535;

	if( deltaRate==0 )
		return current;
	desired = desired & 65535;
	if( current==desired )
		return current;
	if (current > desired)
	{
		if (current - desired < 32768)
			current -= Min((current - desired), deltaRate);
		else
			current += Min((desired + 65536 - current), deltaRate);
	}
	else if (desired - current < 32768)
		current += Min((desired - current), deltaRate);
	else current -= Min((current + 65536 - desired), deltaRate);
	return (current & 65535);
}

simulated function Tick( float Delta )
{
	local bool bFlip;

	if ( Role < ROLE_Authority ) 
	{
        if ( bIsCurrentlyFlipped && Sparks == none )
		{
            SpawnSparksEffects();
        }
    }
	
	if( Level.NetMode!=NM_Client && Physics==PHYS_Karma )
	{
		if( Level.NetMode!=NM_StandAlone && NextKPackSt<Level.TimeSeconds )
		{
			NextKPackSt = Level.TimeSeconds+1.f/NetUpdateFrequency;
			PackState();
		}
		if( KParams!=None && KParams.bContactingLevel && NextFlipCheckTime<Level.TimeSeconds )
		{
			NextFlipCheckTime = Level.TimeSeconds+0.6;
			bFlip = IsFlipped();
			if( bFlip!=bIsCurrentlyFlipped )
			{
				if( bFlip )
				{
					bIsCurrentlyFlipped = bFlip;
					FloodLightAI(Controller).NotifyGotFlipped(bFlip);
				}
			}
		}
	}
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, optional int HitIndex )
{
	if( Level.NetMode==NM_Client || (!bEvilTurret && KFPawn(instigatedBy)!=None) )
		Return;
	if( !KIsAwake() )
		KWake();
	if( VSize(hitlocation-Location)<10 )
		hitlocation.Z+=10;
	if( damageType==HitDgeType && !bIsCurrentlyFlipped )
	if( (damageType!=None && damageType.Default.bBulletHit) || !bEvilTurret )
		momentum*=0.07f; // Reduce momentum for bullet hits.

	if( Physics==PHYS_Karma )
		KAddImpulse(momentum, hitlocation);

	if( bHasGodMode || bIsCurrentlyFlipped || damageType==HitDgeType )
		return;
	Health-=Damage;
	
	if( Health<=0 )
	{
		bIsCurrentlyFlipped = true;
		FloodLightAI(Controller).NotifyGotFlipped(true);
	}
}

simulated function Destroyed()
{
    local int i;
	Super.Destroyed();
	AmbientSound = none;
	if( Controller!=None )
		Controller.Destroy();
	if( Driver!=None )
		Driver.Destroy();
    // Destroy the effects
	if(Level.NetMode != NM_DedicatedServer)
	{
		for(i=0;i<HeadlightCorona.Length;i++)
			HeadlightCorona[i].Destroy();
		HeadlightCorona.Length = 0;

		if(FLProjector != None)
		{
			//FLProjector.bHasLight=!FLProjector.bHasLight;
			FLProjector.Destroy();
		}
		if ( TacShine != None )
			TacShine.Destroy();
		if ( Sparks != none )
			Sparks.Destroy();
	}
	
}

simulated function SpawnSparksEffects()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;

	Sparks = spawn(class'ZedBeamSparks', self,, GetBoneCoords('Base').Origin, Rotation);
	AttachToBone(Sparks,'Base');
	PlaySound(Sound'FloodLightDT_Snd.LightSparksDT',SLOT_Pain,1.0f,,150.f);
	//log("SpawnSparksEffects: Begin");
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( (ControllerClass != None) && (Controller == None) )
		Controller = spawn(ControllerClass);
	if ( Controller != None )
		Controller.Possess(self);
}
simulated function bool IsFlipped()
{
	local vector worldUp, gravUp;

	gravUp = -Normal(PhysicsVolume.Gravity);
	if( gravUp==vect(0,0,0) )
		gravUp.Z = -1;
	worldUp = vect(0,0,1) >> Rotation;
	if( worldUp Dot gravUp<0.75f )
		return true;

	return false;
}

function bool SameSpeciesAs(Pawn P)
{
	if( KFPawn(P)!=None )
		return !bEvilTurret;
	Return (Monster(P)==None);
}


simulated function HeadlightON()
{
	local int i;
	
	if(Level.NetMode != NM_DedicatedServer && Level.bUseHeadlights && !(Level.bDropDetail || (Level.DetailMode == DM_Low)))
		{
			HeadlightCorona.Length = HeadlightCoronaOffset.Length;

			for(i=0; i<HeadlightCoronaOffset.Length; i++)
			{
				HeadlightCorona[i] = spawn( class'HeadlightCorona', self,, Location + (HeadlightCoronaOffset[i] >> Rotation) );
				HeadlightCorona[i].SetBase(self);
				HeadlightCorona[i].SetRelativeRotation(rot(0,0,0));
				HeadlightCorona[i].Skins[0] = HeadlightCoronaMaterial;
				HeadlightCorona[i].ChangeTeamTint(Team);
				HeadlightCorona[i].MaxCoronaSize = HeadlightCoronaMaxSize * Level.HeadlightScaling;
			}

			if(HeadlightProjectorMaterial != None)
			{
				FLProjector = spawn( class'FLProjector', self,, Location + (HeadlightProjectorOffset >> Rotation) );
				FLProjector.SetBase(self);
				FLProjector.SetRelativeRotation( HeadlightProjectorRotation );
				FLProjector.ProjTexture = HeadlightProjectorMaterial;
				FLProjector.SetDrawScale(HeadlightProjectorScale);
				FLProjector.CullDistance	= ShadowCullDistance;
				//AttachToBone(FLProjector,'head');
				//FLProjector.bHasLight=!FLProjector.bHasLight;
			}
		}
	
	if ( TacShine==none )
		{
			TacShine = Spawn(TacShineClass,,,,);
			TacShine.SetDrawScale(TacShineScale);
			AttachToBone(TacShine,'head');
		}
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	bNetNotify = True;
	PostNetReceive();	
	SVehicleUpdateParams();
	HeadlightON();
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if ( bDeleteMe || Level.bLevelChange || Level.Game == None )
		return; // already destroyed, or level is being cleaned up

	if( WeaponOwner!=None )
	{
		if( OwnerPawn!=None && PlayerController(OwnerPawn.Controller)!=None )
			PlayerController(OwnerPawn.Controller).ReceiveLocalizedMessage(Class'FloodLightMessage',2);
		WeaponOwner.CurrentSentry = None;
		WeaponOwner.Destroy();
		WeaponOwner = None;
	}
	if ( Controller != None )
	{
		Controller.bIsPlayer = False;
		Level.Game.Killed(Killer, Controller, self, damageType);
		Controller.Destroy();
	}

	TriggerEvent(Event, self, None);

	// remove powerup effects, etc.
	RemovePowerups();
	Spawn(Class'KFMod.ZEDMKIISecondaryProjectileExplosion');	
	PlaySound(Sound'KF_FY_ZEDV2SND.Fire.WEP_ZEDV2_Secondary_Explode',SLOT_Pain,3.5f,,800.f);
	HurtRadius(10, 175, class'DamTypeFloodLight', 100, Location);
	Destroy();
}

simulated function int GetTeamNum()
{
	Return 250;
}

simulated event SetInitialState()
{
	Super(Actor).SetInitialState();
}

simulated event DrivingStatusChanged();

event TakeWaterDamage(float DeltaTime);

simulated function PreBeginPlay()
{
	if( KarmaParamsRBFull(KParams)!=None )
		KarmaParamsRBFull(KParams).bHighDetailOnly = False; // Hack to fix some issues.
	if ( (ControllerClass != None) && (Controller == None) )
		Controller = spawn(ControllerClass);
	if ( Controller != None )
		Controller.Restart();
	Health = FloodLightHealth;
	Super.PreBeginPlay();
}

defaultproperties
{
	FloodLightDmgScale=0.002
	Mesh=SkeletalMesh'FloodLightModDT_Mesh'
	Physics=PHYS_Karma
	bPhysicsAnimUpdate=False
	bBlockKarma=True
	bNoFriendlyFire=True
	ControllerClass=Class'FloodLightAI'
	SoundVolume=75
	SoundRadius=100

	PeripheralVision=0.7
	CollisionHeight=14
	CollisionRadius=23
	bNetNotify=False
	HitDgeType=Class'DamTypeFloodLight'
	Skins(0)=Shader'KillingFloorTextures.Statics.FloodlightShader'
	Team=250
	bUseCylinderCollision=False
	MenuName="FloodLight"
	VehicleNameString="FloodLight"
	VehicleMass=0.35
	RotationRate=(Yaw=25000,Pitch=25000)
	FloodLightHealth=150
	Health=150
	bStasis=false
	bCanBeBaseForPawns=false
	
	 HeadlightCoronaOffset(0)=(X=8.000000,Y=0.000000,Z=42.000000)
     HeadlightCoronaMaterial=Texture'FloodLightDT_T.Corona2' //Texture'KillingFloorWeapons.Dualies.FlashLightCorona3P'
     HeadlightCoronaMaxSize=40.000000
     HeadlightProjectorMaterial=Texture'KillingFloorWeapons.Dualies.LightCircle'
     HeadlightProjectorOffset=(X=-2.500000,Z=75.000000)
     HeadlightProjectorRotation=(Pitch=-1000)
     HeadlightProjectorScale=0.40000
	 	 
	 TacShineClass=Class'KFMod.TacLightShineAttachment'
	 TacShineScale=0.25
	 
	LightBrightness=64
	LightType=LT_Steady
	bDynamicLight=True
	LightRadius=4.000000
	LightSaturation=255
	 	
	Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull0
		KMass=0.35
		KStartEnabled=True
		KMaxSpeed=1000.000000 //1000
		KMaxAngularSpeed=30.000000
		bKDoubleTickRate=True
		bKAllowRotate=True
		bDestroyOnWorldPenetrate=True
		KFriction=0.999000
		bClientOnly=False
		bDoSafetime=True
		KActorGravScale=2 //2
		bHighDetailOnly=False
		KBuoyancy=1.1
		KAngularDamping=1.000
		KLinearDamping=1.000
		KImpactThreshold=45
		KInertiaTensor(0)=0.30  //Roll
		KInertiaTensor(1)=0
		KInertiaTensor(2)=0
		KInertiaTensor(3)=0.30  //Pitch
		KInertiaTensor(4)=0
		KInertiaTensor(5)=0.30  //Yaw
		KCOMOffset=(Z=-0.1)
	End Object
	KParams=KarmaParamsRBFull'KarmaParamsRBFull0'
	DrawScale=1.5
}
