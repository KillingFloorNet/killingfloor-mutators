//=============================================================================
// AwesomeClot.
//=============================================================================
class Awesomeclot extends Zombieclot
	placeable;

simulated function postbeginplay()
{
super.postbeginplay();
        

}
function RemoveHead()
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

setheadscale(0);
    PlaySound(DecapitationSound, SLOT_Misc,1.30,true,525);
}

function Fire( optional float F )
{
	local actor HitActor;
	local vector HitNormal, HitLocation;//,pushdir;
 
	HitActor = Trace(HitLocation, HitNormal, Location + 10000 * vector(controller.Rotation),Location, true);
	
if(hitactor!=none)
controller.target=hitactor;


RangedAttack(hitactor);




}
simulated function tick(float d)
{

	local actor HitActor;
	local vector HitNormal, HitLocation;

if(controller!=none)
{
	HitActor = Trace(HitLocation, HitNormal, Location + 100 * vector(controller.Rotation),Location, true);
	
if(hitactor!=none)
controller.target=hitactor;

//if(hitactor.isa('pawn'))
//controller.enemy=pawn(hitactor);

RangedAttack(hitactor);


super.tick(d);
}
         linkmesh(skeletalmesh'clot_freak');
skins[0]=Combiner'KF_Specimens_Trip_T.clot_cmb';
skins[1]=none;skins[2]=none;


ragdolloverride="Clot_Trip";
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

simulated function HandleBumpGlass()
{
	//Acceleration = vect(0,0,0);
	//Velocity = vect(0,0,0);

	SetAnimAction(MeleeAnims[0]);
	bShotAnim = true;
	//controller.GotoState('WaitForAnim');
}
State ZombieDying 
{
ignores AnimEnd, Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, Died, RangedAttack;     //Tick

	simulated function Landed(vector HitNormal)
	{
		//SetPhysics(PHYS_None);
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
	
	c=findController();
	controller.unpossess();
	c.possess(self);

        if ( bTearOff && (Level.NetMode == NM_DedicatedServer) )
			LifeSpan = 1.0;
		else
			SetTimer(2.0, false);

        SetPhysics(PHYS_Falling);
		if ( c != None )
		{
			C.Destroy();
		}
	//SetCollision(false, false, false);
 	}
}

function controller findController()
{
local controller c;

For( C=Level.ControllerList; C!=None; C=C.NextController )
	{  if(monstercontroller(c)!=none&&c.pawn==self)
              {return c;}

        }

}


function bool CanAttack(Actor A)
{
return true;
}

defaultproperties
{
     MeleeAnims(0)="'"
     MeleeAnims(1)="'"
     MeleeAnims(2)="'"
     MeleeDamage=1
     bUseExtendedCollision=False
     GroundSpeed=400.000000
     JumpZ=1000.000000
     HealthMax=100.000000
     Health=500
     MenuName=" "
     bHidden=True
     bBlockActors=False
     bProjTarget=False
}
