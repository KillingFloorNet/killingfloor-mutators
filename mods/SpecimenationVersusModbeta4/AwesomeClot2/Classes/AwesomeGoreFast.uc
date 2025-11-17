class AwesomeGoreFast extends ZombieGorefast
	placeable;

function postbeginplay()
{

super.postbeginplay();

setheadscale(1.0);
}
simulated function Fire( optional float F )
{
	local actor HitActor;
	local vector HitNormal, HitLocation;
	local array<int> hits;
	
	
	HitActor = HitpointTrace(HitLocation, HitNormal, Location + vect(0,0,1) * baseeyeheight + 1000 * vector(controller.Rotation),Hits,Location + vect(0,0,1) * baseeyeheight + 1* vector(controller.Rotation)); 

	if( hitactor != none && hitactor != self )
	{
		controller.target=hitactor;
	

		rangedattack(hitactor);
	}
	//super.fire(f);

}

function RangedAttack(Actor A)
{
	Super.RangedAttack(A);
	//if( !bShotAnim && !bDecapitated && VSize(A.Location-Location)<=700 )
		GoToState('RunningState2');
}
/*function PostNetReceive()
{
	if (bRunning)
		MovementAnims[0]='ZombieRun';
	else MovementAnims[0]=default.MovementAnims[0];
}*/
function bool CanAttack(Actor A)
{
	return true;
}
simulated function tick( float d )
{
	local actor HitActor;
	local vector HitNormal, HitLocation;
	local array<int> hits;



	if(controller!=none)
	{


		HitActor = HitpointTrace(HitLocation, HitNormal, (Location + vect(0,0,1) * baseeyeheight) + 100 * vector(controller.Rotation),Hits,(Location + vect(0,0,1) * baseeyeheight) + 1* vector(controller.Rotation));
  
	
		if(hitactor!=none)
		controller.target=hitactor;
			


		super.tick(d);
	}
	
	//if (bRunning) MovementAnims[0]='ZombieRun';
	MovementAnims[0]='WalkF_Fire';

	if(!isinstate('jumprest')&&health>10)
	gotostate('RunningState2');


	linkmesh(skeletalmesh'gorefast_freak');
	skins[0]=Combiner'KF_Specimens_Trip_T.gorefast_cmb';
	skins[1]=none;skins[2]=none;
	
	ragdolloverride="GoreFast_Trip";
}
state RunningState2
{
    // Don't override speed in this state
   function bool CanSpeedAdjust()
    {
        return false;
    }

	function BeginState()
	{
		GroundSpeed = OriginalGroundSpeed;
		//bRunning = true;
		if( Level.NetMode!=NM_DedicatedServer )
			PostNetReceive();

		NetUpdateTime = Level.TimeSeconds - 1;
	}

	function EndState()
	{
		//GroundSpeed = OriginalGroundSpeed;
		//bRunning = False;
		if( Level.NetMode!=NM_DedicatedServer )
			PostNetReceive();

		//RunAttackTimeout=0;

		//NetUpdateTime = Level.TimeSeconds - 1;
	}

	function RemoveHead()
	{
         Global.RemoveHead();
	}
    function RangedAttack(Actor A)
    {
        local float ChargeChance;

      
		chargechance = 1.0;

    	if ( bShotAnim || Physics == PHYS_Swimming)
    		return;
    	else if ( CanAttack(A) )
    	{
    		bShotAnim = true;

    		 //Randomly do a moving attack so the player can't kite the zed
           if( FRand() < ChargeChance )
    		{
        		SetAnimAction('ClawAndMove');
        		RunAttackTimeout = GetAnimDuration('GoreAttack1', 1.0);
    		}
    		else
    		{
        		SetAnimAction('Claw');
        		Controller.bPreparingMove = true;
        		//Acceleration = vect(0,0,0);
                
        		GoToState('RunningState2');
    		}
    		return;
    	}
    }

    function Tick(float DeltaTime)
    {
		global.Tick(DeltaTime);
    }


Begin:
    GoTo('CheckCharge');
CheckCharge:
    if( Controller!=None && Controller.Target!=None && VSize(Controller.Target.Location-Location)<700 )
    {
        Sleep(0.5+ FRand() * 0.5);
        //log("Still charging");
        GoTo('CheckCharge');
    }

}

function HandleBumpGlass()
{
	//Acceleration = vect(0,0,0);
	//Velocity = vect(0,0,0);

	SetAnimAction(MeleeAnims[0]);
	bShotAnim = true;
	//controller.GotoState('WaitForAnim');
}


function controller findController()
{
local controller c;

For( C=Level.ControllerList; C!=None; C=C.NextController )
	{  if(monstercontroller(c)!=none&&c.pawn==self)
              {return c;}

        }

}

