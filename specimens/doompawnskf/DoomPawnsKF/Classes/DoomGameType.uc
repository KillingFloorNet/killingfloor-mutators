// Single player Killing Floor Gametype
class DoomGameType extends KFSPGameType
	Config(DoomPawnsKF);

var() globalconfig bool bMPAllowRespawn,bRespawnPickups,bRespawnWeapons,bUseDoomPlayers,bAutoDifficulty,bMonsterVSPlayers;
var bool bInventoryCheckOK;
var float PlayerDamageScale,MonsterDamageScale;
var string NextMapURL;

static function Texture GetRandomTeamSymbol(int base)
{
	// GRI fix.
	return Texture'Engine.S_Actor';
}

// No ZED time actions!
event Tick(float DeltaTime);
function DramaticEvent(float BaseZedTimePossibility);
function DoBossDeath();

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super(Info).FillPlayInfo(PlayInfo);

	// Standard KF config
	PlayInfo.AddSetting(default.GameGroup,"GameDifficulty", GetDisplayText("GameDifficulty"),0,0,"Select",default.GIPropsExtras[0],"Xb");
	PlayInfo.AddSetting(default.ServerGroup, "LobbyTimeOut",	GetDisplayText("LobbyTimeOut"),		0, 1, "Text",	"3;0:120",	,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "bAdminCanPause",	GetDisplayText("bAdminCanPause"),	1, 1, "Check",			 ,	,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "MaxSpectators",	GetDisplayText("MaxSpectators"),	1, 1, "Text",	 "6;0:32",	,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "MaxPlayers",		GetDisplayText("MaxPlayers"),		0, 1, "Text",	  "6;1:6",	,True);
	PlayInfo.AddSetting(default.ServerGroup, "MaxIdleTime",		GetDisplayText("MaxIdleTime"),		0, 1, "Text",	"3;0:300",	,True,True);
	if (default.GameReplicationInfoClass != None)
	{
		default.GameReplicationInfoClass.static.FillPlayInfo(PlayInfo);
		PlayInfo.PopClass();
	}
	if (default.VoiceReplicationInfoClass != None)
	{
		default.VoiceReplicationInfoClass.static.FillPlayInfo(PlayInfo);
		PlayInfo.PopClass();
	}
	if (default.BroadcastClass != None)
		default.BroadcastClass.static.FillPlayInfo(PlayInfo);
	else class'BroadcastHandler'.static.FillPlayInfo(PlayInfo);
	PlayInfo.PopClass();
	if (class'Engine.GameInfo'.default.VotingHandlerClass != None)
	{
		class'Engine.GameInfo'.default.VotingHandlerClass.static.FillPlayInfo(PlayInfo);
		PlayInfo.PopClass();
	}

	// New doom config
	PlayInfo.AddSetting(default.SandboxGroup,"bUseDoomPlayers","Doom pawn class",0,9,"Check");
	PlayInfo.AddSetting(default.ServerGroup,"bRespawnPickups","Respawn pickups",1,1, "Check",,,True,True);
	PlayInfo.AddSetting(default.ServerGroup,"bRespawnWeapons","Respawn weapons",1,1, "Check",,,True,True);
	PlayInfo.AddSetting(default.ServerGroup,"bAutoDifficulty","Auto difficulty",1,1, "Check",,,True,True);
	PlayInfo.AddSetting(default.ServerGroup,"bMonsterVSPlayers","Versius Mode",1,1, "Check",,,True,True);
}
static function string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "bUseDoomPlayers": return "Use Doom player pawns with enhanced movements.";
		case "bRespawnPickups": return "Allow ammo/inventory pickups respawn.";
		case "bRespawnWeapons": return "Allow weapon pickups respawn.";
		case "bAutoDifficulty": return "Auto scale difficulty level based on player count.";
		case "bMonsterVSPlayers": return "Allow players join monsters team.";
	}
	return Super.GetDescriptionText(PropName);
}

