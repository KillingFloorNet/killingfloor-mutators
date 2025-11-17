//=============================================================================
// AwesomeGoreFast.
//=============================================================================
class Awesomepat extends Zombieboss
	placeable;
	
var int Speed, Invisibility;
var bool bSpeedUp, bCloak, bSwapped;

replication
{
	reliable if(Role == ROLE_Authority)
		bSpeedUp, bCloak, bSwapped, Speed, Invisibility;
}

function SwapWeapons()
{
	bSwapped = !bSwapped;
	if(!bSwapped)
		PlayerController(Controller).ClientMessage("Switched to machinegun", 'CriticalEvent');
	else
		PlayerController(Controller).ClientMessage("Switched to rocketlauncher", 'CriticalEvent');
}

function Hide()
{
	if (!bCloaked && !bShotAnim)
	{
		bCloak = true;
		return;
	}
	if(bCloaked)
		bCloak = false;
}

function SpeedUp()
{
	if(Speed>0)
		bSpeedUp=true;
}

function SpeedDown()
{
	bSpeedUp=false;	
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	local float DamagerDistSq;
	local float UsedPipeBombDamScale;

    //log(GetStateName()$" Took damage. Health="$Health$" Damage = "$Damage$" HealingLevels "$HealingLevels[SyringeCount]);

    if ( class<DamTypeCrossbow>(damageType) == none && class<DamTypeCrossbowHeadShot>(damageType) == none )
    {
    	bOnlyDamagedByCrossbow = false;
    }

    // Scale damage from the pipebomb down a bit if lots of pipe bomb damage happens
    // at around the same times. Prevent players from putting all thier pipe bombs
    // in one place and owning the patriarch in one blow.
	if ( class<DamTypePipeBomb>(damageType) != none )
	{
	   UsedPipeBombDamScale = FMax(0,(1.0 - PipeBombDamageScale));

	   PipeBombDamageScale += 0.075;

	   if( PipeBombDamageScale > 1.0 )
	   {
	       PipeBombDamageScale = 1.0;
	   }

	   Damage *= UsedPipeBombDamScale;
	}

    Super(kfmonster).TakeDamage(Damage,instigatedBy,hitlocation,Momentum,damageType);

    if( ShouldChargeFromDamage() && ChargeDamage > 200 )
    {
        // If someone close up is shooting us, just charge them
        if( InstigatedBy != none )
        {
            DamagerDistSq = VSizeSquared(Location - InstigatedBy.Location);

            if( DamagerDistSq < (700 * 700) )
            {
                SetAnimAction('transition');
        		ChargeDamage=0;        		
        		return;
    		}
        }
    }

	if( Health<=0 || SyringeCount==3 || IsInState('Escaping') || IsInState('KnockDown') /*|| bShotAnim*/ )
		Return;

	if( (SyringeCount==0 && Health<HealingLevels[0]) || (SyringeCount==1 && Health<HealingLevels[1]) || (SyringeCount==2 && Health<HealingLevels[2]) )
	{
	    bShotAnim = true;
		Acceleration = vect(0,0,0);
		SetAnimAction('KnockDown');
		HandleWaitForAnim('KnockDown');
		KFMonsterController(Controller).bUseFreezeHack = True;		
	}
}

