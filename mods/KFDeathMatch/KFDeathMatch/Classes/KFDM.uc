// Killing Floor DeathMatch, written by Marco.
Class KFDM extends KFGameType;

#exec AUDIO IMPORT FILE="LostMatch.WAV" NAME="LostMatch" GROUP="Game"
#exec AUDIO IMPORT FILE="WonMatch.WAV" NAME="WonMatch" GROUP="Game"

var ShopVolume OldOpenShop;
var bool bShopsAreOpened;
var config bool bHandicapMode;
var float NextShopToggleTime;
var array<PlayerStart> SpawningPoints;
var SpawnTesterPawn SpawnTester;
var config int KillCashAward,NumAmmoSpawns,NumWeaponSpawns,InitGrenadesCount;

static function Texture GetRandomTeamSymbol(int base)
{
	return Texture'Engine.S_Actor';
}
event Tick(float DeltaTime);
function DramaticEvent(float BaseZedTimePossibility);
function ShowPathTo(PlayerController P, int TeamNum);
function DoBossDeath();

static event bool AcceptPlayInfoProperty(string PropertyName)
{
	return Super(GameInfo).AcceptPlayInfoProperty(PropertyName);
}

function UnrealTeamInfo GetBotTeam(optional int TeamBots)
{
	local class<UnrealTeamInfo> RosterClass;

	if ( EnemyRoster != None )
		return EnemyRoster;
	if ( EnemyRoster == None )
	{
		RosterClass = class<UnrealTeamInfo>(DynamicLoadObject(DefaultEnemyRosterClass,class'Class'));
		EnemyRoster = spawn(RosterClass);
	}
	EnemyRoster.Initialize(TeamBots);
	return EnemyRoster;
}
function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
	return true;
}
exec function AddBots(int num)
{
	num = Clamp(num, 0, 32 - (NumPlayers + NumBots));

	while (--num >= 0)
	{
		if ( Level.NetMode != NM_Standalone )
			MinPlayers = Max(MinPlayers + 1, NumPlayers + NumBots + 1);
		AddBot();
	}
}
function Bot SpawnBot(optional string botName)
{
	local KFDMBot NewBot;
	local RosterEntry Chosen;
	local UnrealTeamInfo BotTeam;

	BotTeam = GetBotTeam();
	Chosen = BotTeam.ChooseBotClass(botName);

	if (Chosen.PawnClass == None)
		Chosen.Init(); //amb
	NewBot = Spawn(class'KFDMBot');

	if ( NewBot != None )
		InitializeBot(NewBot,BotTeam,Chosen);
	NewBot.PlayerReplicationInfo.Score = StartingCash;

	return NewBot;
}

