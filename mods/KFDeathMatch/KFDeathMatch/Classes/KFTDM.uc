// Killing Floor Team DeathMatch, written by Marco.
Class KFTDM extends KFDM;

#exec AUDIO IMPORT FILE="BlueWin.WAV" NAME="BlueWin" GROUP="Team"
#exec AUDIO IMPORT FILE="RedWin.WAV" NAME="RedWin" GROUP="Team"

var PlayerStart RedSpawn,BlueSpawn;
var config int RoundTimeLimit,RoundWinCashAward;
var int RoundTimeLeft;
var byte MessagesLastMan[2],RoundRestartTime;
var TDMShopTrigger ShopTriggers[2];

function InitGame( string Options, out string Error )
{
	DefaultMaxLives = 0; // Temp, so time limit isnt reset to 0.
	Super.InitGame(Options,Error);
	DefaultMaxLives = 1;
}
static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.GameGroup,"RoundTimeLimit","Round TimeLimit",0, 0, "Text","3;0:999");
	PlayInfo.AddSetting(default.GameGroup,"RoundWinCashAward","Round Win Cash",0, 0, "Text","3;0:999");
	PlayInfo.AddSetting(default.GameGroup,"FriendlyFireScale","FriendlyFire Scale",20,1,"Text","8;0.0:1.0",,,True);
}
static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "RoundTimeLimit":		return "Round time limit (in minutes).";
		case "RoundWinCashAward":		return "Round cash award, all players earn on winning team.";
	}
	return Super.GetDescriptionText(PropName);
}

