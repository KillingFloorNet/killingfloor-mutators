class zombiePlayerController extends KFplayercontroller;

var class<actor> zname;
var controller ch,h[16],s[16];
var Rotator HeadRotDiff;
var bool bReadySpecimen;
var FlashProjector FlashLight;

replication
{
   reliable if(Role < ROLE_Authority)
   ChangeRace,FireZed,altfirezed,modifyspecimen,modifyclass,ReadyUp,Quickheal,makeflashlight,Perk,
   BossHide,BossSwapWeapons,BossSpeedUp,BossSpeedDown;
   reliable if(Role == ROLE_Authority)
   bReadySpecimen,addSHit,NewDamage,DrawNums,Drawpawn,CantSeeMe;     				
}

exec function BossHide()
{
	if (Awesomepat(Pawn)!=none)
		Awesomepat(Pawn).Hide();
}

exec function BossSwapWeapons()
{
	if (Awesomepat(Pawn)!=none)
		Awesomepat(Pawn).SwapWeapons();
}

exec function BossSpeedUp()
{
	if (Awesomepat(Pawn)!=none)
		Awesomepat(Pawn).SpeedUp();
}

exec function BossSpeedDown()
{
	if (Awesomepat(Pawn)!=none)
		Awesomepat(Pawn).SpeedDown();
}

simulated function DrawPawn(pawn p)
{
	zombiepri(playerreplicationinfo).Drawpawn(P);
}

function SetPawnClass(string inClass, string inCharacter)
{
	PawnClass = Class'ZHuman';
	inCharacter = Class'KFGameType'.Static.GetValidCharacter(inCharacter);
	PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(inCharacter);
	PlayerReplicationInfo.SetCharacterName(inCharacter);
}