function Timer()
{
	if(!bCloak)
	{
		Invisibility+=1;
		if(Invisibility>20)
			Invisibility=20;
	}
	else
	{
		Invisibility-=1;
		if(Invisibility<0)
		{
			Invisibility=0;
			bCloak = false;
		}
	}
	if(!bSpeedUp)
	{
		Speed+=1;
		if(Speed>20)
			Speed=20;
	}
	else
	{
		Speed-=1;
		if(Speed<0)
		{
			Speed=0;
			bSpeedUp = false;
		}
	}
}

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
	SetTimer(1.0,true);
	Speed=20;
	Invisibility=20;
	SetHeadScale(1.0);

	//spawn(class'ROVehicleObliteratedEmitter',,,);
    if( Role < ROLE_Authority )
    {
        return;
    }

	// Difficulty Scaling
	if (Level.Game != none)
	{
        //log(self$" Beginning ground speed "$default.GroundSpeed);

        // If you are playing by yourself,  reduce the MG damage
        if( Level.Game.NumPlayers == 1 )
        {
            if( Level.Game.GameDifficulty < 2.0 )
            {
                MGDamage = default.MGDamage * 0.375;
            }
            else if( Level.Game.GameDifficulty < 4.0 )
            {
                MGDamage = default.MGDamage * 0.75;
            }
            else if( Level.Game.GameDifficulty < 7.0 )
            {
                MGDamage = default.MGDamage * 1.15;
            }
            else // Hardest difficulty
            {
                MGDamage = default.MGDamage * 1.3;
            }
        }
        else
        {
            if( Level.Game.GameDifficulty < 2.0 )
            {
                MGDamage = default.MGDamage * 0.375;
            }
            else if( Level.Game.GameDifficulty < 4.0 )
            {
                MGDamage = default.MGDamage * 1.0;
            }
            else if( Level.Game.GameDifficulty < 7.0 )
            {
                MGDamage = default.MGDamage * 1.15;
            }
            else // Hardest difficulty
            {
                MGDamage = default.MGDamage * 1.3;
            }
        }
	}

	HealingLevels[0] = 2000; 
	HealingLevels[1] = 2000; 
	HealingLevels[2] = 4000; 

	HealingAmount = 1200; // 1750 HP

}

event Bump(actor Other)
{
	Super(Monster).Bump(Other);
	if( Other==none )
		return;

	if( Other.IsA('NetKActor') && Physics != PHYS_Falling && !bShotAnim && Abs(Other.Location.Z-Location.Z)<(CollisionHeight+Other.CollisionHeight) )
	{ // Kill the annoying deco brat.
		Controller.Target = Other;
		Controller.Focus = Other;
		bShotAnim = true;
		SetAnimAction('MeleeClaw');
		HandleWaitForAnim('MeleeClaw');
	}
}

simulated function Fire( optional float F )
{
	local actor HitActor;
	local vector HitNormal, HitLocation, PushDir;
	
	HitActor = Trace(HitLocation, HitNormal, Location + 100 * vector(Rotation),Location + vector(Rotation), true);
	  
	controller.target=hitactor;
	controller.enemy=pawn(hitactor);
	
	/*if( bSwapped )
	{
		PushDir = damageForce * vector(Rotation);
		hitactor.TakeDamage(20, self ,HitLocation,pushdir, class'DamTypeClaws');
	}*/

	rangedattack3(hitactor);
	gotostate('jumprest');
}

function RangedAttack3(Actor A)
{
	local vector PushDir, HitLocation;
	
	if ( bShotAnim )
		return;

	bCloak=false;
	UnCloakBoss();
	
	//KFPlayerController(controller).ClientMessage("Target"@A);
	
	bShotAnim = true;
	if( bSwapped )
	{
		//PushDir = damageForce * vector(Rotation);
		//A.TakeDamage(MeleeDamage, self ,HitLocation,pushdir, CurrentDamType);
		//SetAnimAction('MeleeImpale');
		SetAnimAction('RadialAttack');
		//MeleeDamageTarget(MeleeDamage, pushdir);
		//ClawDamageTarget();
	}
	else
	{
		SetAnimAction('MeleeClaw');	
	}
	Controller.bPreparingMove = true;
	Acceleration = vect(0,0,0);
}

simulated function Altfire(optional float f)
{
	local actor HitActor;
	local vector HitNormal, HitLocation;

	bCloak = false;
	
	if(!bswapped)
	{
		bShotAnim = true;
		Acceleration = vect(0,0,0);
		HandleWaitForAnim('PreFireMG');
		AnimBlendParams(1, 1.0, 0.0,, FireRootBone);
		SetAnimAction('PreFireMG');

		MGFireCounter =  Rand(60) + 35;
		GoToState('FireChaingun2');
	}
	else
	{
		HitActor = Trace(HitLocation, HitNormal, Location + 10000 * vector(controller.Rotation),Location + 10* vector(controller.Rotation));
	  	
		controller.target=hitactor;
		controller.enemy=pawn(hitactor);
		
		LastMissileTime = Level.TimeSeconds + 10 + FRand() * 15;

		bShotAnim = true;
		Acceleration = vect(0,0,0);
		AnimBlendParams(1, 1.0, 0.0,, FireRootBone);
		PlayAnim('PreFireMissile',, 0.1, 1);
		SetAnimAction('PreFireMissile');
		HandleWaitForAnim('PreFireMissile');

		GoToState('FireMissile');
	}
}

