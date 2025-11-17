//============================================================
// TTeamFixRules.uc	- Class for managing GameRule specific events
//============================================================
//	TitanTeamFix
//		+ Coded by Shambler (Shambler@OldUnreal.com or Shambler__@Hotmail.com , ICQ: 108730864)
//		- A modular team balancing mutator initially coded for the Titan servers
//			http://ut2004.titaninternet.co.uk/
//
//============================================================
Class TTeamFixRules extends GameRules;

const TTFVersion="v1.0beta19_Test";

var TTeamFix Master;

var bool bPreSpawnEvent;
var bool bKillEvent;
//var bool bEndGameEvent;

function InitializeEvents(TTeamFix Caller)
{
	// Some checking statements
	if (Caller == none)
	{
		Warn("TTeamFixRules::InitializeEvents Caller is none");
		return;
	}

	if (Master != none && Master != Caller)
		Warn("TTeamFixRules::InitializeEvents Master was already set, initializing from new Caller and disregarding old Master");

	Master = Caller;

	bPreSpawnEvent = Master.bNeedPreSpawnEvent;
	bKillEvent = Master.bNeedKilledEvent;
	//bEndGameEvent = Master.bNeedGameEndedEvent;
}

function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string incomingName)
{
	if (bPreSpawnEvent && Master != none && Player != none)
		Master.PlayerSpawning(Player, InTeam);

	return Super.FindPlayerStart(Player, InTeam, incomingName);
}

function ScoreKill(Controller Killer, Controller Killed)
{
	if (bKillEvent && Master != none && Killed != none)
		Master.PlayerKilled(Killed);

	Super.ScoreKill(Killer, Killed);
}

function GetServerDetails(out GameInfo.ServerResponseLine ServerState)
{
	Class'GameInfo'.static.AddServerDetail(ServerState, "TitanTeamFixVersion", TTFVersion);
}

/*
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local bool bReturnValue;

	bReturnValue = Super.CheckEndGame(Winner, Reason);

	if (bEndGameEvent && bReturnValue)
		Master.GameEnded();

	return bReturnValue;
}
*/