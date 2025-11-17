Class AmmoTurret extends SVehicle
	Placeable
	Config(AmmoTurret2)
	CacheExempt;

var KRigidBodyState UpdatingPosition;
var byte AnimRepNum,IdleRotPos,OldAnimRep;
var(Sounds) Sound AlarmNoiseSnd,DiedSnd,LockedOnSnd;
var(Sounds) Sound OpenSnd,CloseSnd,AmmoSnd;
var(Sounds) sound Voices[8];
var vector AttackTargetPos;
var rotator CurrentRot,RotSpeed;
var float NextKPackSt,NextFlipCheckTime;
var() globalconfig int HitDamages,TurretHealth, Cash;
var() class<DamageType> HitDgeType;
var() globalconfig float AmmoRateTime;
var bool NeedAmmo;
var() localized string hp;
var() localized string or;

var transient Font HUDFontz[2];
var Pawn OwnerPawn;
var ATurret WeaponOwner;
var KFAmmoPickup AP;

// Bitmasks
var bool bNeedsKUpdate,bIsCurrentlyFlipped;
var() bool bNoAutoDestruct,bEvilTurret,bHasGodMode;

replication
{
	// Variables the server should send to the client.
	reliable if( Role==ROLE_Authority )
		UpdatingPosition,AnimRepNum,TurretHealth,OwnerPawn, ap, NeedAmmo, SpawnAmmo;
}

final function SetOwningPlayer( Pawn Other, ATurret Wep )
{
	OwnerPawn = Other;
	PlayerReplicationInfo = Other.PlayerReplicationInfo;
	WeaponOwner = Wep;
	bScriptPostRender = true;
}
simulated function PostRender2D(Canvas C, float ScreenLocX, float ScreenLocY)
{
	local string S;
	local float XL,YL;
	local vector D;

	if( Health<=0 || PlayerReplicationInfo==None )
		return; // Dead or unknown owner.
	D = C.Viewport.Actor.CalcViewLocation-Location;
	if( (vector(C.Viewport.Actor.CalcViewRotation) Dot D)>0 )
		return; // Behind the camera
	XL = VSizeSquared(D);
	if( XL>1440000.f || !FastTrace(C.Viewport.Actor.CalcViewLocation,Location) )
		return; // Beyond 1200 distance or not in line of sight.

	if( C.Viewport.Actor.PlayerReplicationInfo==PlayerReplicationInfo )
		C.SetDrawColor(0,200,0,255);
	else C.SetDrawColor(30,154,255,255);

	// Load up fonts if not yet loaded.
	if( Default.HUDFontz[0]==None )
	{
		Default.HUDFontz[0] = Font(DynamicLoadObject("ROFonts_Rus.ROArial7",Class'Font'));
		if( Default.HUDFontz[0]==None )
			Default.HUDFontz[0] = Font'Engine.DefaultFont';
		Default.HUDFontz[1] = Font(DynamicLoadObject("ROFonts_Rus.ROBtsrmVr12",Class'Font'));
		if( Default.HUDFontz[1]==None )
			Default.HUDFontz[1] = Font'Engine.DefaultFont';
	}
	if( C.ClipY<1024 )
		C.Font = Default.HUDFontz[0];
	else C.Font = Default.HUDFontz[1];

	C.Style = ERenderStyle.STY_Alpha;
	S = or@ ":" @PlayerReplicationInfo.PlayerName;
	C.TextSize(S,XL,YL);
	C.SetPos(ScreenLocX-XL*0.5,ScreenLocY-YL*2.f);
	C.DrawTextClipped(S,false);
	S = hp@ ":" @Max(1,float(Health)/float(TurretHealth)*100.f)@"%";
	C.TextSize(S,XL,YL);
	C.SetPos(ScreenLocX-XL*0.5,ScreenLocY-YL*0.75f);
	C.DrawTextClipped(S,false);
}
event bool EncroachingOn( actor Other )
{
	if ( Other.bWorldGeometry || Other.bBlocksTeleport )
		return true;
	if ( Pawn(Other) != None )
		return true;
	return false;
}

function UsedBy( Pawn user );

function bool TryToDrive(Pawn P)
{
	Return False;
}

simulated function PostNetReceive()
{
	bScriptPostRender = (PlayerReplicationInfo!=None);
	Switch( AnimRepNum )
		{
			Case 0:
				PlayOpen();						
				Break;			
			Case 1:
				PlayClose();				
				Break;
			Case 2:
				PlayIdleTurret();
				Break;			
		}
	if( Physics==PHYS_Karma )
	{
		if( !KIsAwake() )
			KWake();
		bNeedsKUpdate = True;
	}
}

/*simulated function Tick( float Delta )
{
	/*if(AnimRepNum == 2 && NeedAmmo)
	{
		Spawnammo();
	}*/	
}*/

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

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, optional int HitIndex )
{
	if( Level.NetMode==NM_Client || (!bEvilTurret && KFPawn(instigatedBy)!=None) || damageType==class'DamTypePipeBomb' )
		Return;
	if( !KIsAwake() )
		KWake();
	if( VSize(hitlocation-Location)<10 )
		hitlocation.Z+=10;			
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
	}
}
simulated function PlayOpen()
{
	AnimRepNum = 1;
	PlaySound(OpenSnd,SLOT_Talk,2.f,,500.f);
		
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	PlayAnim('Open',0.5,0.1);	
	SetTimer(2,false);
}

simulated function PlayClose()
{
	AnimRepNum = 2;
	PlaySound(CloseSnd,SLOT_Talk,2.f,,500.f);	
	if( Level.NetMode==NM_DedicatedServer )
		Return;	
	PlayAnim('Close',0.5,0.1);	
	SetTimer(1,false);
}