exec function Use()
{
	super.use();
	ReadyUP();

}
// Player movement.
// Player Standing, walking, running, falling.
state PlayerWalking
{
ignores SeePlayer, HearNoise, Bump;


    function PlayerMove( float DeltaTime )
    {
        local vector X,Y,Z, NewAccel;
        local eDoubleClickDir DoubleClickMove;
        local rotator OldRotation, ViewRotation;
        local bool  bSaveJump;

        if( Pawn == None )
        {
            GotoState('Dead'); // this was causing instant respawns in mp games
            return;
        }

        GetAxes(Pawn.Rotation,X,Y,Z);

        // Update acceleration.
	if( pawn != none && (pawn.isa('kfpawn')||pawn.isa('awesomecrawler')||pawn.isa('awesomestalker')||pawn.isa('awesomepat')||pawn.isa('awesomegorefast')
		||pawn.isa('awesomesiren')||pawn.isa('awesomebloat')||pawn.isa('awesomehusk')&& !kfmonster(pawn).bShotAnim))
        	NewAccel = aForward*X + aStrafe*Y;
	else if( pawn !=none && (pawn.isa('awesomehusk')||pawn.isa('awesomepat')) && !kfmonster(pawn).bShotAnim
			|| pawn != none && !pawn.isa('awesomehusk') && !pawn.isa('awesomepat') || pawn == none)
			NewAccel = aForward*X;
        NewAccel.Z = 0;
        if ( VSize(NewAccel) < 1.0 )
            NewAccel = vect(0,0,0);
        //DoubleClickMove = PlayerInput.CheckForDoubleClickMove(1.1*DeltaTime/Level.TimeDilation);

        GroundPitch = 0;
        ViewRotation = Rotation;
        if ( Pawn.Physics == PHYS_Walking )
        {
            // tell pawn about any direction changes to give it a chance to play appropriate animation
            //if walking, look up/down stairs - unless player is rotating view
             if ( (bLook == 0)
                && (((Pawn.Acceleration != Vect(0,0,0)) && bSnapToLevel) || !bKeyboardLook) )
            {
                if ( bLookUpStairs || bSnapToLevel )
                {
                    GroundPitch = FindStairRotation(deltaTime);
                    ViewRotation.Pitch = GroundPitch;
                }
                else if ( bCenterView )
                {
                    ViewRotation.Pitch = ViewRotation.Pitch & 65535;
                    if (ViewRotation.Pitch > 32768)
                        ViewRotation.Pitch -= 65536;
                    ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
                    if ( (Abs(ViewRotation.Pitch) < 250) && (ViewRotation.Pitch < 100) )
                        ViewRotation.Pitch = -249;
                }
            }
        }
        else
        {
            if ( !bKeyboardLook && (bLook == 0) && bCenterView )
            {
                ViewRotation.Pitch = ViewRotation.Pitch & 65535;
                if (ViewRotation.Pitch > 32768)
                    ViewRotation.Pitch -= 65536;
                ViewRotation.Pitch = ViewRotation.Pitch * (1 - 12 * FMin(0.0833, deltaTime));
                if ( (Abs(ViewRotation.Pitch) < 250) && (ViewRotation.Pitch < 100) )
                    ViewRotation.Pitch = -249;
            }
        }
        Pawn.CheckBob(DeltaTime, Y);

        // Update rotation.
        SetRotation(ViewRotation);
        OldRotation = Rotation;
        UpdateRotation(DeltaTime, 1);
		bDoubleJump = false;

        if ( bPressedJump && Pawn.CannotJumpNow() )
        {
            bSaveJump = true;
            bPressedJump = false;
        }
        else
            bSaveJump = false;

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        else
            ProcessMove(DeltaTime, NewAccel, DoubleClickMove, OldRotation - Rotation);
        bPressedJump = bSaveJump;
    }


Begin:
}
state PlayerFlying
{
ignores SeePlayer, HearNoise, Bump;

    function PlayerMove(float DeltaTime)
    {
        local vector X,Y,Z,newaccel;

        GetAxes(Rotation,X,Y,Z);

       	newaccel = aForward*X + aStrafe*Y;

	pawn.acceleration = newaccel;
        if ( VSize(Pawn.Acceleration) < 1.0 )
            Pawn.Acceleration = vect(0,0,0);
        if ( VSize(Pawn.Acceleration) < 1.0 )
            Pawn.Velocity = vect(0,0,0);
        // Update rotation.
        UpdateRotation(DeltaTime, 2);

        if ( Role < ROLE_Authority ) // then save this move and replicate it
            ReplicateMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
        else
            ProcessMove(DeltaTime, Pawn.Acceleration, DCLICK_None, rot(0,0,0));
    }

    function BeginState()
    {
        Pawn.SetPhysics(PHYS_Flying);
		Pawn.bBlockActors=false;
    }
}

exec function Say(string msg)
{
	if(msg == "changerace")
		changerace();
	else 
	{
		switch( msg )
		{

			Case "berserker": perk('berserker');break;
			Case "supportspecialist": perk('supportspecialist');break;
			Case "firebug": perk('firebug');break;
			Case "fieldmedic": perk('fieldmedic');break;
			Case "demolitions": perk('demolitions');break;
			Case "sharpshooter": perk('sharpshooter');break;
			Case "commando": perk('commando');break;
		}
	}
	super.say(msg);
}

exec function ReadyUp()
{	
	ServerReadyUp();
}

function ServerReadyUp()
{	
	if( pawn != none && !zombiepri(playerreplicationinfo).bseen && kfgametype(level.game).bwaveinprogress )
	{
		bReadySpecimen = true;
		zombiepri(playerreplicationinfo).breadyspecimen = breadyspecimen;
	}
}

function ZHudActor CreateActor(pawn A)
{
	local ZHudActor Act;

		Act = spawn(class'ZHudActor', A,, A.location, a.rotation);
		Act.setowner(A);
		Act.linkmesh(A.mesh);
		Act.skins = A.skins;
		Act.bonlyownersee=true;
		return Act;

}

simulated function CanSeeMe()
{
	zombiepri(playerreplicationinfo).bseen = ClientSeeME();
}

