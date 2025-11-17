//============================================================
// TTeamFixGeneric.uc		- Gametype independant team balancing class, most implementation is here
//============================================================
//	TitanTeamFix
//		+ Coded by Shambler (Shambler@OldUnreal.com or Shambler__@Hotmail.com , ICQ: 108730864)
//		- A modular team balancing mutator initially coded for the Titan servers
//			http://ut2004.titaninternet.co.uk/
//
//============================================================
//
// Highly configurable team balancer class.
// It's possible to tweak this to suit a variety of different
// gametypes, all without touching any code.
//
//============================================================
Class TTeamFixGeneric extends TTeamFix
	config(TitanTeamFix);


// ===== Configurable variables

// TODO: Merge these two structs

// The optional course of action to take after a player exits the game (if an action is already pending then this is ignored)
enum ExitEvent
{
	EXIT_EvenTeams,		// Even the teams straight away
	EXIT_Countdown,		// Count down from 'ExitCountdown' seconds and rechecks if the teams are even after that many seconds, if not then evens them
	EXIT_DeathEvent,	// Evens the teams the next time a recently joined player dies (must have joined within one minute of the most recent player)
	EXIT_CountdownOrDeath	// A combination of 'EXIT_Countdown' and 'EXIT_DeathEvent', if no player has been switched after the countdown then even teams
};

// Same as the above struct, except these apply when a player dies
enum DeathEvent
{
	DEATH_EvenTeams,
	DEATH_Countdown,
	DEATH_DeathEvent,
	DEATH_CountdownOrDeath
};

var config bool bCheckOnExit;			// If true then the code checks if the teams are uneven each time someone exits, and then acts according to ExitEvent
var config bool bSpectateMeansExit;		// If true then when a player becomes a spectator then he is treated as an exiting player
var config ExitEvent PlayerExitEvent;		// The action to undertake when the teams become uneven after a player exits
var config int ExitCountdown;			// If PlayerExitEvent is set to 'EXIT_Countdown' or 'EXIT_CountdownOrDeath' then this is the time to count down from

var config bool bCheckOnDeath;			// As above except only applies to dying players
var config DeathEvent PlayerDeathEvent;		// ^^
var config int DeathCountdown;			// ^^
var config bool bForceOnTeamDeath;		// Forces the teams to become even ONLY when an entire team is dead (for round based gametypes, i.e. TAM)

// Variables only relevant to Death balancing events
var config int JoinTimeLeniancy;		// Any player that has been in the game for LESS than this amount of time is a candidate for switching
var config int MinSwitchCandidates;		// ADVANCED: The minimum number of people which can be monitored during death event checks (overriden by any Imbalance)
var config int MaxSwitchCandidates;		// ADVANCED: The maximum number of people which can be monitored at any given time

// Variables related to messages
var config bool bNotifySwitchedPlayer;		// Tell the switched player that he has been switched
var config string SwitchedMessage;		// Message to give players who have been switched
var config bool bAnnounceSwitch;		// Tells all the players that 'blah' has been switched
var config bool bSkipSwitchedAnnounce;		// Works with the above variable, if true then will skip sending announce message to the switched player(s)
var config string AnnounceMessage;		// Message to give all players when a player is switched
var config string MultipleAnnounceMessage;	// Same as above, but replaces the above string when more than one player is switched
var config bool bAnnounceImbalance;		// When the teams become imbalanced, notify all players
var config string ImbalanceMessage;		// Message to give everyone when the teams become imbalanced
var config bool bAnnounceSlotOpened;		// When a server is full and an exiting player opens a slot, notify all spectators
var config string SlotOpenedMessage;		// Message to give spectators when a slot opens
var config color MessageColor;			// The color to give all messages

// Get rid of some of these variables
var config bool bDisableTTeamFix;		// A mutate command is used to enable/disable the team balancing functions
var config bool bDisablePreferredTeam;		// This decides wether to discard a joining players preferred team or not
var config bool bPreferLosingTeam;		// This sets new players preferred team to the currently losing team

// Preset configuration loading (for servers that run multiple servers from one install, using only different UT2004.ini files)
var config bool bLoadConfigProfile;		// If true, it loads a special configuration profile
var config bool bPrefixGameToProfile;		// If true, it prefixes the profile name with the current GameInfo's class name (excluding package name)
var class<TTeamFixConfigProfile> ConfigProfileClass; // The config profile class which corresponds to this teamfix class


// ===== Runtime variables
var bool bPendingBalance;
var bool bCurrentlyUneven;			// This variable is ONLY MEANT TO HELP WITH IMBALANCE MESSAGES!!! Don't ever rely on this variable being correct!!
var TTeamFixConfigProfile ConfigObject;		// Object which contains the config profile for this class (if config profiles are enabled)