function bool CanAttack(Actor A)
{
	return true;
}

simulated function HandleWaitForAnim( name NewAnim )
{
    local float RageAnimDur;

	RageAnimDur = GetAnimDuration(NewAnim);
}

function StartHealing()
{
	
	bCloak=false;
	UnCloakBoss();
	bShotAnim = true;
	Acceleration = vect(0,0,0);
	SetAnimAction('Heal');
	HandleWaitForAnim('Heal');
	health += healingamount;
	KFGameType(Level.Game).AddBossBuddySquad();
}

function bool CanHeal()
{
	local int i;
	
	for(i = 0; i < 3; i++)
	{
		if( healinglevels[i] > 0)
		{
			healinglevels[i] = 0;
			return true;
		}
	}
	return false;
}

function bool MakeGrandEntry()
{
	bShotAnim = true;
	Acceleration = vect(0,0,0);
	SetAnimAction('Entrance');	

	return True;
}

simulated function tick(float delta)
{
	local controller c;
	local actor HitActor;
	local vector HitNormal, HitLocation;
	
    super.tick(delta);
	    
    if( !controller.isa('playercontroller') )
		return;
		
	HitActor = Trace(HitLocation, HitNormal, Location + 10000 * vector(controller.Rotation),Location, true);
	
	if(hitactor!=none)
	controller.target=hitactor;

	if( controller.isa('playercontroller') && findController()!=none)
	findController().destroy();

	controller.enemy=none;

    linkmesh(skeletalmesh'Patriarch_freak');
	if(bCloak && !bCloaked )
		CloakBoss();
	else if (!bCloak)
		UnCloakBoss();
	if(bSpeedUp)
	{
		GroundSpeed = 300;
		MovementAnims[0]='RunF';
	}
	else
	{
		GroundSpeed = 120;
		MovementAnims[0]=default.MovementAnims[0];
	}
	/*Skins[0]=Combiner'KF_Specimens_Trip_T.gatling_cmb';
    Skins[1]=Combiner'KF_Specimens_Trip_T.patriarch_cmb';
	skins[2]=none;*/
	ragdolloverride="Patriarch_Trip";
	

	For( C=Level.ControllerList; C!=None; C=C.NextController )
	{  
		if(monstercontroller(c)!=none&&c.pawn==self)
          {c.target=controller.target;c.setrotation(controller.rotation);}
    }

	if(bShotAnim)
	{
		acceleration=vect(0,0,0);
		velocity=vect(0,0,0);
	}
}