function bool ClientSeeMe()
{
	local kfpawn p;
	local controller c;
	local bool bTrace;

	for( C=Level.controllerList;C!=none;C=C.NextController)
	{
		if(C.pawn!=none && KFPawn(C.pawn)!=none)
		{
			P = KFPawn(C.pawn);

			if(pawn != none)
				bTrace = fasttrace(pawn.location, p.location + vect(0,0,1) * p.baseeyeheight + 10 * vector(p.rotation));

			if( P != none && pawn != none && bTrace && vsize(pawn.location - p.location) < 2000)
				return true;
		}
	}	
	return false;
}	  
 
simulated function bool CantSeeMe(pawn p)
{
	local bool bTrace;

	bTrace = fasttrace(pawn.location, p.location + vect(0,0,1) * p.baseeyeheight + 10 * vector(p.rotation));

		if( P != none && pawn != none &&  bTrace && vsize(pawn.location - p.location) < 2000)
		   return false;	
	return true;
}

exec function QuickHeal()
{
	if( PAWN != none && pawn.isa('kfmonster') )
	{
		if(ZombieBoss(pawn) != none)
		{
			
			if( ZombieBoss(pawn).OnlyEnemyAround( pawn ) && awesomepat(pawn).canheal() ) 
				{					
					awesomepat(pawn).Starthealing();
					KBroadcast("Patriarch Healed. ",none,false);
				}				
		}
	}
	else 
	{
		if(ZombieBoss(pawn) != none)
			clientmessage(" Unable to heal. ");

		if(kfpawn(pawn) != none)
			kfpawn(pawn).quickheal();
	}	
}

simulated event postbeginplay()
{
	local float i;
	local name perk;

	PlayerReplicationInfoClass=class'awesomeclot2.zombiepri';
	super.postbeginplay();

	i=rand(7);

	switch( i )
	{
		case 0:perk='firebug';break;
		case 1:perk='fieldmedic';break;
		case 2:perk='sharpshooter';break;
		case 3:perk='berserker';break;
		case 4:perk='commando';break;
		case 5:perk='supportspecialist';break;
		case 6:perk='Demolitions';break;
	}
	PerkChange(Perk);
	pawnclass=class'zhuman';
}
	
/*exec function NextWeapon()
{
	super.NextWeapon();		
}
exec function PrevWeapon()
{
	super.PrevWeapon();	
}*/

simulated Function KBroadcast(string msg,sound plays,bool bnotbroadcast)
{
	local controller C;

	for(c=level.controllerlist;c!=none;c=c.nextcontroller)
	{
		if(bnotbroadcast==false)
		{
			PlayerController(C).ClearProgressMessages();
			PlayerController(C).SetProgressTime(6);
			PlayerController(C).SetProgressMessage(0, Msg, class'Canvas'.Static.MakeColor(255,255,255));
		}

		if(zombiegametype(level.game).bcanbroadcastNow>5)
		{
			zombieplayerController(C).greaseplaysound(plays,true,64);
		}		
	}

	if(zombiegametype(level.game).bcanbroadcastnow>5)
	{
		level.game.broadcast(none,msg);
		zombiegametype(level.game).bcanbroadcastnow=0;
	}
}