struct SwitchedData
{
	var controller SwitchedPlayer;
	var byte NumSwitches;
};

// For creating a 2d array
struct ListOrganiser
{
	var array<controller> Players;
};

var array<SwitchedData> SwitchedList;

var bool bCandidatesAvailable;
var array<Controller> SwitchCandidateList;


/*
struct PlayerShuffleData
{
	var controller Controller;
	var float PPH;
};
*/


// ===== General functions

// Here the BeginPlay function is used to sort out activation of events based on the activated configurable variables
function BeginPlay()
{
	if (bLoadConfigProfile)
		LoadPresetConfig();

	InitializeDefaults();
}

// Sets up preset configuration variables
function LoadPresetConfig()
{
	local string ConfigName, PrefixConfigName, FinalConfig;
	//local TTeamFixConfigProfile ConfigObject;
	local array<String> KnownProfiles;
	local int i;


	// Use the TTeamFixConfigLoader class (which stores config info in UT2004.ini) to find the desired config set
	ConfigName = class'TTeamFixConfigLoader'.default.ActiveConfiguration;

	if (bPrefixGameToProfile)
	{
		PrefixConfigName = String(Level.Game.Class);
		PrefixConfigName = Mid(PrefixConfigName, InStr(PrefixConfigName, ".") + 1)$"_"$ConfigName;
	}

	// Check that the config profile exists
	KnownProfiles = GetPerObjectNames("TitanTeamFix", string(ConfigProfileClass.Name));

	for (i=0; i<KnownProfiles.Length; ++i)
	{
		// If the prefixed profile exists, it has precedence over the non-prefixed profile...store it and break
		if (PrefixConfigName != "" && KnownProfiles[i] ~= PrefixConfigName)
		{
			FinalConfig = PrefixConfigName;
			break;
		}

		if (KnownProfiles[i] ~= ConfigName)
			FinalConfig = ConfigName;
	}


	// Log success/failure in finding configuration profiles
	if (PrefixConfigName != "" && FinalConfig != PrefixConfigName)
		Log("Could not find configuration profile '"$PrefixConfigName$"' for loading", 'TitanTeamFix');
	else if (ConfigName != "" && FinalConfig != ConfigName && FinalConfig != PrefixConfigName)
		Log("Could not find configuration profile '"$ConfigName$"' for loading", 'TitanTeamFix');


	// Assign the found configuration, defaulting if not found
	if (FinalConfig == "")
		ConfigName = "default";
	else
		ConfigName = FinalConfig;


	Log("Loading configuration profile '"$ConfigName$"'", 'TitanTeamFix');


	// Load the object which contains the specified config information
	ConfigObject = new(none, ConfigName) ConfigProfileClass;

	// If the default config profile was loaded, make sure that profile exists (otherwise, create it)
	if (ConfigName == "default")
	{
		for (i=0; i<KnownProfiles.Length-1; ++i)
			if (KnownProfiles[i] == "default")
				break;

		if (i >= KnownProfiles.Length || KnownProfiles[i] != "default")
		{
			Log("Default profile did not exist, creating default profile", 'TitanTeamFix');

			ConfigObject.ClearConfig();
			ConfigObject.SaveConfig();
		}
	}

	// Transfer the properties
	ConfigObject.TransferProperties(Self);
}

// Sets up default variables for enabling/disabling events
function InitializeDefaults()
{
	if (bCheckOnExit || bAnnounceSlotOpened)
		bNeedExitingEvent = !bDisableTTeamFix;

	if (bDisablePreferredTeam)
		bNeedJoiningEvent = !bDisableTTeamFix;

	if ((bCheckOnExit && bSpectateMeansExit) || bCheckOnDeath || bAnnounceSlotOpened)
		bNeedKilledEvent = !bDisableTTeamFix;
}

// Rewritten to allow halting of initialization if the mutator is disabled
function InitializeBalancing()
{
	if (!bDisableTTeamFix)
		Super.InitializeBalancing();
}


// Not currently used
/*function PlayerSpawning(controller Player, out byte InTeam)
{
	if (bDisableTTeamFix)
		return;
}*/

