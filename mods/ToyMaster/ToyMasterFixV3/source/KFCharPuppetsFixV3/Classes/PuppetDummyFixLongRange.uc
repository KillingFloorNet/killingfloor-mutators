//================
//Code fixes and balancing by Skell*.
//Original content is by Alex Quick and David Hensley.
//================
//Ventriloquist Puppet (Knifethrower)
//================
class PuppetDummyFixLongRange extends PuppetDummyLongRange;

#exec obj load file="KFPuppetsFixV3_T.utx"
#exec obj load file="KFPuppetsFixV3_A.ukx"

var float MeleeDamageBase; //Added to do difficulty scaling
var float HeadshotSkillMultiplier; //Added for trying headshots.

var () const class<Projectile> ThrownProjectileClass;

simulated function PostBeginPlay()
{
    //Damage scaling and aim style
    if (Level.Game != none && !bDiffAdjusted)
    {
        MeleeDamage = int(default.MeleeDamageBase * (1.0 + FClamp(((Level.Game.GameDifficulty - 2.0) / 5.0), 0.0, 1.0)));

        HeadshotSkillMultiplier = FClamp(((Level.Game.GameDifficulty - 2.0) / 5.0), 0.0, 1.0);
    }
    else
    {
    	MeleeDamage = int(MeleeDamageBase);
    }

    if(ThrownProjectileClass == class'KFCharPuppetsFixV3.PuppetKnifeFix')
    {
        class 'KFCharPuppetsFixV3.PuppetKnifeFix'.static.PreloadAssets();
    }

    super.PostBeginPlay();

    BurnDamageScale = 1.0; //Do everything else and then set this to 0
}



function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
    //Removed damage reduction to fire

    //Make the call go all the way back to KFMonster
    Super(KFMonster).TakeDamage(Damage,instigatedBy,hitlocation,momentum,damageType,HitIndex);
}

//Overwritten to fix knives
function SpawnTwoShots()
{
	local vector X,Y,Z, FireStart;
	local rotator FireRotation;

	local Projectile ThrownKnife;
	
	//Extra aim calculations
	local vector TargetLoc;
	local float XDist, YDist, ZDist, HDist;
	local float CurrentAngle, HeadAngle, OffsetAngle;

	if( Controller!=None && KFDoorMover(Controller.Target)!=None )
	{
		Controller.Target.TakeDamage(22,Self,Location,vect(0,0,0),Class'DamTypeVomit');
		return;
	}

	GetAxes(Rotation,X,Y,Z);
	FireStart = GetBoneCoords('Knife_L').Origin;
	if ( !SavedFireProperties.bInitialized )
	{
		SavedFireProperties.AmmoClass = Class'SkaarjAmmo';
		SavedFireProperties.ProjectileClass = ThrownProjectileClass; //Changed from PuppetKnife
		SavedFireProperties.WarnTargetPct = 1;
		SavedFireProperties.MaxRange = 65535;
		SavedFireProperties.bTossed = False;
		SavedFireProperties.bTrySplash = False; //Why would you try splash damage? Changed to false.
		SavedFireProperties.bLeadTarget = True;
		SavedFireProperties.bInstantHit = False;
		SavedFireProperties.bInitialized = True;
	}

    ToggleAuxCollision(false);

	FireRotation = Controller.AdjustAim(SavedFireProperties,FireStart,450);

	//If we're on Suicidal or Hell on Earth, we'll go for headshots/upper-body shots.
	if(Controller != None && KFHumanPawn(Controller.Target) != None)
	{
		TargetLoc = Controller.Target.Location;
		
		//Break down the vector and get scalar values so we can estimate and angle.
		XDist = abs(Location.X - TargetLoc.X);
		YDist = abs(Location.Y - TargetLoc.Y);
		ZDist = abs(Location.Z - TargetLoc.Z);

		HDist = Sqrt(Square(XDist) + Square(YDist));

		if(HDist < 0.01)
			HDist = 1.0;

		CurrentAngle = 32768.0 * Tan(ZDist/HDist);
		HeadAngle = 32768.0 * Tan((ZDist + Controller.Target.CollisionHeight)/HDist);

		OffsetAngle = HeadAngle - CurrentAngle;

		//Clamped to ensure the throw doesn't go crazy if the target is super close.
		FireRotation.Pitch += Clamp(int( (OffsetAngle * (FRand() - 0.35) ) * (0.55 * HeadshotSkillMultiplier)), -8192, 8192);
	}
    
    ThrownKnife = Spawn(ThrownProjectileClass,,,FireStart,FireRotation); //Changed from PuppetKnife

    if(ThrownKnife != None)
    	ThrownKnife.Instigator = self;

	ToggleAuxCollision(true);
}