event PreBeginPlay()
{
	Super(xTeamGame).PreBeginPlay();
	GameReplicationInfo.bNoTeamSkins = true;
	GameReplicationInfo.bForceNoPlayerLights = true;
	GameReplicationInfo.bNoTeamChanges = false;
}
function UnrealTeamInfo GetBotTeam(optional int TeamBots)
{
	return Super(xTeamGame).GetBotTeam(TeamBots);
}
function byte PickTeam(byte num, Controller C)
{
	return Super(TeamGame).PickTeam(num,C);
}
function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
	return Super(xTeamGame).ChangeTeam(Other,num,bNewTeam);
}
final function PickSpawnPoints()
{
	local byte c;

	RedSpawn = SpawningPoints[Rand(SpawningPoints.Length)];
	while( ++c<20 )
	{
		BlueSpawn = SpawningPoints[Rand(SpawningPoints.Length)];
		if( BlueSpawn!=RedSpawn && VSizeSquared(BlueSpawn.Location-RedSpawn.Location)>4000000.f && !FastTrace(BlueSpawn.Location,RedSpawn.Location) )
			break; // Make sure other team dosen't spawn too close or in visible sight.
	}
	ShopTriggers[0] = Spawn(Class'TDMShopTrigger',,,RedSpawn.Location);
	ShopTriggers[1] = Spawn(Class'TDMShopTrigger',,,BlueSpawn.Location);
	ShopTriggers[1].Team = 1;
	if( RoundTimeLimit>0 )
		RoundTimeLeft = RoundTimeLimit*60;
}
function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
	local byte Team;
	local NavigationPoint N;

	if( RedSpawn==None )
		return Super.FindPlayerStart(Player,InTeam,incomingName); // Game has not started yet.

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

	if( Team==0 )
		return RedSpawn;
	return BlueSpawn;
}
function StartMatch()
{
	PickSpawnPoints();
	Super.StartMatch();
}
function int ReduceDamage(int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	if( instigatedBy!=None && instigatedBy!=injured && injured.GetTeamNum()==instigatedBy.GetTeamNum() )
	{
		if( FriendlyFireScale==0.f || Damage<=0 )
			return 0;
		else return Super.ReduceDamage(Max(Damage*FriendlyFireScale,1),injured,instigatedBy,HitLocation,Momentum,DamageType);
	}
	return Super.ReduceDamage(Damage,injured,instigatedBy,HitLocation,Momentum,DamageType);
}
function PlayEndOfMatchMessage()
{
	local Controller C;
	local Sound S;

	if( TeamInfo(GameReplicationInfo.Winner).TeamIndex==0 )
		S = Sound'RedWin';
	else S = Sound'BlueWin';
	for ( C = Level.ControllerList; C != None; C = C.NextController )
	{
		if ( C.IsA('PlayerController') )
			PlayerController(C).ClientPlaySound(S,true,2.f,SLOT_Talk);
	}
}
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local Controller P, NextController;
	local PlayerController Player;

	if ( (GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
		return false;

	// check for tie
	if( Teams[0].Score==Teams[1].Score )
	{
		if ( !bOverTimeBroadcast )
		{
			BroadcastLocalizedMessage(class'KFDMTimeMessage', -1);
			bOverTimeBroadcast = true;
		}
		return false;
	}

	EndTime = Level.TimeSeconds + EndTimeDelay;
	if( Teams[0].Score<Teams[1].Score )
		GameReplicationInfo.Winner = Teams[1];
	else GameReplicationInfo.Winner = Teams[0];

	for ( P=Level.ControllerList; P!=None; P=NextController )
	{
		NextController = P.NextController;
		Player = PlayerController(P);
		if ( Player != None )
		{
			Player.ClientSetBehindView(true);
			Player.ClientGameEnded();
		}
		P.GameHasEnded();
	}
	return true;
}
function ScoreKill(Controller Killer, Controller Other)
{
	Super.ScoreKill(Killer,Other);
	if( Other.PlayerReplicationInfo!=None )
		Other.PlayerReplicationInfo.bOutOfLives = true;
}
final function bool CheckAlivePPL()
{
	local Controller C;
	local byte Alives[2],i;
	local PlayerController Alive[2];

	for( C=Level.ControllerList; C!=None; C=C.nextController )
	{
		if( C.bIsPlayer && C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator && !C.PlayerReplicationInfo.bOutOfLives
		 && C.PlayerReplicationInfo.Team!=None )
		{
			Alive[C.PlayerReplicationInfo.Team.TeamIndex] = PlayerController(C);
			Alives[C.PlayerReplicationInfo.Team.TeamIndex]++;
		}
	}
	if( Alives[0]==0 && Alives[1]==0 )
		RoundEnd(2); // Draw
	else if( Alives[0]==0 )
		RoundEnd(1); // Blue
	else if( Alives[1]==0 )
		RoundEnd(0); // Red
	else
	{
		// Inform about last man standing ;)
		for( i=0; i<2; i++ )
		{
			if( Alives[i]==1 && MessagesLastMan[i]==0 )
			{
				if( Alive[i]!=None )
					Alive[i].ReceiveLocalizedMessage(Class'KFLastManStandingMsg');
				MessagesLastMan[i] = 1;
			}
		}
		return true;
	}
	return false;
}
final function RoundEnd( byte Winner )
{
	local Controller C;

	if( ShopTriggers[0]!=None )
		ShopTriggers[0].Destroy();
	if( ShopTriggers[1]!=None )
		ShopTriggers[1].Destroy();
	if( Winner==0 )
	{
		Teams[0].Score+=1;
		Teams[0].NetUpdateTime = Level.TimeSeconds-1.f;
		if( Teams[0].Score==(Teams[1].Score+1) )
			BroadcastLocalizedMessage(class'KFTDMWinMessage', 1);
		else if( Teams[0].Score==(Teams[1].Score+2) )
			BroadcastLocalizedMessage(class'KFTDMWinMessage', 2);
		else BroadcastLocalizedMessage(class'KFTDMWinMessage', 0);
	}
	else if( Winner==1 )
	{
		Teams[1].Score+=1;
		Teams[1].NetUpdateTime = Level.TimeSeconds-1.f;
		if( Teams[1].Score==(Teams[0].Score+1) )
			BroadcastLocalizedMessage(class'KFTDMWinMessage', 4);
		else if( Teams[1].Score==(Teams[0].Score+2) )
			BroadcastLocalizedMessage(class'KFTDMWinMessage', 5);
		else BroadcastLocalizedMessage(class'KFTDMWinMessage', 3);
	}
	else BroadcastLocalizedMessage(class'KFTDMWinMessage', -1);
	RoundRestartTime = 4;
	for( C=Level.ControllerList; C!=None; C=C.nextController )
	{
		if( C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator && C.PlayerReplicationInfo.Team!=None
		 && C.PlayerReplicationInfo.Team.TeamIndex==Winner )
			C.PlayerReplicationInfo.Score+=RoundWinCashAward;
	}
}
final function StartNewRound()
{
	local Controller C,NC;
	local array<Controller> CA;
	local int i;
	local Projectile P;

	if( GoalScore>0 ) // Check winners
	{
		if( Teams[0].Score>=GoalScore )
		{
			EndGame(None,"fraglimit");
			return;
		}
		else if( Teams[1].Score>=GoalScore )
		{
			EndGame(None,"fraglimit");
			return;
		}
	}

	// First kill all pawns.
	for( C=Level.ControllerList; C!=None; C=NC )
	{
		NC = C.nextController;
		if( C.Pawn!=None && C.PlayerReplicationInfo!=None )
			C.Pawn.Destroy();
	}

	// Then even the teams.
	if( Teams[0].Size>(Teams[1].Size+1) ) // To many Reds.
	{
		for( C=Level.ControllerList; C!=None; C=C.nextController )
		{
			if( C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator && C.PlayerReplicationInfo.Team!=None
			 && C.PlayerReplicationInfo.Team.TeamIndex==0 )
				CA[CA.Length] = C;
		}
		while( Teams[0].Size>(Teams[1].Size+1) && CA.Length>0 )
		{
			i = Rand(CA.Length);
			ChangeTeam(CA[i],1,true);
			CA.Remove(i,1);
		}
	}
	else if( Teams[1].Size>(Teams[0].Size+1) ) // To many Blues.
	{
		for( C=Level.ControllerList; C!=None; C=C.nextController )
		{
			if( C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator && C.PlayerReplicationInfo.Team!=None
			 && C.PlayerReplicationInfo.Team.TeamIndex==1 )
				CA[CA.Length] = C;
		}
		while( Teams[1].Size>(Teams[0].Size+1) && CA.Length>0 )
		{
			i = Rand(CA.Length);
			ChangeTeam(CA[i],0,true);
			CA.Remove(i,1);
		}
	}

	// Kill any active projectiles
	foreach DynamicActors(Class'Projectile',P)
		P.Destroy();

	// Init new spawns and respawn players.
	PickSpawnPoints();
	for( C=Level.ControllerList; C!=None; C=NC )
	{
		NC = C.nextController;
		if( C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator && C.PlayerReplicationInfo.Team!=None )
		{
			C.PlayerReplicationInfo.bOutOfLives = false;
			RestartPlayer(C);
		}
	}
	bFinalStartup = false;
}
final function UpdateViewsNow()
{
	local Controller C;

	for( C=Level.ControllerList; C!=None; C=C.nextController )
	{
		if( C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator && PlayerController(C)!=None && C.Pawn!=None )
		{
			PlayerController(C).ClientSetBehindView(false);
			PlayerController(C).ClientSetViewTarget(C.Pawn);
			PlayerController(C).ReceiveLocalizedMessage(Class'KFMainMessages',3);
		}
		else if( KFInvasionBot(C)!=None && C.Pawn!=None && FRand()<0.5f )
			KFInvasionBot(C).DoTrading();
	}
}
function CheckScore(PlayerReplicationInfo Scorer);

function RestartPlayer( Controller aPlayer )
{
	if ( aPlayer.PlayerReplicationInfo.bOutOfLives || aPlayer.Pawn!=None )
		return;
	if( aPlayer.PlayerReplicationInfo.Team.TeamIndex==0 )
		aPlayer.PawnClass = Class'KFRedTDMPlayer';
	else aPlayer.PawnClass = Class'KFBlueTDMPlayer';
	aPlayer.PreviousPawnClass = aPlayer.PawnClass;
	KFPlayerReplicationInfo(aPlayer.PlayerReplicationInfo).ClientVeteranSkill = Class'KFVeterancyTypes';
	aPlayer.PlayerReplicationInfo.Score = Max(MinRespawnCash, int(aPlayer.PlayerReplicationInfo.Score));
	Super(Invasion).RestartPlayer(aPlayer);
}
function bool IsInShopVolume( Pawn Other )
{
	local TDMShopTrigger Sh;

	foreach Other.TouchingActors(Class'TDMShopTrigger',Sh)
		if( Sh.Team==Other.GetTeamNum() )
			Return True;
	return false;
}
final function DamagePlayers()
{
	local Controller C;
	local Inventory I;

	for( C=Level.ControllerList; C!=None; C=C.nextController )
	{
		if( C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator && C.Pawn!=None )
		{
			C.Pawn.TakeDamage(10, None, C.Pawn.Location, vect(0,0,0), Class'Suicided');
			I = C.Pawn.FindInventoryType(Class'Syringe');
			if( I!=None )
				I.Destroy();
		}
	}
	RoundTimeLeft = 3;
}

State MatchInProgress
{
	function OpenShops();
	function CloseShops();

	function Timer()
	{
		Global.Timer();

		if ( !bFinalStartup )
		{
			bFinalStartup = true;
			UpdateViewsNow();
		}
		if( RoundRestartTime>0 && --RoundRestartTime==0 )
			StartNewRound();
		else if( RoundRestartTime==0 )
		{
			CheckAlivePPL();
			if( RoundTimeLimit>0 )
			{
				if( RoundTimeLeft<=0 )
					DamagePlayers();
				else RoundTimeLeft--;
			}
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
	}
}

defaultproperties
{
     RoundTimeLimit=5
     RoundWinCashAward=200
     bHandicapMode=False
     KillCashAward=300
     TeamAIType(0)=Class'KFDeathMatch.TDMTeamAI'
     TeamAIType(1)=Class'KFDeathMatch.TDMTeamAI'
     DefaultMaxLives=1
     DefaultEnemyRosterClass="XGame.xTeamRoster"
     bTeamGame=True
     ScoreBoardType="KFDeathMatch.KFTDMScoreBoard"
     HUDType="KFDeathMatch.TDMHUDKillingFloor"
     GoalScore=5
     MaxLives=1
     GameName="KF TeamDeathMatch"
     Description="TeamDeathMatch Gameplay."
}