event PlayerController Login( string Portal, string Options, out string Error )
{
	local PlayerController NewPlayer;
	local Controller C;
	local bool bTempLate;

	bTempLate = bNoLateJoiners;
	bNoLateJoiners = False;
	NewPlayer = Super(KFGameType).Login(Portal,Options,Error);
	bNoLateJoiners = bTempLate;
	if( NewPlayer==None )
		return None;

	NewPlayer.PlayerReplicationInfo.bOutOfLives = false;
	NewPlayer.PlayerReplicationInfo.NumLives = 0;
	if( Level.NetMode!=NM_StandAlone && !bMPAllowRespawn )
	{
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
			if ( C!=NewPlayer && (C.PlayerReplicationInfo != None) && C.PlayerReplicationInfo.bOutOfLives && !C.PlayerReplicationInfo.bOnlySpectator && !bWaitingToStartMatch )
			{
				NewPlayer.PlayerReplicationInfo.bOutOfLives = true;
				NewPlayer.PlayerReplicationInfo.NumLives = 1;
				Break;
			}
	}
	if( Level.NetMode!=NM_StandAlone && (bMPAllowRespawn || bWaitingToStartMatch) )
		UpdateDamageScales();
	return NewPlayer;
}
function Logout( Controller Exiting )
{
	Super.Logout(Exiting);
	UpdateDamageScales();
}
final function UpdateDamageScales()
{
	local Controller C;
	local int PLCount;

	if( !bAutoDifficulty )
		return;
	if( bMPAllowRespawn )
		PLCount = NumPlayers;
	else
	{
		// Count num players alive.
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
			if ( C.bIsPlayer && PlayerController(C)!=None && C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOutOfLives && !C.PlayerReplicationInfo.bOnlySpectator )
				PLCount++;
	}
	PLCount = Max(PLCount,1); // Assume its always at least one.

	// Set damage scaling players receive.
	PlayerDamageScale = FMin(float(PLCount)*0.15+0.7f,2.5f);
	// Set damage scaling monsters receive.
	MonsterDamageScale = FMin(1.1f/(float(PLCount)*0.2+0.8f),0.25f);
}
function ScoreKill(Controller Killer, Controller Other)
{
	local PlayerReplicationInfo OtherPRI;
	local int KillScore;

	OtherPRI = Other.PlayerReplicationInfo;
	if ( OtherPRI != None )
	{
		OtherPRI.Score -= (OtherPRI.Score * (GameDifficulty * 0.05));	// you Lose 35% of your current cash on suicidal, 15% on normal.
		OtherPRI.Team.Score -= (OtherPRI.Score * (GameDifficulty * 0.05));

		if (OtherPRI.Score < 0 )
			OtherPRI.Score = 0;
		if (OtherPRI.Team.Score < 0 )
			OtherPRI.Team.Score = 0;

		OtherPRI.Team.NetUpdateTime = Level.TimeSeconds - 1;
		if( Level.NetMode==NM_StandAlone || !bMPAllowRespawn )
		{
			OtherPRI.NumLives++;
			OtherPRI.bOutOfLives = true;
			if( Killer!=None && Killer.PlayerReplicationInfo!=None && Killer.bIsPlayer )
				BroadcastLocalizedMessage(class'KFInvasionMessage',1,OtherPRI,Killer.PlayerReplicationInfo);
			else if( Killer==None || Monster(Killer.Pawn)==None )
				BroadcastLocalizedMessage(class'KFInvasionMessage',1,OtherPRI);
			else BroadcastLocalizedMessage(class'KFInvasionMessage',1,OtherPRI,,Killer.Pawn.Class);
			CheckScore(None);
		}
	}

	if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreKill(Killer, Other);

	if ( MonsterController(Killer) != None )
		return;

	if( (killer == Other) || (killer == None) )
	{
		if ( Other.PlayerReplicationInfo != None )
		{
			Other.PlayerReplicationInfo.Score -= 1;
			Other.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
			ScoreEvent(Other.PlayerReplicationInfo,-1,"self_frag");
		}
	}

	if ( Killer==None || !Killer.bIsPlayer || (Killer==Other) )
		return;

	if ( Other.bIsPlayer && Killer.PlayerReplicationInfo!=None && Monster(Other.Pawn)==None && Monster(Killer.Pawn)==None )
	{
		Killer.PlayerReplicationInfo.Score -= 5;
		Killer.PlayerReplicationInfo.Team.Score -= 2;
		Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
		ScoreEvent(Killer.PlayerReplicationInfo, -5, "team_frag");
		return;
	}
	else if( Monster(Other.Pawn)!=None && Monster(Killer.Pawn)!=None )
		return; // No Score for monster team-kills.
	if(Killer.PlayerReplicationInfo !=none)
	{
		if( KFPawn(Other.Pawn)!=None )
			KillScore = 5; // 5 score for killing a player.
		else
		{
			if( Monster(Other.Pawn)!=None )
				KillScore = Monster(Other.Pawn).ScoringValue;
			else if( LastKilledMonsterClass==None )
				KillScore = 2;
			else KillScore = LastKilledMonsterClass.Default.ScoringValue;
			KillScore = Max(1,KillScore);

			Killer.PlayerReplicationInfo.Team.Score += KillScore;
			Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
		}
		Killer.PlayerReplicationInfo.Kills++;
		Killer.PlayerReplicationInfo.Score += KillScore;
		Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "tdm_frag");
	}
	if (Killer.PlayerReplicationInfo !=none )
		Killer.PlayerReplicationInfo.Score = Max(int(Killer.PlayerReplicationInfo.Score),0);
}

