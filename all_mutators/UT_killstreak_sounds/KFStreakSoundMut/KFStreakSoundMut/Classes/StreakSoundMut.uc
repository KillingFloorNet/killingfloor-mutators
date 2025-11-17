class StreakSoundMut extends Mutator
	config(StreakSoundMut);

#exec AUDIO IMPORT FILE="Sounds\prepare.wav" NAME="Prepare" GROUP="FX"

var SoundGameRules RulesMod;
var int PreparedWave;
var config int RampageKills,KillingSpreeKills,MonsterKillKills,UnstoppableKills,UltraKillKills,GodLikeKills,WickedSickKills,LudicrousKills,HolyShitKills,MultiKillKills;
var config float MultiKillTime;
var config bool bActivateHeadshot, bActivateHumiliation;
var string SoundMutGroup;

function PostBeginPlay()
{
	local KFGameType KF;
	
	KF = KFGameType(Level.Game);
	
	if(KF == None)
		Destroy();

	if( RulesMod==None )
		RulesMod = Spawn(Class'SoundGameRules');
	AddToPackageMap("KFStreakSoundMut");

	setTimer(1.f,true);
}

function Timer()
{
	local KFGameType KF;
	local Controller C;

	KF = KFGameType(Level.Game);
	if((KF.bWaveInProgress || KF.bWaveBossInProgress) && KF.WaveNum > PreparedWave)
	{
		PreparedWave = KF.WaveNum;
		for( C=Level.ControllerList; C!=None; C=C.nextController )
		{
			if( C.bIsPlayer && PlayerController(C)!=None )
			{
				PlayerController(C).ClientPlaySound(Sound'KFStreakSoundMut.Prepare',true,2.f,SLOT_None);
				PlayerController(C).ReceiveLocalizedMessage(Class'StreakMessage',10);
			}
		}
	}
}

static function FillPlayInfo(PlayInfo PlayInfo)
{	
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.SoundMutGroup,"RampageKills","Rampage Kills",1,0, "Text", "4;0:1000");
	PlayInfo.AddSetting(default.SoundMutGroup,"KillingSpreeKills","Killing Spree Kills",1,0, "Text", "4;0:1000");
	PlayInfo.AddSetting(default.SoundMutGroup,"UnstoppableKills","Unstoppable Kills",1,0, "Text", "4;0:1000");
	PlayInfo.AddSetting(default.SoundMutGroup,"UltraKillKills","Ultrakill Kills",1,0, "Text", "4;0:1000");
	PlayInfo.AddSetting(default.SoundMutGroup,"GodLikeKills","Godlike Kills",1,0, "Text", "4;0:1000");
	PlayInfo.AddSetting(default.SoundMutGroup,"WickedSickKills","Wicked Sick Kills",1,0, "Text", "4;0:1000");
	PlayInfo.AddSetting(default.SoundMutGroup,"LudicrousKills","Ludicrous Kills",1,0, "Text", "4;0:1000");
	PlayInfo.AddSetting(default.SoundMutGroup,"HolyShitKills","Holy Shit Kills",1,0, "Text", "4;0:1000");
	PlayInfo.AddSetting(default.SoundMutGroup,"MultiKillKills","Multikill Kills",1,0, "Text", "4;0:1000");
	PlayInfo.AddSetting(default.SoundMutGroup,"MultiKillTime","Multikill Time",1,0, "Text", "8;0.00:1000");
	PlayInfo.AddSetting(default.SoundMutGroup,"bActivateHeadshot","Headshot Sound",1,0, "Check");
	PlayInfo.AddSetting(default.SoundMutGroup,"bActivateHumiliation","Humiliation Sound",1,0, "Check");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "RampageKills": 			return "Kills needed for Rampage Sound";
		case "KillingSpreeKills": 		return "Kills needed for Killing Spree Sound";
		case "UnstoppableKills": 		return "Kills needed for Unstoppable Sound";
		case "UltraKillKills": 			return "Kills needed for Ultrakill Sound";
		case "GodLikeKills": 			return "Kills needed for Godlike Sound";
		case "WickedSickKills": 		return "Kills needed for Wicked Sick Sound";
		case "LudicrousKills": 			return "Kills needed for Ludicrous Sound";
		case "HolyShitKills": 			return "Kills needed for Holy Shit Sound";
		case "MultiKillKills": 			return "Kills needed for Multikill Sound";
		case "MultiKillTime": 			return "Interval for a Multikill";
		case "bActivateHeadshot": 		return "Activate Custom Sound for Headshots";
		case "bActivateHumiliation": 	return "Activate Custom Sound for Knife-Kills";
	}
	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     PreparedWave=-1
     RampageKills=10
     KillingSpreeKills=15
     MonsterKillKills=40
     UnstoppableKills=60
     UltraKillKills=80
     GodLikeKills=100
     WickedSickKills=120
     LudicrousKills=150
     HolyShitKills=200
     MultiKillKills=3
     MultiKillTime=1.000000
     bActivateHeadshot=True
     bActivateHumiliation=True
     SoundMutGroup="Streak Sounds"
     GroupName="KF-StreakSound"
     FriendlyName="Killing Streak Sounds"
     Description="Plays sounds for killing streaks"
}
