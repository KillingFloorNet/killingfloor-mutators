// Coded by .:..: (2007)
Class DoomWeapon extends KFWeapon
	Abstract;

// Use Start/End firing replication? (For rapid fire weapons to reduce bandwith)
var() bool bUseStartEndReplic;
// The "animations" for this gun
var(Animation) Material IdleAnimTex;
var(Animation) array<Material> FireAnim;
var bool bGunIsFiring,bDelayedFireW,bHoldingFire,bDoCalculateSwing;
var() float RefiringSpeed;
var int CurrentFireAnim;
var float AnimTime,SwingOffset[3];
var byte CurrentAnim;
var() Class<Projectile> ProjectileClass;
struct IntRange
{
	var() int Min,Max;
};
var() IntRange InstaHitDamage,NumShotsPerFire;
var() bool bUseInstantHit;
var() vector FireOffset;
var FireProperties SavedFireProperties;
var() float Spreading[2]; // 0 - X, 1 - Y
var() class<Actor> TraceHitFX;
var() float InstaHitMom,YPosModifier;
var() Class<DamageType> InstaHitDamageType;
var() int AmmoPerFire;
var() Sound FireSound,PutDownSound;
var bool bTempData; // For swaying

const ZeroValue=1.571017; // The exact zero value for Sinus and Cosinus

replication
{
	reliable if (Role < ROLE_Authority)
		ServerFireWeapon,ServerBeginFireW,ServerEndFireW;
}

