//============================================================
// TTeamFix.uc		- This class will be the placeholder for the balancing system
//============================================================
//	TitanTeamFix
//		+ Coded by Shambler (Shambler@OldUnreal.com or Shambler__@Hotmail.com)
//		- A modular team balancing mutator initially coded for the Titan servers
//			http://ut2004.titaninternet.co.uk/
//
//============================================================
//
// This class is designed to be a modular base class for all team-balancing components,
// it is designed around certain key events like for a player joining a team or leaving
// the game etc. and these key events are called by either the 'EventMutator' or the
// 'EventRules' objects.
//
// The reason I want this to be modular is so that anybody can code plugins for this
// mutator so it can run better on different gametypes...i.e. for instance I am
// planning a plugin for this mutator which will be for the TAM (Team Arena Master)
// gametype, which is round based....thus switching live players mid-round would be
// very inappropriate and would piss people off....a plugin can be coded to suit TAM.
// (that's actually half the reason for me coding this in the first place)
//
//============================================================
Class TTeamFix extends Info;


// Change these values in subclasses via the default properties, in most cases the original defaults will suit your purposes
var class<TTeamFixMut>		EventMutClass;
var class<TTeamFixRules>	EventRulesClass;


// Events that require 'EventRules' (set these in default properties or in BeginPlay)
var bool bNeedPreSpawnEvent;
var bool bNeedKilledEvent;
//var bool bNeedGameEndedEvent;

// Events that require 'EventMutator'
var bool bNeedExitingEvent;
var bool bNeedJoiningEvent;
var bool bNeedJoinedEvent;
var bool bNeedDisableCmd;


// ===== Runtime variables
var TTeamFixMut			EventMutator;
var TTeamFixRules		EventRules;

var GameReplicationInfo		GRI;


// ===== ONSPlus hack, allows TitanTeamFix to load through ONSPlus and evade the whitelist
var config bool bCustomMutHandling;
var config string CustomMutHandle;


// ===== General functions
// Note: you must set the 'bNeed' variables BEFORE PostBeginPlay, so set them within BeginPlay

function PostBeginPlay()
{
	if (TeamGame(Level.Game) != none)
		InitializeBalancing();
}

function InitializeBalancing()
{
	local mutator m;
	local gamerules g;
	local class<Info> HandleClass;

	// Set the GRI
	GRI = Level.Game.GameReplicationInfo;

	// Check if an existing mutator exists for this object (even if we don't need it)
	if (EventMutator == none)
		for (m=Level.Game.BaseMutator; m!=none; m=m.NextMutator)
			if (TTeamFixMut(m) != none && m.Class == EventMutClass)
				EventMutator = TTeamFixMut(m);

	// Same as above except for gamerules
	if (EventRules == none)
		for (g=Level.Game.GameRulesModifiers; g!=none; g=g.NextGameRules)
			if (TTeamFixRules(g) != none && g.Class == EventRulesClass)
				EventRules = TTeamFixRules(g);

	// Initiate the 'EventMutator' and 'EventRules' objects if needed
	if (NeedMutator())
	{
		if (EventMutator == none)
		{
			EventMutator = Spawn(EventMutClass);
			EventMutator.bUserAdded = True;

			if (!bCustomMutHandling)
			{
				Level.Game.BaseMutator.AddMutator(EventMutator);
			}
			else
			{
				HandleClass = Class<Info>(DynamicLoadObject(CustomMutHandle, Class'Class'));

				if (HandleClass != None)
					Spawn(HandleClass, EventMutator);
			}
		}

		EventMutator.InitializeEvents(self);
	}

	if (NeedRules())
	{
		if (EventRules == none)
		{
			EventRules = Spawn(EventRulesClass);
			Level.Game.AddGameModifier(EventRules);
		}

		EventRules.InitializeEvents(self);
	}
}


// ===== Checking functions

// This returns true if the current configuration needs events from the mutator class
function bool NeedMutator()
{
	if (bNeedExitingEvent || bNeedDisableCmd || bNeedJoiningEvent || bNeedJoinedEvent)
		return true;

	return false;
}

// Same as above except this is if we need a GameRules class
function bool NeedRules()
{
	if (bNeedPreSpawnEvent || bNeedKilledEvent)// || bNeedGameEndedEvent)
		return true;

	return false;
}

// Returns the team with too many players and the no. of extra players (also returns bSlotOpened=True if the server was full and an exiting player opened a slot)
function bool bTeamsUneven(optional out int Team, optional out int Imbalance, optional controller Leaving)
{
	local int ExitingImbalance[2];

	// If the GRI or the teaminfo's are not set then might aswell assume teams are even
	if (GRI == none)
	{
		GRI = Level.Game.GameReplicationInfo;

		if (GRI == none)
			return false;
	}

	// Check that both teams exist and that the game hasn't ended
	if (GRI.Teams[0] == none || GRI.Teams[1] == none || Level.Game.bGameEnded)
		return false;


	// If a player is leaving the game (specified by the optional 'Leaving' variable) then take that into account
	if (Leaving != none && Leaving.PlayerReplicationInfo != none && Leaving.PlayerReplicationInfo.Team != none)
		ExitingImbalance[Leaving.PlayerReplicationInfo.Team.TeamIndex] = 1;

	// If team 0's size has more than 1 extra player then teams are considered uneven
	if (GRI.Teams[0].Size - ExitingImbalance[0] > (GRI.Teams[1].Size - ExitingImbalance[1]) + 1)
	{
		Team = 0;
		Imbalance = (GRI.Teams[0].Size - ExitingImbalance[0]) - (GRI.Teams[1].Size - ExitingImbalance[1]);

		return true;
	}
	else if ((GRI.Teams[1].Size - ExitingImbalance[1]) > (GRI.Teams[0].Size - ExitingImbalance[0]) + 1)
	{
		Team = 1;
		Imbalance = (GRI.Teams[1].Size - ExitingImbalance[1]) - (GRI.Teams[0].Size - ExitingImbalance[0]);

		return true;
	}

	return false;
}


// ===== Functions relying on outside-class events from 'EventMutator' and 'EventRules'

// 'EventRules' events
function PlayerSpawning(controller Player, out byte InTeam);
singular function PlayerKilled(controller Player);
//function GameEnded();

// 'EventMutator' events
function PlayerExitingGame(controller Player);
function PlayerJoiningGame(out string Portal, out string Options);
function PlayerJoinedGame(PlayerReplicationInfo PRI);
function DisableBalancing();
function EnableBalancing();
function TakeCommand(string Command, PlayerController Sender);



defaultproperties
{
	EventMutClass=Class'TTeamFixMut'
	EventRulesClass=Class'TTeamFixRules'

	bNeedDisableCmd=True

	bCustomMutHandling=False
}