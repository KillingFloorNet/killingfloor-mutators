//============================================================
// TTeamFixStatConfigProfile.uc		- Configuration profiles specifically for TTeamFixStatsBalance
//============================================================
//	TitanTeamFix
//		+ Coded by Shambler (Shambler@OldUnreal.com or Shambler__@Hotmail.com)
//		- A modular team balancing mutator initially coded for the Titan servers
//			http://ut2004.titaninternet.co.uk/
//
//============================================================
//
// This profile class is only compatable with the 
// TTeamFixStatsBalance balancing class.
//
//============================================================
Class TTeamFixStatConfigProfile extends TTeamFixConfigProfile
	PerObjectConfig
	config(TitanTeamFix);

var config string	SQLBalanceQuery;


var config string	SQLServerIP;
var config bool		bResolveIPString;
var config int		SQLServerPort;
var config string	SQLUser;
var config string	SQLPassword;
var config string	SQLDatabase;

var config int		SQLLinkPort;

var config string	SQLTableName;
var config bool		bPrefixGameToTable;
var config bool		bPrefixProfileToTable;

var config bool		bAutoCreateDatabase;
var config bool		bAutoCreateTable;
var config bool		bCurrentDatabaseExists;
var config string	LastDatabase;


function TransferProperties(TTeamFixGeneric Owner)
{
	local TTeamFixStatsBalance CurOwner;

	CurOwner = TTeamFixStatsBalance(Owner);

	Super.TransferProperties(Owner);


	CurOwner.SQLBalanceQuery		= SQLBalanceQuery;
	CurOwner.SQLServerIP		= SQLServerIP;
	CurOwner.bResolveIPString		= bResolveIPString;
	CurOwner.SQLServerPort		= SQLServerPort;
	CurOwner.SQLUser			= SQLUser;
	CurOwner.SQLPassword		= SQLPassword;
	CurOwner.SQLDatabase		= SQLDatabase;
	CurOwner.SQLLinkPort		= SQLLinkPort;
	CurOwner.SQLTableName		= SQLTableName;
	CurOwner.bPrefixGameToTable	= bPrefixGameToTable;
	CurOwner.bPrefixProfileToTable	= bPrefixProfileToTable;
	CurOwner.bAutoCreateDatabase	= bAutoCreateDatabase;
	CurOwner.bAutoCreateTable		= bAutoCreateTable;
	CurOwner.bCurrentDatabaseExists	= bCurrentDatabaseExists;
	CurOwner.LastDatabase		= LastDatabase;
}

function SaveProperties(TTeamFixGeneric Owner)
{
	local TTeamFixStatsBalance CurOwner;

	CurOwner = TTeamFixStatsBalance(Owner);


	// Set these BEFORE calling super, because the original function contains SaveConfig()
	SQLBalanceQuery		= CurOwner.SQLBalanceQuery;
	SQLServerIP		= CurOwner.SQLServerIP;
	bResolveIPString	= CurOwner.bResolveIPString;
	SQLServerPort		= CurOwner.SQLServerPort;
	SQLUser			= CurOwner.SQLUser;
	SQLPassword		= CurOwner.SQLPassword;
	SQLDatabase		= CurOwner.SQLDatabase;
	SQLLinkPort		= CurOwner.SQLLinkPort;
	SQLTableName		= CurOwner.SQLTableName;
	bPrefixGameToTable	= CurOwner.bPrefixGameToTable;
	bPrefixProfileToTable	= CurOwner.bPrefixProfileToTable;
	bAutoCreateDatabase	= CurOwner.bAutoCreateDatabase;
	bAutoCreateTable	= CurOwner.bAutoCreateTable;
	bCurrentDatabaseExists	= CurOwner.bCurrentDatabaseExists;
	LastDatabase		= CurOwner.LastDatabase;

	Super.SaveProperties(Owner);
}

defaultproperties
{
	// TTeamFixConfigProfile
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



	// TTeamFixStatConfigProfile
	SQLBalanceQuery="select GUID,(PPPG+(RecentPPPG/PPPG)-1.0+(select if(GamesPlayed>10,((GamesWon/GamesPlayed)-0.5)*2.0,0.0))*0.5)from %t where(%g)"

	bResolveIPString=False
	SQLDatabase="TitanTeamFix"

	SQLLinkPort=0

	SQLTableName="Players"
	bPrefixGameToTable=True
	bPrefixProfileToTable=True

	bAutoCreateDatabase=True
	bAutoCreateTable=True
	bCurrentDatabaseExists=False
	LastDatabase=""
}