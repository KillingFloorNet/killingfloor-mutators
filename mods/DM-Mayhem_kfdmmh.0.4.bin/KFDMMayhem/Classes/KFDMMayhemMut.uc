class KFDMMayhemMut extends Mutator;

var config bool bRandomItemSpawnMechanism,mhBUseEndGameBoss,bTeamGame,bSpecimenHeatlhCap,bBossesHealthBar,bLimitAmountOfSpecimens;
var config float damageScaling;
var config int mhMaxPlayers;
var localized string GUIDisplayText[8];	// Config property label names
var localized string GUIDescText[8];	// Config property long descriptions

function preBeginPlay()
{
	local ROServerLoading LO;

	super.preBeginPlay();
//	No espawneó todavía.
	forEach AllActors(class'ROServerLoading',LO)
		log( "RLOG: LO.mapName = " @ LO.mapName );
}

function postBeginPlay()
{
	local int index;

	log( "RLOG: level.title = " @ level.title );
	log( "RLOG: GetUrlOption = " @ GetUrlOption("map") );
	if( KFDMMayhem( level.game ) == none )
		level.serverTravel( level.title $ "?game=KFDMMayhem.KFDMMayhem",true );

	if( KFDMMayhem( level.game ) != none )
	{
		KFDMMayhem( level.game ).bTeamGame = bTeamGame;
		KFDMMayhem( level.game ).mhBUseEndGameBoss = mhBUseEndGameBoss;
		KFDMMayhem( level.game ).mhMaxPlayers = mhMaxPlayers;
		KFDMMayhem( level.game ).bBossesHealthBar = bBossesHealthBar;
		KFDMMayhem( level.game ).bRandomItemSpawnMechanism = bRandomItemSpawnMechanism;
		KFDMMayhem( level.game ).damageScaling = damageScaling;
		KFDMMayhem( level.game ).originalDamageScaling = damageScaling;
		KFDMMayhem( level.game ).bLimitAmountOfSpecimens = bLimitAmountOfSpecimens;
	}

//	Removal of automatic sounds. See also MHPlayerController.speech.
	for(index = 0;index < 25;index++)
	{
		class'KFVoicePack'.default.automaticSound[index] = none;
		class'KFVoicePackTwo'.default.automaticSound[index] = none;
	}
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if(other.IsA('KFMonster') && bSpecimenHeatlhCap)
	{
		KFMonster(other).Health /= KFMonster(other).NumPlayersHealthModifer();
		KFMonster(other).HealthMax /= KFMonster(other).NumPlayersHealthModifer();
		KFMonster(other).HeadHealth /= KFMonster(other).NumPlayersHeadHealthModifer();
		KFMonster(other).Health *= 1 + KFMonster(other).PlayerCountHealthScale;
		KFMonster(other).HealthMax *= 1 + KFMonster(other).PlayerCountHealthScale;
		KFMonster(other).HeadHealth *= 1 + KFMonster(other).PlayerNumHeadHealthScale;
	}

	if(other.isA('KFAmmunition') && !other.IsA('FragAmmo'))
		KFAmmunition(other).ammoPickupAmount = KFAmmunition(other).ammoPickupAmount *= 3;

	if( Controller( Other ) != None )
		Controller( Other ).PlayerReplicationInfoClass = Class'MHPlayerReplicationInfo';
	return true;
}

static function string getDisplayText( string propertyName )
{
	switch( propertyName )
	{
		case "bTeamGame":					return default.GUIDisplayText[0];
		case "mhBUseEndGameBoss":			return default.GUIDisplayText[1];
		case "mhMaxPlayers":				return default.GUIDisplayText[2];
		case "bBossesHealthBar":			return default.GUIDisplayText[3];
		case "bRandomItemSpawnMechanism":	return default.GUIDisplayText[4];
		case "bSpecimenHeatlhCap":			return default.GUIDisplayText[5];
		case "damageScaling":				return default.GUIDisplayText[6];
		case "bLimitAmountOfSpecimens":		return default.GUIDisplayText[7];
	}
}

static event string getDescriptionText(string propName)
{
	switch(propName)
	{
		case "bTeamGame":					return default.GUIDescText[0];
		case "mhBUseEndGameBoss":			return default.GUIDescText[1];
		case "mhMaxPlayers":				return default.GUIDescText[2];
		case "bBossesHealthBar":			return default.GUIDescText[3];
		case "bRandomItemSpawnMechanism":	return default.GUIDescText[4];
		case "bSpecimenHeatlhCap":			return default.GUIDescText[5];
		case "damageScaling":				return default.GUIDescText[6];
		case "bLimitAmountOfSpecimens":		return default.GUIDescText[7];
	}

	return super.getDescriptionText(propName);
}