singular function PlayerKilled(controller Player)
{
	local int BiggerTeam, Imbalance, i;
	local controller SpectatingPlayer, c;
	local array<ListOrganiser> PlayerList;
	local bool bSwitchedPlayer;

	if (bDisableTTeamFix)
		return;


	// A player is becoming a spectator
	if (Player != none && Player.PlayerReplicationInfo != none && Player.PlayerReplicationInfo.bOnlySpectator)
	{
		// If the player is becoming a spectator then you MUST account for the fact that he has not yet left his team
		SpectatingPlayer = Player;


		// Message that a slot has opened
		if (bAnnounceSlotOpened && Level.Game.NumPlayers + 1 >= Level.Game.MaxPlayers)
			for (c=Level.ControllerList; c!=none; c=c.NextController)
				if (PlayerController(c) != none && c.PlayerReplicationInfo != none && c.PlayerReplicationInfo.bOnlySpectator)
					PlayerController(c).ClientMessage(Class'GameInfo'.static.MakeColorCode(MessageColor)$SlotOpenedMessage);


		if (bSpectateMeansExit)
			PlayerExitingGame(Player);
	}


	// The teams are currently uneven, handle any checks
	if ((bCheckOnDeath || bCheckOnExit) && bTeamsUneven(BiggerTeam, Imbalance, SpectatingPlayer))
	{
		// If the imbalance message is on, broadcast that message
		if (bAnnounceImbalance && !bCurrentlyUneven)
			for (c=Level.ControllerList; c!=none; c=c.NextController)
				if (PlayerController(c) != none)
					PlayerController(c).ClientMessage(Class'GameInfo'.static.MakeColorCode(MessageColor)$ImbalanceMessage);

		bCurrentlyUneven = True;

		// Checks initialized by a person leaving
		if (bCheckOnExit && bPendingBalance && SpectatingPlayer == None)
		{
			if (PlayerExitEvent == EXIT_DeathEvent || PlayerExitEvent == EXIT_CountdownOrDeath)
			{
				// See if you can switch the current player
				if (bCandidatesAvailable)
				{
					for (i=0; i<SwitchCandidateList.Length; i++)
					{
						if (SwitchCandidateList[i] == Player)
						{
							SwitchCandidateList.Remove(i, 1);
							SwitchPlayer(Player);
							bSwitchedPlayer = True;

							break;
						}
					}
				}

				// If this player was switched and the teams are now even then disable the checks
				if (bSwitchedPlayer && !bTeamsUneven(BiggerTeam, Imbalance))
				{
					bCurrentlyUneven = False;
					ResetChecks();

					return;
				}
			}
		}

		// Checks for when a person dies
		if (bCheckOnDeath)
		{
			if (PlayerDeathEvent == DEATH_EvenTeams)
			{
				if (!bForceOnTeamDeath || CheckTeamDeath(Player))
					EvenTeams(BiggerTeam, Imbalance, SpectatingPlayer);

				return;
			}
			else if (PlayerDeathEvent == DEATH_Countdown)
			{
				if (!bPendingBalance && (!bForceOnTeamDeath || CheckTeamDeath(Player)))
				{
					bPendingBalance = True;
					SetTimer(DeathCountdown, false);

					return;
				}
			}
			else if (PlayerDeathEvent == DEATH_DeathEvent || PlayerDeathEvent == DEATH_CountdownOrDeath)
			{
				// First check if the CURRENT player can be switched otherwise setup a pending check (if one isn't already set)

				// If the SwitchCandidateList has not yet been setup then set that up now
				PlayerList = CreateList(BiggerTeam, SpectatingPlayer);
				SwitchCandidateList = OrganizeList(PlayerList, MaxSwitchCandidates);
				bCandidatesAvailable = True;

				// Remove players that are past the JoinTimeLeniancy limit
				for (i=SwitchCandidateList.Length-1; i>Max(MinSwitchCandidates-1, Imbalance-1); i--)
					if (SwitchCandidateList[i] == none || SwitchCandidateList[i].PlayerReplicationInfo.bOnlySpectator
						|| Level.Game.GameReplicationInfo.ElapsedTime - SwitchCandidateList[i].PlayerReplicationInfo.StartTime > JoinTimeLeniancy)
						SwitchCandidateList.Remove(i, 1);

				// See if the current player is in the list and if so, remove him from the list and switch him
				for (i=0; i<SwitchCandidateList.Length; i++)
				{
					if (SwitchCandidateList[i] == Player)
					{
						SwitchCandidateList.Remove(i, 1);
						SwitchPlayer(Player);
						bSwitchedPlayer = True;

						break;
					}
				}

				// If the current player could be switched and the teams are now balanced then disable further checks
				if (bSwitchedPlayer && !bTeamsUneven(BiggerTeam, Imbalance))
				{
					bCurrentlyUneven = False;
					ResetChecks();

					return;
				}

				// The teams are still unbalanced, setup checks
				if ((!bSwitchedPlayer || bTeamsUneven(BiggerTeam, Imbalance)) && !bPendingBalance)
				{
					bPendingBalance = True;

					if (PlayerDeathEvent == DEATH_CountdownOrDeath)
						SetTimer(DeathCountdown, false);

					return;
				}
			}
		}
	}
	else if (bCheckOnDeath || bCheckOnExit)	// The teams are currently EVEN, stop any pending checks
	{
		ResetChecks();
	}
}

