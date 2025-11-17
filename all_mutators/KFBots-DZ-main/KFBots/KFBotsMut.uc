// Written by Marco
Class KFBotsMut extends Mutator
	Config(KFBots);

// #ifdef WITH_SENTRY_BOT
	// #exec obj load file="Doom3KFBeta4.u"
// #endif

var() config array<string> BotPerks,BotChars;
var() config int NumBots,NonPerkIndex;
var() config int MaxVeteranLevel,MinVeteranLevel;
var() config float BotAmmoCostScale,BotWeaponCostScale,BotArmorCostScale;
var DZ_GameType KF;
var float NextTraderMsg,NextYellTime;
var array< class<KFVeterancyTypes> > LoadedSkills;
var array< class<Pickup> > ItemForSale;
var array<RosterEntry> BotRoosters;
var bool bDoPendingWelcome;
var() config bool bUseCustomChars;

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.RulesGroup, "NumBots", "Number Bots", 0, 0, "Text",   "3;0:64");
	PlayInfo.AddSetting(default.RulesGroup, "MaxVeteranLevel", "Max Bot Vet Level", 0, 0, "Text",   "3;0:255");
	PlayInfo.AddSetting(default.RulesGroup, "MinVeteranLevel", "Min Bot Vet Level", 0, 0, "Text",   "3;0:255");
	PlayInfo.AddSetting(default.RulesGroup, "bUseCustomChars", "Use Custom Chars",  0, 0, "Check");
	PlayInfo.AddSetting(default.RulesGroup,"BotAmmoCostScale", "Ammo Cost Scale", 0,0, "Text","8;0.0:2.0");
	PlayInfo.AddSetting(default.RulesGroup,"BotWeaponCostScale", "Weapon Cost Scale", 0,0, "Text","8;0.0:2.0");
	PlayInfo.AddSetting(default.RulesGroup,"BotArmorCostScale", "Armor Cost Scale", 0,0, "Text","8;0.0:2.0");
}

function Mutate(string MutateString, PlayerController Sender)
{
	local KFInvBots NewBot;
	local RosterEntry Chosen;
	local UnrealTeamInfo BotTeam;

	if (MutateString == "addbot" && (Sender.PlayerReplicationInfo.bAdmin || Sender.PlayerReplicationInfo.bSilentAdmin || Viewport(Sender.Player)!=None))
	{
	BotTeam = KF.GetBotTeam();
	if( BotRoosters.Length>0 )
		Chosen = PickCustomBot();
	if( Chosen==None )
		Chosen = BotTeam.ChooseBotClass("");

	if( Chosen.PawnClass == None )
		Chosen.Init(); //amb
	NewBot = Spawn(class'KFInvBots');

	if ( NewBot==None )
		return;

	InitializeBot(NewBot,BotTeam,Chosen);

	// Decide if bot should be a veteran.
	if ( LoadedSkills.Length > 0 && KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo) != None )
	{
		KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo).ClientVeteranSkill = LoadedSkills[Rand(LoadedSkills.Length)];
		if( MinVeteranLevel==MaxVeteranLevel )
			KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo).ClientVeteranSkillLevel = MaxVeteranLevel;
		else KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo).ClientVeteranSkillLevel = MinVeteranLevel+Rand(MaxVeteranLevel+1-MinVeteranLevel);
	}

	NewBot.Mute = Self;
	NewBot.PlayerReplicationInfo.Score = KF.StartingCash;
	NewBot.PlayerReplicationInfo.PlayerID = KF.CurrentID++;
	NewBot.Skill = 9;

//	KF.NumBots++;
	if ( Level.NetMode == NM_Standalone ) KF.RestartPlayer(NewBot);
	else NewBot.GotoState('Dead');
	bDoPendingWelcome = true;
		}

	super.Mutate(MutateString,Sender);
}

static event string GetDescriptionText(string PropName)
{
	switch( PropName )
	{
	case "NumBots":
		return "Number of bots should appear in game.";
	case "MaxVeteranLevel":
		return "Maximum veterancy level for bots.";
	case "MinVeteranLevel":
		return "Minimum veterancy level for bots.";
	case "bUseCustomChars":
		return "Use bot characters from a custom characters list.";
	case "BotAmmoCostScale":
		return "Ammo cost scaling for bots (in trader).";
	case "BotWeaponCostScale":
		return "Weapon cost scaling for bots (in trader).";
	case "BotArmorCostScale":
		return "Armor cost scaling for bots (in trader).";
	default:
		return Super.GetDescriptionText(PropName);
	}
}