event InitGame( string Options, out string Error )
{
	local KFLevelRules KFLRit;
	local ShopVolume SH;
	local ZombieVolume ZZ;
	local KFRandomSpawn RS;
	local NavigationPoint N;
	local Pickup I;

	MaxLives = 0;
	Super(DeathMatch).InitGame(Options, Error);

	foreach DynamicActors(class'KFLevelRules',KFLRit)
		KFLRit.Destroy();
	foreach AllActors(class'ShopVolume',SH)
		ShopList[ShopList.Length] = SH;
	foreach AllActors(class'ZombieVolume',ZZ)
		ZedSpawnList[ZedSpawnList.Length] = ZZ;
	foreach AllActors(class'KFRandomSpawn',RS)
	{
		TestSpawnPoint(RS);
		RS.SetTimer(0,false);
		RS.Destroy();
	}
	foreach AllActors(class'Pickup',I)
	{
		TestSpawnPoint(I);
		I.Destroy();
	}
	if( SpawningPoints.Length==0 )
		Warn("Could not find any possible spawn areas on this map!!!");
	for( N=Level.NavigationPointList; N!=None; N=N.nextNavigationPoint )
		if( PlayerStart(N)!=None && PointIsGood(N.Location) )
			SpawningPoints[SpawningPoints.Length] = PlayerStart(N);
	if( SpawnTester!=None )
		SpawnTester.Destroy();

	//provide default rules if mapper did not need custom one
	if(KFLRules==none)
		KFLRules = spawn(class'KFDMLevelRules');
}
function RestartPlayer( Controller aPlayer )
{
	if ( aPlayer.Pawn!=None )
		return;
	aPlayer.PawnClass = Class'KFDMHumanPawn';
	aPlayer.PreviousPawnClass = Class'KFDMHumanPawn';
	KFPlayerReplicationInfo(aPlayer.PlayerReplicationInfo).ClientVeteranSkill = Class'KFVeterancyTypes';
	aPlayer.PlayerReplicationInfo.bOutOfLives = false;
	aPlayer.PlayerReplicationInfo.Score = Max(MinRespawnCash, int(aPlayer.PlayerReplicationInfo.Score));
	Super(Invasion).RestartPlayer(aPlayer);
}
final function TestSpawnPoint( Actor Other )
{
	local rotator R;

	if( SpawnTester==None )
	{
		SpawnTester = Spawn(Class'SpawnTesterPawn',,,Other.Location);
		if( SpawnTester==None )
			Return;
	}
	else if( !SpawnTester.SetLocation(Other.Location) )
		Return;
	if( !PointIsGood(SpawnTester.Location) )
		return;
	R.Yaw = Rand(65536);
	SpawningPoints[SpawningPoints.Length] = Spawn(Class'DynSpawnPoint',,,SpawnTester.Location,R);
}
final function bool PointIsGood( vector Point )
{
	local int i;

	for( i=0; i<SpawningPoints.Length; i++ )
		if( VSize(SpawningPoints[i].Location-Point)<600.f && FastTrace(SpawningPoints[i].Location,Point) )
			return false; // Don't allow 2 visilbe spawn points next to each other.
	return true;
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super(Info).FillPlayInfo(PlayInfo);  // Always begin with calling parent

	PlayInfo.AddSetting(default.GameGroup,   "GoalScore","Frag Limit",0, 0, "Text","3;0:999");
	PlayInfo.AddSetting(default.GameGroup,   "TimeLimit","Time Limit",0, 0, "Text","3;0:999");
	PlayInfo.AddSetting(default.GameGroup,   "KillCashAward","Kill Cash Award",0, 0, "Text","3;0:999");
	PlayInfo.AddSetting(default.GameGroup,   "NumAmmoSpawns","Num Ammo Pickups",0, 0, "Text","2;0:10");
	PlayInfo.AddSetting(default.GameGroup,   "NumWeaponSpawns","Num Weapon Pickups",0, 0, "Text","2;0:10");
	PlayInfo.AddSetting(default.GameGroup,   "InitGrenadesCount","Initial Grenades",0, 0, "Text","2;0:5");
	PlayInfo.AddSetting(default.ServerGroup,   "MinPlayers","Num Bots",0, 0, "Text","2;0:64",,True,True);

	PlayInfo.AddSetting(default.SandboxGroup,"StartingCash", GetDisplayText("StartingCash"),0,0,"Text","200;0:500");
	PlayInfo.AddSetting(default.SandboxGroup,"MinRespawnCash", GetDisplayText("MinRespawnCash"),0,1,"Text","200;0:500");

	PlayInfo.AddSetting(default.ServerGroup, "LobbyTimeOut",	GetDisplayText("LobbyTimeOut"),		0, 1, "Text",	"3;0:120",	,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "bAdminCanPause",	GetDisplayText("bAdminCanPause"),	1, 1, "Check",			 ,	,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "MaxSpectators",	GetDisplayText("MaxSpectators"),	1, 1, "Text",	 "6;0:32",	,True,True);
	PlayInfo.AddSetting(default.ServerGroup, "MaxPlayers",		GetDisplayText("MaxPlayers"),		0, 1, "Text",	  "6;1:6",	,True);
	PlayInfo.AddSetting(default.ServerGroup, "MaxIdleTime",		GetDisplayText("MaxIdleTime"),		0, 1, "Text",	"3;0:300",	,True,True);

	// Add GRI's PIData
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
}
static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "KillCashAward":		return "Kill cash award earned on enemy frag.";
		case "NumAmmoSpawns":		return "Number of ammo pickups that can be available at once.";
		case "NumWeaponSpawns":		return "Number of weapon pickups that can be available at once.";
		case "MinPlayers":		return "Minimum number of players in game (rest will be filled with bots.";
		case "InitGrenadesCount":	return "Initial amount of grenades players start with.";
	}
	return Super.GetDescriptionText(PropName);
}
function bool CheckMaxLives(PlayerReplicationInfo Scorer)
{
	return false;
}
function CheckScore(PlayerReplicationInfo Scorer)
{
	local controller C;

	if ( (GameRulesModifiers != None) && GameRulesModifiers.CheckScore(Scorer) )
		return;

	if ( Scorer != None )
	{
		if ( (GoalScore>0) && (Scorer.Kills>=GoalScore) )
			EndGame(Scorer,"fraglimit");
		else if ( bOverTime )
		{
			// end game only if scorer has highest score
			for ( C=Level.ControllerList; C!=None; C=C.NextController )
				if ( (C.PlayerReplicationInfo != None) && (C.PlayerReplicationInfo != Scorer) && (C.PlayerReplicationInfo.Kills>=Scorer.Kills) )
					return;
			EndGame(Scorer,"fraglimit");
		}
	}
}
function ScoreKill(Controller Killer, Controller Other)
{
	if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreKill(Killer, Other);

	if( (killer == Other) || (killer == None) )
	{
		if ( Other.PlayerReplicationInfo != None )
		{
			Other.PlayerReplicationInfo.Kills--;
			Other.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
			ScoreEvent(Other.PlayerReplicationInfo,-1,"self_frag");
		}
		return;
	}

	if ( Killer.PlayerReplicationInfo==None )
		return;

	if( Killer.PlayerReplicationInfo.Score>1000 )
		Killer.PlayerReplicationInfo.Score+=int(KillCashAward*0.5);
	else Killer.PlayerReplicationInfo.Score+=KillCashAward;
	Killer.PlayerReplicationInfo.Kills++;
	Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
	ScoreEvent(Killer.PlayerReplicationInfo, 1, "frag");
	CheckScore(Killer.PlayerReplicationInfo);
}
function Timer()
{
	Super(xTeamGame).Timer();
}
function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> damageType)
{
	Super(DeathMatch).Killed(Killer,Killed,KilledPawn,DamageType);
}

