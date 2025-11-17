class TimedResurrectionMut extends Mutator
	config(TimedResurrectionMut);
	
var() config bool timedResurrectionEnabled;
var() config int timedResurrectionPeriod;
var globalconfig color MsgColor;

event PreBeginPlay()
{
	if(timedResurrectionEnabled) 
		SetTimer(timedResurrectionPeriod, true);
	SaveConfig();
}

function Timer()
{
	local Controller C;
	
	for(C = Level.ControllerList; C != None; C = C.nextController)
	{
		if(C.PlayerReplicationInfo.PlayerID > 0)
			ReSpawnRoutine(PlayerController(C));
	}
}

function ReSpawnRoutine(PlayerController C)
{
	local int waveMons;
	//local color msgColor;
	
	if(C.PlayerReplicationInfo != None && !C.PlayerReplicationInfo.bOnlySpectator && C.PlayerReplicationInfo.bOutOfLives && bWaveInProgress)
	{
		C.ClearProgressMessages();
		C.SetProgressTime(5);
		C.SetProgressMessage(0, "You will be respawned in 30 sec", MsgColor);
		//Level.Game.Broadcast(None, Msg);
		log(">>> Broadcast respawn");
		
		waveMons = KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonsters;
		log(">>> Monsters before: " $ waveMons);
		waveMons += 10;
		KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonsters = waveMons;
		log(">>> Monsters after: " $ KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonsters);
		
		Level.Game.Disable('Timer');
		C.PlayerReplicationInfo.bOutOfLives = false;
		C.PlayerReplicationInfo.NumLives = 0;
		C.PlayerReplicationInfo.Score = Max(KFGameType(Level.Game).MinRespawnCash, int(C.PlayerReplicationInfo.Score));
		C.GotoState('PlayerWaiting');
		C.SetViewTarget(C);
		C.ClientSetBehindView(false);
		C.bBehindView = False;
		C.ClientSetViewTarget(C.Pawn);
		Invasion(Level.Game).bWaveInProgress = false;
		C.ServerReStartPlayer();
		Invasion(Level.Game).bWaveInProgress = true;
		Level.Game.Enable('Timer');
		//C.ClientMessage(MSG_ReSpawned);
	}
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.RulesGroup, "timedResurrectionEnabled", "TimedResurrection Enabled", 1, 0, "Check");
	PlayInfo.AddSetting(default.RulesGroup, "timedResurrectionPeriod", "TimedResurrection Period", 1, 1,"Text");
}

static function string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "timedResurrectionEnabled":
			return "Is timed resurrection enabled?";
		case "timedResurrectionPeriod":
			return "Timer time period";
	}
	return "";
}

defaultproperties
{
	timedResurrectionEnabled=true
	timedResurrectionPeriod=30
	MsgColor=(G=255,R=255,A=127)
	bAddToServerPackages=True
	GroupName="TimedResurrectionMut"
	FriendlyName="TimedResurrectionMut"
	Description="Resurrects you each N seconds"
}