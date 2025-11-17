//RespawnMut
//
//Enables deathmatch type respawning
//
//Originally FA_ForceRespawn trigger by Falidell with credit to Atari(Unreal) for most of the respawning code
//Converted to mutator by madcap

class RespawnMut extends Mutator;

var	array<PlayerStart> Positions[];
var bool	EN;

function PostBeginPlay()
{
	local PlayerStart N;
	local int j;
	super.PostBeginPlay();
	j=0;
	EN=True;

		ForEach AllActors( class'PlayerStart', N )
		{
			if(N!=None)
			{
				Positions[j]=N;
				j++;
			}
			//log("found spot"@N);
		}	
}

simulated function Tick( float DeltaTime )
{
    local Controller C;
 
	for (C=Level.ControllerList; C!=None; C=C.NextController)
		if ((C.PlayerReplicationInfo != None && !C.PlayerReplicationInfo.bIsSpectator && !C.PlayerReplicationInfo.bOnlySpectator) && (C.IsInState('Dead') || C.Pawn.Health <= 0))
            	RP(C);
}

// Checks and stuff for the RespawnPLR function
//---------------------------------------------------

//this finds us a starting position... PlayerStarts without Desirability...for Now
//ToDo: Lookinto optionally pick playerstarts based off of desirability
//Desireability will be weighed on: Location.vs.others and Location.Vs.Enemy
// perhaps more stuff like that :::::: Decided not to do so.... if LD's Make their levels
// with any sort of thought this should already be done for us by default... if not.... not my problem lol!!
function PlayerStart FPS()
{
    local PlayerStart BestStart;
	local int i,j;
	
	if(positions.length==1)
	{
		log("FPS"@BestStart);
		BestStart=Positions[0];
		return BestStart;
	}
	i=RandRange(0,Positions.Length);
	if(Positions[i].bEnabled)
	{
		BestStart=Positions[i];
	}
	else// if the randomly choosen spot is unavailable
	{
		//log(i@ "is not bEnabled");
		for(j=0;j<Positions.Length;++j)
		{
			if(Positions[j].bEnabled)
			{
				//log(j@ "is not bEnabled");
				BestStart=Positions[j];
			}
		}
		if(BestStart==None)// if all else fails then we ignore if it's bEnabled
		{				   // and Choose the Very First one on the list
			BestStart=Positions[0];
			//log("none available...Made"@BestStart@"our Spot");
		}
	}
	log("FPS"@BestStart);
    return BestStart;
}

function RP( Controller person )
{
    local PlayerStart startSpot;
    local class<Pawn> DefaultPlayerClass;
	//log("!!!!!!! RP 0");
    startSpot = FPS();
	//log("!!!!!!! RP 1");
    if( startSpot == None )
    {
        log(" Player start not found!!!");
        return;
    }
	//log("!!!!!!! RP 2");
    if ( person.PawnClass != None )
	{
		//log("!!!!!!! RP 2B");
        person.Pawn = Spawn(person.PawnClass,,,StartSpot.Location,StartSpot.Rotation);
	}
	//log("!!!!!!! RP 3");
    if( person.Pawn==None )
    {
		//log("!!!!!!! RP 3B");
        DefaultPlayerClass = GetDefaultPlayerClass(person);
        person.Pawn = Spawn(DefaultPlayerClass,,,StartSpot.Location,StartSpot.Rotation);
    }
	//log("!!!!!!! RP 4");
    if ( person.Pawn == None )// kept this just in case of some bull****
    {
        log("Couldn't spawn player of type "$person.PawnClass$" at "$StartSpot);
        person.GotoState('Dead');
        if ( PlayerController(person) != None )
		{
			PlayerController(person).ClientGotoState('Dead','Begin');
		}
        return;
    }
	//log("!!!!!!! RP 5");
    if ( PlayerController(person) != None )
	{
		PlayerController(person).TimeMargin = -0.1;
	}// this may be a c++ and Java hybrid engine but it still yells at me
	// when i don't add brackets {} 
		
    person.Pawn.Anchor = startSpot;
	person.Pawn.LastStartSpot = startSpot;
	person.Pawn.LastStartTime = Level.TimeSeconds;
    person.PreviousPawnClass = person.Pawn.Class;

    person.Possess(person.Pawn);
    person.PawnClass = person.Pawn.Class;
	
	SetPlayerDefaults(person.Pawn);
    person.ClientSetRotation(person.Pawn.Rotation);
	
	KFHumanPawn(person.Pawn).AddDefaultInventory();
	
	//scoreboard stuff so we actually show up as alive after respawn
	KFPlayerController(person).PlayerReplicationinfo.bReadyToPlay = true;
	KFPlayerController(person).PlayerReplicationinfo.bOutofLives = false;
	KFPlayerController(person).PlayerReplicationinfo.numlives = 1;
	
	//get outa those windows you distracted players!!
	KFPlayerController(Person).ClientCloseMenu(true, true);
	//**** dat Film Grain
	HudKillingfloor(Level.GetLocalPlayerController().MyHud).SpectatorOverlay = None;
	removeGrainthingy();// both simulated and reg to make absolutely sure it's removed.....
						// prob don't need both but i don't yet entirely understand replication and how to tell
						// what things GET be Replicated
						// ex. simulated functions if they are called inside a non simulated function does it get
						// signaled over to the client?????? not even sure if it removed the grain in the first place..
						// i don't have a server to test these things.... atm i don't have internet to send the pack over to
						// fel or someone to test it out for me either =(  ***Thursday September 1, 2011 :: 1:29AM MST ***
						// to change up the perks if needed
	KFHumanPawn(person.Pawn).VeterancyChanged();
	log("spawned player!!!!!!!!!!!!!!!!!!!!!!!");
    TriggerEvent( StartSpot.Event, StartSpot, person.Pawn);
}
simulated function removeGrainthingy()
{
	HudKillingfloor(Level.GetLocalPlayerController().MyHud).SpectatorOverlay = None;
}

//returns default pawn
function class<Pawn> GetDefaultPlayerClass(Controller C)
{
    local PlayerController PC;
    local String PawnClassName;
    local class<Pawn> PawnClass;

    PC = PlayerController( C );

    if( PC != None )
    { 
        PawnClassName = PC.GetDefaultURL( "Class" );
        PawnClass = class<Pawn>( DynamicLoadObject( PawnClassName, class'Class') );

        if( PawnClass != None )
		{
            return( PawnClass );
		}
    }

    return( class<Pawn>( DynamicLoadObject( "KFmod.KFHumanPawn", class'Class' ) ) );
}

//.....duh
function SetPlayerDefaults(Pawn PlayerPawn)
{
    PlayerPawn.AirControl = PlayerPawn.Default.AirControl;
    PlayerPawn.GroundSpeed = PlayerPawn.Default.GroundSpeed;
    PlayerPawn.WaterSpeed = PlayerPawn.Default.WaterSpeed;
    PlayerPawn.AirSpeed = PlayerPawn.Default.AirSpeed;
    PlayerPawn.Acceleration = PlayerPawn.Default.Acceleration;
    PlayerPawn.JumpZ = PlayerPawn.Default.JumpZ;
}

defaultproperties
{
	bAddToServerPackages=true
     GroupName="KF-RespawnMut"
     FriendlyName="Respawn Mut"
     Description="Respawns players after death"
     bAlwaysRelevant=True
}