state FireChaingun2
{
	function RangedAttack(Actor A)
	{
		Controller.Target = A;		
	}

    // Chaingun mode handles this itself
    function bool ShouldChargeFromDamage()
    {
        return false;
    }

    function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
    {
        global.TakeDamage(Damage,instigatedBy,hitlocation,vect(0,0,0),damageType);
    }

	simulated function EndState()
	{
        TraceHitPos = vect(0,0,0);
		bMinigunning = False;

        AmbientSound = default.AmbientSound;
        SoundVolume=default.SoundVolume;
        SoundRadius=default.SoundRadius;
        MGFireCounter=0;

        LastChainGunTime = Level.TimeSeconds + 5 + (FRand()*10);
	}

	simulated function BeginState()
	{
		PatriarchMGPreFire();
		bCloak=false;
		UnCloakBoss();
        bFireAtWill = False;
		Acceleration = vect(0,0,0);
		MGLostSightTimeout = 0.0;
		bMinigunning = True;
	}

	simulated function AnimEnd( int Channel )
	{
		if( MGFireCounter <= 0 )
		{
			bShotAnim = true;
			Acceleration = vect(0,0,0);
			SetAnimAction('FireEndMG');
			AnimBlendParams(1, 1.0, 0.0,, FireRootBone);
			PlayAnim('FireEndMG',, 0.1, 1);
			HandleWaitForAnim('FireEndMG');
			GoToState('zombiehunt');
		}
		else
		{
			if ( Controller.Enemy != none )
			{
				if ( Controller.LineOfSightTo(Controller.Enemy) && FastTrace(GetBoneCoords('tip').Origin,Controller.Enemy.Location))
				{
					MGLostSightTimeout = 0.0;
    			}
				else
				{
                    MGLostSightTimeout = Level.TimeSeconds + (0.25 + FRand() * 0.35);
				}
			}
			else
			{
                MGLostSightTimeout = Level.TimeSeconds + (0.25 + FRand() * 0.35);
                Controller.Focus = None;
			}

			if( !bFireAtWill )
			{
                MGFireDuration = Level.TimeSeconds + (0.75 + FRand() * 0.5);
			}
			else if ( FRand() < 0.03 && Controller.Enemy != none && PlayerController(Controller.Enemy.Controller) != none )
			{
				// Randomly send out a message about Patriarch shooting chain gun(3% chance)
				PlayerController(Controller.Enemy.Controller).Speech('AUTO', 9, "");
			}

			bFireAtWill = True;
			bShotAnim = true;
			Acceleration = vect(0,0,0);
			AnimBlendParams(1, 1.0, 0.0,, FireRootBone);
			PlayAnim('FireMG',, 0.1, 1);
			bWaitForAnim = true;
		}
	}

	simulated function FireMGShot()
	{
		local vector Start,End,Dir;
		local rotator R;
		local Actor A;
		local actor HitActor;
		local vector HitNormal, HitLocation;
		local array<int> hits;

		HitActor = Trace(HitLocation, HitNormal, Location + 10000 * vector(controller.Rotation),Location + 10* vector(controller.Rotation));

		MGFireCounter--;
		Acceleration = vect(0,0,0);
		velocity =vect(0,0,0);

        if( AmbientSound != MiniGunFireSound )
        {
            SoundVolume=255;
            SoundRadius=400;
            AmbientSound = MiniGunFireSound;
        }

		Start = GetBoneCoords('tip').Origin;
		if( Controller.Focus!=None )
			R = rotator(Controller.Focus.Location-Start);

		if( NeedToTurnFor(R) )
			R = Rotation;
		// KFTODO: Maybe scale this accuracy by his skill or the game difficulty
		Dir = Normal(vector(R)+VRand()*0.06); //*0.04
		End = Start+Dir*10000;

		A = HitpointTrace(HitLocation, HitNormal, GetBoneCoords('tip').Origin + 10000 * vector(controller.Rotation),hits,GetBoneCoords('tip').Origin + 10 * vector(controller.Rotation));

		if( A==None )
			Return;
		TraceHitPos = HitLocation;
		if( Level.NetMode!=NM_DedicatedServer )
			AddTraceHitFX(HitLocation);

		if( A!=Level )
			A.TakeDamage(MGDamage+Rand(3),Self,HitLocation,Dir*500,Class'DamageType');
	}

	function bool NeedToTurnFor( rotator targ )
	{
		local int YawErr;

		targ.Yaw = DesiredRotation.Yaw & 65535;
		YawErr = (targ.Yaw - (Rotation.Yaw & 65535)) & 65535;
		return !((YawErr < 2000) || (YawErr > 64535));
	}

Begin:
	While( True )
	{
		Acceleration = vect(0,0,0);

        if( MGLostSightTimeout > 0 && Level.TimeSeconds > MGLostSightTimeout )
			bShotAnim = true;

		if( MGFireCounter <= 0 )
		{
			bShotAnim = true;
			Acceleration = vect(0,0,0);
			SetAnimAction('FireEndMG');
			GoToState('zombiehunt');
		}

		// Give some randomness to the patriarch's firing
		if( Level.TimeSeconds > MGFireDuration )
		{
            if( AmbientSound != MiniGunSpinSound )
            {
                SoundVolume=185;
                SoundRadius=200;
                AmbientSound = MiniGunSpinSound;
            }
            Sleep(0.5 + FRand() * 0.75);
            MGFireDuration = Level.TimeSeconds + (0.75 + FRand() * 0.5);
		}
		else
		{
            if( bFireAtWill )
    			FireMGShot();
    		Sleep(0.05);
		}
	}
}

