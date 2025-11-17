class BTrapProjectile extends Projectile;

//var float ExplodeTimer;
var bool bCanHitOwner, bHitWater;
var() float DampenFactor, DampenFactorParallel;
var class<xEmitter> HitEffectClass;
var float LastSparkTime;

var bool bHasExploded;
var     bool    bDisintegrated; // This nade has been disintegrated by a siren scream.
var     bool    bEnemyDetected; // We've found an enemy
var     bool    bArmed;         // Landed on the ground and armed
var() array<Sound> ExplodeSounds;
var     int     PlacedTeam;     // TeamIndex of the team that placed this projectile
var     bool            bTriggered; // This thing has exploded

var() 	array<string> 	ExplodeSoundRefs;
var		string			StaticMeshRef;

/// Оригинал. Для bTriggered не требуется репликация с сервера на клиент. Sir Arthur
/**replication
{
	reliable if(Role == ROLE_Authority)
		bTriggered;
}*/
///

static function PreloadAssets()
{
	default.ExplodeSounds[0] = sound(DynamicLoadObject(default.ExplodeSoundRefs[0], class'Sound', true));

	UpdateDefaultStaticMesh(StaticMesh(DynamicLoadObject(default.StaticMeshRef, class'StaticMesh', true)));
}

static function bool UnloadAssets()
{
	default.ExplodeSounds[0] = none;

	UpdateDefaultStaticMesh(none);

	return true;
}

// cut-n-paste to remove grenade smoke trail
simulated function PostBeginPlay()
{
	if ( Role == ROLE_Authority )
	{
		Instigator.PlaySound(Sound'KF_AxeSnd.Axe_Fire',SLOT_Pain,TransientSoundVolume,,TransientSoundRadius,,false);
		Velocity = Speed * Vector(Rotation);
		RandSpin(25000);
		bCanHitOwner = false;
		if (Instigator.HeadVolume.bWaterVolume)
		{
			bHitWater = true;
			Velocity = 0.6*Velocity;
		}
	}
}

function Timer()
{	
}

simulated function Landed( vector HitNormal )
{
    SetTimer(1.0,True);
    HitWall( HitNormal, none );
}

/// Sir Arthur
simulated singular function Touch(Actor Other) {
	local vector HitLocation, HitNormal;

	if(Other == None) return;

	///log(Default.Class.Name$", touch, touch is"@Other);
	///BroadcastText(Default.Class.Name$", 00_Touch, Other is"@Other$", KFBulletWhipAttachment is"@KFBulletWhipAttachment(Other));
	///BroadcastText(Default.Class.Name$", 00_Touch, KFHumanPawn is"@KFHumanPawn(Other));
	///BroadcastText(Default.Class.Name$", 00_Touch, Other.bBlockActors is"@Other.bBlockActors$", Other.bProjTarget is"@Other.bProjTarget);
	///BroadcastText(Default.Class.Name$", 00_Touch, KFMonster is"@KFMonster(Other)$", ExtendedZCollision is"@ExtendedZCollision(Other));

	if(KFHumanPawn(Other) != None ||  /// Проверяем, что человек коснулся капкана
	   /// Некоторые проверки происходят по имени класса, чтобы капкан не был зависим от последовательности компиляции мутаторов и расположения классов ботов и собаки
	      Other.Class.Name == 'Shepard' ||  /// Проверяем, что собака коснулась капкана
	   Projectile(Other) != None ||  /// Проверка на касания снарядами, включая мины, чтобы они не взрывались от капкана
	   KFMonster(Other) != None && ClassIsChildOf(Other.Class, Class'HardPat')) {  /// Проверяем, что Патриарх коснулся капкана
		return;  /// Выходим из функции, игнорируя касания капкана кем и чем угодно, включая Патриарха
	} 

	/// Этот код перенёс сюда из родительского класса Projectile, т. к. функция Touch является сингулярной, т. е. не может вызывать сама себя рекурсивно через спецификатор вызова Super
	///if ( Other.bProjTarget || Other.bBlockActors )  /// оригинал
	if(Other.bBlockActors)  /// Sir Arthur
	{
		///BroadcastText(Default.Class.Name$", 01_Touch, Other is"@Other);
		LastTouched = Other;
		if ( Velocity == vect(0,0,0) || Other.IsA('Mover') )
		{
			ProcessTouch(Other,Location);
			LastTouched = None;
			return;
		}

		if ( Other.TraceThisActor(HitLocation, HitNormal, Location, Location - 2*Velocity, GetCollisionExtent()) )
			HitLocation = Location;

		ProcessTouch(Other, HitLocation);
		LastTouched = None;
		if ( (Role < ROLE_Authority) && (Other.Role == ROLE_Authority) && (Pawn(Other) != None) )
			ClientSideTouch(Other, HitLocation);
	}
	///
}
///

