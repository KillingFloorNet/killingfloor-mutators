class AmmoCraftGunBladeProjectile extends ROBallisticProjectile;

#exec OBJ LOAD FILE=KF_InventorySnd.uax

var xEmitter Trail;
var Emitter Corona;
var() class<DamageType> DamageTypeHeadShot;

// Sounds
var     sound       BladeHitWall;   // Sound of the blade hitting a wall
var     sound       BladeHitArmor;  // Sound of the blade hitting an armored enemy
var     sound       BladeHitFlesh;  // Sound of the blade hitting flesh

var() float HeadShotDamageMult;

var Actor ImpactActor;
var Pawn IgnoreImpactPawn;

// Dynamic loading
var()	string	AmbientSoundRef;
var		string	StaticMeshRef;
var		string	BladeHitWallRef;
var		string	BladeHitArmorRef;
var		string	BladeHitFleshRef;

// Bouncing vars
var     byte    Bounces;        // Number of times this blade has bounced
var     int     MaxBounces;     // Maximum number of times this blade should be able to bounce

// Physics
var() 		float 		StraightFlightTime;          // How long the projectile and flies straight
var 		float 		TotalFlightTime;             // How long the rocket has been in flight
var 		bool 		bOutOfPropellant;            // Projectile is out of propellant
// Physics debugging
var 		vector 		OuttaPropLocation;

var     class<Emitter>      ExplosionEmitterClass; // Emitter class for the explosion

var string ExplosionSoundRef;

var() sound ExplosionSound;	// The sound of the rocket exploding

replication
{
	reliable if ( Role == ROLE_Authority && bNetInitial )
		ImpactActor;

    reliable if (bNetInitial && Role == ROLE_Authority)
        Bounces;
}

static function PreloadAssets()
{
	default.ExplosionSound = sound(DynamicLoadObject(default.ExplosionSoundRef, class'Sound', true));

	default.AmbientSound = sound(DynamicLoadObject(default.AmbientSoundRef, class'Sound', true));

	default.BladeHitWall = sound(DynamicLoadObject(default.BladeHitWallRef, class'Sound', true));
	default.BladeHitArmor = sound(DynamicLoadObject(default.BladeHitArmorRef, class'Sound', true));
	default.BladeHitFlesh = sound(DynamicLoadObject(default.BladeHitFleshRef, class'Sound', true));

	// UpdateDefaultStaticMesh(StaticMesh(DynamicLoadObject(default.StaticMeshRef, class'StaticMesh', true)));
}

static function bool UnloadAssets()
{
	default.ExplosionSound = none;

	default.AmbientSound = none;

	default.BladeHitWall = none;
	default.BladeHitArmor = none;
	default.BladeHitFlesh = none;

	UpdateDefaultStaticMesh(none);

	return true;
}

simulated function PostBeginPlay()
{
    local vector Dir;

    BCInverse = 1 / BallisticCoefficient;

    OrigLoc = Location;

    Dir = vector(Rotation);
    Velocity = Speed * Dir;

    if (PhysicsVolume.bWaterVolume)
    {
        Velocity = 0.6 * Velocity;
    }

	// if ( Level.NetMode != NM_DedicatedServer )
	// {
	// 	if ( !PhysicsVolume.bWaterVolume )
	// 	{
	// 		Trail = Spawn(class'CrossbuzzsawTracer', self);
	// 		Trail.Lifespan = Lifespan;

	// 		Corona = Spawn(class'CrossbuzzsawCorona', self);
	// 		Corona.Lifespan = Lifespan;
	// 	}
	// }

	Bounces = MaxBounces;

	super(Projectile).PostBeginPlay();
}

simulated function Tick( float DeltaTime )
{
    SetRotation(Rotator(Normal(Velocity)));

    if ( Physics == PHYS_Projectile && VSizeSquared(Velocity) < ((Speed * Speed) * 0.1) )
    {
        SetPhysics(PHYS_Falling);
    }

    if ( !bOutOfPropellant )
    {
        if ( TotalFlightTime <= StraightFlightTime )
        {
            TotalFlightTime += DeltaTime;
        }
        else
        {
            OuttaPropLocation = Location;
            bOutOfPropellant = true;
        }
    }

    if (bOutOfPropellant && !bTrueBallistics)
    {
		//log(" Projectile flew "$(VSize(OrigLoc - OuttaPropLocation)/50.0)$" meters before running out of juice");
		//SetPhysics(PHYS_Falling);
		bTrueBallistics = true;
    }
}