state FireMissile
{
Ignores RangedAttack;

    function bool ShouldChargeFromDamage()
    {
        return false;
    }

	simulated function BeginState()
	{
		PatriarchMisslePreFire();
        Acceleration = vect(0,0,0);
		bCloak=false;
		UnCloakBoss();
	}

	simulated function AnimEnd( int Channel )
	{
		local vector Start;
		local Rotator R;

		Start = GetBoneCoords('tip').Origin;

		if ( !SavedFireProperties.bInitialized )
		{
			SavedFireProperties.AmmoClass = MyAmmo.Class;
			SavedFireProperties.ProjectileClass = MyAmmo.ProjectileClass;
			SavedFireProperties.WarnTargetPct = 0.15;
			SavedFireProperties.MaxRange = 10000;
			SavedFireProperties.bTossed = False;
			SavedFireProperties.bTrySplash = False;
			SavedFireProperties.bLeadTarget = True;
			SavedFireProperties.bInstantHit = True;
			SavedFireProperties.bInitialized = true;
		}

		R = AdjustAim(SavedFireProperties,Start,100);
		PlaySound(RocketFireSound,SLOT_Interact,2.0,,TransientSoundRadius,,false);
		Spawn(Class'BossLAWProj',,,Start,controller.rotation);

		bShotAnim = true;
		
		SetAnimAction('FireEndMissile');
		HandleWaitForAnim('FireEndMissile');

		// Randomly send out a message about Patriarch shooting a rocket(5% chance)
		if ( FRand() < 0.05 && Controller.Enemy != none && PlayerController(Controller.Enemy.Controller) != none )
		{
			PlayerController(Controller.Enemy.Controller).Speech('AUTO', 10, "");
		}

		GoToState('zombiehunt');
	}
	
	simulated function EndState()
	{
        TraceHitPos = vect(0,0,0);
		bMinigunning = False;

        AmbientSound = default.AmbientSound;
        SoundVolume=default.SoundVolume;
        SoundRadius=default.SoundRadius;
        MGFireCounter=0;

        LastChainGunTime = Level.TimeSeconds + 5 + (FRand()*10);
	}
Begin:	
	while ( true )
	{
		Acceleration = vect(0,0,0);
		velocity =vect(0,0,0);
		Sleep(0.1);
	}
}
state Charging
{
    // Don't override speed in this state
    function bool CanSpeedAdjust()
    {
        return false;
    }

    function bool ShouldChargeFromDamage()
    {
        return false;
    }

	function BeginState()
	{
		gotostate('zombiehunt');
	}

	function EndState()
	{
        GroundSpeed = OriginalGroundSpeed;
		LastChargeTime = Level.TimeSeconds;
	}	

	function Tick( float Delta )
	{
        GoToState('zombiehunt');
		Global.Tick(Delta);		
	}

	function bool MeleeDamageTarget(int hitdamage, vector pushdir)
	{
		local bool RetVal;

        NumChargeAttacks--;

		RetVal = Global.MeleeDamageTarget(hitdamage, pushdir*1.5);
		if( RetVal )
			GoToState('zombiehunt');
		return RetVal;
	}

	simulated function RangedAttack(Actor A)
	{
		Global.RangedAttack(A);
	}
	
Begin:
	Sleep(6);
	GoToState('zombiehunt');
}

State ZombieDying
{
ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, Died, RangedAttack;     //Tick

	simulated function Landed(vector HitNormal)
	{
		SetCollision(false, false, false);
		Disable('Tick');
	}

	simulated function Timer()
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

	simulated function BeginState()
	{
 		local controller c;

		c = findController();
       	if ( bTearOff && (Level.NetMode == NM_DedicatedServer) )
			LifeSpan = 1.0;
		else
			SetTimer(2.0, false);

        SetPhysics(PHYS_Falling);
		if ( c != None )
		{
			C.Destroy();
		}
 	}
}

function controller findController()
{
	local controller c;

	For( C=Level.ControllerList; C!=None; C=C.NextController )
		if(monstercontroller(c)!=none&&c.pawn==self)
            {return c;}
}

simulated function HandleBumpGlass()
{
	SetAnimAction(MeleeAnims[0]);
}

function bool DoJump( bool bUpdating )
{
	if ( !bIsCrouched && !bWantsToCrouch && ((Physics == PHYS_Walking) || (Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) )
	{
		Velocity.Z = Default.JumpZ;
		setPhysics(PHYS_falling);
		return true;
	}
	return false;	
}

defaultproperties
{
     GroundSpeed=220.000000
     Health=3500
	 ImpaleMeleeDamageRange=100
	 MeleeRange=30.000000
	 MeleeDamage=85
	 PlayerCountHealthScale=0.950000
}