//Overwritten to change HitF as that's not an animation for puppet_ventriloquist.
function RemoveHead()
{
	local int i;

	Intelligence = BRAINS_Retarded;

	bDecapitated  = true;
	DECAP = true;
	DecapTime = Level.TimeSeconds;

	Velocity = vect(0,0,0);
	SetAnimAction('Hit_reaction_F'); //Changed from HitF
	SetGroundSpeed(GroundSpeed *= 0.80);
	AirSpeed *= 0.8;
	WaterSpeed *= 0.8;

	AmbientSound = MiscSound;

	if ( Controller != none )
	{
		MonsterController(Controller).Accuracy = -5;
	}

	if( KFPawn(LastDamagedBy)!=None )
	{
		TakeDamage( LastDamageAmount + 0.25 * HealthMax , LastDamagedBy, LastHitLocation, LastMomentum, LastDamagedByType);

		if ( BurnDown > 0 )
		{
			KFSteamStatsAndAchievements(KFPawn(LastDamagedBy).PlayerReplicationInfo.SteamStatsAndAchievements).AddBurningDecapKill(class'KFGameType'.static.GetCurrentMapName(Level));
		}
	}

	if( Health > 0 )
	{
		BleedOutTime = Level.TimeSeconds +  BleedOutDuration;
	}

	if (MeleeAnims[2] == 'Claw3')
		MeleeAnims[2] = 'Claw2';
	if (MeleeAnims[1] == 'Claw3')
		MeleeAnims[1] = 'Claw1';

	for( i = 0; i < 4; i++ )
	{
		if( HeadlessWalkAnims[i] != '' && HasAnim(HeadlessWalkAnims[i]) )
		{
			MovementAnims[i] = HeadlessWalkAnims[i];
			WalkAnims[i]     = HeadlessWalkAnims[i];
		}
	}

	PlaySound(DecapitationSound, SLOT_Misc,1.30,true,525);
}

defaultproperties
{
     MeleeDamageBase=6.000000
     ThrownProjectileClass=Class'KFCharPuppetsFixV3.PuppetKnifeFix'
     BurnDamageScale=1.000000
     ColOffset=(Z=36.000000)
     ColRadius=20.000000
     ColHeight=26.000000
     LeftShoulderBone="CHR_LCollarbone"
     RightShoulderBone="CHR_RCollarbone"
     LeftThighBone="CHR_LThigh"
     RightThighBone="CHR_RThigh"
     LeftFArmBone="CHR_LForearm"
     RightFArmBone="CHR_RForearm"
     LeftFootBone="CHR_LFoot"
     RightFootBone="CHR_RFoot"
     LeftHandBone="CHR_LPalm"
     RightHandBone="CHR_RPalm"
     OnlineHeadshotOffset=(X=2.500000,Z=44.000000)
     OnlineHeadshotScale=1.250000
     HeadHealth=65.000000
     HealthMax=325.000000
     Health=325
     MovementAnims(0)="WalkF"
     SwimAnims(0)="WalkF"
     SwimAnims(1)="WalkB"
     SwimAnims(2)="WalkL"
     SwimAnims(3)="WalkR"
     WalkAnims(0)="WalkF"
     WalkAnims(1)="WalkB"
     WalkAnims(2)="WalkL"
     WalkAnims(3)="WalkR"
     DodgeAnims(0)="hit_reaction_F"
     DodgeAnims(1)="hit_reaction_B"
     DodgeAnims(2)="hit_reaction_L"
     DodgeAnims(3)="hit_reaction_R"
     Mesh=SkeletalMesh'KFPuppetsFixV3_A.puppet_ventriloquist_fix'
     CollisionRadius=16.000000
     CollisionHeight=29.000000
}
