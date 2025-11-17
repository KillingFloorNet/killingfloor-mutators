//============================================================
// TTeamFixConfigProfile.uc		- An object for storing multiple configuration profiles
//============================================================
//	TitanTeamFix
//		+ Coded by Shambler (Shambler@OldUnreal.com or Shambler__@Hotmail.com)
//		- A modular team balancing mutator initially coded for the Titan servers
//			http://ut2004.titaninternet.co.uk/
//
//============================================================
//
// This class stores configuration profiles and allows admins
// to specify a seperate name for each profile.
//
// This profile class is only compatable with the 
// TTeamFixGeneric balancing class.
//
//============================================================
class TTeamFixConfigProfile extends Object
	PerObjectConfig
	config(TitanTeamFix);

var config bool bCheckOnExit;
var config bool bSpectateMeansExit;
var config TTeamFixGeneric.ExitEvent PlayerExitEvent;
var config int ExitCountdown;
var config bool bCheckOnDeath;
var config TTeamFixGeneric.DeathEvent PlayerDeathEvent;
var config int DeathCountdown;
var config bool bForceOnTeamDeath;
var config int JoinTimeLeniancy;
var config int MinSwitchCandidates;
var config int MaxSwitchCandidates;
var config bool bNotifySwitchedPlayer;
var config string SwitchedMessage;
var config bool bAnnounceSwitch;
var config bool bSkipSwitchedAnnounce;
var config string AnnounceMessage;
var config string MultipleAnnounceMessage;
var config bool bAnnounceImbalance;
var config string ImbalanceMessage;
var config bool bAnnounceSlotOpened;
var config string SlotOpenedMessage;
var config color MessageColor;
var config bool bDisableTTeamFix;
var config bool bDisablePreferredTeam;
var config bool bPreferLosingTeam;

function TransferProperties(TTeamFixGeneric Owner)
{
	Owner.bCheckOnExit		= bCheckOnExit;
	Owner.bSpectateMeansExit	= bSpectateMeansExit;
	Owner.PlayerExitEvent		= PlayerExitEvent;
	Owner.ExitCountdown		= ExitCountdown;
	Owner.bCheckOnDeath		= bCheckOnDeath;
	Owner.PlayerDeathEvent		= PlayerDeathEvent;
	Owner.DeathCountdown		= DeathCountdown;
	Owner.bForceOnTeamDeath		= bForceOnTeamDeath;
	Owner.JoinTimeLeniancy		= JoinTimeLeniancy;
	Owner.MinSwitchCandidates	= MinSwitchCandidates;
	Owner.MaxSwitchCandidates	= MaxSwitchCandidates;
	Owner.bNotifySwitchedPlayer	= bNotifySwitchedPlayer;
	Owner.SwitchedMessage		= SwitchedMessage;
	Owner.bAnnounceSwitch		= bAnnounceSwitch;
	Owner.bSkipSwitchedAnnounce	= bSkipSwitchedAnnounce;
	Owner.AnnounceMessage		= AnnounceMessage;
	Owner.MultipleAnnounceMessage	= MultipleAnnounceMessage;
	Owner.bAnnounceImbalance	= bAnnounceImbalance;
	Owner.ImbalanceMessage		= ImbalanceMessage;
	Owner.bAnnounceSlotOpened	= bAnnounceSlotOpened;
	Owner.SlotOpenedMessage		= SlotOpenedMessage;
	Owner.MessageColor		= MessageColor;
	Owner.bDisableTTeamFix		= bDisableTTeamFix;
	Owner.bDisablePreferredTeam	= bDisablePreferredTeam;
	Owner.bPreferLosingTeam		= bPreferLosingTeam;
}

function SaveProperties(TTeamFixGeneric Owner)
{
	bCheckOnExit		= Owner.bCheckOnExit;
	bSpectateMeansExit	= Owner.bSpectateMeansExit;
	PlayerExitEvent		= Owner.PlayerExitEvent;
	ExitCountdown		= Owner.ExitCountdown;
	bCheckOnDeath		= Owner.bCheckOnDeath;
	PlayerDeathEvent	= Owner.PlayerDeathEvent;
	DeathCountdown		= Owner.DeathCountdown;
	bForceOnTeamDeath	= Owner.bForceOnTeamDeath;
	JoinTimeLeniancy	= Owner.JoinTimeLeniancy;
	MinSwitchCandidates	= Owner.MinSwitchCandidates;
	MaxSwitchCandidates	= Owner.MaxSwitchCandidates;
	bNotifySwitchedPlayer	= Owner.bNotifySwitchedPlayer;
	SwitchedMessage		= Owner.SwitchedMessage;
	bAnnounceSwitch		= Owner.bAnnounceSwitch;
	bSkipSwitchedAnnounce	= Owner.bSkipSwitchedAnnounce;
	AnnounceMessage		= Owner.AnnounceMessage;
	MultipleAnnounceMessage	= Owner.MultipleAnnounceMessage;
	bAnnounceImbalance	= Owner.bAnnounceImbalance;
	ImbalanceMessage	= Owner.ImbalanceMessage;
	bAnnounceSlotOpened	= Owner.bAnnounceSlotOpened;
	SlotOpenedMessage	= Owner.SlotOpenedMessage;
	MessageColor		= Owner.MessageColor;
	bDisableTTeamFix	= Owner.bDisableTTeamFix;
	bDisablePreferredTeam	= Owner.bDisablePreferredTeam;
	bPreferLosingTeam	= Owner.bPreferLosingTeam;

	SaveConfig();
}

defaultproperties
{
	// REMEMBER: If you update a default property here, make sure you do it in ALL OTHER TTeamFixConfigProfile subclasses too!

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
}