// NOTE: The teams seem to become uneven AFTER this function is called, not before
function PlayerExitingGame(controller Player)
{
	local int BiggerTeam, Imbalance, i;
	local array<ListOrganiser> PlayerList;
	local controller c;

	if (bDisableTTeamFix)
		return;


	if (bCheckOnExit)
	{
		// The teams have become uneven, run through the checks
		if (bTeamsUneven(BiggerTeam, Imbalance, Player))
		{
			// If the imbalance message is on, broadcast that message
			if (bAnnounceImbalance && !bCurrentlyUneven)
				for (c=Level.ControllerList; c!=none; c=c.NextController)
					if (PlayerController(c) != none)
						PlayerController(c).ClientMessage(Class'GameInfo'.static.MakeColorCode(MessageColor)$ImbalanceMessage);

			bCurrentlyUneven = True;

			if (PlayerExitEvent == EXIT_EvenTeams)
			{
				if (!bForceOnTeamDeath || CheckTeamDeath(Player))
					EvenTeams(BiggerTeam, Imbalance, Player);

				return;
			}
			else
			{
				if (PlayerExitEvent == EXIT_Countdown || PlayerExitEvent == EXIT_CountdownOrDeath)
				{
					bPendingBalance = True;
					SetTimer(ExitCountdown, false);

					return;
				}

				if (PlayerExitEvent == EXIT_DeathEvent || PlayerExitEvent == EXIT_CountdownOrDeath)
				{
					// Setup the candidates to monitor for death
					PlayerList = CreateList(BiggerTeam, Player);
					SwitchCandidateList = OrganizeList(PlayerList, MaxSwitchCandidates);
					bCandidatesAvailable = True;

					// Remove players that are past the JoinTimeLeniancy limit
					for (i=SwitchCandidateList.Length-1; i>Max(MinSwitchCandidates-1, Imbalance-1); i--)
						if (SwitchCandidateList[i] == none || SwitchCandidateList[i].PlayerReplicationInfo.bOnlySpectator
							|| Level.Game.GameReplicationInfo.ElapsedTime - SwitchCandidateList[i].PlayerReplicationInfo.StartTime > JoinTimeLeniancy)
							SwitchCandidateList.Remove(i, 1);

					bPendingBalance = True;
					return;
				}
			}
		}
		else
		{
			ResetChecks();
		}
	}

	// If the free slot mesage is on, broadcast it to all spectators
	if (bAnnounceSlotOpened && AIController(Player) == none && Level.Game.AtCapacity(False))
		for (c=Level.ControllerList; c!=none; c=c.NextController)
			if (PlayerController(c) != none && c.PlayerReplicationInfo != none && c.PlayerReplicationInfo.bOnlySpectator)
				PlayerController(c).ClientMessage(Class'GameInfo'.static.MakeColorCode(MessageColor)$SlotOpenedMessage);
}

function PlayerJoiningGame(out string Portal, out string Options)
{
	local int iTempInt, iTempInt2, ScoreDifference;
	local string sTempStr;

	// Set new players preferred team to the losing teams
	if (bPreferLosingTeam)
	{
		// First determine the winning team
		ScoreDifference = Level.Game.GameReplicationInfo.Teams[0].Score - Level.Game.GameReplicationInfo.Teams[1].Score;

		if (ScoreDifference < 0)
			ScoreDifference = 0;
		else if (ScoreDifference > 0)
			ScoreDifference = 1;
		else
			ScoreDifference = Rand(1);


		// Apply the selected team to the preffered team option
		iTempInt = InStr(Caps(Options), "?TEAM=");
		sTempStr = Mid(Options, iTempInt + 1);
		iTempInt2 = InStr(sTempStr, "?");

		if (iTempInt2 != -1)
			sTempStr = Left(Options, iTempInt)$"?Team="$ScoreDifference$Mid(sTempStr, iTempInt2);
		else
			sTempStr = Left(Options, iTempInt)$"?Team="$ScoreDifference;

		Options = sTempStr;
	}
	else if (bDisablePreferredTeam) // Remove the preferred team
	{
		iTempInt = InStr(Caps(Options), "?TEAM=");
		sTempStr = Mid(Options, iTempInt + 1);
		iTempInt2 = InStr(sTempStr, "?");

		if (iTempInt2 != -1)
			sTempStr = Left(Options, iTempInt)$Mid(sTempStr, iTempInt2);
		else
			sTempStr = Left(Options, iTempInt);

		Options = sTempStr;
	}
}