simulated function PostNetReceive()
{
    if ( ImpactActor != None && Base != ImpactActor )
    {
        GoToState('OnWall');
    }
}

simulated state OnWall
{
    Ignores HitWall;

	function ProcessTouch(Actor Other, vector HitLocation)
	{
		// <!--
		// Copy of KFAmmoPickup:state Pickup
		local Inventory CurInv;
		local bool bPickedUp;
		local int AmmoPickupAmount;
		local Boomstick DBShotty;
		local bool bResuppliedBoomstick;

		if ( Pawn(Other) != none && Pawn(Other).bCanPickupInventory && Pawn(Other).Controller != none && FastTrace(Other.Location, Location) )
		{
			for ( CurInv = Other.Inventory; CurInv != none; CurInv = CurInv.Inventory )
			{
				if (Boomstick(CurInv) != none)
				{
					DBShotty = Boomstick(CurInv);
				}

				if ( KFAmmunition(CurInv) != none && KFAmmunition(CurInv).bAcceptsAmmoPickups )
				{
					if ( KFAmmunition(CurInv).AmmoPickupAmount > 1 )
					{
						if ( KFAmmunition(CurInv).AmmoAmount < KFAmmunition(CurInv).MaxAmmo )
						{
							if ( KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo).ClientVeteranSkill != none )
							{
								AmmoPickupAmount = float(KFAmmunition(CurInv).AmmoPickupAmount) * KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo).ClientVeteranSkill.static.GetAmmoPickupMod(KFPlayerReplicationInfo(Pawn(Other).PlayerReplicationInfo), KFAmmunition(CurInv));
							}
							else
							{
								AmmoPickupAmount = KFAmmunition(CurInv).AmmoPickupAmount;
							}

							KFAmmunition(CurInv).AmmoAmount = Min(KFAmmunition(CurInv).MaxAmmo, KFAmmunition(CurInv).AmmoAmount + AmmoPickupAmount);

							if ( DBShotgunAmmo(CurInv) != none )
							{
								bResuppliedBoomstick = true;
							}

							bPickedUp = true;
						}
					}
					else if ( KFAmmunition(CurInv).AmmoAmount < KFAmmunition(CurInv).MaxAmmo )
					{
						bPickedUp = true;

						if ( FRand() <= (1.0 / Level.Game.GameDifficulty) )
						{
							KFAmmunition(CurInv).AmmoAmount++;
						}
					}
				}
			}

			if (bPickedUp)
			{
				if ( bResuppliedBoomstick && DBShotty != none )
				{
					DBShotty.AmmoPickedUp();
				}

				PlaySound(Sound'KF_InventorySnd.Ammo_GenericPickup', SLOT_Pain, 2 * TransientSoundVolume, , 400);

				if (PlayerController(Pawn(Other).Controller) != none)
				{
					PlayerController(Pawn(Other).Controller).ReceiveLocalizedMessage(class'KFmod.ProjectilePickupMessage',1);
				}

				Destroy();

				// AnnouncePickup(Pawn(Other));
				// GotoState('Sleeping', 'Begin');

				// if ( KFGameType(Level.Game) != none )
				// {
				// 	KFGameType(Level.Game).AmmoPickedUp(self);
				// }
			}
		}
		// -->

		// local Inventory inv;

		// if (Pawn(Other)!=None && Pawn(Other).Inventory!=None)
		// {
		// 	for ( inv = Pawn(Other).Inventory; inv!=None; inv=inv.Inventory )
		// 	{
		// 		if ( Crossbuzzsaw(Inv)!=None && Weapon(inv).AmmoAmount(0)<Weapon(inv).MaxAmmo(0) )
		// 		{
		// 			KFweapon(Inv).AddAmmo(1,0);
		// 			PlaySound(Sound'KF_InventorySnd.Ammo_GenericPickup', SLOT_Pain,2 * TransientSoundVolume,,400);

		// 			if ( PlayerController(Instigator.Controller)!=none )
		// 			{
        //                 PlayerController(Instigator.Controller).ReceiveLocalizedMessage(class'KFmod.ProjectilePickupMessage',1);
		// 			}

		// 			Destroy();
		// 		}
		// 	}
		// }
	}

	simulated function Tick( float Delta )
	{
		if ( Base == None )
		{
			if ( Level.NetMode==NM_Client )
				bHidden = True;
			else
				Destroy();
		}
	}

	simulated function BeginState()
	{
		bCollideWorld = false;
		//if( Level.NetMode!=NM_DedicatedServer )
			AmbientSound = None;

		if ( Trail != None )
			Trail.mRegen = false;

		if ( Corona != none )
        {
            Corona.Kill();
		}

		SetCollisionSize(75, 50);

		UV2Texture = FadeColor'PatchTex.Common.PickupOverlay';
	}
}