function PreBeginPlay()
{
	local int i,j;
	local class<KFVeterancyTypes> V;
	local RosterEntry R;

	// Adjust weapon priorities since TWI never did that...
	Class'SinglePickup'.Default.MaxDesireability = 0.25;
	Class'Single'.Default.AIRating = 0.25;
	Class'DualiesPickup'.Default.MaxDesireability = 0.35;
	Class'Dualies'.Default.AIRating = 0.35;
	Class'Knife'.Default.AIRating = 0.2;
	Class'ClaymoreSwordPickup'.Default.MaxDesireability = 0.9;
	Class'ClaymoreSword'.Default.AIRating = 0.9;
	Class'KatanaPickup'.Default.MaxDesireability = 0.9;
	Class'Katana'.Default.AIRating = 0.9;
	Class'LAWPickup'.Default.MaxDesireability = 0.9;
	Class'LAW'.Default.AIRating = 0.9;
	Class'PipeBombPickup'.Default.MaxDesireability = 0.85;
	Class'PipeBombExplosive'.Default.AIRating = 0.25;
	Class'ZEDGunPickup'.Default.MaxDesireability = 0.65;
	Class'ZEDMKIIPickup'.Default.MaxDesireability = 0.65;
	Class'Potato'.Default.MaxDesireability = 0; // Don't waste money on the potato :)

	// Fix firemodes to not crash with bots around (because KFMeleeFire.Timer crashes when bot dies while firing).
	Class'Axe'.Default.FireModeClass[0] = Class'FIX_AxeFire';
	Class'Axe'.Default.FireModeClass[1] = Class'FIX_AxeFireB';
	Class'Bat'.Default.FireModeClass[0] = Class'FIX_BatFire';
	Class'Chainsaw'.Default.FireModeClass[0] = Class'FIX_ChainsawFire';
	Class'Chainsaw'.Default.FireModeClass[1] = Class'FIX_ChainsawAltFire';
	Class'Claws'.Default.FireModeClass[0] = Class'FIX_ClawsFire';
	Class'ClaymoreSword'.Default.FireModeClass[0] = Class'FIX_ClaymoreSwordFire';
	Class'ClaymoreSword'.Default.FireModeClass[1] = Class'FIX_ClaymoreSwordFireB';
	Class'DwarfAxe'.Default.FireModeClass[0] = Class'FIX_DwarfAxeFire';
	Class'DwarfAxe'.Default.FireModeClass[1] = Class'FIX_DwarfAxeFireB';
	Class'Katana'.Default.FireModeClass[0] = Class'FIX_KatanaFire';
	Class'Katana'.Default.FireModeClass[1] = Class'FIX_KatanaFireB';
	Class'Knife'.Default.FireModeClass[0] = Class'FIX_KnifeFire';
	Class'Knife'.Default.FireModeClass[1] = Class'FIX_KnifeFireB';
	Class'Machete'.Default.FireModeClass[0] = Class'FIX_MacheteFire';
	Class'Machete'.Default.FireModeClass[1] = Class'FIX_MacheteFireB';
	Class'Scythe'.Default.FireModeClass[0] = Class'FIX_ScytheFire';
	Class'Scythe'.Default.FireModeClass[1] = Class'FIX_ScytheFireB';

// #ifdef WITH_SENTRY_BOT
	 Class'SentryGunPickup'.Default.MaxDesireability = 0.65;
	 Class'EngineerMedicSentryBotPickup'.Default.MaxDesireability = 0.65;
//	 Class'EngineerMedicSentryBotPickup'.Default.CorrespondingPerkIndex = 7; // Make any bot perk buy this weapon.
	 Class'SentryGun'.Default.AIRating = 0.1;
	 Class'MedicSentryBot'.Default.AIRating = 0.1;
// #endif

	KF = DZ_GameType(Level.Game);
	if( KF==None )
	{
		Error("This is not a KF based game mode.");
		return;
	}
	KF.bNoBots = true;
	KF.bBotsAdded = true;
	KF.InitialBots = NumBots;

	for( i=0; i<BotPerks.Length; ++i )
	{
		V = Class<SRVeterancyTypes>(DynamicLoadObject(BotPerks[i],Class'Class'));
		if( V!=None )
			LoadedSkills[LoadedSkills.Length] = V;
	}
	MinVeteranLevel = Min(MinVeteranLevel,MaxVeteranLevel);
	
	// Load bot roosters
	if( bUseCustomChars )
	{
		for( i=0; i<BotChars.Length; ++i )
		{
			j = InStr(BotChars[i],":");
			if( j<=0 )
				R = class'xRosterEntry'.Static.CreateRosterEntryCharacter(BotChars[i]);
			else
			{
				R = class'xRosterEntry'.Static.CreateRosterEntryCharacter(Left(BotChars[i],j));
				R.ModifiedPlayerName = Mid(BotChars[i],j+1);
			}
			BotRoosters[BotRoosters.Length] = R;
		}
	}
	Spawn(Class'KFBotChatManager');
}
function MatchStarting()
{
	local byte c;

	if( Level.NetMode==NM_StandAlone )
	{
		KF.RemainingBots = 0;
		while( ++c<=NumBots )
			AddBot();
	}
	else
	{
		KF.MinPlayers = NumBots;
		if( KF.NeedPlayers() )
			AddBot();
		SetTimer(1,true);
	}
}
function Timer()
{
	if( bDoPendingWelcome )
	{
		KF.bWelcomePending = true;
		bDoPendingWelcome = false;
	}
	if( KF.bGameEnded )
		SetTimer(0,false);
	else if( KF.NeedPlayers() )
		AddBot();
}
final function InitializeBot(KFInvBots NewBot, UnrealTeamInfo BotTeam, RosterEntry Chosen)
{
	local string S;

	NewBot.InitializeSkill(9);
	Chosen.InitBot(NewBot);
	BotTeam.AddToTeam(NewBot);
	if ( Len(Chosen.ModifiedPlayerName)!=0 )
		S = Chosen.ModifiedPlayerName;
	else S = Chosen.PlayerName;
	KF.ChangeName(NewBot, S, false);
	BotTeam.SetBotOrders(NewBot,Chosen);
	NewBot.PlayerReplicationInfo.SetCharacterName(Chosen.PlayerName);
	NewBot.PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(Chosen.PlayerName);
	NewBot.UsingRooster = Chosen;
}
final function AddBot()
{
	local KFInvBots NewBot;
	local RosterEntry Chosen;
	local UnrealTeamInfo BotTeam;

	BotTeam = KF.GetBotTeam();
	if( BotRoosters.Length>0 )
		Chosen = PickCustomBot();
	if( Chosen==None )
		Chosen = BotTeam.ChooseBotClass("");

	if( Chosen.PawnClass == None )
		Chosen.Init(); //amb
	NewBot = Spawn(class'KFInvBots');

	if ( NewBot==None )
		return;

	InitializeBot(NewBot,BotTeam,Chosen);

	// Decide if bot should be a veteran.
	if ( LoadedSkills.Length > 0 && KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo) != None )
	{
		KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo).ClientVeteranSkill = LoadedSkills[Rand(LoadedSkills.Length)];
		if( MinVeteranLevel==MaxVeteranLevel )
			KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo).ClientVeteranSkillLevel = MaxVeteranLevel;
		else KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo).ClientVeteranSkillLevel = MinVeteranLevel+Rand(MaxVeteranLevel+1-MinVeteranLevel);
	}

	NewBot.Mute = Self;
	NewBot.PlayerReplicationInfo.Score = KF.StartingCash;
	NewBot.PlayerReplicationInfo.PlayerID = KF.CurrentID++;
	NewBot.Skill = 9;

	KF.NumBots++;
	if ( Level.NetMode == NM_Standalone )
		KF.RestartPlayer(NewBot);
	else NewBot.GotoState('Dead','MPStart');
	bDoPendingWelcome = true;
}