function Timer()
{
	local int BiggerTeam, Imbalance;

	if ((bCheckOnExit && (PlayerExitEvent == EXIT_Countdown || PlayerExitEvent == EXIT_CountdownOrDeath))
		|| (bCheckOnDeath && (PlayerDeathEvent == DEATH_Countdown || PlayerDeathEvent == DEATH_CountdownOrDeath)))
	{
		if (bTeamsUneven(BiggerTeam, Imbalance))
			EvenTeams(BiggerTeam, Imbalance);

		ResetChecks();
	}
}


function DisableBalancing()
{
	bDisableTTeamFix = True;
	SaveConfig();

	// Turn off events
	InitializeDefaults();

	if (EventMutator != none)
		EventMutator.InitializeEvents(self);

	if (EventRules != none)
		EventRules.InitializeEvents(self);
	
}

function EnableBalancing()
{
	bDisableTTeamFix = False;
	SaveConfig();

	// (Re)Initialize balancing system
	InitializeBalancing();
}

function ResetChecks()
{
	bPendingBalance = False;
	SetTimer(0, False);

	if (bCandidatesAvailable)
		SwitchCandidateList.Length = 0;
}

function EvenTeams(int BiggerTeam, int PlayerImbalance, optional Controller Leaving)
{
	local int SwitchesNeeded, i, j, iTempInt;
	local array<ListOrganiser> TeamList;
	local array<controller> FinalSwitchList;
	local controller c;
	local bool bContinue;
	local string PlayerMessage;

	// Remove all pending checks
	bCurrentlyUneven = False;
	ResetChecks();


	// First off sort out the number of players we need to switch

	// If true then PlayerImbalance is an odd number..The point in this is we want 3 divided by 2 (i.e. 1.5) rounded off to 1 instead of 2
	if (float(PlayerImbalance) % 2.0 != 0.0)
		SwitchesNeeded = (PlayerImbalance - 1) / 2;
	else
		SwitchesNeeded = PlayerImbalance / 2;


	// Now gather the list of players from the oversized team and find out which ones can be switched

	// This 'groups' the players from the oversized team, the higher-up groups are the groups of people who have been force-switched the least
	TeamList = CreateList(BiggerTeam, Leaving);

	// Organise the list
	FinalSwitchList = OrganizeList(TeamList, SwitchesNeeded);


	// List can sometimes be empty
	if (FinalSwitchList.Length <= 0)
		return;


	// Switch the required players
	for (i=0; i<FinalSwitchList.Length; i++)
	{
		SwitchPlayer(FinalSwitchList[i]);

		// Notify the player that he has been switched
		if (bNotifySwitchedPlayer && PlayerController(FinalSwitchList[i]) != none)
			PlayerController(FinalSwitchList[i]).ClientMessage(Class'GameInfo'.static.MakeColorCode(MessageColor)$SwitchedMessage);
	}

	// Notify all players that the teams have been evened
	if (bAnnounceSwitch)
	{
		// First setup the %p replacer message, if there are multiple players then it will format them like this: "Bob, Dave and Bitchface"
		if (FinalSwitchList.Length > 1)
		{
			iTempInt = InStr(MultipleAnnounceMessage, "%p");

			if (iTempInt != -1)
			{
				for (j=0; j<FinalSwitchList.Length; ++j)
				{
					if (FinalSwitchList[j].PlayerReplicationInfo == none)
						continue;

					// I don't use switches often...
					Switch (FinalSwitchList.Length - j)
					{
						Case 1:
							PlayerMessage = PlayerMessage@FinalSwitchList[j].PlayerReplicationInfo.PlayerName;
							break;

						Case 2:
							PlayerMessage = PlayerMessage@FinalSwitchList[j].PlayerReplicationInfo.PlayerName@"and";
							break;

						default:
							PlayerMessage = PlayerMessage@FinalSwitchList[j].PlayerReplicationInfo.PlayerName$",";
					}
				}

				// Now finalise the message
				PlayerMessage = Left(MultipleAnnounceMessage, iTempInt)$PlayerMessage$Mid(MultipleAnnounceMessage, iTempInt + 2);
			}
			else
			{
				PlayerMessage = AnnounceMessage;
			}
		}
		else if (FinalSwitchList[0].PlayerReplicationInfo != none)
		{
			iTempInt = InStr(AnnounceMessage, "%p");

			if (iTempInt != -1)
				PlayerMessage = Left(AnnounceMessage, iTempInt)$FinalSwitchList[0].PlayerReplicationInfo.PlayerName$Mid(AnnounceMessage, iTempInt + 2);
			else
				PlayerMessage = AnnounceMessage;
		}
		else
		{
			PlayerMessage = AnnounceMessage;
		}

		// Now find the players to send the message to
		for (c=Level.ControllerList; c!=none; c=c.NextController)
		{
			if (PlayerController(c) != none)
			{
				// If you wish to skip sending the announcement to the players being switched, then this checks if the current player is one of them
				if (bSkipSwitchedAnnounce)
				{
					for (i=0; i<FinalSwitchList.Length; ++i)
					{
						if (FinalSwitchList[i] == c)
						{
							bContinue = True;
							break;
						}
					}

					if (bContinue)
					{
						bContinue = False;
						continue;
					}
				}

				// Now send the message
				PlayerController(c).ClientMessage(Class'GameInfo'.static.MakeColorCode(MessageColor)$PlayerMessage);
			}
		}
	}
}