simulated function Explode(vector HitLocation, vector HitNormal);

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
	local vector X,End,HL,HN;
	local Vector TempHitLocation, HitNormal;
	local array<int>	HitPoints;
    local KFPawn HitPawn;
	local bool	bHitWhipAttachment;

	if ( Other == none || Other == Instigator || Other.Base == Instigator || !Other.bBlockHitPointTraces || Other==IgnoreImpactPawn ||
        (IgnoreImpactPawn != none && Other.Base == IgnoreImpactPawn) )
		return;

	X =  Vector(Rotation);

	if ( ROBulletWhipAttachment(Other) != none )
	{
		bHitWhipAttachment = true;

        if (!Other.Base.bDeleteMe)
        {
	        Other = Instigator.HitPointTrace(TempHitLocation, HitNormal, HitLocation + (65535 * X), HitPoints, HitLocation,, 1);

			if( Other == none || HitPoints.Length == 0 )
				return;

			HitPawn = KFPawn(Other);

			if (Role == ROLE_Authority)
			{
				if ( HitPawn != none )
				{
					// Hit detection debugging
					/*log("Bullet hit "$HitPawn.PlayerReplicationInfo.PlayerName);
					HitPawn.HitStart = HitLocation;
					HitPawn.HitEnd = HitLocation + (65535 * X);*/

					if( !HitPawn.bDeleteMe )
						HitPawn.ProcessLocationalDamage(Damage, Instigator, TempHitLocation, MomentumTransfer * X, MyDamageType,HitPoints);

					Damage/=1.25;
					Velocity*=0.85;

					IgnoreImpactPawn = HitPawn;

					if( Level.NetMode!=NM_Client )
						PlayhitNoise(Pawn(Other)!=none && Pawn(Other).ShieldStrength>0);

					// Hit detection debugging
					/*if( Level.NetMode == NM_Standalone)
						HitPawn.DrawBoneLocation();*/

					return;
				}
			}
		}
		else
		{
			return;
		}
	}

	if ( Level.NetMode!=NM_Client )
	{
		PlayhitNoise(Pawn(Other)!=none && Pawn(Other).ShieldStrength>0);
	}

	if ( Physics==PHYS_Projectile && Pawn(Other)!=None && Vehicle(Other)==None )
	{
		IgnoreImpactPawn = Pawn(Other);
		if( IgnoreImpactPawn.IsHeadShot(HitLocation, X, 1.0) )
			Other.TakeDamage(Damage * HeadShotDamageMult, Instigator, HitLocation, MomentumTransfer * X, DamageTypeHeadShot);
		else
			Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * X, MyDamageType);

		Damage /= 1.25;
		Velocity *= 0.85;

		return;
	}
	else if ( ExtendedZCollision(Other)!=None && Pawn(Other.Owner)!=None )
	{
		if ( Other.Owner==IgnoreImpactPawn )
			return;

		IgnoreImpactPawn = Pawn(Other.Owner);

		if ( IgnoreImpactPawn.IsHeadShot(HitLocation, X, 1.0))
			Other.TakeDamage(Damage * HeadShotDamageMult, Instigator, HitLocation, MomentumTransfer * X, DamageTypeHeadShot);
		else
			Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * X, MyDamageType);

		Damage /= 1.25;
		Velocity *= 0.85;

		return;
	}

	if ( Level.NetMode!=NM_DedicatedServer && SkeletalMesh(Other.Mesh)!=None && Other.DrawType==DT_Mesh && Pawn(Other)!=None )
	{ // Attach victim to the wall behind if it dies.
		End = Other.Location+X*600;

		if ( Other.Trace(HL,HN,End,Other.Location,False)!=None )
			Spawn(Class'BodyAttacher',Other,,HitLocation).AttachEndPoint = HL-HN;
	}

	//Stick(Other,HitLocation);
	if ( Level.NetMode!=NM_Client )
	{
		if (Pawn(Other) != none && Pawn(Other).IsHeadShot(HitLocation, X, 1.0))
			Pawn(Other).TakeDamage(Damage * HeadShotDamageMult, Instigator, HitLocation, MomentumTransfer * X, DamageTypeHeadShot);
		else
			Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * X, MyDamageType);
	}
}