State MatchInProgress
{
	function BeginState()
	{
		if( Level.NetMode==NM_StandAlone || !bMPAllowRespawn )
			MaxLives = 1;
		else MaxLives = 0;
		OpenShops();
		SetupPickups();
		bForceRespawn = false;
		Super.BeginState();
	}
	final function bool SomeonesAlive()
	{
		local Controller C;

		For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( C.Pawn!=None && C.Pawn.Health>0 && KFPawn(C.Pawn)!=None )
				return true;
		}
		return false;
	}
	function OpenShops()
	{
		local int i;

		bTradingDoorsOpen = True;
		for( i=0; i<ShopList.Length; i++ )
		{
			if( ShopList[i].bAlwaysClosed )
				continue;
			ShopList[i].OpenShop();
		}
	}
	function SetupPickups()
	{
		local int i;

		// Enable all
		for ( i = 0; i < WeaponPickups.Length ; i++ )
			if( WeaponPickups[i]!=None )
				WeaponPickups[i].EnableMe();
        	for ( i = 0; i < AmmoPickups.Length ; i++ )
			if( AmmoPickups[i]!=None && AmmoPickups[i].bSleeping )
				AmmoPickups[i].GotoState('Pickup');
	}
	function Timer()
	{
		Global.Timer();

		if ( !bFinalStartup )
		{
			bFinalStartup = true;
			PlayStartupMessage();
		}
		ElapsedTime++;
		GameReplicationInfo.ElapsedTime = ElapsedTime;
		if( (Level.NetMode==NM_StandAlone || !bMPAllowRespawn) && !SomeonesAlive() )
			EndGame(None,"TimeLimit");
	}
	function DoWaveEnd();
}
function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType)
{
	Super(Invasion).Killed(Killer,Killed,KilledPawn,damageType);
}
function SetupWave();

