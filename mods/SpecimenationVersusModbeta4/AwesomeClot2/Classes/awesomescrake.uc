//=============================================================================
// AwesomeGoreFast.
//=============================================================================
class Awesomescrake extends Zombiescrake
	placeable;

function postbeginplay()
{
super.postbeginplay();


gotostate('runningstate');


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
function bool CanAttack(Actor A)
{
return true;
}
simulated function tick(float d)
{

	local actor HitActor;
	local vector HitNormal, HitLocation;
	local array<int> hits;
	
	IF(cONTROLLER!=nonE)
	{
		HitActor = HitpointTrace(HitLocation, HitNormal, Location + vect(0,0,1) * baseeyeheight + 10000 * vector(controller.Rotation),Hits,(Location + vect(0,0,1) * baseeyeheight) + 1* vector(controller.Rotation));   
        	
		if(hitactor!=none)
          		controller.target=hitactor;




		super.tick(d);
	}
			 linkmesh(skeletalmesh'scrake_freak');
	skins[0]=Shader'KF_Specimens_Trip_T.scrake_FB';
	skins[1]=none;
	skins[2]=none;
	ragdolloverride="Scrake_Trip";
	
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
	if ( bShotAnim || Physics == PHYS_Swimming)
		return;
	// if ( CanAttack(A) )
	//{
		bShotAnim = true;
		SetAnimAction(MeleeAnims[Rand(2)]);
		CurrentDamType = ZombieDamType[0];
		//PlaySound(sound'Claw2s', SLOT_None); KFTODO: Replace this
		GoToState('SawingLoop');
	//}

	       if(!isinstate('jumprest'))
		GoToState('RunningState');
}
state RunningState
{
    // Don't override speed in this state
    function bool CanSpeedAdjust()
    {
        return false;
    }

	function BeginState()
	{
		GroundSpeed = OriginalGroundSpeed * 3.5;
		bCharging = true;
		if( Level.NetMode!=NM_DedicatedServer )
			PostNetReceive();

		NetUpdateTime = Level.TimeSeconds - 1;


	}

	function EndState()
	{
		//GroundSpeed = OriginalGroundSpeed;
		//bCharging = False;
		//if( Level.NetMode!=NM_DedicatedServer )
	     // PostNetReceive();
	}

	function RemoveHead()
	{
		GoToState('');
		Global.RemoveHead();
	}

    function RangedAttack(Actor A)
    {
    	if ( bShotAnim || Physics == PHYS_Swimming)
    		return;
    	//else if ( CanAttack(A) )
    	//{
    		bShotAnim = true;
    		SetAnimAction(MeleeAnims[Rand(2)]);
    		CurrentDamType = ZombieDamType[0];
    		GoToState('SawingLoop');
    	//}
    }
}
State SawingLoop
{
    // Don't override speed in this state
    function bool CanSpeedAdjust()
    {
        return false;
    }

	function BeginState()
	{
        local float ChargeChance, RagingChargeChance;

        // Decide what chance the scrake has of charging during an attack
       /* if( Level.Game.GameDifficulty < 2.0 )
        {
            ChargeChance = 0.25;
            RagingChargeChance = 0.5;
        }
        else if( Level.Game.GameDifficulty < 4.0 )
        {
            ChargeChance = 0.5;
            RagingChargeChance = 0.70;
        }
        else if( Level.Game.GameDifficulty < 7.0 )
        {
            ChargeChance = 0.65;
            RagingChargeChance = 0.85;
        }
        else // Hardest difficulty
        {*/
            ChargeChance = 1;
            RagingChargeChance = 1.0;
       // }

        // Randomly have the scrake charge during an attack so it will be less predictable
        if( (Health/HealthMax) < 0.5 )
		{
            GroundSpeed = OriginalGroundSpeed * AttackChargeRate;
    		bCharging = true;
    		if( Level.NetMode!=NM_DedicatedServer )
    			PostNetReceive();

    		NetUpdateTime = Level.TimeSeconds - 1;
		}
	}

	function RangedAttack(Actor A)
	{



		if ( bShotAnim )
			return;
		//else if ( CanAttack(A) )
		//{
			Acceleration = vect(0,0,0);
			bShotAnim = true;
			//MeleeDamage = default.MeleeDamage*0.6;
			SetAnimAction('SawImpaleLoop');
			CurrentDamType = ZombieDamType[0];
			if( AmbientSound != SawAttackLoopSound )
			{
                AmbientSound=SawAttackLoopSound;
			}
		//}
		else GoToState('runningstate');
	}
	function AnimEnd( int Channel )
	{
		Super.AnimEnd(Channel);
		if( Controller!=None && Controller.Enemy!=None )
			RangedAttack(Controller.Enemy); // Keep on attacking if possible.
	}

	function Tick( float Delta )
	{
        // Keep the scrake moving toward its target when attacking
    	if( Role == ROLE_Authority && bShotAnim && !bWaitForAnim )
    	{
    		if( LookTarget!=None )
    		{
    		    //Acceleration = AccelRate * Normal(LookTarget.Location - Location);
    		}
        }
//loopanim('ChargeF',0.6);

        global.Tick(Delta);
	}

	function EndState()
	{
		//AmbientSound=default.AmbientSound;
		//MeleeDamage= default.MeleeDamage;

		//GroundSpeed = OriginalGroundSpeed;
		//bCharging = False;
		//if( Level.NetMode!=NM_DedicatedServer )
			//PostNetReceive();
	}
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

gotostate('runningstate');
jumpz=default.jumpz;

}

function bool DoJump( bool bUpdating );
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
//c=findController();
        if ( bTearOff && (Level.NetMode == NM_DedicatedServer) )
			LifeSpan = 1.0;
		else
			SetTimer(2.0, false);

        SetPhysics(PHYS_Falling);
		if ( c != None )
		{
			C.Destroy();
		}SetCollision(false, false, false);
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

function controller findController()
{
local controller c;

For( C=Level.ControllerList; C!=None; C=C.NextController )
	{  if(monstercontroller(c)!=none&&c.pawn==self)
              {return c;}

        }

}

function altfire(float f)
{


switch(rand(3))
{
	case 1:zombieplayercontroller(controller).kbroadcast(playerreplicationinfo.playername$"("$menuname$"): hehe!",sound'scrake_talk3',true);break;
	case 2:zombieplayercontroller(controller).kbroadcast(playerreplicationinfo.playername$"("$menuname$"): hehe!",sound'scrake_talk6',true);break;
	case 3:zombieplayercontroller(controller).kbroadcast(playerreplicationinfo.playername$"("$menuname$"): I like trousers!",sound'scrake_Talk8',true);break;

}

}

defaultproperties
{
     AttackChargeRate=1.000000
     ControllerClass=None
	 Health=2000
	 HealthMax=2000
	 PlayerCountHealthScale=0.950000
}