function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
	local int i;
	local NavigationPoint N, BestStart;
	local float BestRating, NewRating;
	local byte Team;

	if ( GameRulesModifiers != None )
	{
		N = GameRulesModifiers.FindPlayerStart(Player,InTeam,incomingName);
		if ( N != None )
			return N;
	}

	// use InTeam if player doesn't have a team yet
	if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
	{
		if ( Player.PlayerReplicationInfo.Team != None )
			Team = Player.PlayerReplicationInfo.Team.TeamIndex;
		else Team = InTeam;
	}
	else Team = InTeam;

	for( i=0; i<SpawningPoints.Length; i++ )
	{
		N = SpawningPoints[i];
		NewRating = RatePlayerStart(N,Team,Player);
		if ( NewRating > BestRating )
		{
			BestRating = NewRating;
			BestStart = N;
		}
	}

	if ( (BestStart == None) || ((PlayerStart(BestStart) == None) && (Player != None) && Player.bIsPlayer) )
	{
		log("Warning - PATHS NOT DEFINED or NO PLAYERSTART with positive rating");
		BestStart = SpawningPoints[0];
	}
	return BestStart;
}

function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local Controller P, NextController;
	local PlayerController Player;

	if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
		return false;

	if ( Winner == None )
	{
		// find winner
		for ( P=Level.ControllerList; P!=None; P=P.nextController )
			if ( P.bIsPlayer && ((Winner == None) || (P.PlayerReplicationInfo.Kills>= Winner.Kills)) )
			{
				Winner = P.PlayerReplicationInfo;
			}
	}

	// check for tie
	for ( P=Level.ControllerList; P!=None; P=P.nextController )
	{
		if ( P.bIsPlayer && (Winner != P.PlayerReplicationInfo) && (P.PlayerReplicationInfo.Kills==Winner.Kills) )
		{
			if ( !bOverTimeBroadcast )
			{
				BroadcastLocalizedMessage(class'KFDMTimeMessage', -1);
				bOverTimeBroadcast = true;
			}
			return false;
		}
	}

	EndTime = Level.TimeSeconds + EndTimeDelay;
	GameReplicationInfo.Winner = Winner;

	EndGameFocus = Controller(Winner.Owner).Pawn;
	if ( EndGameFocus != None )
		EndGameFocus.bAlwaysRelevant = true;
	for ( P=Level.ControllerList; P!=None; P=NextController )
	{
		NextController = P.NextController;
		Player = PlayerController(P);
		if ( Player != None )
		{
			//if ( !Player.PlayerReplicationInfo.bOnlySpectator )
			//	PlayWinMessage(Player, (Player.PlayerReplicationInfo == Winner));
			Player.ClientSetBehindView(true);
			if ( EndGameFocus != None )
			{
				Player.ClientSetViewTarget(EndGameFocus);
				Player.SetViewTarget(EndGameFocus);
			}
			Player.ClientGameEnded();
		}
		P.GameHasEnded();
	}
	return true;
}