final function RosterEntry PickCustomBot()
{
	local int n,i;
	
	for( n=Min(10,BotRoosters.Length+1); n>=0; --n )
	{
		i = Rand(BotRoosters.Length);
		if( !BotRoosters[i].bTaken )
			return BotRoosters[i];
	}
	for( n=0; n<BotRoosters.Length; ++n )
	{
		if( ++i>=BotRoosters.Length )
			i = 0;
		if( !BotRoosters[i].bTaken )
			return BotRoosters[i];
	}
	return None;
}

final function BuildSaleList()
{
	local KFBotLevelRules L;
	local int i;
	
	ItemForSale.Length = 0;
	L = DZ_GameType(Level.Game).KFLRules;
	
	if( L==None )
	{
		L = Spawn(class'KFBotLevelRules');
		L.LifeSpan = 0.01;
	}
	for( i=0; i<L.MediItemForSale.Length; ++i )
	{
		if( L.MediItemForSale[i]!=None )
			ItemForSale[ItemForSale.Length] = L.MediItemForSale[i];
	}
	for( i=0; i<L.SuppItemForSale.Length; ++i )
	{
		if( L.SuppItemForSale[i]!=None )
			ItemForSale[ItemForSale.Length] = L.SuppItemForSale[i];
	}
	for( i=0; i<L.ShrpItemForSale.Length; ++i )
	{
		if( L.ShrpItemForSale[i]!=None )
			ItemForSale[ItemForSale.Length] = L.ShrpItemForSale[i];
	}
	for( i=0; i<L.CommItemForSale.Length; ++i )
	{
		if( L.CommItemForSale[i]!=None )
			ItemForSale[ItemForSale.Length] = L.CommItemForSale[i];
	}
	for( i=0; i<L.BersItemForSale.Length; ++i )
	{
		if( L.BersItemForSale[i]!=None )
			ItemForSale[ItemForSale.Length] = L.BersItemForSale[i];
	}
	for( i=0; i<L.FireItemForSale.Length; ++i )
	{
		if( L.FireItemForSale[i]!=None )
			ItemForSale[ItemForSale.Length] = L.FireItemForSale[i];
	}
	for( i=0; i<L.DemoItemForSale.Length; ++i )
	{
		if( L.DemoItemForSale[i]!=None )
			ItemForSale[ItemForSale.Length] = L.DemoItemForSale[i];
	}
	for( i=0; i<L.AssItemForSale.Length; ++i )
	{
		if( L.AssItemForSale[i]!=None )
			ItemForSale[ItemForSale.Length] = L.AssItemForSale[i];
	}
	for( i=0; i<L.FigItemForSale.Length; ++i )
	{
		if( L.FigItemForSale[i]!=None )
			ItemForSale[ItemForSale.Length] = L.FigItemForSale[i];
	}
	for( i=0; i<L.VIPItemForSale.Length; ++i )
	{
		if( L.VIPItemForSale[i]!=None )
			ItemForSale[ItemForSale.Length] = L.VIPItemForSale[i];
	}
	for( i=0; i<L.NeutItemForSale.Length; ++i )
	{
		if( L.NeutItemForSale[i]!=None )
			ItemForSale[ItemForSale.Length] = L.NeutItemForSale[i];
	}
}

