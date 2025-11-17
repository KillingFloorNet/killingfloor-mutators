Class MutKFBots extends Mutator;

var() config array<string> BotPerks, BotChars;
var() config int NumBots, NonPerkIndex;
var() config int MaxVeteranLevel, MinVeteranLevel;
var() config float BotAmmoCostScale, BotWeaponCostScale, BotArmorCostScale;
var KFGameType KF;
var float NextTraderMsg, NextYellTime;
var array< class<KFVeterancyTypes> > LoadedSkills;
var array< class<Pickup> > ItemForSale;
var array<RosterEntry> BotRoosters;
var bool bDoPendingWelcome;

var() config bool bUseCustomChars;
var() config bool bEnableBotOrderChatCommands;

var() config int NumBotsMin, NumBotsMax, ConstantRestoreHPVal, ConstantRestoreHPMax;
var() config bool StartBotsWithoutPlayers;

function PreBeginPlay()
{
	local int i, j;
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
	Class'Axe'.Default.FireModeClass[0] = Class'KFBotsAxeFire';
	Class'Axe'.Default.FireModeClass[1] = Class'KFBotsAxeFireB';
	Class'Bat'.Default.FireModeClass[0] = Class'KFBotsBatFire';
	Class'Chainsaw'.Default.FireModeClass[0] = Class'KFBotsChainsawFire';
	Class'Chainsaw'.Default.FireModeClass[1] = Class'KFBotsChainsawAltFire';
	Class'Claws'.Default.FireModeClass[0] = Class'KFBotsClawsFire';
	Class'ClaymoreSword'.Default.FireModeClass[0] = Class'KFBotsClaymoreSwordFire';
	Class'ClaymoreSword'.Default.FireModeClass[1] = Class'KFBotsClaymoreSwordFireB';
	Class'DwarfAxe'.Default.FireModeClass[0] = Class'KFBotsDwarfAxeFire';
	Class'DwarfAxe'.Default.FireModeClass[1] = Class'KFBotsDwarfAxeFireB';
	Class'Katana'.Default.FireModeClass[0] = Class'KFBotsKatanaFire';
	Class'Katana'.Default.FireModeClass[1] = Class'KFBotsKatanaFireB';
	Class'Knife'.Default.FireModeClass[0] = Class'KFBotsKnifeFire';
	Class'Knife'.Default.FireModeClass[1] = Class'KFBotsKnifeFireB';
	Class'Machete'.Default.FireModeClass[0] = Class'KFBotsMacheteFire';
	Class'Machete'.Default.FireModeClass[1] = Class'KFBotsMacheteFireB';
	Class'Scythe'.Default.FireModeClass[0] = Class'KFBotsScytheFire';
	Class'Scythe'.Default.FireModeClass[1] = Class'KFBotsScytheFireB';

// #ifdef WITH_SENTRY_BOT
	// Class'SentryGunPickup'.Default.MaxDesireability = 0.65;
	// Class'SentryGunPickup'.Default.CorrespondingPerkIndex = 7; // Make any bot perk buy this weapon.
	// Class'SentryGun'.Default.AIRating = 0.1;
// #endif

	KF = KFGameType(Level.Game);

	if (KF == None)
	{
		Error("This is not a KF based game mode.");
		return;
	}

	KF.bNoBots = true;
	KF.bBotsAdded = true;

	if (NumBots == -1)
	{
		NumBots = Rand(NumBotsMax) + 1;

		if (NumBots < NumBotsMin)
			NumBots = NumBotsMin;
	}

	KF.InitialBots = NumBots;

	for (i=0; i<BotPerks.Length; ++i)
	{
		V = Class<KFVeterancyTypes>(DynamicLoadObject(BotPerks[i],Class'Class'));

		if (V != None)
			LoadedSkills[LoadedSkills.Length] = V;
	}

	MinVeteranLevel = Min(MinVeteranLevel, MaxVeteranLevel);

	// Load bot roosters
	if (bUseCustomChars)
	{
		for (i = 0; i < BotChars.Length; ++i)
		{
			j = InStr(BotChars[i], ":");

			if (j <= 0)
				R = class'xRosterEntry'.Static.CreateRosterEntryCharacter(BotChars[i]);
			else
			{
				R = class'xRosterEntry'.Static.CreateRosterEntryCharacter(Left(BotChars[i], j));
				R.ModifiedPlayerName = Mid(BotChars[i], j+1);
			}

			BotRoosters[BotRoosters.Length] = R;
		}
	}

	if (bEnableBotOrderChatCommands)
	{
		Spawn(Class'KFBotsChatHandler');
	}
}

function PostBeginPlay()
{
	super.PostBeginPlay();

	if (StartBotsWithoutPlayers)
	{
		Level.Game.StartMatch();
		AddBotsOnStart();
	}
}

function MatchStarting()
{
	if (!StartBotsWithoutPlayers)
	{
		AddBotsOnStart();
	}
}