// Render the actual weapon
simulated event RenderOverlays( canvas Canvas )
{
	local float S,T;
	local int Y,X;
	local Material M;
	
	S = GetScreenSize(Canvas.ClipX);
	Y = Canvas.ClipY;
	M = GetCurrentAnimTex();
	if( M==None ) Return;
	M = UpdateShader(M);
	if( CurrentAnim==1 || CurrentAnim==4 )
	{
		T = (Level.TimeSeconds-AnimTime)/0.3;
		if( CurrentAnim==1 )
			Y-=(T*M.MaterialVSize()*S);
		else Y-=((1-T)*M.MaterialVSize()*S);
	}
	else Y-=M.MaterialVSize()*S;
	X = Canvas.ClipX/2;
	X+=SwingOffset[0]*S*40;
	Y+=SwingOffset[1]*S*23;
	Canvas.DrawColor.R = 255;
	Canvas.DrawColor.B = 255;
	Canvas.DrawColor.G = 255;
	RenderWeapon(Canvas,Y+YPosModifier*S,X,M,S);
}
simulated function RenderWeapon( Canvas C, int YPos, int XPos, Material M, float Scale )
{
	C.SetPos(int(XPos-(M.MaterialUSize()*Scale/2)),YPos);
	C.DrawTile(M,int(M.MaterialUSize()*Scale),int(M.MaterialVSize()*Scale),0,1,M.MaterialUSize(),(M.MaterialVSize()-1));
}
simulated function Material GetCurrentAnimTex()
{
	if( CurrentAnim!=3 )
		Return IdleAnimTex;
	Return FireAnim[CurrentFireAnim];
}
simulated function Material UpdateShader( Material M )
{
	local bool bOver,bInvis;

	bOver = (OverlayMaterial!=None);
	bInvis = (Instigator!=None && (Instigator.bHidden || (Instigator.IsA('XPawn') && XPawn(Instigator).bInvis)));
	if( bOver || bInvis )
	{
		Shader'RendShader'.Diffuse = M;
		if( bOver )
		{
			if( Shader(OverlayMaterial)!=None && Shader(OverlayMaterial).Diffuse==None )
				Shader'RendShader'.Specular = Shader(OverlayMaterial).Specular;
			else Shader'RendShader'.Specular = OverlayMaterial;
			Shader'RendShader'.SpecularityMask = M;
		}
		else
		{
			Shader'RendShader'.Specular = None;
			Shader'RendShader'.SpecularityMask = None;
		}
		if( bInvis )
			Shader'RendShader'.OutputBlending = OB_Translucent;
		else Shader'RendShader'.OutputBlending = OB_Masked;
		Return Shader'RendShader';
	}
	Return M;
}
simulated function bool ReadyToFire(int Mode)
{
	if( Instigator.IsLocallyControlled() && ClientState!=WS_ReadyToFire )
		Return False;
	Return True;
}
simulated function bool IsFiring() // called by pawn animation, mostly
{
	Return bGunIsFiring;
}
simulated event WeaponTick(float dt)
{
	local float CX,CY;

	if( bDoCalculateSwing ) // Sway in the hands, all this code written by me ^^
	{
		if( Instigator!=None && VSize(Instigator.Acceleration)>50 )
		{
			if( !bTempData )
			{
				if( SwingOffset[2]<0 )
					SwingOffset[2]+=(((SwingOffset[2]+1)^2)*dt);
				else if( SwingOffset[2]<1 )
					SwingOffset[2]+=(((1-SwingOffset[2])^2)*dt);
				else bTempData = True;
			}
			else if( SwingOffset[2]>0 )
				SwingOffset[2]-=(((1-SwingOffset[2])^2)*dt);
			else if( SwingOffset[2]>-1 )
				SwingOffset[2]-=(((SwingOffset[2]+1)^2)*dt);
			else bTempData = False;
			CX = (SwingOffset[2])*ZeroValue;
			CY = Cos(CX);
			CX = Sin(CX);
		}
		if( SwingOffset[0]!=CX )
			SwingOffset[0]+=((CX-SwingOffset[0])*dt*4);
		if( SwingOffset[1]!=CY )
			SwingOffset[1]+=((CY-SwingOffset[1])*dt*4);
	}
}
function bool IsRapidFire() // called by pawn animation
{
	Return bUseStartEndReplic;
}
simulated function int GetScreenSize( float X )
{
	Return X/250;
}
simulated function AnimEnd(int channel);
function FireShot()
{
	local vector X,Y,Z,Start;
	local rotator R;
	local int i,j;

	ConsumeAmmo(0,AmmoPerFire);
	GetViewAxes(X,Y,Z);
	Start = Instigator.Location + Instigator.EyePosition() + X*FireOffset.X + Y*FireOffset.Y + Z*FireOffset.Z;
	R = AdjustAim(Start,200);
	j = GetFromRange(NumShotsPerFire);
	if( Spreading[0]==0 && Spreading[1]==0 )
	{
		For( i=0; i<j; i++ )
		{
			SpawnTheShot(Start,R);
		}
		Return;
	}
	X = vector(R);
	For( i=0; i<j; i++ )
	{
		R.Yaw = Spreading[0] * (FRand()-0.5);
		R.Pitch = Spreading[1] * (FRand()-0.5);
		R.Roll = Spreading[1] * (FRand()-0.5);
		SpawnTheShot(Start,Rotator(X >> R));
	}
}
function SpawnTheShot( vector Pos, Rotator Aim )
{
	local vector HitL,HitN,X;
	local Actor A;
	local byte c;

	if( ProjectileClass!=None && !bUseInstantHit )
		Spawn(ProjectileClass,,,Pos,Aim);
	else
	{
		X = vector(Aim);
		A = Trace(HitL,HitN,Pos+X*15000,Pos, true);
		if( A==None )
			Return;
		while( A.IsA('KFBulletWhipAttachment') && c++<30 )
		{
			Pos = HitL;
			A = A.Trace(HitL,HitN,Pos+X*15000,Pos, true);
			if( A==None ) Return;
		}
		if( Pawn(A)==None || Vehicle(A)!=None )
			Spawn(TraceHitFX,,,HitL+HitN*8);
		if( !A.bWorldGeometry )
			A.TakeDamage(GetFromRange(InstaHitDamage), Instigator, HitL, InstaHitMom*X, InstaHitDamageType);
	}
}
function Rotator AdjustAim(Vector Start, float InAimError)
{
	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = AmmoClass[0];
		SavedFireProperties.ProjectileClass = ProjectileClass;
		SavedFireProperties.WarnTargetPct = 0.65;
		SavedFireProperties.MaxRange = 25000;
		if( ProjectileClass!=None && !bUseInstantHit )
		{
			SavedFireProperties.bTossed = (ProjectileClass.Default.Physics==PHYS_FAlling);
			SavedFireProperties.bTrySplash = (ProjectileClass.Default.DamageRadius>50);
			SavedFireProperties.bLeadTarget = True;
			SavedFireProperties.bInstantHit = False;
		}
		else
		{
			SavedFireProperties.bTossed = False;
			SavedFireProperties.bTrySplash = False;
			SavedFireProperties.bLeadTarget = False;
			SavedFireProperties.bInstantHit = True;
			InAimError*=2;
		}
		SavedFireProperties.bInitialized = true;
	}
    return Instigator.AdjustAim(SavedFireProperties, Start, InAimError);
}
simulated function MakeFireSound()
{
	ShakeWeaponHand();
	if( FireSound!=None )
		Instigator.PlayOwnedSound(FireSound,SLOT_Misc,TransientSoundVolume,,TransientSoundRadius,GetSoundPitch());
	if( Level.NetMode!=NM_Client )
		Instigator.MakeNoise(TransientSoundVolume);
}
function HackPlayFireSound()
{
	MakeFireSound();
}
// 0 - Select
// 1 - Idle
// 2 - Fire
// 3 - Down
// 4 - Firing ended (If theres some aftermath anims)
simulated function SetClientAnim( float Num )
{
	AnimTime = Level.TimeSeconds;
	CurrentAnim = Num+1;
	bDoCalculateSwing = (Num==1 || Num==4);
}
simulated function HandelBringUp();
simulated function BringUp(optional Weapon PrevWeapon)
{
	if ( ClientState == WS_Hidden )
	{
		PlayOwnedSound(SelectSound, SLOT_Interact,,,,, false);
		ClientPlayForceFeedback(SelectForce);  // jdf
		if ( Instigator.IsLocallyControlled() )
			SetClientAnim(0);
		HandelBringUp();
		ClientState = WS_BringUp;
		SetTimer(BringUpTime, false);
	}
	if ( (PrevWeapon != None) && PrevWeapon.HasAmmo() && !PrevWeapon.bNoVoluntarySwitch )
		OldWeapon = PrevWeapon;
	else
		OldWeapon = None;
}
simulated function bool PutDown()
{
	if ( IsFiring() )
		return false;
	GoToState('');
	if (ClientState == WS_BringUp || ClientState == WS_ReadyToFire)
	{
		if (Instigator.IsLocallyControlled())
			SetClientAnim(3);
		PlayOwnedSound(PutDownSound, SLOT_Interact,,,,, false);
		ClientState = WS_PutDown;
		if ( Level.GRI.bFastWeaponSwitching )
			DownDelay = 0;
		if ( DownDelay > 0 )
			SetTimer(DownDelay, false);
		else
			SetTimer(PutDownTime, false);
	}
	Instigator.AmbientSound = None;
	OldWeapon = None;
	return true; // return false if preventing weapon switch
}
simulated function Timer()
{
	local float OldDownDelay;

	OldDownDelay = DownDelay;
	DownDelay = 0;

	if (ClientState == WS_BringUp)
	{
		SetClientAnim(1);
		ClientState = WS_ReadyToFire;
	}
	else if (ClientState == WS_PutDown)
	{
		if ( OldDownDelay > 0 )
		{
			SetTimer(PutDownTime, false);
			return;
		}
		if ( Instigator.PendingWeapon == None )
		{
			SetClientAnim(1);
			ClientState = WS_ReadyToFire;
		}
		else
		{
			ClientState = WS_Hidden;
			Instigator.ChangedWeapon();
			if ( Instigator.Weapon == self )
				BringUp();
		}
	}
}
simulated function ImmediateStopFire()
{
	GoToState('');
}
simulated function bool KeepFiring()
{
	if( !HasTheNeededAmmo() )
		Return False;
	if( Instigator!=None && Instigator.Controller!=None )
	{
		if( !Instigator.Controller.IsA('AIController') )
		{
			if( Level.NetMode!=NM_Client && IsNetworkClient() )
			{
				if( bDelayedFireW )
				{
					bDelayedFireW = False;
					Return True;
				}
				Return (bHoldingFire);
			}
			Return (bHoldingFire || Instigator.Controller.bFire!=0 || Instigator.Controller.bAltFire!=0);
		}
		else if( bUseStartEndReplic )
			Return AIController(Instigator.Controller).WeaponFireAgain(1.1,True);
		else Return AIController(Instigator.Controller).WeaponFireAgain(0.9,True);
	}
	Return False;
}
function ServerFireWeapon()
{
	if( bUseStartEndReplic )
		Return;
	if( IsFiring() )
		bDelayedFireW = True;
	else ClientStartFire(0);
}
function ServerBeginFireW()
{
	if( !bUseStartEndReplic )
		Return;
	bHoldingFire = True;
	if( IsFiring() )
		bDelayedFireW = True;
	else ClientStartFire(0);
}
function ServerEndFireW()
{
	if( bUseStartEndReplic )
		bHoldingFire = False;
}
simulated function DoFireWeapon( bool bFirstFire )
{
	bGunIsFiring = True;
	if( Instigator.IsLocallyControlled() )
		SetClientAnim(2);
	MakeFireSound();
	if( Level.NetMode!=NM_Client )
		FireShot();
	else if( !bUseStartEndReplic )
		ServerFireWeapon();
	else if( bFirstFire )
		ServerBeginFireW();
}
simulated event ClientStartFire(int Mode)
{
	if ( Pawn(Owner).Controller.IsInState('GameEnded') || Pawn(Owner).Controller.IsInState('RoundEnded') || !ReadyToFire(0) )
		return;
	if( !HasTheNeededAmmo() )
	{
		if( Instigator.IsLocallyControlled() )
			DoAutoSwitch();
		Return;
	}
	DoFireWeapon(True);
	GoToState('WeaponIsFiring');
}
final function bool IsNetworkClient()
{
	Return (Instigator!=None && Instigator.Controller!=None && Instigator.Controller.IsA('PlayerController') && PlayerController(Instigator.Controller).Player!=None &&
	 PlayerController(Instigator.Controller).Player.IsA('NetConnection'));
}
simulated function class<Pickup> AmmoPickupClass(int mode)
{
	if ( AmmoClass[0] != None )
		return AmmoClass[0].Default.PickupClass;

	return None;
}
function int GetFromRange( IntRange R )
{
	if( R.Min>=R.Max )
		Return R.Min;
	Return R.Min+(R.Max-R.Min)*FRand();
}
function bool BotFire(bool bFinished, optional name FiringMode)
{
	ClientStartFire(0);
	Return True;
}
simulated function bool HasAmmo()
{
	// If it's a bot, tell the truth to not mess him up
	if( Instigator==None || Instigator.Controller==None || !Instigator.Controller.IsA('PlayerController') )
		Return HasTheNeededAmmo();
	Return True; // In Doom you can always select weapons with no ammo, but not fire with them.
}

