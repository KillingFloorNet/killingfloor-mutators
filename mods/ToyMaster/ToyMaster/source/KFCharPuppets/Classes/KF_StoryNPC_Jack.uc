class KF_StoryNPC_Jack extends KF_StoryNPC_Static;

var()       float               PlayerCountHealthScale; // How much % of total health to add to this Zed for each additional player in the game
var         bool                bDiffAdjusted; // has this monster had it's stats adjusted for the server's difficulty? Do once.
var         FireProperties      SavedFireProperties;
var         class<Ammunition>   AmmunitionClass;
var         Ammunition          MyAmmo;


var protected bool bFirstActivation;

// Number of seconds before Jack tossess another bomb.
var () float BombTossInterval;
// The last time a Bomb was thrown.
var protected float LastBombTossTime;
// Number of seconds before Jack tosses another set of knives.
var () float KnifeTossInterval;
// the last time a set of knives was thrown.
var protected float LastKnifeTossTime;
// every time he goes back in his box, his toss speed increases by this amount.
var () const float TossSpeedUpModifier;

// Class type of knife thrown by jack in the box.
var () const class<Projectile>  KnifeProjectileClass;
// Class type of bomb thrown by jack in the box.
var () const class<Projectile> BombProjectileClass;

// Number of bombs to throw.
var () const int NumBombs;
// Number of bombs to throw when he hides.
var () const int NumHidingBombs;
// Number of knives to throw.
var () const int NumKnives;
// amount of spread / aim error when throwing a knife.
var () const float KnifeAimError;
// amount of spread / aim error when throwing a bomb.
var () const float BombAimError;

// The player who we're currently aiming at.
var protected Pawn  TargetPlayer;
// the guy we were last aiming at.
var protected Pawn  LastTarget;
// Jack looks for a new enemy every this amount of seconds.
var () const float FindNewEnemyInterval;
// Time at which we last found a new enemy to throw stuff at.
var protected float LastAcquiredTargetTime;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	if(AuxCollisionCylinder != none)
	{
	   AuxCollisionCylinder.Destroy();
	}

//	if ( (ControllerClass != None) && (Controller == None) )
//		Controller = spawn(ControllerClass);
	if ( Controller != None )
	{
		Controller.Possess(self);
		MyAmmo = spawn(AmmunitionClass);
	}

    if(KnifeProjectileClass == class 'KFCharPuppets.JackSawBlade')
    {
        class 'KFCharPuppets.JackSawBlade'.static.PreloadAssets();
    }
}

simulated function Touch(Actor Other)
{
    if(Other.IsA('Projectile') && Other.Instigator != none && Other.Instigator != self)
    {
        Projectile(Other).Explode(Other.Location,Normal(Location-Other.Location));
    }

    Super.Touch(Other);
}

simulated function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    if(bActive && Health > 0)
    {
        FindTarget();

        CheckThrowBombs();
        CheckThrowKnives();
    }
}

// Look for something to throw stuff at!
function FindTarget()
{
    local Controller C;
    local array<Pawn> ValidTargets;

    if(level.TimeSeconds - LastAcquiredTargetTime >
    FindNewEnemyInterval || TargetPlayer == none ||
    TargetPlayer.health <= 0)
    {
        for (C = Level.ControllerList; C != None; C = C.NextController)
        {
            if(C.bIsPlayer && C.Pawn != none && C.Pawn.health > 0 &&
            C.Pawn != LastTarget)
            {
                ValidTargets[ValidTargets.length] = C.Pawn;
            }
        }

        // Nothing to aim at.  Check to see if maybe the only guy who's left is our previous target.
        if(ValidTargets.length == 0)
        {
            if(LastTarget != none &&
            LastTarget.Health > 0)
            {
                SetTarget(LastTarget);
            }
        }
        else
        {
            // Randomly pick from the available players.
            SetTarget(ValidTargets[Rand(ValidTargets.length)]);
        }
    }
}

function SetTarget( Pawn NewTarget)
{
    LastAcquiredTargetTime = Level.TimeSeconds;
    LastTarget = TargetPlayer;
    TargetPlayer = NewTarget;
}

// Decide if it's time to throw another bomb.
simulated function CheckThrowBombs()
{
    if(TargetPlayer != none &&
    Level.TimeSeconds - LastBombTossTime > BombTossInterval)
    {
        LastBombTossTime = Level.TimeSeconds;
        ThrowBomb(,500.f);
    }
}

// Decide if it's time to throw some more knives.
simulated function CheckThrowKnives()
{
    if(TargetPlayer != none &&
    Level.TimeSeconds - LastKnifeTossTime > KnifeTossInterval)
    {
        LastKnifeTossTime = Level.TimeSeconds;
        ThrowKnives();
    }
}

// Throw a bunch of bombs in a fan formation around the jack.
simulated function ThrowLotsOfBombs()
{
    local Rotator TargetDir;
    local float SpacingIncrement;
    local int i;

    // Start with wherever he's facing.
    TargetDir = Rotation;
    SpacingIncrement = 65536.f / NumHidingBombs;

    for(i = 0 ; i < NumHidingBombs; i ++)
    {
        ThrowBomb(Normal(Vector(TargetDir)),RandRange(250.f,1000.f)) ;
        TargetDir.Yaw += SpacingIncrement;
    }
}