// Gather the list of players from the oversized team and find out which ones can be switched
function array<ListOrganiser> CreateList(int BiggerTeam, optional controller Leaving)
{
	local controller c;
	local int CurNumSwitches;
	local array<ListOrganiser> TeamList;

	for (c=level.ControllerList; c!=none; c=c.NextController)
	{
		if (AIController(c) == none && c.GetTeamNum() == BiggerTeam && c != Leaving && c.PlayerReplicationInfo != none
			&& !c.PlayerReplicationInfo.bOnlySpectator && c.PlayerReplicationInfo.HasFlag == none)
		{
			CurNumSwitches = SearchList(c);

			if (TeamList.Length < CurNumSwitches + 1)
				TeamList.Length = CurNumSwitches + 1;

			// Working with a 2d array here
			TeamList[CurNumSwitches].Players[TeamList[CurNumSwitches].Players.Length] = c;
		}
	}

	return TeamList;
}

function array<Controller> OrganizeList(array<ListOrganiser> TeamList, int SwitchesNeeded)
{
	local array<controller> SwitchList, FinalSwitchList;
	local int i, j, k;

	for (i=0; i<TeamList.Length && FinalSwitchList.Length < SwitchesNeeded; i++)
	{
		if (TeamList[i].Players.Length == 0)
			continue;

		SwitchList.Length = 0;

		// The players are now organised by the number of times they have been switched, now (for each group..i.e. group with 0 switches or 1 switches) sort
		//	the players by the time they have joined (more recent players are higher up in list)
		for (j=0; j<TeamList[i].Players.Length; j++)
		{
			for (k=0; k<SwitchList.Length; k++)
			{
				if (SwitchList[k].PlayerReplicationInfo.StartTime <= TeamList[i].Players[j].PlayerReplicationInfo.StartTime)
				{
					SwitchList.Insert(k, 1);
					SwitchList[k] = TeamList[i].Players[j];

					break;
				}
				else if (k == SwitchList.Length - 1)
					SwitchList[SwitchList.Length] = TeamList[i].Players[j];
			}

			if (SwitchList.Length == 0)
				SwitchList[SwitchList.Length] = TeamList[i].Players[j];
		}

		// This group of players has now been sorted by their time, add them to the FinalSwitchList
		for (j=0; j<SwitchList.Length && FinalSwitchList.Length < SwitchesNeeded; j++)
			FinalSwitchList[FinalSwitchList.Length] = SwitchList[j];
	}

	return FinalSwitchList;
}

// Returns the number of times a certain player has been switched
function int SearchList(controller Player)
{
	local int i;

	for (i=0; i<SwitchedList.Length; i++)
	{
		// Remove entries with missing controllers as those players have most likely left the game
		if (SwitchedList[i].SwitchedPlayer == none)
		{
			SwitchedList.Remove(i, 1);
			i--;

			continue;
		}

		if (SwitchedList[i].SwitchedPlayer == Player)
		{
			return SwitchedList[i].NumSwitches;
		}
	}

	return 0;
}