function int ReduceDamage(int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	if( Damage<=0 || IsInShopVolume(injured) )
		return 0;

	if( DamageType==Class'DamTypeFrag' )
		Damage*=0.75;
	else if( Class<KFWeaponDamageType>(DamageType)!=None && Class<KFWeaponDamageType>(DamageType).Default.bIsMeleeDamage )
		Damage*=0.7; // Melee do more damage.
	else Damage*=0.25; // Overpowered weapon damage reduction!
	if( bHandicapMode && instigatedBy!=None && injured!=instigatedBy )
		Damage/=(1.f+float(instigatedBy.GetSpree())*0.1f);
	Damage = Max(Damage,1); // Make sure it does at least one hitpoint damage.
	return super(DeathMatch).ReduceDamage(Damage,injured,InstigatedBy,HitLocation,Momentum,DamageType);
}
function bool IsInShopVolume( Pawn Other )
{
	local ShopVolume S;

	foreach Other.TouchingActors(Class'ShopVolume',S)
		if( S.bCurrentlyOpen )
			return true;
	return false;
}

function AmmoPickedUp(KFAmmoPickup PickedUp)
{
	PickedUp.Destroy(); // Kill all ammo pickups.
}

function PlayEndOfMatchMessage()
{
	local Controller C;

	for ( C = Level.ControllerList; C != None; C = C.NextController )
	{
		if ( C.IsA('PlayerController') && !C.PlayerReplicationInfo.bOnlySpectator )
		{
			if (C.PlayerReplicationInfo == GameReplicationInfo.Winner)
				PlayerController(C).ClientPlaySound(Sound'WonMatch',true,2.f,SLOT_Talk);
			else
				PlayerController(C).ClientPlaySound(Sound'LostMatch',true,2.f,SLOT_Talk);
		}
	}
}

function DiscardInventory( Pawn Other )
{
	local Inventory I,II;
	local Weapon W;
	local WeaponPickup WW;

	for( I=Other.Inventory; I!=None; I=II )
	{
		II = I.Inventory;
		W = Weapon(I);
		if( W!=None && W.bCanThrow && Frag(W)==None && Syringe(W)==None && Welder(W)==None && Knife(W)==None )
		{
			W.Velocity = VRand()*300.f;
			W.DropFrom(Other.Location);
		}
		else I.Destroy();
	}
	foreach CollidingActors(Class'WeaponPickup',WW,100,Other.Location)
		if( WW.bDropped )
			WW.LifeSpan = 10.f; // Make sure it gets destroyed.
	Super.DiscardInventory(Other);
}