function ThrowBomb(optional vector CustomTossDir, optional float CustomTossSpeed)
{
    local Projectile  MyBomb;
    local float ZSpawnOffset;
    local vector SpawnLocation;
    local vector AimError;
    local int i;
    local int NumToSpawn;
    local vector TossDir;

    if(Role < Role_Authority)
    {
        return;
    }

    NumToSpawn = NumBombs;

    ZSpawnOffset = CollisionHeight / 2;
    SpawnLocation = Location + vect(0,0,1) * ZSPawnOffset;

    TossDir = Normal((TargetPlayer.Location + AimError) - SpawnLocation) ;
    if(VSize(CustomTossDir) != 0)
    {
        TossDir = CustomTossDir;
    }

    for(i = 0 ; i < NumToSpawn ; i ++)
    {
        MyBomb = Spawn(BombProjectileClass ,,,SpawnLocation, Rotation);
        MyBomb.Instigator = self;

        AimError = VRand() * BombAimError;
        MyBomb.Velocity = TossDir * CustomTossSpeed  + vect(0,0,250.f) ;
    }
}

function ThrowKnives()
{
    local Projectile MyKnife;
    local float ZSpawnOffset;
    local vector SpawnLocation;
    local vector AimError;
    local int i;

    if(Role < Role_Authority)
    {
        return;
    }

    ZSpawnOffset = CollisionHeight / 2;
    SpawnLocation = Location + vect(0,0,1) * ZSPawnOffset;

    for(i = 0 ; i < NumKnives; i ++)
    {
        MyKnife = Spawn(KnifeProjectileClass,,,SpawnLocation, Rotation);
        MyKnife.Instigator = self;

        AimError = VRand() * KnifeAimError;
        MyKnife.Velocity = Normal((TargetPlayer.Location + AimError) - SpawnLocation) * MyKnife.MaxSpeed ;
    }
}

function Trigger( Actor Other, Pawn EventInstigator )
{
    log(self@"===================================");
    log(self@"TRIGGERED BY - > "@EventInstigator);
    Super.Trigger(Other,EventInstigator);
}

/* turns this NPC on / off
ie. Makes it damageable and decides whether AI ignores it

Network :  Server */

function SetActive(bool On)
{
    if(!bFirstActivation && !bActive && On)
    {
        bFirstActivation = true;
        LastBombTossTime = Level.TimeSeconds;
        LastKnifeTossTime = Level.TimeSeconds;
    }

    Super.SetActive(On);

    if(bActive)
    {
        if(!bDiffAdjusted)
        {
            bDiffAdjusted = ScaleHealthToPlayerCount();
        }
    }
    else
    {
        BombTossInterval    *= (1.f - TossSpeedUpModifier)  ;
        KnifeTossInterval   *=  (1.f - TossSpeedUpModifier)  ;
    }
}

//// Scales the health this Story NPC has by number of players
function bool ScaleHealthToPlayerCount()
{
    local float ScalingValue;

    ScalingValue = NumPlayersHealthModifer();

	Health    *= ScalingValue;
    HealthMax *= ScalingValue;

    return true;
}


// returns a value to scale this NPC's health by
function float NumPlayersHealthModifer()
{
	local float AdjustedModifier;
	local int NumEnemies;
	local Controller C;

	AdjustedModifier = 1.0;

	For( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( PlayerController(C) != none && C.Pawn!=None && C.Pawn.Health > 0 )
		{
			NumEnemies++;
		}
	}

	if( NumEnemies > 1 )
	{
		AdjustedModifier += (NumEnemies - 1) * PlayerCountHealthScale;
	}

	return AdjustedModifier;
}


function ProcessLocationalDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, array<int> PointsHit )
{
    log("PROCESS LOC DAMAGE - "@Damage@instigatedBy@damageType@PointsHit[0]);
    Super.ProcessLocationalDamage(Damage,instigatedBy,hitLocation,momentum,damageType,PointsHit);
}

function float GetExposureTo(vector TestLocation)
{
	local float PercentExposed;

	if( FastTrace(GetBoneCoords(HeadBone).Origin,TestLocation))
	{
		PercentExposed += 1.f;
	}

	return PercentExposed;
}

defaultproperties
{
     PlayerCountHealthScale=0.750000
     AmmunitionClass=Class'KFMod.BZombieAmmo'
     BombTossInterval=15.000000
     KnifeTossInterval=4.000000
     TossSpeedUpModifier=0.250000
     KnifeProjectileClass=Class'KFCharPuppets.PuppetKnife'
     BombProjectileClass=Class'KFCharPuppets.ToyBomb'
     NumBombs=1
     NumHidingBombs=10
     NumKnives=5
     KnifeAimError=150.000000
     BombAimError=250.000000
     FindNewEnemyInterval=6.000000
     bNoThreatToZEDs=True
     bShowHealthBar=True
     NPCHealth=1000.000000
     bDamageable=False
     bUseHitPoints=True
     HeadBone="BoneD"
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'KF_Puppets.jack_in_the_box'
     Skins(0)=Texture'KF_Puppets_T.Gameplay.JackintheBox_D'
     Skins(1)=Texture'KF_Puppets_T.Gameplay.JackInTheBox_Box_D'
     CollisionRadius=200.000000
     CollisionHeight=300.000000
     bUseCylinderCollision=True
     bBlockHitPointTraces=True
}