simulated function greaseplaysound(sound s,bool b,float f)
{
	clientplaysound(s,b,f);
}

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
    local vector globalX,globalY,globalZ;
    local vector localX,localY,localZ,Headloc,x,y,z;
	local coords C;
	local rotator HeadRot,HeadRotDifference;
	
	if(kfmonster(pawn) == none)
	{
		super.CalcBehindView(CameraLocation, CameraRotation, Dist);
		return;
	}
	else if(kfmonster(pawn) != none && pawn.health > 0)
	{
		C = pawn.GetBoneCoords(xpawn(pawn).HeadBone);


			
		//pawn.SetBoneScale(4,0,xpawn(pawn).headbone);
		HeadLoc = C.Origin + (xpawn(pawn).HeadHeight * xpawn(pawn).HeadScale * 1 * C.XAxis);
	    
		HeadRot = pawn.GetBoneRotation(xpawn(pawn).HeadBone);
	    
		if(HeadrotDiff.yaw == 0 && headrotdiff.pitch == 0)
		  HeadRotdiff = HeadRot;    
		  
		CameraRotation = Rotation;
		CameraRotation.Roll = 0;

		HeadRotDifference = (HeadRotDiff - HeadRot)/4;
		
		HeadRotDiff = headrot;
		CameraRotation += CameraDeltaRotation;
	    
			OldCameraRot = CameraRotation;
			OldCameraRot.roll += clamp(HeadRotDifference.roll,-1000,1000);
			OldCameraRot.yaw += clamp(HeadRotDifference.yaw,-500,500);
			OldCameraRot.pitch += clamp(HeadRotDifference.pitch,-1000,1000);
			
			//Log("Dont Update Cam "$bBlockCloseCamera@bValidBehindCamera@ViewDist);
			SetRotation(OldCameraRot);
		

		GetAxes(OldCameraRot,x,y,z);
		CameraLocation = Headloc + X * 10;
		CameraRotation = OldCameraRot;
	    
		// add view swivel rotation to cameraview (amb)
		GetAxes(CameraSwivel,globalX,globalY,globalZ);
		localX = globalX >> CameraRotation;
		localY = globalY >> CameraRotation;
		localZ = globalZ >> CameraRotation;
		CameraRotation = OrthoRotation(localX,localY,localZ);
		
		pawn.baseeyeheight = cameralocation.z - pawn.location.z;
		return;
	}

	super.CalcBehindView(CameraLocation, CameraRotation, Dist);
	return;    
}

function MakeFlashLight(pawn p);
/*{

	FlashLight=spawn(class'FlashProjector',p);
	Flashlight.setowner(P);
	flashlight.lightpawn = p;

}*/
function deleteflashlight();
/*{
	flashlight.destroy();
}*/

function Possess(pawn p)
{
	local float i;
	local name perk;

	if( p.isa('monster') )
	MakeFlashLight(p);

	if( KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill == none && monster(p) == none)
	{
		i=rand(7);

	
		switch( i )
		{
			case 0:perk='firebug';break;
			case 1:perk='fieldmedic';break;
			case 2:perk='sharpshooter';break;
			case 3:perk='berserker';break;
			case 4:perk='commando';break;
			case 5:perk='supportspecialist';break;
			case 6:perk='Demolitions';break;
		}
		PerkChange(Perk);
	}
	super.possess(p);

	bReadySpecimen = false;
	zombiepri(playerreplicationinfo).breadyspecimen = breadyspecimen;		
}

exec function altfire(optional float f)
{
	altfireZed(f);
}

function getem()
{
	local int f,d;

	For( Ch=Level.ControllerList; Ch!=None; Ch=Ch.NextController )
	{
		if(ch.playerreplicationinfo!=none&&ch.bisplayer==true)
	    {
			h[d]=ch;d++;
	    }
		else if(ch.playerreplicationinfo!=none&&ch.bisplayer==false)
	    {
			s[f]=ch;f++;
	    }
	}
}
exec function fire(optional float f)
{
	fireZed(f);
	if ( HudKillingFloor(myHUD) != none && HudKillingFloor(myHUD).bDisplayInventory )
		{
			HudKillingFloor(myHUD).SelectWeapon();
			bFire = 0;
		}
}
exec function fireZed(optional float f)
{
	if ( HudKillingFloor(myHUD) != none && HudKillingFloor(myHUD).bDisplayInventory )
	{
		HudKillingFloor(myHUD).SelectWeapon();
		bFire = 0;
	}
	else
		super.Fire(F);	
}

exec function altfireZed(optional float f)
{
	super.altfire(f);
}