State MatchInProgress
{
	function OpenShops()
	{
		local int i;
		local array<ShopVolume> V;

		bTradingDoorsOpen = True;

		for( i=0; i<ShopList.Length; i++ )
		{
			if( !ShopList[i].bAlwaysClosed && OldOpenShop!=ShopList[i] )
				V[V.Length] = ShopList[i];
		}
		if( V.Length==0 )
		{
			OldOpenShop = None;
			return;
		}
		OldOpenShop = V[Rand(V.Length)];
		OldOpenShop.OpenShop();
	}

	function CloseShops()
	{
		local int i;

		bTradingDoorsOpen = False;
		for( i=0; i<ShopList.Length; i++ )
		{
			if( ShopList[i].bCurrentlyOpen )
				ShopList[i].CloseShop();
		}
	}

	function Timer()
	{
		local Controller C;

		Global.Timer();

		for( C=Level.ControllerList; C!=None; C=C.nextController )
			if( C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator && C.PlayerReplicationInfo.bReadyToPlay
			 && C.IsA('PlayerController') && C.IsInState('PlayerWaiting') )
				RestartPlayer(C);
		if ( !bFinalStartup )
		{
			bFinalStartup = true;
			//PlayStartupMessage();
		}
		if ( NeedPlayers() && AddBot() && (RemainingBots > 0) )
			RemainingBots--;
		ElapsedTime++;
		GameReplicationInfo.ElapsedTime = ElapsedTime;

		if ( bOverTime )
			EndGame(None,"TimeLimit");
		else if ( TimeLimit > 0 )
		{
			GameReplicationInfo.bStopCountDown = false;
			RemainingTime--;
			GameReplicationInfo.RemainingTime = RemainingTime;
			if ( RemainingTime % 60 == 0 )
				GameReplicationInfo.RemainingMinute = RemainingTime;
			if( RemainingTime==600 || RemainingTime==300 || RemainingTime==180 || RemainingTime==120 || RemainingTime==60
				 || RemainingTime==30 || RemainingTime==20 || (RemainingTime<=10 && RemainingTime>=1) )
				BroadcastLocalizedMessage(class'KFDMTimeMessage', RemainingTime);
			if ( RemainingTime <= 0 )
				EndGame(None,"TimeLimit");
		}

		if( NextShopToggleTime>Level.TimeSeconds )
			return;
		if( bShopsAreOpened )
		{
			// Close Trader doors
			if( bTradingDoorsOpen )
			{
				CloseShops();
				TraderProblemLevel = 0;
			}
			if( TraderProblemLevel<4 )
			{
				if( BootShopPlayers() )
					TraderProblemLevel = 0;
				else TraderProblemLevel++;
			}
			else
			{
				bShopsAreOpened = false;
				NextShopToggleTime = Level.TimeSeconds+60.f*FRand();
			}
		}
		else
		{
			OpenShops();
			bShopsAreOpened = true;
			NextShopToggleTime = Level.TimeSeconds+80.f+130.f*FRand();
		}
	}
	function BeginState()
	{
		local byte i;
		local InvSpawnManager S;

		NextShopToggleTime = Level.TimeSeconds+60.f*FRand();
		for( i=0; i<NumAmmoSpawns; i++ )
			Spawn(Class'InvSpawnManager').PickupClass = Class'KFAmmoPickup';
		for( i=0; i<NumWeaponSpawns; i++ )
			Spawn(Class'InvSpawnManager').InvList = KFLRules;
		S = Spawn(Class'InvSpawnManager');
		S.PickupClass = Class'Vest';
		S.DisableTime = 60.f;
	}
}
State MatchOver
{
	function Timer()
	{
		local Controller C;

		Global.Timer();

		if ( !bGameRestarted && (Level.TimeSeconds > EndTime + RestartWait) )
			RestartGame();

		if ( EndGameFocus != None )
		{
			EndGameFocus.bAlwaysRelevant = true;
			for ( C = Level.ControllerList; C != None; C = C.NextController )
				if ( PlayerController(C) != None )
					PlayerController(C).ClientSetViewtarget(EndGameFocus);
		}

		// play end-of-match message for winner/losers (for single and muli-player)
		EndMessageCounter++;
		if ( EndMessageCounter == EndMessageWait )
			PlayEndOfMatchMessage();
	}
	function BeginState()
	{
		GameReplicationInfo.bStopCountDown = true;
		KFGameReplicationInfo(GameReplicationInfo).EndGameType = 2;
	}
}

defaultproperties
{
     bHandicapMode=True
     KillCashAward=150
     NumAmmoSpawns=3
     NumWeaponSpawns=2
     InitGrenadesCount=1
     MinRespawnCash=200
     bNoBots=False
     TeamAIType(0)=Class'KFDeathMatch.DMTeamAI'
     TeamAIType(1)=Class'KFDeathMatch.DMTeamAI'
     DefaultMaxLives=0
     DefaultEnemyRosterClass="XGame.xDMRoster"
     bTeamGame=False
     DefaultPlayerClassName="KFDeathMatch.KFDMHumanPawn"
     ScoreBoardType="KFDeathMatch.KFDMScoreBoard"
     HUDType="KFDeathMatch.DMHUDKillingFloor"
     GoalScore=20
     MaxLives=0
     TimeLimit=15
     MutatorClass="KFDeathMatch.KFDMBaseMut"
     PlayerControllerClassName="KFMod.KFPlayerController"
     GameName="KF DeathMatch"
     Description="DeathMatch Gameplay."
}
