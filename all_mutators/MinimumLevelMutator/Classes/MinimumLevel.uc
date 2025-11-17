class MinimumLevel extends Mutator
	Config(MinimumLevel);

struct WhiteListEntry {
	var String SteamID64;
	var String Name;
};

var config array<WhiteListEntry> WhiteList;
var config float UpdateFrequency;
var config int LevelLimit;
var config color TextColour, HighlightColour;
var config string KickReason, KickMessage, LobbyMessage, TraderMessage;
var string TextCode, HighlightCode, TempLobbyMessage, TempTraderMessage, TempKickReason, TempKickMessage;

static function FillPlayInfo(PlayInfo PlayInfo) {
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting("Minimum Level", "LevelLimit",		"Level limit",			0, 1,	"Text",		"1;0:6");
	PlayInfo.AddSetting("Minimum Level", "LobbyMessage",		"Lobby message",		0, 2,	"Text",		"256");
	PlayInfo.AddSetting("Minimum Level", "TraderMessage",		"Trader message",		0, 3,	"Text",		"256");
	PlayInfo.AddSetting("Minimum Level", "KickMessage",		"Kick message",			0, 4,	"Text",		"256");
	PlayInfo.AddSetting("Minimum Level", "KickReason",		"Kick reason",			0, 5,	"Text",		"256");
	PlayInfo.AddSetting("Minimum Level", "UpdateFrequency",		"Update frequency",		0, 6,	"Text",		"2;1:30");
}

static event string GetDescriptionText(string Property) {
	switch (Property) {
		case "LevelLimit":
			return "The minimum perk level allowed.";
		case "LobbyMessage":
			return "The message sent to players below the perk level limit in lobby. %level% gets replaced with level limit.";
		case "TraderMessage":
			return "The message sent to players below the perk level limit during trader phases. %level% gets replaced with level limit and %time% gets replaced with remaining time.";
		case "KickReason":
			return "The kick reason gets sent to the kicked player. %level% gets replaced with the perk level limit.";
		case "KickMessage":
			return "The kick message gets sent to everyone notifying them about the kick. %name% gets replaced with player's name and %level% with the perk level limit.";
		case "UpdateFrequency":
			return "How fast should the mutator check for late joiners, in seconds.";
		default:
			return Super.GetDescriptionText(Property);
	}
}

function Timer() {
	local Controller C;
	local PlayerController PC;
	local int WaveNum, TimeLeft;
	local string SteamID64;
	WaveNum = KFGameType(Level.Game).WaveNum;
	TimeLeft = KFGameType(Level.Game).WaveCountDown;
	for (C = Level.ControllerList; C != None; C = C.NextController) {
		PC = PlayerController(C);
		if (PC != None && PC.bIsPlayer && PC.PlayerReplicationInfo != None && !PC.PlayerReplicationInfo.bOnlySpectator && !PC.PlayerReplicationInfo.bBot && !PC.PlayerReplicationInfo.bAdmin && KFPlayerReplicationInfo(PC.PlayerReplicationInfo).ClientVeteranSkill != None && KFPlayerReplicationInfo(PC.PlayerReplicationInfo).ClientVeteranSkillLevel < LevelLimit) {
			SteamID64 = PC.PlayerReplicationInfo.SteamStatsAndAchievements.GetSteamUserID();
			if (WhiteListCheck(SteamID64))
				continue;
			else if (WaveNum == 0 && TimeLeft == 15)
				PlayerController(C).TeamMessage(None, TempLobbyMessage, 'MinimumLevel');
			else if (TimeLeft > 5 && KFPlayerReplicationInfo(PC.PlayerReplicationInfo).PlayerHealth > 0)
				PlayerController(C).TeamMessage(None, Repl(TempTraderMessage, "%time%", HighlightCode$TimeLeft - 5$TextCode), 'MinimumLevel');
			else if (KFPlayerReplicationInfo(PC.PlayerReplicationInfo).PlayerHealth > 0) {
				Level.Game.AccessControl.KickPlayer(PC);
				PC.ClientNetworkMessage("AC_Kicked", TempKickReason);
				SendMessage(TextCode$Repl(TempKickMessage, "%name%", HighlightCode$PC.PlayerReplicationInfo.PlayerName$TextCode));
			}
		}
	}
}

function bool WhiteListCheck(string SteamID64) {
	local int i;
	for (i = 0; i < default.WhiteList.Length; i++)
		if (default.WhiteList[i].SteamID64 == SteamID64)
			return True;
	return False;
}

function SendMessage(string Message) {
	local controller C;
	for (C = Level.ControllerList; C != None; C = C.nextController) {
		if (C.IsA('PlayerController')) {
			if (C.PlayerReplicationInfo.PlayerName ~= "WebAdmin" && C.PlayerReplicationInfo.PlayerID == 0)
				PlayerController(C).TeamMessage(None, Repl(Repl(Message, TextCode, ""), HighlightCode, ""), 'MinimumLevel');
			else
				PlayerController(C).TeamMessage(None, Message, 'MinimumLevel');
		}
	}
}

function PostBeginPlay() {
	local GameRules GR;
	Super.PostBeginPlay();
	GR = spawn(class'MinimumLevelGameRules');
	MinimumLevelGameRules(GR).ParentMutator = Self;
	if (Level.Game.GameRulesModifiers == None)
		Level.Game.GameRulesModifiers = GR;
	else Level.Game.GameRulesModifiers.AddGameRules(GR);
	TextCode = class'Engine.GameInfo'.static.MakeColorCode(TextColour);
	HighlightCode = class'Engine.GameInfo'.static.MakeColorCode(HighlightColour);
	TempLobbyMessage = TextCode$Repl(LobbyMessage, "%level%", HighlightCode$LevelLimit$TextCode);
	TempTraderMessage = TextCode$Repl(TraderMessage, "%level%", HighlightCode$LevelLimit$TextCode);
	TempKickReason = TextCode$Repl(KickReason, "%level%", HighlightCode$LevelLimit$TextCode);
	TempKickMessage = TextCode$Repl(KickMessage, "%level%", HighlightCode$LevelLimit$TextCode);
	SetTimer(UpdateFrequency, True);
}

defaultproperties {
	LevelLimit=3
	UpdateFrequency=3.0
	LobbyMessage="Your perk level is below %level%, change to a higher level perk before the game begins."
	TraderMessage="Your perk level is below %level%, change to a higher level perk. You have %time% seconds."
	KickReason="You need to use a perk with a level %level% or higher."
	KickMessage="%name% was kicked for using a perk with a level below %level%."
	TextColour=(B=255,G=255,R=255,A=255)
	HighlightColour=(B=0,G=0,R=255,A=255)
	GroupName="KF-MinimumLevel"
	FriendlyName="Minimum Level"
	Description="Kicks players who join after a set wave."
}