exec function ChangeRace()
{
	if(level.game.isa('kfgametype') && playerreplicationinfo.bonlyspectator==false )
	{
		ClientOpenMenu("awesomeclot2.guiselectclass");
		greaseplaysound(sound'PerkAchieved',true,64);
	}	    
}

function MakeBotFollow()
{
	local bot B;
	
	foreach allactors(class'bot', B)
	{
		if( B != none )
		{
			b.gotostate('');
			b.SetOrders('Follow', self);
			b.StartMonitoring(self.Pawn,b.Squad.GetRestingFormation().FormationSize);
			teamgame(level.game).teams[0].ai.PutBotOnSquadLedBy( self, B);
		}
			
	}
}

exec function perk(name Perk)
{
	if(kfmonster(pawn) == none||pawn==none)
	ServerChangeTo(Perk);	
}

function ServerChangeTo(name Perk)
{
	PerkChange(Perk);
}

simulated function PerkChange(name Perk)
{
	if( zombiegametype(level.game).bwaveinprogress )
	   {
		clientmessage(" Can't change perk during wave.");
		 return;
	    }

	Switch( Perk )
	{
		case 'FireBug': class'KFPlayerController'.default.SelectedVeterancy = class'KFVetFireBug';break;
		case 'FieldMedic': class'KFPlayerController'.default.SelectedVeterancy = class'KFVetFieldMedic';break;
		case 'Commando': class'KFPlayerController'.default.SelectedVeterancy = class'KFVetCommando';break;
		case 'Demolitions': class'KFPlayerController'.default.SelectedVeterancy = class'KFVetDemolitions';break;
		case 'SharpShooter': class'KFPlayerController'.default.SelectedVeterancy = class'KFVetSharpShooter';break;
		case 'Berserker': class'KFPlayerController'.default.SelectedVeterancy = class'KFVetBerserker';break;
		case 'SupportSpecialist': class'KFPlayerController'.default.SelectedVeterancy = class'KFVetSupportSpec';break;
	}
	
					saveconfig();
				KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill = class'KFPlayerController'.default.SelectedVeterancy;
				if(1 + class'KFGameType'.default.gamedifficulty <= 6)
				KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkillLevel = 1 + class'KFGameType'.default.gamedifficulty;
				else
				KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkillLevel = 6;
}

simulated function VeterancyVersus()
{
				default.SelectedVeterancy = class'KFPlayerController'.default.SelectedVeterancy;
				SelectedVeterancy = class'KFPlayerController'.default.SelectedVeterancy;
				saveconfig();
				KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill = class'KFPlayerController'.default.SelectedVeterancy;
				if(1 + class'KFGameType'.default.gamedifficulty <= 6)
				KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkillLevel = 1 + class'KFGameType'.default.gamedifficulty;
				else
				KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkillLevel = 6;
}

exec function bool Modifyclass(controller other)
{
	return ServerModifyclass(other);
}

simulated function DrawNums(int specs,int hums)
{
	zhud(myhud).hunum = hums;
	zhud(myhud).specinum = specs;
}

simulated function addSHit(string msg)
{
	zhud(myhud).addSHit(msg);
}

simulated function NewDamage(int Dam)
{
	zhud(myhud).SetDamage(dam,level.timeseconds);
}

function bool ServerModifyclass(controller other)
{
	zombiegametype(level.game).takefromlist(other);
	if(zombiegametype(level.game).getplayers()<float(zombiegametype(level.game).maxplayers)/2 || zombiegametype(level.game).IsPlayer(other))
	{
		//VeterancyVersus();	
	 	
		if(pawn !=  none && other.pawn.isa('monster'))
			//pawn.gibbedby(none);		
			pawn.Destroy();
		
		zname=class'actor';
		//if(isinstate('spectating') && level.game.isinstate('matchinprogress') )
		//becomeactiveplayer();

		other.bhiddened=true;
		other.pawnclass=class'zhuman';
		//other.pawnclass=class'kfhumanpawn';
		zombiegametype(level.game).Becomeplayer(other);
		other.bisplayer=true;
		other.playerreplicationinfo.numlives=1;
		other.playerreplicationinfo.boutoflives=false;		
		//if(level.netmode==nm_standalone)
		Other.PlayerReplicationInfo.Team=zombiegametype(level.game).teams[0];
		//if(pawn != none && other.pawn.isa('monster'))
		//other.level.game.restartplayer(other);
	}
	else return ModifySPECIMEN(other);

	return true;
}

