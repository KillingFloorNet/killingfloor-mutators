//=============================================================================
// AwesomeGoreFast.
//=============================================================================
class Awesomesiren extends Zombiesiren
	placeable;


function postbeginplay()
{

super.postbeginplay();


}
function altfire(float f)
{


switch(rand(5))
{
case 1:zombieplayercontroller(controller).kbroadcast(playerreplicationinfo.playername$"("$menuname$"): Why did they have to take my eyes",sound'sirenvoice1',true);break;
case 2:zombieplayercontroller(controller).kbroadcast(playerreplicationinfo.playername$"("$menuname$"): I feel like to sing they love it when I sing!",sound'sirenvoice2',true);break;
case 3:zombieplayercontroller(controller).kbroadcast(playerreplicationinfo.playername$"("$menuname$"): uhh? Get me out of this... Jacket!",sound'sirenvoice3',true);break;
case 4:zombieplayercontroller(controller).kbroadcast(playerreplicationinfo.playername$"("$menuname$"): *cries* Everything is black...Everything...",sound'sirenvoice4',true);break;

}

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

gotostate('zombiehunt');
jumpz=default.jumpz;

}

function bool DoJump( bool bUpdating );
}
simulated function tick(float d)
{

	local actor HitActor;
	local vector HitNormal, HitLocation;


	if(controller!=none)
{HitActor = Trace(HitLocation, HitNormal, Location + 10000 * vector(controller.Rotation),Location, true);
	
if(hitactor!=none)
controller.target=hitactor;

//if(hitactor.isa('pawn'))
//controller.enemy=pawn(hitactor);

super.tick(d);}

         linkmesh(skeletalmesh'siren_freak');
skins[0]=FinalBlend'KF_Specimens_Trip_T.siren_hair_fb';
skins[1]=none;skins[2]=none;



}
function RangedAttack(Actor A)
{
	local int LastFireTime;
	local float Dist;

	if ( bShotAnim )
		return;

    Dist = VSize(A.Location - Location);

	if ( Physics == PHYS_Swimming )
	{
		SetAnimAction('Claw');
		bShotAnim = true;
		LastFireTime = Level.TimeSeconds;
	}

		bShotAnim = true;
		LastFireTime = Level.TimeSeconds;
		SetAnimAction('Claw');
		//PlaySound(sound'Claw2s', SLOT_Interact); KFTODO: Replace this
		Controller.bPreparingMove = true;
		//Acceleration = vect(0,0,0);
	
	
		bShotAnim=true;
		SetAnimAction('Siren_Scream');
		// Only stop moving if we are close
		if( Dist < ScreamRadius * 0.25 )
		{
    		Controller.bPreparingMove = true;
    		Acceleration = vect(0,0,0);
        }

	
}
function bool CanAttack(Actor A)
{
return true;
}
function Fire( optional float F )
{
	local actor HitActor;
	local vector HitNormal, HitLocation;

HitActor = Trace(HitLocation, HitNormal, Location + 10000 * vector(controller.Rotation),Location, true);
	
controller.target=hitactor;

rangedattack(hitactor);


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
		}
 	}
}
// Scream Time
/*simulated function SpawnTwoShots()
{
  local actor pp;
  DoShakeEffect();

	if( Level.NetMode!=NM_Client )
	{
	
	

	
       foreach radiusactors(class'actor',pp, 600, location)
               if(pp!=none)
        {
if( Level.NetMode!=nm_standalone&&pp.isa('kfhumanpawn'))
pp.TakeDamage(meleedamage, self ,Location,velocity, ScreamDamageType);
    }	
	}
}*/
function controller findController()
{
local controller c;

For( C=Level.ControllerList; C!=None; C=C.NextController )
	{  if(monstercontroller(c)!=none&&c.pawn==self)
              {return c;}

        }SetCollision(false, false, false);

}

defaultproperties
{
     GroundSpeed=150.000000
     JumpZ=450.000000
     ControllerClass=None
}