simulated function PlayIdleTurret()
{
	AnimRepNum = 3;
	
	if( Level.NetMode==NM_DedicatedServer )
		Return;	
	PlayAnim('Idle',0.8f);	
	SetTimer(AmmoRateTime,false);
}

simulated function PlayTurretDied()
{
	AnimRepNum = 3;	
	if( Level.NetMode==NM_DedicatedServer )
		Return;	
	PlayAnim('Idle',0.5,0.1);	
}


simulated function Timer()
{
	if (AnimRepNum == 3)
	{
		AnimRepNum = 0;
		PlayOpen();			
	}
	else if (AnimRepNum == 1)
	{	
		NeedAmmo = true;
		PlayClose();
	}
	else if (AnimRepNum == 2)
	{
		PlayIdleTurret();
	}	
}

function SpawnAmmo()
{
	local vector AmmoSpot;
	local rotator Rot;
	
	AmmoSpot = location;
	AmmoSpot.z +=50;
	if(Rand(10)>5)
		AmmoSpot.x +=Max(50, Rand(100));
	else
		AmmoSpot.x -=Max(50, Rand(100));
	if(Rand(10)>5)
		AmmoSpot.y +=Max(50, Rand(100));
	else
		AmmoSpot.y -=Max(50, Rand(100));
	Rot.roll = 10000;
	Rot.pitch = Rand(65536);
	Rot.yaw = Rand(65536);	
	AP = Spawn(class'MyAmmoPickup' , , , AmmoSpot , Rot);	
	if (AP!=none)
	{
		AP.Gotostate('Sleeping', 'Respawn');
		PlaySound(AmmoSnd,SLOT_Talk,2.f,,500.f);	
		needammo = false;		
	}	
}

simulated function Destroyed()
{
	if( Controller!=None )
		Controller.Destroy();
	if( Driver!=None )
		Driver.Destroy();
	Super.Destroyed();
}

event PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( (ControllerClass != None) && (Controller == None) )
		Controller = spawn(ControllerClass);
	if ( Controller != None )
		Controller.Possess(self);
	FindZ();
}

function FindZ()
{
	local vector hl, hn, te, ts;
	
	hl = vect(0,0,-99999999);
	ts = location;
	te = location;
	te.z -= 99999;
	Trace(hl, hn, te, ts);
	hl.z+=25;
	SetLocation(hl);
	ts = hl;		
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
	if( KFHumanPawn(P)==None || ZombieBossBase(P)==None )
		return true;
	else
		Return false;
}

simulated function PostNetBeginPlay()
{
	bNetNotify = True;
	PostNetReceive();
}

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if ( bDeleteMe || Level.bLevelChange || Level.Game == None )
		return; // already destroyed, or level is being cleaned up

	if( WeaponOwner!=None )
	{
		if( OwnerPawn!=None && PlayerController(OwnerPawn.Controller)!=None )
			PlayerController(OwnerPawn.Controller).ReceiveLocalizedMessage(Class'AmmoTurretMessage',2);
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
	Spawn(Class'PanzerfaustHitConcrete_simple');
	PlaySound(Sound'KF_GrenadeSnd.NadeBase.Nade_Explode1',SLOT_Pain,2.5f,,800.f);

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
	if( Level.NetMode!=NM_DedicatedServer )
	{
		TweenAnim('Idle',0.001f);		
	}
	//PlayIdleTurret();
	Health = TurretHealth;
	Super.PreBeginPlay();
}

defaultproperties
{
     OpenSnd=Sound'AmmoTurret_S.Open'
     CloseSnd=Sound'AmmoTurret_S.Close'
     AmmoSnd=Sound'AmmoTurret_S.Ammo'
     HitDamages=5
     TurretHealth=250
     HitDgeType=Class'KFMod.KFProjectileWeaponDamageType'
     AmmoRateTime=15.000000
     HP="Vida"
     or="Dueño"
     VehicleMass=0.350000
     Team=250
     VehicleNameString="AmmoAmmoAmmo"
     bCanBeBaseForPawns=Falso
     PeripheralVision=0.700000
     Health=250
     MenuName="AmmoAmmoAmmo"
     ControllerClass=Class'NMAmmoTurret.ATurretAI'
     bStasis=Falso
     Mesh=SkeletalMesh'AmmoTurret2_A.ammocrate2mesh'
     Skins(0)=Combiner'AmmoTurret2_T.Box_cmb'
     Skins(1)=Combiner'AmmoTurret2_T.Items_cmb'
     SoundRadius=140.000000
     CollisionRadius=23.000000
     CollisionHeight=28.000000
     RotationRate=(Pitch=25000,Yaw=25000)
     Begin Object Class=KarmaParamsRBFull Name=KarmaParamsRBFull0
         KInertiaTensor(0)=0.100000
         KInertiaTensor(3)=0.100000
         KInertiaTensor(5)=0.100000
         KCOMOffset=(Y=-0.020000)
         KMass=0.350000
         KAngularDamping=0.010000
         KBuoyancy=1.100000
         KStartEnabled=Verdadero
         KActorGravScale=2.000000
         KMaxSpeed=1000.000000
         KMaxAngularSpeed=30.000000
         bHighDetailOnly=Falso
         bClientOnly=Falso
         bKDoubleTickRate=Verdadero
         bKAllowRotate=Verdadero
         bDestroyOnWorldPenetrate=Verdadero
         bDoSafetime=Verdadero
         KFriction=0.850000
         KImpactThreshold=45.000000
     End Object
     KParams=KarmaParamsRBFull'NMAmmoTurret.AmmoTurret.KarmaParamsRBFull0'

}