function WeaponPickedUp(KFRandomItemSpawn PickedUp)
{
	if ( Level.NetMode!=NM_StandAlone && bRespawnWeapons && PickedUp!=none )
		PickedUp.EnableMeDelayed(30);
	else if( PickedUp!=None )
		PickedUp.DisableMe();
}
function AmmoPickedUp(KFAmmoPickup PickedUp)
{
	if ( Level.NetMode!=NM_StandAlone && bRespawnPickups && PickedUp!=none )
		PickedUp.GotoState('Sleeping', 'DelayedSpawn');
}
function bool ShouldRespawn( Pickup Other )
{
	if( Level.NetMode==NM_StandAlone )
		return false;
	if( WeaponPickup(Other)!=None )
	{
		if( !bRespawnWeapons )
			return false;
	}
	else if( !bRespawnPickups )
		return false;
	return (Other.ReSpawnTime>0.f);
}
function RestartGame()
{
	if ( bGameRestarted )
		return;
	if( Level.NetMode==NM_StandAlone )
	{
		bGameRestarted = true;
		bInventoryCheckOK = true;
		Class'PlayerTravelManager'.Static.SaveTravel(Level,true); // Allow player to restart with their inventory.
		Level.ServerTravel("?restart",false);
		return;
	}
	Super.RestartGame();
}
function RestartPlayer( Controller aPlayer )
{
	if ( aPlayer.PlayerReplicationInfo.bOutOfLives || aPlayer.Pawn!=None )
		return;
	if( bUseDoomPlayers )
	{
		aPlayer.PawnClass = Class'KFDoomPlayerPawn';
		aPlayer.PreviousPawnClass = Class'KFDoomPlayerPawn';
	}
	Super(Invasion).RestartPlayer(aPlayer);
	if ( KFPawn(aPlayer.Pawn) != none )
		Class'PlayerTravelManager'.Static.LoadPlayerInv(KFPawn(aPlayer.Pawn),(Level.NetMode==NM_StandAlone));
}
function SendPlayer( PlayerController aPlayer, string URL )
{
	local Controller C,NC;
	local bool bIsEnding;

	if( bGameEnded || aPlayer==None || aPlayer.PlayerReplicationInfo==None || KFPawn(aPlayer.Pawn)==None )
		Return;
	aPlayer.Pawn.bAlwaysRelevant = true;
	bInventoryCheckOK = true;
	Broadcast(Self,aPlayer.PlayerReplicationInfo.PlayerName@"has ended the level.");
	bIsEnding = (Left(URL,4)~="NULL");
	if( !bIsEnding )
		Class'PlayerTravelManager'.Static.SaveTravel(Level,false);
	// Focus view on map ender
	for( C=Level.ControllerList; C!=None; C=NC )
	{
		NC = C.NextController;
		if( PlayerController(C)!=None )
		{
			PlayerController(C).ClientSetBehindView(true);
			PlayerController(C).SetViewTarget(aPlayer.Pawn);
			PlayerController(C).ClientSetViewTarget(aPlayer.Pawn);
			PlayerController(C).ClientGameEnded();
		}
		C.GameHasEnded();
	}
	if( bIsEnding )
	{
		Class'PlayerTravelManager'.Static.ResetTravel();
		WaveNum = FinalWave+1;
		EndGame(None,"TimeLimit");
		Return;
	}
	GoToState('MapSwitching');
	NextMapURL = URL;
	bGameEnded = True;
}
function ProcessServerTravel( string URL, bool bItems )
{
	if( !bInventoryCheckOK )
		Class'PlayerTravelManager'.Static.ResetTravel();
	Super.ProcessServerTravel(URL,bItems);
}
function int ReduceDamage(int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local KFPlayerController PC;
	local armor FirstArmor, NextArmor;
	local int OriginalDamage;

	OriginalDamage = Damage;
	if( Damage==0 || injured.InGodMode() || injured.PhysicsVolume.bNeutralZone )
		return 0;
	if ( KFPawn(Injured) != none )
	{
		if ( KFPlayerReplicationInfo(Injured.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Injured.PlayerReplicationInfo).ClientVeteranSkill != none )
			Damage = KFPlayerReplicationInfo(Injured.PlayerReplicationInfo).ClientVeteranSkill.Static.ReduceDamage(KFPlayerReplicationInfo(Injured.PlayerReplicationInfo), KFPawn(Injured), KFMonster(instigatedBy), Damage, DamageType);
	}

	if ( instigatedBy == None )
		return Super(xTeamGame).ReduceDamage( Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );

	if ( Monster(Injured) != None )
	{
		if ( instigatedBy != None )
			PC = KFPlayerController(instigatedBy.Controller);
		if( KFPawn(instigatedBy)!=None )
			Damage = Max((float(Damage)*MonsterDamageScale*instigatedBy.DamageScaling),1);
		if ( GameRulesModifiers != None )
			return GameRulesModifiers.NetDamage( OriginalDamage, Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
		return Damage;
	}
	if( instigatedBy!=injured && Monster(InstigatedBy)==None && injured.Controller!=None && injured.Controller.bIsPlayer && instigatedBy.Controller!=None
		 && instigatedBy.Controller.bIsPlayer )
	{
		if ( class<WeaponDamageType>(DamageType) != None || class<VehicleDamageType>(DamageType) != None )
			Momentum *= TeammateBoost;

		if ( FriendlyFireScale==0.0 || (Vehicle(injured) != None && Vehicle(injured).bNoFriendlyFire) )
		{
			if ( GameRulesModifiers != None )
				return GameRulesModifiers.NetDamage( Damage, 0,injured,instigatedBy,HitLocation,Momentum,DamageType );
			else return 0;
		}
		Damage *= FriendlyFireScale;
	}

	if ( (instigatedBy != None) && (InstigatedBy != Injured) && (Level.TimeSeconds - injured.SpawnTime < SpawnProtectionTime)
		&& (class<WeaponDamageType>(DamageType) != None || class<VehicleDamageType>(DamageType) != None) )
		return 0;

	if ( GameRulesModifiers != None )
		return GameRulesModifiers.NetDamage( OriginalDamage, Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
	if ( (injured.Inventory != None) && (damage > 0) ) //then check if carrying armor
	{
		FirstArmor = injured.inventory.PrioritizeArmor(Damage, DamageType, HitLocation);
		while( (FirstArmor != None) && (Damage > 0) )
		{
			NextArmor = FirstArmor.nextArmor;
			Damage = FirstArmor.ArmorAbsorbDamage(Damage, DamageType, HitLocation);
			FirstArmor = NextArmor;
		}
	}
	if( Damage<=0 )
		return 0;
	if ( instigatedBy == None)
		return Damage;

	if ( Level.Game.GameDifficulty <= 3 )
	{
		if ( injured.IsPlayerPawn() && (injured == instigatedby) && (Level.NetMode == NM_Standalone) )
			Damage *= 0.5;
	}
	if( Monster(instigatedBy)!=None )
		return Max((float(Damage) * PlayerDamageScale * instigatedBy.DamageScaling),1);
	return Max((float(Damage) * instigatedBy.DamageScaling),1);
}

State MapSwitching
{
Ignores RestartPlayer;

	function int ReduceDamage(int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
	{
		return 0;
	}
Begin:
	Sleep(3);
	Level.ServerTravel(NextMapURL,False);
}

function Timer()
{
	if( bWelcomePending )
		bWelcomePending = false; // Never handle welcome messages.
	Super.Timer();
}
function BroadcastLocalizedMessage( class<LocalMessage> MessageClass, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	if( MessageClass!=GameMessageClass || Switch!=4 ) // No broadcasting exiting game messages.
		Super.BroadcastLocalizedMessage(MessageClass,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
}

defaultproperties
{
     bMPAllowRespawn=True
     bRespawnPickups=True
     bRespawnWeapons=True
     bUseDoomPlayers=True
     PlayerDamageScale=1.000000
     MonsterDamageScale=1.000000
     LoginMenuClass="DoomPawnsKF.DOOMLoginMenu"
     MutatorClass="DoomPawnsKF.DoomBaseMut"
     GameName="Doom SinglePlayer"
     Description="Doom Story Based Cooperative Gameplay."
}