simulated State WeaponIsFiring
{
Ignores ClientStartFire;

	simulated function BeginState()
	{
		bGunIsFiring = True;
		CurrentFireAnim = 0;
		if( Instigator.IsLocallyControlled() )
			SetTimer(RefiringSpeed/FireAnim.Length,True);
	}
	simulated function EndState()
	{
		bGunIsFiring = False;
		SetTimer(0,False);
		if( Level.NetMode==NM_Client && bUseStartEndReplic )
			ServerEndFireW();
	}
	simulated function Timer()
	{
		if( CurrentFireAnim<(FireAnim.Length-1) )
			CurrentFireAnim++;
	}
	simulated function bool ReadyToFire(int Mode)
	{
		Return False;
	}
	function bool BotFire(bool bFinished, optional name FiringMode)
	{
		Return True;
	}
Begin:
	if( Level.NetMode==NM_Client || bUseStartEndReplic || !IsNetworkClient() )
		Sleep(RefiringSpeed);
	else if( RefiringSpeed<0.3 )
		Sleep(RefiringSpeed*0.9);
	else Sleep(RefiringSpeed-0.1); // Just to help to make sure it dosent get off sync.
	if( KeepFiring() )
	{
		DoFireWeapon(False);
		BeginState(); // To reset firing animation.
		GoTo'Begin';
	}
	else
	{
		bGunIsFiring = False;
		if( Instigator.IsLocallyControlled() )
		{
			SetClientAnim(4);
			if( !HasTheNeededAmmo() )
				DoAutoSwitch();
			else if( Instigator!=None && Instigator.PendingWeapon != None )
				PutDown();
		}
		GoToState('');
	}
}
function float RefireRate()
{
	Return RefiringSpeed;
}
function bool FireOnRelease()
{
	Return False;
}
function bool RecommendSplashDamage()
{
	if ( !SavedFireProperties.bInitialized )
		AdjustAim(Instigator.Location,0);
	Return SavedFireProperties.bTrySplash;
}
function bool SplashDamage()
{
	return RecommendSplashDamage();
}
function byte BestMode()
{
	Return 0;
}
function bool SplashJump()
{
	return RecommendSplashDamage();
}
simulated function FillToInitialAmmo()
{
	if ( !bNoAmmoInstances && Ammo[0]!=None )
		Ammo[0].AmmoAmount = Max(Ammo[0].AmmoAmount,Ammo[0].InitialAmount);
	if ( AmmoClass[0] != None )
		AmmoCharge[0] = Max(AmmoCharge[0], AmmoClass[0].Default.InitialAmount);
}
function GiveTo(Pawn Other, optional Pickup Pickup)
{
	local int m;
	local weapon w;
	local bool bPossiblySwitch, bJustSpawned;

	Instigator = Other;
	W = Weapon(Instigator.FindInventoryType(class));
	if ( W == None || W.Class != Class ) // added class check because somebody made FindInventoryType() return subclasses for some reason
	{
		bJustSpawned = true;
		Super(Inventory).GiveTo(Other);
		bPossiblySwitch = true;
		W = self;
	}
	else if ( !W.HasAmmo() )
		bPossiblySwitch = true;

	if ( Pickup == None )
		bPossiblySwitch = true;

	W.GiveAmmo(0,WeaponPickup(Pickup),bJustSpawned);

	if ( Instigator.Weapon != W )
		W.ClientWeaponSet(bPossiblySwitch);

	if ( !bJustSpawned )
	{
		for (m = 0; m < NUM_FIRE_MODES; m++)
			Ammo[m] = None;
		Destroy();
	}
}
function GiveAmmo(int m, WeaponPickup WP, bool bJustSpawned)
{
	local bool bJustSpawnedAmmo;
	local int addAmount, InitialAmount;

	if( m!=0 )
		Return;
	if ( AmmoClass[0]!=None )
	{
		Ammo[0] = Ammunition(Instigator.FindInventoryType(AmmoClass[0]));
		bJustSpawnedAmmo = false;

		if ( bNoAmmoInstances )
		{
			InitialAmount = AmmoClass[0].Default.InitialAmount;
			if ( WP!=None && WP.bThrown )
				InitialAmount = WP.AmmoAmount[0];

			if ( Ammo[0] != None )
			{
				addamount = InitialAmount + Ammo[0].AmmoAmount;
				Ammo[0].Destroy();
			}
			else
				addAmount = InitialAmount;

			AddAmmo(addAmount,0);
		}
		else
		{
			if ( (Ammo[0] == None) && (AmmoClass[0] != None) )
			{
				Ammo[0] = Spawn(AmmoClass[0], Instigator);
				Instigator.AddInventory(Ammo[0]);
				bJustSpawnedAmmo = true;
			}
			else bJustSpawnedAmmo = (bJustSpawned || ((WP != None) && !WP.bWeaponStay));

			if ( WP!=None && (WP.AmmoAmount[0]>0 || WP.bThrown) )
				addAmount = WP.AmmoAmount[0];
			else if ( bJustSpawnedAmmo )
				addAmount = Ammo[0].InitialAmount;

			Ammo[0].AddAmmo(addAmount);
			Ammo[0].GotoState('');
		}
	}
}
simulated function float AmmoStatus(optional int Mode)
{
	if( bNoAmmoInstances || Ammo[0]==None )
	{
		if( AmmoClass[0]==None )
			Return 0;
		Return float(AmmoCharge[0])/float(AmmoClass[0].Default.MaxAmmo);
	}
	else Return float(Ammo[0].AmmoAmount)/float(Ammo[0].MaxAmmo);
}
simulated function class<Ammunition> GetAmmoClass(int mode)
{
	return AmmoClass[0];
}
simulated function PostBeginPlay()
{
	local int m;

	Super(Inventory).PostBeginPlay();
	for (m = 0; m < NUM_FIRE_MODES; m++)
	{
		if (FireModeClass[m] != None)
			FireMode[m] = new(self) FireModeClass[m];
	}
	InitWeaponFires();

	for (m = 0; m < NUM_FIRE_MODES; m++)
	{
		if (FireMode[m] != None)
		{
			FireMode[m].ThisModeNum = m;
			FireMode[m].Weapon = self;
			FireMode[m].Instigator = Instigator;
			FireMode[m].Level = Level;
			FireMode[m].Owner = self;
			FireMode[m].PreBeginPlay();
			FireMode[m].BeginPlay();
			FireMode[m].PostBeginPlay();
			FireMode[m].SetInitialState();
			FireMode[m].PostNetBeginPlay();
		}
	}

	if ( SmallViewOffset == vect(0,0,0) )
		SmallViewOffset = Default.PlayerviewOffset;

	if ( SmallEffectOffset == vect(0,0,0) )
		SmallEffectOffset = EffectOffset + Default.PlayerViewOffset - SmallViewOffset;

	if ( Level.GRI != None )
		CheckSuperBerserk();
}
simulated function bool HasTheNeededAmmo()
{
	if( AmmoPerFire==0 )
		Return True;
	if( bNoAmmoInstances )
		Return (AmmoCharge[0]>=AmmoPerFire);
	else if( Ammo[0]!=None )
		Return (Ammo[0].AmmoAmount>=AmmoPerFire);
	Return True;
}
simulated function CheckSuperBerserk()
{
	if ( Level.GRI.WeaponBerserk > 1.0 )
		RefiringSpeed/=Level.GRI.WeaponBerserk;
}
simulated function StartBerserk()
{
	if ( (Level.GRI != None) && Level.GRI.WeaponBerserk > 1.0 )
		return;
	bBerserk = true;
	RefiringSpeed*=0.75;
}
simulated function StopBerserk()
{
	bBerserk = false;
	if ( (Level.GRI != None) && Level.GRI.WeaponBerserk > 1.0 )
		return;
	RefiringSpeed = Default.RefiringSpeed;
}
simulated function float GetSoundPitch()
{
	Return RefiringSpeed/Default.RefiringSpeed;
}
simulated function float RateSelf()
{
	if ( !HasTheNeededAmmo() )
		CurrentRating = -2;
	else if ( Instigator.Controller == None )
		return 0;
	else
		CurrentRating = Instigator.Controller.RateWeapon(self);
	return CurrentRating;
}
simulated function ShakeWeaponHand()
{
	if( ThirdPersonActor!=None )
		IncrementFlashCount(0);
}