function PlayHitNoise(bool bArmored)
{
	if ( bArmored )
	{
		PlaySound(BladeHitArmor,,2.0);   // implies hit a target with shield/armor
	}
	else
    {
        PlaySound(BladeHitFlesh,,2.0);
    }
}

simulated function HitWall(vector HitNormal, actor Wall )
{
    if ( (Mover(Wall) != None) && Mover(Wall).bDamageTriggered )
    {
        if ( Level.NetMode != NM_Client )
        {
            Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
        }

        Destroy();

        return;
    }

	// PlaySound(BladeHitWall,SLOT_None,0.6,,300,0.9+frand()*0.2);
	PlaySound(ExplosionSound,,2.0);

    if (EffectIsRelevant(Location, false))
    {
		Spawn(class'CrossbuzzsawImpact',,,, rotator(hitnormal));
		Spawn(ExplosionEmitterClass,,,Location + HitNormal * 20, Rotator(HitNormal));
    }

	if (Physics == PHYS_Projectile && Bounces > 0)
    {
        Velocity = 0.95 * (Velocity - 2.0 * HitNormal*(Velocity dot HitNormal)); // slow the projectile after bounce
        Bounces = Bounces - 1;
        return;
    }
    else
    {
		bBounce = false;
		Stick(Wall, Location);
	}

    // SetRotation(rotator(Velocity));

	if ( Instigator != None && Level.NetMode != NM_Client )
		MakeNoise(0.3);
}

simulated function Landed(vector HitNormal)
{
	HitWall(HitNormal, None);
}

simulated function Stick(actor HitActor, vector HitLocation)
{
	local name NearestBone;
	local float dist;

	SetPhysics(PHYS_None);

	if (Pawn(HitActor) != none)
	{
		NearestBone = GetClosestBone(HitLocation, HitLocation, dist, 'CHR_Spine2', 15);
		HitActor.AttachToBone(self, NearestBone);
	}
	else
    {
        SetBase(HitActor);
    }

	ImpactActor = HitActor;

	if (Base == None)
		Destroy();
	else
		GoToState('OnWall');
}

simulated function PhysicsVolumeChange( PhysicsVolume Volume )
{
	if ( Volume.bWaterVolume && !PhysicsVolume.bWaterVolume )
	{
		if ( Trail != None )
			Trail.mRegen = false;

		if ( Corona != none )
        {
            Corona.Kill();
		}

		Velocity *= 0.65;
	}
}

simulated function Destroyed()
{
	if (Trail != None)
		Trail.mRegen = false;

	if ( Corona != none )
    {
        Corona.Kill();
	}

	Super.Destroyed();
}

defaultproperties
{
	DamageTypeHeadShot=Class'KFMod.DamTypeCrossbuzzsawHeadShot'
	HeadShotDamageMult=2.000000
	AmbientSoundRef="KF_IJC_HalloweenSnd.KF_SawbladeBow_Projectile_Loop"
	// StaticMeshRef="EffectsSM.Weapons.cheetah_blade"
	StaticMesh=StaticMesh'kf_generic_sm.pickups.Metal_Ammo_Box'
	BladeHitWallRef="KF_IJC_HalloweenSnd.KF_SawbladeBow_Projectile_Hit"
	BladeHitArmorRef="KF_IJC_HalloweenSnd.KF_SawbladeBow_Projectile_Hit"
	BladeHitFleshRef="KF_AxeSnd.Axe_HitFlesh"

	ExplosionEmitterClass=Class'KFMod.SPGrenadeExplosion'

	Bounces=1
	MaxBounces=0 //5

	StraightFlightTime=0.2 //0.650000
	AmbientVolumeScale=1.0 //2.000000
	bTrueBallistics=False

	Speed=600.0 //1500.000000

	Damage=500.000000
	MomentumTransfer=50000.000000
	MyDamageType=Class'KFMod.DamTypeCrossbuzzsaw'
	ExplosionDecal=Class'KFMod.ShotgunDecal'
	DrawType=DT_StaticMesh
	CullDistance=7500.000000
	bNetTemporary=False
	bUpdateSimulatedPosition=True
	LifeSpan=180.000000
	DrawScale=1.000000
	Style=STY_Alpha
	bUnlit=False
	SoundVolume=175
	SoundRadius=250.000000
	TransientSoundVolume=0.500000
	bBounce=True
}