// Adds a player (or modifies an entry) in the switched players list and switches the player
function SwitchPlayer(controller Player)
{
	local int i;
	local float OldScore, OldDeaths;
	local bool bExistingEntry;

	// Iterate through the SwitchedList to see if player is already added
	for (i=0; i<SwitchedList.Length; i++)
	{
		// Clean the list as you go
		if (SwitchedList[i].SwitchedPlayer == none)
		{
			SwitchedList.Remove(i, 1);
			i--;

			continue;
		}

		if (SwitchedList[i].SwitchedPlayer == Player)
		{
			bExistingEntry = True;
			SwitchedList[i].NumSwitches++;

			break;
		}
	}

	// If the player isn't added yet then add him
	i = SwitchedList.Length; // If you use 'SwitchedList.Length' in the 2 lower lines of code instead of 'i' you'd get some horrible bugs :)
	SwitchedList.Length = SwitchedList.Length + 1;

	SwitchedList[i].SwitchedPlayer = Player;
	SwitchedList[i].NumSwitches++;


	// Now switch the player (TODO: add a message here to notify a player switch from TTF!)
	i = Player.GetTeamNum();

	if (i == 0)
		i = 1;
	else
		i = 0;

	Player.StartSpot = none;

	if (Player.PlayerReplicationInfo.Team != none)
		Player.PlayerReplicationInfo.Team.RemoveFromTeam(Player);

	if (TeamGame(level.game).Teams[i].AddToTeam(Player))
	{
		Level.Game.BroadcastLocalizedMessage(Level.Game.GameMessageClass, 3, Player.PlayerReplicationInfo, None, TeamGame(level.game).Teams[i]);

		if (ONSPlayerReplicationInfo(Player.PlayerReplicationInfo) != none)
		{
			ONSPlayerReplicationInfo(Player.PlayerReplicationInfo).StartCore = None;
			ONSPlayerReplicationInfo(Player.PlayerReplicationInfo).TemporaryStartCore = None;
		}

		OldScore = Player.PlayerReplicationInfo.Score;
		OldDeaths = Player.PlayerReplicationInfo.Deaths;

		if (Player.Pawn != none)
			Player.Pawn.PlayerChangedTeam();

		Player.PlayerReplicationInfo.Score = OldScore;
		Player.PlayerReplicationInfo.Deaths = OldDeaths;
	}
}

// Returns true when everyone on a whole team is dead
function bool CheckTeamDeath(optional controller AlreadyDead)
{
	local controller c;
	local bool bTeam0Alive, bTeam1Alive;

	for (c=Level.ControllerList; c!=none; c=c.NextController)
	{
		if (c == AlreadyDead)
			continue;

		if (c.GetTeamNum() == 0)
		{
			if (!c.IsInState('Dead') && !c.PlayerReplicationInfo.bOutOfLives)
				bTeam0Alive = True;
		}
		else if (c.GetTeamNum() == 1)
		{
			if (!c.IsInState('Dead') && !c.PlayerReplicationInfo.bOutOfLives)
				bTeam1Alive = True;
		}
	}

	return !bTeam0Alive || !bTeam1Alive;
}