State ZombieDying
{
ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, Died, RangedAttack;     //Tick

	function Landed(vector HitNormal)
	{
		//SetPhysics(PHYS_None);
		SetCollision(false, false, false);
		Disable('Tick');
	}

	function Timer()
	{
		local KarmaParamsSkel skelParams;

		if ( !PlayerCanSeeMe() )
		{
			StartDeRes();
			Destroy();
		}
		// If we are running out of life, but we still haven't come to rest, force the de-res.
		// unless pawn is the viewtarget of a player who used to own it
		else if ( LifeSpan <= DeResTime && bDeRes == false )
		{
			skelParams = KarmaParamsSkel(KParams);

			skelParams.bKImportantRagdoll = false;

			// spawn derez
			bDeRes=true;
		}
		else
		{
			SetTimer(1.0, false);
		}
	}

	function BeginState()
	{
     local controller c;
		
		c=findController();
        if ( bTearOff && (Level.NetMode == NM_DedicatedServer) )
			LifeSpan = 1.0;
		else
			SetTimer(2.0, false);

        SetPhysics(PHYS_Falling);
		if ( c != None )
		{
			C.Destroy();
		}//SetCollision(false, false, false);
 	}
}
simulated function RemoveHead()
{
    local int i;

	Intelligence = BRAINS_Retarded; // Headless dumbasses!

	bDecapitated  = true;
	DECAP = true;
	DecapTime = Level.TimeSeconds;

	Velocity = vect(0,0,0);
	SetAnimAction('HitF');
	GroundSpeed *= 0.8;
	AirSpeed *= 0.8;
	WaterSpeed *= 0.8;
	setheadscale(0);
	// No more raspy breathin'...cuz he has no throat or mouth :S
	AmbientSound = MiscSound;

	//TODO - do we need to inform the controller that we can't move owing to lack of head,
	//	   or is that handled elsewhere
	MonsterController(Controller).Accuracy = -5;  // More chance of missing. (he's headless now, after all) :-D

	// Head explodes, causing additional hurty.

	if( KFPawn(LastDamagedBy)!=None )
          TakeDamage( LastDamageAmount + 0.25 * HealthMax , LastDamagedBy, LastHitLocation, LastMomentum, LastDamagedByType);

    if( Health > 0 )
    {
        BleedOutTime = Level.TimeSeconds +  BleedOutDuration;
    }

	//TODO - Find right place for this
	// He's got no head so biting is out.
	if (MeleeAnims[2] == 'Claw3')
		MeleeAnims[2] = 'Claw2';
	if (MeleeAnims[1] == 'Claw3')
		MeleeAnims[1] = 'Claw1';

    // Plug in headless anims if we have them
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

function bool DoJump( bool bUpdating )
{

	if ( !bIsCrouched && !bWantsToCrouch && ((Physics == PHYS_Walking) || (Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) )
	{

		Velocity.Z = JumpZ;
		setPhysics(PHYS_falling);
		gotostate('Jumprest');
		return true;
	}
	return false;	
}
state Jumprest
{

function beginstate()
{	
	settimer(2,false);
	jumpz=0;

}
function timer()
{

	jumpz=default.jumpz;
	gotostate('runningstate2');

}

	function bool DoJump( bool bUpdating );
}

// High damage was taken, make em fall over.
function bool FlipOver()
{
	if( Physics==PHYS_Falling )
		SetPhysics(PHYS_Walking);
	bShotAnim = true;
	SetAnimAction('KnockDown');
	Acceleration = vect(0,0,0);
	Velocity.X = 0;
	Velocity.Y = 0;
	Return True;
}

// New Hit FX for Zombies!
simulated function PlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, optional int HitIdx )
{
	local Vector HitNormal;
	local Vector HitRay ;
	local Name HitBone;
	local float HitBoneDist;
	local PlayerController PC;
	local bool bShowEffects, bRecentHit;
	local ProjectileBloodSplat BloodHit;
	local rotator SplatRot;

	bRecentHit = Level.TimeSeconds - LastPainTime < 0.2;

    LastDamageAmount = Damage;

	// Call the modified version of the original Pawn playhit
	OldPlayHit(Damage,InstigatedBy,HitLocation,DamageType,Momentum);

	if ( Damage <= 0 )
		return;

	if( Health>0 && Damage>(float(Default.Health)/1.5) )
		FlipOver();

	PC = PlayerController(Controller);
	bShowEffects = ( (Level.NetMode != NM_Standalone) || (Level.TimeSeconds - LastRenderTime < 2.5)
					|| ((InstigatedBy != None) && (PlayerController(InstigatedBy.Controller) != None))
					|| (PC != None) );
	if ( !bShowEffects )
		return;

	if ( BurnDown > 0 && !bBurnified )
	{
    	bBurnified = true;
	}

	HitRay = vect(0,0,0);
	if( InstigatedBy != None )
		HitRay = Normal(HitLocation-(InstigatedBy.Location+(vect(0,0,1)*InstigatedBy.EyeHeight)));

	if( DamageType.default.bLocationalHit )
	{
		CalcHitLoc( HitLocation, HitRay, HitBone, HitBoneDist );
	}
	else
	{
		HitLocation = Location ;
		HitBone = FireRootBone;
		HitBoneDist = 0.0f;
	}

	if( DamageType.default.bAlwaysSevers && DamageType.default.bSpecial )
		HitBone = 'head';

	if( InstigatedBy != None )
		HitNormal = Normal( Normal(InstigatedBy.Location-HitLocation) + VRand() * 0.2 + vect(0,0,2.8) );
	else
		HitNormal = Normal( Vect(0,0,1) + VRand() * 0.2 + vect(0,0,2.8) );

	//log("HitLocation "$Hitlocation) ;

	if ( DamageType.Default.bCausesBlood && (!bRecentHit || (bRecentHit && (FRand() > 0.8))))
	{
		if ( !class'GameInfo'.static.NoBlood() )
		{
        	if ( Momentum != vect(0,0,0) )
				SplatRot = rotator(Normal(Momentum));
			else
			{
				if ( InstigatedBy != None )
					SplatRot = rotator(Normal(Location - InstigatedBy.Location));
				else
					SplatRot = rotator(Normal(Location - HitLocation));
			}

		 	BloodHit = Spawn(ProjectileBloodSplatClass,InstigatedBy,, HitLocation, SplatRot);
		}
	}

	if( InstigatedBy != none && InstigatedBy.PlayerReplicationInfo != none &&
        KFSteamStatsAndAchievements(InstigatedBy.PlayerReplicationInfo.SteamStatsAndAchievements) != none &&
		Health <= 0 && Damage > DamageType.default.HumanObliterationThreshhold && Damage != 1000 && (!bDecapitated || bPlayBrainSplash) )
	{
		KFSteamStatsAndAchievements(InstigatedBy.PlayerReplicationInfo.SteamStatsAndAchievements).AddGibKill(class<DamTypeM79Grenade>(damageType) != none);

		if ( self.IsA('ZombieFleshPound') )
		{
			KFSteamStatsAndAchievements(InstigatedBy.PlayerReplicationInfo.SteamStatsAndAchievements).AddFleshpoundGibKill();
		}
	}

	DoDamageFX( HitBone, Damage, DamageType, Rotator(HitNormal) );

	if (DamageType.default.DamageOverlayMaterial != None && Damage > 0 ) // additional check in case shield absorbed
		SetOverlayMaterial( DamageType.default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, false );
}

// Modified version of the original Pawn playhit. Set up because we want our blood puffs to be directional based
// On the momentum of the bullet, not out from the center of the player
simulated function OldPlayHit(float Damage, Pawn InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, optional int HitIndex)
{
    local Vector HitNormal;
	local vector BloodOffset, Mo;
	local class<Effects> DesiredEffect;
	local class<Emitter> DesiredEmitter;
	local PlayerController Hearer;

	if ( DamageType == None )
		return;
	if ( (Damage <= 0) && ((Controller == None) || !Controller.bGodMode) )
		return;

	if (Damage > DamageType.Default.DamageThreshold) //spawn some blood
	{

		HitNormal = Normal(HitLocation - Location);

		// Play any set effect
		if ( EffectIsRelevant(Location,true) )
		{
			DesiredEffect = DamageType.static.GetPawnDamageEffect(HitLocation, Damage, Momentum, self, (Level.bDropDetail || Level.DetailMode == DM_Low));

			if ( DesiredEffect != None )
			{
				BloodOffset = 0.2 * CollisionRadius * HitNormal;
				BloodOffset.Z = BloodOffset.Z * 0.5;

				Mo = Momentum;
				if ( Mo.Z > 0 )
					Mo.Z *= 0.5;
				spawn(DesiredEffect,self,,HitLocation + BloodOffset, rotator(Mo));
			}

			// Spawn any preset emitter

			DesiredEmitter = DamageType.Static.GetPawnDamageEmitter(HitLocation, Damage, Momentum, self, (Level.bDropDetail || Level.DetailMode == DM_Low));
			if (DesiredEmitter != None)
			{
			    if( InstigatedBy != none )
			        HitNormal = Normal((InstigatedBy.Location+(vect(0,0,1)*InstigatedBy.EyeHeight))-HitLocation);

				spawn(DesiredEmitter,,,HitLocation+HitNormal + (-HitNormal * CollisionRadius), Rotator(HitNormal));
			}
		}
	}
	if ( Health <= 0 )
	{
		if ( PhysicsVolume.bDestructive && (PhysicsVolume.ExitActor != None) )
			Spawn(PhysicsVolume.ExitActor);
		return;
	}

	if ( Level.TimeSeconds - LastPainTime > 0.1 )
	{
		if ( InstigatedBy != None && (DamageType != None) && DamageType.default.bDirectDamage )
			Hearer = PlayerController(InstigatedBy.Controller);
		if ( Hearer != None )
			Hearer.bAcuteHearing = true;
		PlayTakeHit(HitLocation,Damage,damageType);
		if ( Hearer != None )
			Hearer.bAcuteHearing = false;
		LastPainTime = Level.TimeSeconds;
	}
}

// Implemented in subclasses - return false if there is some action that we don't want the direction hit to interrupt
simulated function bool HitCanInterruptAction()
{
    return true;
}

simulated function PlayDirectionalHit(Vector HitLoc)
{
	local Vector X,Y,Z, Dir;

	GetAxes(Rotation, X,Y,Z);
	HitLoc.Z = Location.Z;
	Dir = -Normal(Location - HitLoc);


    if( !HitCanInterruptAction() )
    {
        return;
    }

	// random
	if ( VSize(Location - HitLoc) < 1.0 )
		Dir = VRand();
	else Dir = -Normal(Location - HitLoc);

	if ( Dir Dot X > 0.7 || Dir == vect(0,0,0))
	{
		if( LastDamagedBy!=none && LastDamageAmount>0 )
			if (VSize(LastDamagedBy.Location - Location) <= (MeleeRange * 2) && ClassIsChildOf(LastDamagedbyType,class 'DamTypeMelee')
			 && LastDamageAmount > (0.10* default.Health) || LastDamageAmount >= (0.5 * default.Health) )
			{
                SetAnimAction(HitAnims[Rand(3)]);
				bSTUNNED = true;
				SetTimer(1.0,false);
			}
		else SetAnimAction(KFHitFront);
	}
	else if ( Dir Dot X < -0.7 )
		SetAnimAction(KFHitBack);
	else if ( Dir Dot Y > 0 )
		SetAnimAction(KFHitRight);
	else SetAnimAction(KFHitLeft);
}


simulated function bool IsHeadShot(vector loc, vector ray, float AdditionalScale)
{
    local coords C;
    local vector HeadLoc, B, M, diff;
    local float t, DotMM, Distance;
    local int look;

    if (HeadBone == '')
        return False;

    // If we are a dedicated server estimate what animation is most likely playing on the client
    if (Level.NetMode == NM_DedicatedServer)
    {
        if (Physics == PHYS_Falling)
            PlayAnim(AirAnims[0], 1.0, 0.0);
        else if (Physics == PHYS_Walking)
        {
            // Only play the idle anim if we're not already doing a different anim.
            // This prevents anims getting interrupted on the server and borking things up - Ramm
            if( !IsAnimating(0) )
            {
                if (bIsCrouched)
                    PlayAnim(IdleCrouchAnim, 1.0, 0.0);
                else
                    PlayAnim(IdleWeaponAnim, 1.0, 0.0);
            }

			if ( bDoTorsoTwist )
			{
                SmoothViewYaw = Rotation.Yaw;
                SmoothViewPitch = ViewPitch;

                look = (256 * ViewPitch) & 65535;
                if (look > 32768)
                    look -= 65536;

                SetTwistLook(0, look);
            }
        }
        else if (Physics == PHYS_Swimming)
            PlayAnim(SwimAnims[0], 1.0, 0.0);

        SetAnimFrame(0.5);
    }

    C = GetBoneCoords(HeadBone);

    HeadLoc = C.Origin + (HeadHeight * HeadScale * AdditionalScale * C.XAxis);

    // Express snipe trace line in terms of B + tM
    B = loc;
    M = ray * (2.0 * CollisionHeight + 2.0 * CollisionRadius);

    // Find Point-Line Squared Distance
    diff = HeadLoc - B;
    t = M Dot diff;
    if (t > 0)
    {
        DotMM = M dot M;
        if (t < DotMM)
        {
            t = t / DotMM;
            diff = diff - (t * M);
        }
        else
        {
            t = 1;
            diff -= M;
        }
    }
    else
        t = 0;

    Distance = Sqrt(diff Dot diff);

    return (Distance < (HeadRadius * HeadScale * AdditionalScale));
}

defaultproperties
{
     MeleeDamage=10
     KFRagdollName="Gorefast_Trip"
     GroundSpeed=240.000000
     JumpZ=450.000000
     HealthMax=200.000000
     Health=200
     ControllerClass=None
	 MovementAnims(0)='WalkF_Fire'
}