// KF override...
simulated function bool AllowReload()
{
	return false;
}
simulated function ServerInterruptReload();
simulated function ClientInterruptReload();
simulated function bool InterruptReload()
{
	return false;
}
simulated function ActuallyFinishReloading();
simulated function PostNetReceive()
{
	Super(Weapon).PostNetReceive();
}
simulated function bool ConsumeAmmo( int Mode, float Load, optional bool bAmountNeededIsMax )
{
	return Super(Weapon).ConsumeAmmo(Mode,Load,bAmountNeededIsMax);
}
function ClipUpgrade();
simulated exec function ToggleIronSights();
function ServerRequestAutoReload();
simulated function Fire(float F)
{
	Super(Weapon).Fire(F);
}
simulated function HandleSleeveSwapping();
function bool HandlePickupQuery( pickup Item )
{
	// Allow pickup ammo for the weapon.
	return Super(Weapon).HandlePickupQuery(Item);
}

defaultproperties
{
     RefiringSpeed=0.650000
     InstaHitDamage=(Min=12,Max=20)
     NumShotsPerFire=(Min=1,Max=1)
     FireOffset=(X=0.400000,Z=-0.500000)
     TraceHitFX=Class'DoomPawnsKF.DoomSmokePuff'
     InstaHitMom=1.000000
     InstaHitDamageType=Class'DoomPawnsKF.ShotDmg'
     AmmoPerFire=1
     MagCapacity=1
     bHoldToReload=True
     Weight=1.000000
     FireModeClass(0)=Class'DoomPawnsKF.NullFireMode'
     FireModeClass(1)=Class'DoomPawnsKF.NullFireMode'
     PutDownTime=0.300000
     BringUpTime=0.300000
     TransientSoundVolume=2.000000
     TransientSoundRadius=750.000000
}