/*
function TakeCommand(string Command, PlayerController Sender)
{
	local controller c;
	local array<PlayerShuffleData> Players, SortedPlayers, CurTeam;
	local PlayerShuffleData TempData;
	local int TeamCount[2];
	local int iTempInt, i, j, k, CurNum;

	local float OverallPPHAvg;
	local float TotalPPH;
	local float PPHDiff, CurDiff;

	local int SwitchList[2];
	local float BestErrorCorrection;

	if (Command ~= "TTF_ShuffleTeams")
	{
		TeamCount[0] = -100;
		TeamCount[1] = -100;

		// Gather the playerlist for players in the game longer than 2 minutes
		for (c=level.ControllerList; c!=none; c=c.NextController)
		{
			if (AIController(c) == none && c.PlayerReplicationInfo != none && !c.PlayerReplicationInfo.bOnlySpectator && c.PlayerReplicationInfo.HasFlag == none
				&& Level.TimeSeconds - c.PlayerReplicationInfo.StartTime > 120.0)
			{
				iTempInt = c.GetTeamNum();

				if (TeamCount[iTempInt] == -100)
					TeamCount[iTempInt] = c.PlayerReplicationInfo.Team.Size;

				TeamCount[iTempInt] -= 1;

				Players.Length = Players.Length + 1;

				Players[Players.Length-1].Controller = c;
				Players[Players.Length-1].PPH = c.PlayerReplicationInfo.Score / ((Level.TimeSeconds - C.PlayerReplicationInfo.StartTime) / 3600.0);

				TotalPPH += Players[Players.Length-1].PPH;
			}
		}

		if (TeamCount[0] == -100)
			TeamCount[0] = 0;

		if (TeamCount[1] == -100)
			TeamCount[1] = 0;

		// Not a nice piece of code :( TeamCount represents the number of people on each team who have NOT had their PPH added to TotalPPH...so add in the avg. count in their place
		//	the purpose of this is to try and keep the PPH reading 'smooth'...players who have been in the game less than two minutes 'might' have a disproportionately large PPH
		OverallPPHAvg = TotalPPH / float(Players.Length);
		TotalPPH += float(TeamCount[0] + TeamCount[1]) * OverallPPHAvg; //(float(TeamCount[0]) * OverallPPHAvg) + (float(TeamCount[1]) * OverallPPHAvg);
		OverallPPHAvg = TotalPPH / (float(Players.Length) + TeamCount[0] + TeamCount[1]);

		// No list
		if (Players.Length < 2)
		{
			if (Level.TimeSeconds < 120.0)
				Sender.ClientMessage(Class'GameInfo'.static.MakeColorCode(MessageColor)$"TitanTeamFix: This command can only be used after two minutes of game time");
			else
				Sender.ClientMessage(Class'GameInfo'.static.MakeColorCode(MessageColor)$"TitanTeamFix: Not enough players found active for more than two minutes");

			return;
		}


		// Sorting loops can be confusing no matter how simple they are, so assume you fucked up everything here
		SortedPlayers.Length = Players.Length;

		// First sort the list by PPH highest-to-lowest
		for (i=0; i<SortedPlayers.Length; ++i)
		{
			CurNum = -1;

			for (j=0; j<Players.Length; ++j)
				if (CurNum == -1 || Players[j].PPH > Players[CurNum].PPH)
					CurNum = j;

			SortedPlayers[i] = Players[CurNum];
			Players.Remove(CurNum, 1);
		}

		// Now grab every second player in that list and put them into one of the team lists
		for (i=0; i<SortedPlayers.Length; i++)
		{
			CurTeam.Length = CurTeam.Length + 1;
			CurTeam[CurTeam.Length-1] = SortedPlayers[i];

			PPHDiff += SortedPlayers[i].PPH;

			// This is effectively i++ aswel....SortedList will be left as the second team list
			SortedPlayers.Remove(i, 1);
		}


		PPHDiff -= TotalPPH * 0.5;

		// If the PPHDiff is off by more than 5%, then try to perform extra balancing checks (up to a maximum of approximately 1024 loop repetitions..which is possible max of 1200)
		//if (Abs(PPHDiff) > TotalPPH * 0.025)
		for (k=0; Abs(PPHDiff) > TotalPPH * 0.025 && SortedPlayers.Length * CurTeam.Length * k < 1024; ++k)
		{
			// Begin the most ugly sorting algorithm EVER (I wont be suprised if this triggers the infinite loop check)
			for (i=0; i<SortedPlayers.Length; ++i)
			{
				for (j=0; j<CurTeam.Length; ++j)
				{
					CurDiff = CurTeam[j].PPH - SortedPlayers[i].PPH;

					if (CurDiff < 0.0 && PPHDiff > 0.0 || CurDiff > 0.0 && PPHDiff < 0.0)
						continue;

					CurDiff = Abs(Abs(CurDiff) - Abs(PPHDiff));

					if (CurDiff < BestErrorCorrection)
					{
						BestErrorCorrection = CurDiff;

						// SwitchList 0 is the CurTeam element to switch
						SwitchList[0] = j;
						SwitchList[1] = i;
					}
				}
			}

			// Switch the two selected players
			TempData = CurTeam[SwitchList[0]];
			CurTeam[SwitchList[0]] = SortedPlayers[SwitchList[1]];
			SortedPlayers[SwitchList[1]] = TempData;
		}


		// Now go about sorting the lists
		for (i=0; i<CurTeam.Length; ++i)
			if (CurTeam[i].Controller.GetTeamNum() != 0)
				SwitchPlayer(CurTeam[i].Controller);

		for (i=0; i<SortedPlayers.Length; ++i)
			if (SortedPlayers[i].Controller.GetTeamNum() != 1)
				SwitchPlayer(SortedPlayers[i].Controller);
	}
}
*/

defaultproperties
{
	bCheckOnExit=True
	bSpectateMeansExit=True
	PlayerExitEvent=EXIT_Countdown
	ExitCountdown=15

	bCheckOnDeath=False
	PlayerDeathEvent=DEATH_CountdownOrDeath
	DeathCountdown=15

	JoinTimeLeniancy=120
	MinSwitchCandidates=1
	MaxSwitchCandidates=5

	bDisablePreferredTeam=True
	bPreferLosingTeam=True
	bDisableTTeamFix=False
	bForceOnTeamDeath=False

	bNotifySwitchedPlayer=True
	SwitchedMessage="TitanTeamFix: You have been switched to balance the teams"
	bAnnounceSwitch=True
	bSkipSwitchedAnnounce=True
	AnnounceMessage="TitanTeamFix: %p has been switched to balance the teams"
	MultipleAnnounceMessage="TitanTeamFix: %p have been switched to balance the teams"
	bAnnounceImbalance=True
	ImbalanceMessage="TitanTeamFix: The teams have become uneven"
	bAnnounceSlotOpened=True
	SlotOpenedMessage="TitanTeamFix: A slot has opened, another player can join the game"
	MessageColor=(R=145,G=135,B=181)

	bNeedPreSpawnEvent=False
	bNeedKilledEvent=False
	bNeedExitingEvent=False

	bLoadConfigProfile=False
	bPrefixGameToProfile=False
	ConfigProfileClass=Class'TTeamFixConfigProfile'
}