simulated function ProcessTouch( actor Other, vector HitLocation )
{
	local int ttl;
	local InvBTrap RR;

	///log(Default.Class.Name$", 00_ProcessTouch, bTriggered is"@bTriggered);
	///BroadcastText(Default.Class.Name$", 00_ProcessTouch, bTriggered is"@bTriggered);
	if(!bTriggered)
	{
		if( Other.bBlockHitPointTraces )
		{
			///BroadcastText(Default.Class.Name$", 01_ProcessTouch, return");
			return;
		}

		if (Other.IsA('NetKActor'))
			KAddImpulse(Velocity,HitLocation,);

		if ( !Other.bWorldGeometry && ((Other != Instigator && Other.Base != Instigator )|| bCanHitOwner) )
			Velocity = Vect(0,0,0);
	}

	/// оригинал
	/**else
	{
		//LIST OF "BIG" ZEDS
		///log(Default.Class.Name$", 00_ProcessTouch, zombie is"@Other);
		///BroadcastText(Default.Class.Name$", 00_ProcessTouch, zombie is"@Other);
		if(KFMonster(Other)!=None && (Other.IsA('HardPat')))
		{
			if(Role==ROLE_Authority)
			{
				///log(Default.Class.Name$", 01_ProcessTouch, zombie is"@Other);
				///BroadcastText(Default.Class.Name$", 01_ProcessTouch, zombie is"@Other);
				PlaySound(ExplodeSounds[0],,2.5*TransientSoundVolume);
				Other.TakeDamage(Damage,Instigator,Other.Location,vect(0,0,1),MyDamageType);
				TTL=5;
				
				//BONUS FOR HUNTER
				if(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.default.PerkIndex==12)
				{
					TTL=5 + 1*(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkillLevel/14);
				}
				
				RR = KFMonster(Other).spawn(class'InvBTrap', Other,,,rot(0,0,0));
				RR.GiveTo(KFMonster(Other));
				RR.InitTimer(TTL);				
			}
			Destroy();
		}		
	}*/
	///

	/// Sir Arthur
	else {
		PlaySound(ExplodeSounds[0], , 2.5 * TransientSoundVolume);

		if(Role==ROLE_Authority) {
			Other.TakeDamage(Damage,Instigator,Other.Location,vect(0,0,1),MyDamageType);
			TTL=5;

			//BONUS FOR HUNTER
			if(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.default.PerkIndex==12)
			{
				TTL=5 + 1*(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkillLevel/14);
			}

			RR = KFMonster(Other).spawn(class'InvBTrap', Other,,,rot(0,0,0));
			RR.GiveTo(KFMonster(Other));
			RR.InitTimer(TTL);				
		}

		Destroy();
	}
	///
}

// Overridden to tweak the handling of the impact sound
simulated function HitWall( vector HitNormal, actor Wall )
{
    local Vector VNorm;
	local PlayerController PC;

    // Reflect off Wall w/damping
    VNorm = (Velocity dot HitNormal) * HitNormal;
    Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;

    RandSpin(100000);
    DesiredRotation.Roll = 0;
    RotationRate.Roll = 0;
    Speed = VSize(Velocity);

    if ( Speed < 20 )
    {
        bBounce = False;
        PrePivot.Z = 3.5;
		SetPhysics(PHYS_None);
		DesiredRotation = Rotation;
		DesiredRotation.Roll = 0;
		DesiredRotation.Pitch = 0;
		SetRotation(DesiredRotation);
		SetTimer(0.1,True);
		bTriggered=true;
    }
    else
    {
		if ( (Level.NetMode != NM_DedicatedServer) && (Speed > 50) )
			PlaySound(ImpactSound, SLOT_Misc );
		else
		{
			bFixedRotationDir = false;
			bRotateToDesired = true;
			DesiredRotation.Pitch = 0;
			RotationRate.Pitch = 50000;
		}
        if ( !Level.bDropDetail && (Level.DetailMode != DM_Low) && (Level.TimeSeconds - LastSparkTime > 0.5) && EffectIsRelevant(Location,false) )
        {
			PC = Level.GetLocalPlayerController();
			if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 6000 )
				Spawn(HitEffectClass,,, Location, Rotator(HitNormal));
            LastSparkTime = Level.TimeSeconds;
        }
    }
}

simulated function BlowUp(vector HitLocation)
{	
	if ( Role == ROLE_Authority )
		MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal);

simulated function Disintegrate(vector HitLocation, vector HitNormal);

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation );

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex);

defaultproperties
{
     DampenFactor=0.250000
     DampenFactorParallel=0.400000
     ExplodeSounds(0)=Sound'BTrap.BTrap_Act'
     StaticMeshRef="BTrap.BTrapSMesh"
     Speed=50.000000
     MaxSpeed=50.000000
     TossZ=0.000000
     Damage=2500.000000
     DamageRadius=350.000000
     MomentumTransfer=100000.000000
     MyDamageType=Class'BTrap.DamTypeBTrap'
     ImpactSound=SoundGroup'KF_GrenadeSnd.Nade_HitSurf'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'BTrap.BTrapSMesh'
     bNetTemporary=False
     Physics=PHYS_Falling
     LifeSpan=0.000000
     bUnlit=False
     FluidSurfaceShootStrengthMod=3.000000
     TransientSoundVolume=200.000000
     TransientSoundRadius=500.000000
     CollisionRadius=30.000000
     CollisionHeight=5.000000
     bProjTarget=True
     bNetNotify=True
     bBounce=True
     bFixedRotationDir=True
     DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
}
