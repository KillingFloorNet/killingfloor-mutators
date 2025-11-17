//=============================================================================
// AwesomeGoreFast.
//=============================================================================
class Awesomecrawler extends Zombiecrawler
	placeable;


function postbeginplay()
{

super.postbeginplay();


}
simulated function bool DoPounce()
{
	if ( bIsCrouched || bWantsToCrouch || (Physics != PHYS_Walking)  )
		return false;
	


	Velocity = Normal(Location + 200 * vector(Rotation)-Location)*PounceSpeed;
 	dojump(true);    
	SetPhysics(PHYS_Falling);
	ZombieSpringAnim();
	gotostate('Jumprest');
	bPouncing=true;
	return true;
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

		gotostate('zombiehunt');
		jumpz=default.jumpz;

	}

	function bool DoPounce();
	function bool DoJump( bool bUpdating );
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
function controller findController()
{
local controller c;

For( C=Level.ControllerList; C!=None; C=C.NextController )
	{  if(monstercontroller(c)!=none&&c.pawn==self)
              {return c;}

        }

}
simulated function Fire( optional float F )
{
	local actor HitActor;
	local vector HitNormal, HitLocation;

	HitActor = Trace(HitLocation, HitNormal, Location + 10000 * vector(controller.Rotation),Location, true);
	
	controller.target=hitactor;

	DoPounce();


}
simulated function HandleBumpGlass()
{
	//Acceleration = vect(0,0,0);
	//Velocity = vect(0,0,0);

	SetAnimAction(MeleeAnims[0]);
	bShotAnim = true;
	//controller.GotoState('WaitForAnim');
}
function bool DoJump( bool bUpdating )
{
      
	if ( !bIsCrouched && !bWantsToCrouch && ((Physics == PHYS_Walking) || (Physics == PHYS_Ladder) || (Physics == PHYS_Spider)) )
	{
Velocity = Normal(Location + 200 * vector(Rotation)-Location)*PounceSpeed;
 Velocity.Z = JumpZ;;    
SetPhysics(PHYS_Falling);
	ZombieSpringAnim();
	bPouncing=true;
gotostate('Jumprest');
return true;
	}
return false;	
}
simulated function tick( float delta)
{
if(controller!=none)
{super.tick(delta);

controller.movetarget=none;
controller.enemy=none;}
        
 linkmesh(skeletalmesh'crawler_freak');
skins[0]=Combiner'KF_Specimens_Trip_T.crawler_cmb';
skins[1]=none;skins[2]=none;


}

defaultproperties
{
     PounceSpeed=500.000000
     MeleeDamage=15
     GroundSpeed=230.000000
     JumpZ=250.000000
     HealthMax=100.000000
     Health=100
     ControllerClass=None
}