defaultproperties
{
     BotPerks(0)="ServerPerksDZ.SRVetFieldMedic"
     BotPerks(1)="ServerPerksDZ.SRVetSupportSpec"
     BotPerks(2)="ServerPerksDZ.SRVetSharpshooter"
     BotPerks(3)="ServerPerksDZ.SRVetCommando"
     BotPerks(4)="ServerPerksDZ.SRVetBerserker"
     BotPerks(5)="ServerPerksDZ.SRVetFirebug"
     BotPerks(6)="ServerPerksDZ.SRVetDemolitions"
     BotPerks(7)="ServerPerksDZ.SRVetAssistant"
     BotPerks(8)="ServerPerksDZ.SRVetDolboyob"
     BotChars(0)="Ash_Harding"
     BotChars(1)="Captian_Wiggins:Cpt.Wiggins"
     BotChars(2)="Chopper_Harris"
     BotChars(3)="Corporal_Lewis:Crp.Lewis"
     BotChars(4)="FoundryWorker_Aldridge:Aldridge"
     BotChars(5)="Harold_Hunt"
     BotChars(6)="Harold_Lott"
     BotChars(7)="Lieutenant_Masterson:Lt.Masterson"
     BotChars(8)="Mike_Noble"
     BotChars(9)="Mr_Foster:Mr.Foster"
     BotChars(10)="Mrs_Foster:Mrs.Foster"
     BotChars(11)="Paramedic_Alfred_Anderson:Alfred Anderson"
     BotChars(12)="Police_Constable_Briar:PC.Briar"
     BotChars(13)="Police_Sergeant_Davin:PS.Davin"
     BotChars(14)="Private_Schnieder:Pvt.Schnieder"
     BotChars(15)="Security_Officer_Thorne:Thorne"
     BotChars(16)="Sergeant_Powers:Srg.Powers"
     NumBots=4
     NonPerkIndex=7
     MaxVeteranLevel=6
     BotAmmoCostScale=1.000000
     BotWeaponCostScale=1.000000
     BotArmorCostScale=1.000000
     GroupName="KF-Bots"
     FriendlyName="Bots Mutator"
     Description="Add KF bots to the game."
}