function ClotFly()
{
	if ( (Pawn != None) && Pawn.CheatFly() )
	{
		ClientMessage("Spawn Mode");
		GotoState('PlayerFlying');
	}
}

exec function bool ModifySPECIMEN(controller other)
{
	return ServerModifySPECIMEN(other);	
}

function bool ServerModifySPECIMEN(controller other)
{
	zombiegametype(level.game).takefromlist(other);
	if(zombiegametype(level.game).isspecimen(other)||zombiegametype(level.game).getpeople()>=2&&zombiegametype(level.game).getspecimens()<float(zombiegametype(level.game).maxplayers)/2)
	{
		SelectedVeterancy = none;

		KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill=none;

		if(pawn !=  none && kfpawn(pawn) != none)
		//{pawn.gibbedby(none);}
		pawn.Destroy();
		
		zname=class'actor';
		zombiegametype(level.game).Becomespecimen(other);
		BBloom();
		Other.PlayerReplicationInfo.Team=zombiegametype(level.game).teams[1];
		other.bhiddened=false;
		other.bisplayer=false;
		other.pawn=none;

		return true;
	}
	else modifyclass(self);

	return true;
}

function PawnDied(Pawn P)
{
	bisplayer = true;
	DeleteFlashLight();
	super.pawndied(p);
}

function BBloom()
{
	local bool bBloom;

	bBloom = bool(ConsoleCommand("get ini:Engine.Engine.ViewportManager Bloom"));

    	if( bBloom )
    	{
    		PostFX_SetActive(0, false);
    		//ConsoleCommand("set ini:Engine.Engine.ViewportManager Bloom"@False);
    	}
}

function ClientSetBehindView(bool B)
{
	super(PlayerController).ClientSetBehindView(B);
	
	if(Level.NetMode == 1)
	{
		return;
	}
	
	if(KFHumanPawn(Pawn) != none)
	{
		
		if(B)
		{
			Pawn.SetBoneScale(1, 1.00, 'CHR_LArmUpper');
			Pawn.SetBoneScale(2, 1.00, 'CHR_RArmUpper');
			Pawn.SetBoneScale(4, 1.00, 'CHR_Head');
			Pawn.SetBoneScale(5, 1.00, 'CHR_Spine1');
			Pawn.SetBoneScale(6, 1.00, 'CHR_Spine2');
			Pawn.SetBoneScale(7, 1.00, 'CHR_Spine3');
			
			if(KFPawn(Pawn).Adjuster != none)
			{
				KFPawn(Pawn).Adjuster.bHidden = true;
			}
		}
		else
		{
			Pawn.SetBoneScale(1, 0.00, 'CHR_LArmUpper');
			Pawn.SetBoneScale(2, 0.00, 'CHR_RArmUpper');
			Pawn.SetBoneScale(4, 0.00, 'CHR_Head');
			Pawn.SetBoneScale(5, 0.00, 'CHR_Spine1');
			Pawn.SetBoneScale(6, 0.00, 'CHR_Spine2');
			Pawn.SetBoneScale(7, 0.00, 'CHR_Spine3');
			
			if(KFPawn(Pawn).Adjuster != none)
			{
				KFPawn(Pawn).Adjuster.bHidden = false;
			}
		}
	}
}

defaultproperties
{
     PlayerReplicationInfoClass=Class'AwesomeClot2.ZombiePRI'
     PawnClass=Class'AwesomeClot2.ZHuman'
}