function AddBotsOnStart()
{
	local byte c;

	if (Level.NetMode == NM_StandAlone)
	{
		KF.RemainingBots = 0;

		while(++c <= NumBots)
			AddBot();
	}
	else
	{
		KF.MinPlayers = NumBots;

		if(KF.NeedPlayers())
			AddBot();

		SetTimer(1, true);
	}
}

function Timer()
{
	local KFInvBots bot;
	if (ConstantRestoreHPVal > 0)
	{
		foreach DynamicActors(class'KFInvBots', bot)
		{
			if (bot != none && bot.Pawn != none && bot.Pawn.Health > 0 && bot.Pawn.Health < ConstantRestoreHPMax)
			{
				bot.Pawn.Health += ConstantRestoreHPVal;
			}
		}
	}

	if (bDoPendingWelcome)
	{
		KF.bWelcomePending = true;
		bDoPendingWelcome = false;
	}

	if (KF.bGameEnded)
		SetTimer(0, false);
	else if (KF.NeedPlayers())
		AddBot();
}

final function InitializeBot(KFInvBots NewBot, UnrealTeamInfo BotTeam, RosterEntry Chosen)
{
	local string S;

	NewBot.InitializeSkill(9);
	Chosen.InitBot(NewBot);
	BotTeam.AddToTeam(NewBot);

	if (Len(Chosen.ModifiedPlayerName) != 0)
		S = Chosen.ModifiedPlayerName;
	else
		S = Chosen.PlayerName;

	KF.ChangeName(NewBot, S, false);

	BotTeam.SetBotOrders(NewBot, Chosen);
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

	if( BotRoosters.Length > 0 )
		Chosen = PickCustomBot();
	if( Chosen==None )
		Chosen = BotTeam.ChooseBotClass("");

	if( Chosen.PawnClass == None )
		Chosen.Init(); //amb

	NewBot = Spawn(class'KFInvBots');

	if (NewBot == None)
		return;

	InitializeBot(NewBot, BotTeam, Chosen);

	// Decide if bot should be a veteran.
	if (LoadedSkills.Length > 0 && KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo) != None)
	{
		KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo).ClientVeteranSkill = LoadedSkills[Rand(LoadedSkills.Length)];

		if( MinVeteranLevel==MaxVeteranLevel )
			KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo).ClientVeteranSkillLevel = MaxVeteranLevel;
		else
			KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo).ClientVeteranSkillLevel = MinVeteranLevel+Rand(MaxVeteranLevel+1-MinVeteranLevel);
	}

	NewBot.Mute = Self;
	NewBot.PlayerReplicationInfo.Score = KF.StartingCash;
	NewBot.PlayerReplicationInfo.PlayerID = KF.CurrentID++;
	NewBot.Skill = 9;

	KF.NumBots++;

	if (Level.NetMode == NM_Standalone)
		KF.RestartPlayer(NewBot);
	else
		NewBot.GotoState('Dead', 'MPStart');

	bDoPendingWelcome = true;
}

final function RosterEntry PickCustomBot()
{
	local int n,i;

	for(n = Min(10, BotRoosters.Length + 1); n >= 0; --n)
	{
		i = Rand(BotRoosters.Length);

		if(!BotRoosters[i].bTaken)
			return BotRoosters[i];
	}

	for(n = 0; n < BotRoosters.Length; ++n)
	{
		if(++i >= BotRoosters.Length)
			i = 0;
		if(!BotRoosters[i].bTaken)
			return BotRoosters[i];
	}

	return None;
}

final function BuildSaleList()
{
	local KFLevelRules L;
	local int i;

	ItemForSale.Length = 0;
	L = KFGameType(Level.Game).KFLRules;

	if( L==None )
	{
		L = Spawn(class'KFLevelRules');
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
	for( i=0; i<L.NeutItemForSale.Length; ++i )
	{
		if( L.NeutItemForSale[i]!=None )
			ItemForSale[ItemForSale.Length] = L.NeutItemForSale[i];
	}
}

defaultproperties
{
	BotPerks(0)="KFMod.KFVetFieldMedic"
	BotPerks(1)="KFMod.KFVetSupportSpec"
	BotPerks(2)="KFMod.KFVetSharpshooter"
	BotPerks(3)="KFMod.KFVetCommando"
	BotPerks(4)="KFMod.KFVetBerserker"
	BotPerks(5)="KFMod.KFVetFirebug"
	BotPerks(6)="KFMod.KFVetDemolitions"

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

	NumBots=-1 // -1 = Random between NumBotsMin and NumBotsMax
	NumBotsMin=10
	NumBotsMax=14

	StartBotsWithoutPlayers=True

	ConstantRestoreHPVal=5
	ConstantRestoreHPMax=200

	bEnableBotOrderChatCommands=false
	NonPerkIndex=7
	MaxVeteranLevel=6
	BotAmmoCostScale=1.000000
	BotWeaponCostScale=1.000000
	BotArmorCostScale=1.000000

	GroupName="KF-MutKFBots"
	FriendlyName="MutKFBots"
	Description=""
}
