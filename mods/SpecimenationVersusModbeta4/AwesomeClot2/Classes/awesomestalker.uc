//=============================================================================
// AwesomeGoreFast.
//=============================================================================
class Awesomestalker extends Zombiestalker
	placeable;

function postbeginplay()
{
	super.postbeginplay();

	linkmesh(skeletalmesh'Stalker_freak');           
	ragdolloverride="Stalker_Trip";
	skins[0]=Shader'KF_Specimens_Trip_T.stalker_invisible';
	skins[1]=none;
	skins[2]=none;
	SetHeadScale(1.0);
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

	if(controller!=none)
	{


		HitActor = HitpointTrace(HitLocation, HitNormal, (Location + vect(0,0,1) * baseeyeheight) + 100 * vector(controller.Rotation),Hits,(Location + vect(0,0,1) * baseeyeheight) + 1* vector(controller.Rotation));
  
	
		if(hitactor!=none)
		controller.target=hitactor;
			


		super.tick(d);
	}

	if(bhiddened==false){
			 linkmesh(skeletalmesh'stalker_freak');
			Skins[0] = Shader'KF_Specimens_Trip_T.stalker_invisible';
			Skins[1] = Shader'KF_Specimens_Trip_T.stalker_invisible';}
	else if(bhiddened==true){
			 linkmesh(skeletalmesh'stalker_freak');
				Skins[1] = FinalBlend'KF_Specimens_Trip_T.stalker_fb';
				Skins[0] = Combiner'KF_Specimens_Trip_T.stalker_cmb';
	}
}

simulated function Fired( optional float F )
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
	bhiddened=true;
	


}
simulated function CloakStalker()
{
	if ( bSpotted )
	{
		if( Level.NetMode == NM_DedicatedServer )
			return;

		Skins[0] = Finalblend'KFX.StalkerGlow';
		Skins[1] = Finalblend'KFX.StalkerGlow';
		bUnlit = true;
		return;
	}
	bhiddened=false;
	
	if ( !bDecapitated && !bAshen ) // No head, no cloak, honey.  updated :  Being charred means no cloak either :D
	{
		Visibility = 1;
		bCloaked = true;

		if( Level.NetMode == NM_DedicatedServer )
			Return;

		Skins[0] = Shader'KF_Specimens_Trip_T.stalker_invisible';
		Skins[1] = Shader'KF_Specimens_Trip_T.stalker_invisible';

		// Invisible - no shadow
		if(PlayerShadow != none)
			PlayerShadow.bShadowActive = false;
		if(RealTimeShadow != none)
			RealTimeShadow.Destroy();

		// Remove/disallow projectors on invisible people
		Projectors.Remove(0, Projectors.Length);
		bAcceptsProjectors = false;
		//SetOverlayMaterial(Material'stalker_invisible', 0.25, true);
	}
}

simulated function UnCloakStalker()
{
	if( !bAshen )
	{
		LastUncloakTime = Level.TimeSeconds;

		Visibility = default.Visibility;
		bCloaked = false;

		// 25% chance of our Enemy saying something about us being invisible
		if( Level.NetMode!=NM_Client && !KFGameType(Level.Game).bDidStalkerInvisibleMessage && FRand()<0.25 && Controller.Enemy!=none &&
		 PlayerController(Controller.Enemy.Controller)!=none )
		{
			PlayerController(Controller.Enemy.Controller).Speech('AUTO', 17, "");
			KFGameType(Level.Game).bDidStalkerInvisibleMessage = true;
		}
		if( Level.NetMode == NM_DedicatedServer )
			Return;

		if ( Skins[0] != Combiner'KF_Specimens_Trip_T.stalker_cmb' )
		{
			Skins[1] = FinalBlend'KF_Specimens_Trip_T.stalker_fb';
			Skins[0] = Combiner'KF_Specimens_Trip_T.stalker_cmb';

			if (PlayerShadow != none)
				PlayerShadow.bShadowActive = true;

			bAcceptsProjectors = true;

			//SetOverlayMaterial(Material'stalker_cmb', 0.25, true);
		}
	}
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
function controller findController()
{
	local controller c;

	For( C=Level.ControllerList; C!=None; C=C.NextController )
		{  if(monstercontroller(c)!=none&&c.pawn==self)
				  {return c;}

			}

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
function altfire(float f)
{
	if(bCloaked)
		UnCloakStalker();
	else
		CloakStalker();
}

defaultproperties
{
     HealthMax=200.000000
     Health=200
     ControllerClass=None
}