static function fillPlayInfo( PlayInfo playInfo )
{
	super.fillPlayInfo(playInfo);
	playInfo.AddSetting (default.GameGroup , "bTeamGame" , getDisplayText( "bTeamGame" ) , 0 , 0 , "Check", "", "", false, false );
	playInfo.AddSetting (default.GameGroup , "mhBUseEndGameBoss" , getDisplayText( "mhBUseEndGameBoss" ) , 0 , 1 , "Check", "", "", false, false );
	playInfo.AddSetting (default.GameGroup , "mhMaxPlayers" , getDisplayText( "mhMaxPlayers" ) , 0 , 2 , "Text", "0:64", "", false, false );
	playInfo.AddSetting (default.GameGroup , "bBossesHealthBar" , getDisplayText( "bBossesHealthBar" ) , 0 , 3 , "Check", "", "", false, false );
	playInfo.AddSetting (default.GameGroup , "bRandomItemSpawnMechanism" , getDisplayText( "bRandomItemSpawnMechanism" ) , 0 , 4 , "Check", "", "", false, true );
	playInfo.AddSetting (default.GameGroup , "bSpecimenHeatlhCap" , getDisplayText( "bSpecimenHeatlhCap" ) , 0 , 5 , "Check", "", "", false, true );
	playInfo.AddSetting (default.GameGroup , "damageScaling" , getDisplayText( "damageScaling" ) , 0 , 6 , "Text", "0:1", "", false, true );
	playInfo.AddSetting (default.GameGroup , "bLimitAmountOfSpecimens" , getDisplayText( "bLimitAmountOfSpecimens" ) , 0 , 7 , "Check", "", "", false, true );
}

function mutate( string mutateString,PlayerController sender )
{
	local bool distOverHundred;
	local float dist;
	local MHHumanPawn player;
	local ZombieFleshPound fp;

	if( mutateString == "dist" )
	{
		log( "RLOG: sender.location =" @ sender.location );
		log( "RLOG: sender.pawn.location =" @ sender.pawn.location );
		forEach dynamicActors( class'MHHumanPawn',player )
		{
			distOverHundred = VSizeSquared( sender.pawn.location - player.location ) > 10000; // 100 ** 2.
			dist = VSize( sender.pawn.location - player.location );
			log( "RLOG: distOverHundred =" @ distOverHundred );
			log( "RLOG: each player.location =" @ player.location );
			log( "RLOG: each player dist to sender =" @ dist );
		}
	}

	if( mutateString == "see" )
	{
		forEach dynamicActors( class'MHHumanPawn',player )
			log( "RLOG: PlayerCanSeeMe =" @ player.PlayerCanSeeMe() );
	}

	if( mutateString == "skin" )
	{
		forEach dynamicActors( class'MHHumanPawn',player )
			log( "RLOG: Skin [0] =" @ player.Skins[0] );
	}

	if( mutateString == "max" )
	{
		log( "RLOG: level.game.mhMaxPlayers" @ level.game.maxPlayers );
	}

	if( mutateString == "fp" )
	{
		forEach dynamicActors( class'ZombieFleshPound',fp )
		{
			log( "RLOG: fp health =" @ fp.Health );
			log( "RLOG: fp healthmax =" @ fp.HealthMax );
			log( "RLOG: fp healthhead =" @ fp.HeadHealth );
		}
	}

	super.mutate( mutateString,sender );
}

defaultproperties
{
     bRandomItemSpawnMechanism=True
     bSpecimenHeatlhCap=True
     bLimitAmountOfSpecimens=True
     DamageScaling=0.350000
     mhMaxPlayers=32
     GUIDisplayText(0)="Team deathmatch"
     GUIDisplayText(1)="Patriarch battle"
     GUIDisplayText(2)="Maximum players"
     GUIDisplayText(3)="Bosses health bar"
     GUIDisplayText(4)="No trader mode"
     GUIDisplayText(5)="Specimen health cap"
     GUIDisplayText(6)="Damage Scaling"
     GUIDisplayText(7)="Limit zed amount"
     GUIDescText(0)="Team based deathmatch mayhem."
     GUIDescText(1)="Wether Kevin should show up after his children are down."
     GUIDescText(2)="Maximum amount of players allowed in the server (overrides server's MaxPlayers setting)."
     GUIDescText(3)="Tough specimen's health is visible."
     GUIDescText(4)="Trader does not open, instead items spawns randomly like classic deathmatch."
     GUIDescText(5)="Restricts specimen health to avoid immortal fleshpounds on crowded servers."
     GUIDescText(6)="Amount of damage applied between players."
     GUIDescText(7)="Limits the amount of speciments to equal easy difficulty, no matter which difficulty is chosen."
     GroupName="KF-GameTypes"
     FriendlyName="Killing Floor Deathmatch Mayhem"
     Description="Free for all deathmatch with specimens on the way."
}
