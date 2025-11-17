//============================================================
// TTeamFixMut.uc	- Class for managing mutator-specific events
//============================================================
//	TitanTeamFix
//		+ Coded by Shambler (Shambler@OldUnreal.com or Shambler__@Hotmail.com , ICQ: 108730864)
//		- A modular team balancing mutator initially coded for the Titan servers
//			http://ut2004.titaninternet.co.uk/
//
//============================================================
Class TTeamFixMut extends Mutator;

var TTeamFix Master;

// ===== Variables controlling used code
var bool bExitingEvent;
var bool bJoiningEvent;
var bool bJoinedEvent;

var float LastKeyGrab;

var array<PlayerReplicationInfo> DelayedJoinNotify;

function InitializeEvents(TTeamFix Caller)
{
	// Some checking statements
	if (Caller == none)
	{
		Warn("TTeamFixMut::InitializeEvents Caller is none");
		return;
	}

	if (Master != none && Master != Caller)
		Warn("TTeamFixMut::InitializeEvents Master was already set, initializing from new Caller and disregarding old Master");

	Master = Caller;

	bExitingEvent = Master.bNeedExitingEvent;
	bJoiningEvent = Master.bNeedJoiningEvent;
	bJoinedEvent = Master.bNeedJoinedEvent;
}

function NotifyLogout(Controller Exiting)
{
	Super.NotifyLogout(Exiting);

	if (bExitingEvent && Master != none && Exiting != none)
		Master.PlayerExitingGame(Exiting);
}

// Enable/disable commands
function Mutate(string MutateString, PlayerController Sender)
{
	//local controller c;

	if (Sender != none && Sender.PlayerReplicationInfo != none && Sender.PlayerReplicationInfo.bAdmin && Master != none)
	{
		if (MutateString ~= "DisableTTF")
			Master.DisableBalancing();
		else if (MutateString ~= "EnableTTF")
			Master.EnableBalancing();
		else if (MutateString ~= "TTF_ShuffleTeams")
			Master.TakeCommand(MutateString, Sender);
	}
	// This is for helping me debug this command on Titan, only I can use this debug ability...admins can call the same command because of the above code
/*
	else if (MutateString ~= "TTF_ShuffleTeams" && Sender.GetPlayerIDHash() == "0d8e29a9dd5385a50c1ba233b4609693")
	{
		Master.TakeCommand(MutateString, Sender);
	}
*/


	/*
	if (MutateString ~= "KillBot 0")
	{
		for (c=level.ControllerList; c!=none; c=c.NextController)
			if (AIController(c) != none && AIController(c).PlayerReplicationInfo.Team.TeamIndex == 0)
				c.Destroy();
	}
	else if (MutateString ~= "KillBot 1")
	{
		for (c=level.ControllerList; c!=none; c=c.NextController)
			if (AIController(c) != none && AIController(c).PlayerReplicationInfo.Team.TeamIndex == 1)
				c.Destroy();
	}
	*/

	Super.Mutate(MutateString, Sender);
}

function ModifyLogin(out string Portal, out string Options)
{
	if (bJoiningEvent && Master != none)
		Master.PlayerJoiningGame(Portal, Options);

	Super.ModifyLogin(Portal, Options);
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if (bJoinedEvent && PlayerReplicationInfo(Other) != none && Controller(Other.Owner) != none && Master != none)
	{
		// This code is called when a players PRI is spawned, too early to check the players GUID so delay it
		DelayedJoinNotify.Length = DelayedJoinNotify.Length + 1;
		DelayedJoinNotify[DelayedJoinNotify.Length-1] = PlayerReplicationInfo(Other);

		Enable('Tick');
	}

	return True;
}

function Tick(float DeltaTime)
{
	local int i;

	for (i=0; i<DelayedJoinNotify.Length; ++i)
	{
		// If there is no net connection open for this player, his GUID has not yet been set
		//if (DelayedJoinNotify[i] == none || DelayedJoinNotify[i].Owner == none || PlayerController(DelayedJoinNotify[i].Owner).Player == none
		//	|| NetConnection(PlayerController(DelayedJoinNotify[i].Owner).Player) == none)
		//	continue;

		// The above seems to give LOTS of accessed nones for 'Owner', don't know why
		if (DelayedJoinNotify[i] != none && DelayedJoinNotify[i].Owner != none && PlayerController(DelayedJoinNotify[i].Owner).Player != none
			&& NetConnection(PlayerController(DelayedJoinNotify[i].Owner).Player) != none)
		{
			Master.PlayerJoinedGame(DelayedJoinNotify[i]);
			LastKeyGrab = Level.TimeSeconds;

			DelayedJoinNotify.Remove(i, 1);
			--i;
		}
	}



	if (DelayedJoinNotify.Length <= 0)
	{
		Disable('Tick');
	}
	else if (Level.TimeSeconds - LastKeyGrab > 10.0)
	{
		for (i=0; i<DelayedJoinNotify.Length; ++i)
			Log("Player without a net connection (thus, no valid GUID), name:"@DelayedJoinNotify[i].PlayerName, 'TitanTeamFix');

		DelayedJoinNotify.Length = 0;
		Disable('Tick');
	}
}