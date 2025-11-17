class KFDMMayhem extends KFGameType config;

// This are setted by the mutator to allow GUI configuration.
var config bool mhBUseEndGameBoss,bRandomItemSpawnMechanism,bBossesHealthBar,bLimitAmountOfSpecimens;
var config float damageScaling,originalDamageScaling;
var config int mhMaxPlayers;

var int amountOfPlayerSpawnLocations; //Amount of places where player can actually spawn.
var float lastItemShuffleTime;

var KFDMMayhemRules rules;
var array< MHWeaponGroup > weaponGroups[4];

event preBeginPlay()
{
	local KFLevelRules oldRules;

	super.preBeginPlay();

	foreach allActors(class'KFLevelRules', oldRules)
		if(oldRules != none)
			oldRules.destroy();
	spawn(class'MHLevelRules');

	if( bTeamGame )
	{
		GameReplicationInfo.bNoTeamSkins = false;
		GameReplicationInfo.bNoTeamChanges = false;
		LoginMenuClass = "GUI2K4.UT2K4PlayerLoginMenu";
		scoreBoardType = "KFDMMayhem.MHScoreBoardTeamDeathMatch";
	}
	else
	{
		FriendlyFireScale = 1;
		ScoreBoardType = "KFDMMayhem.MHScoreBoardDeathMatch";
	}

	if( bRandomItemSpawnMechanism )
	{
		KFGameReplicationInfo(GameReplicationInfo).bHUDShowCash = false;
		weaponGroups[0] = New class'MHMeleeGroup';
		weaponGroups[1] = New class'MHLowTierGroup';
		weaponGroups[2] = New class'MHMediumTierGroup';
		weaponGroups[3] = New class'MHHighTierGroup';
	}
}

function postBeginPlay()
{
	local KFRandomSpawn randomSpawn;

	super.PostBeginPlay();

//	Initialization
	forEach DynamicActors( Class'KFRandomSpawn',randomSpawn ) amountOfPlayerSpawnLocations++;
	rules = spawn( class'KFDMMayhemRules' );
	Level.Game.AddGameModifier ( rules );
	log( "RLOG: bUseEndGameBoss =" @ bUseEndGameBoss );
	log( "RLOG: FF =" @ FriendlyFireScale );
	bUseEndGameBoss = mhBUseEndGameBoss;
	maxPlayers = mhMaxPlayers;
	log( "RLOG: mhBUseEndGameBoss =" @ mhBUseEndGameBoss );
}

event PlayerController Login
(
	string Portal,
	string Options,
	out string Error
)
{
	local MHPlayerController newPlayer;

	newPlayer = MHPlayerController( super.Login( Portal,Options,Error ) );
	if( newPlayer != none )
	{
		log( "RLOG: KFDMMayhem.bTeamGame =" @ bTeamGame );
		newPlayer.bRandomItemSpawnMechanism = bRandomItemSpawnMechanism;
		newPlayer.bTeamGame = bTeamGame;
		newPlayer.bBossesHealthBar = bBossesHealthBar;
	}
	return newPlayer;
}

function restartPlayer( Controller aPlayer )
{
	log("RLOG: RP" @ MHPlayerController(aPlayer).LastPawnWeapon);

//	Skip round ending.
	aPlayer.PlayerReplicationInfo.bOutOfLives = false;
	if( bWaveInProgress && PlayerController ( aPlayer ) != none )
		super( Invasion ).RestartPlayer( aPlayer );
	else super.RestartPlayer(aPlayer);

//	Relocate aPlayer
	moveToRandomSpawn ( aPlayer );
	aPlayer.pawn.PlayTeleportEffect( true,true );
	log("RLOG: restartPlayer.Location" @ aPlayer.pawn.location);
}

function bool checkEndGame(PlayerReplicationInfo Winner, string Reason)
{
	if ( WaveNum > FinalWave || ( WaveNum == FinalWave && !bUseEndGameBoss ) )
		return super.CheckEndGame( Winner,Reason );
	return false;
}

function int randomSpawnWeightFor( KFRandomSpawn aRandomSpawn )
// Returns the weight used to evaluate
{
	local int weight,minimumDistanceSquare;
	local MHHumanPawn player;

	weight = rand( 10 );

	log( "RLOG: weight initial =" @ weight );
	minimumDistanceSquare = -1;
	forEach DynamicActors( class'MHHumanPawn',player )
	{
		if(minimumDistanceSquare < 0)
			minimumDistanceSquare = int( VSizeSquared( aRandomSpawn.Location - player.Location ) );
		else
			minimumDistanceSquare = min( minimumDistanceSquare,int( VSizeSquared( aRandomSpawn.Location - player.Location ) ) );
		log( "RLOG: distance =" @ VSize( aRandomSpawn.Location - player.Location ) );
		log( "RLOG: distanceSqare =" @ VSizeSquared( aRandomSpawn.Location - player.Location ) );
		log( "RLOG: minimumDistanceSquare =" @ minimumDistanceSquare );
	}

	log( "RLOG: minimumDistanceSquare final =" @ minimumDistanceSquare );
	if( minimumDistanceSquare < 262144 ) // 512 ** 2.
	{
		log( "RLOG: multi = /2" );
		weight /= 2;
		}
	else if( minimumDistanceSquare < 4194304 ) // 2048 ** 2.
	{
		log( "RLOG: multi = *2" );
		weight *= 2;
	}
	else
	{
		log( "RLOG: multi = *1" );
	}

	log( "RLOG: weight final =" @ weight );

	return weight;
}

function KFRandomSpawn nextRandomSpawn()
// Returns the next random spawn.
{
	local int spawnLocationIndex,maximumWeight;
	local array< KFRandomSpawn > randomSpawns;
	local array< int > randomSpawnsWeight;
	local KFRandomSpawn randomSpawn;

//	Array initialization.
	forEach DynamicActors( class'KFRandomSpawn',randomSpawn )
	{
		randomSpawns[spawnLocationIndex] = randomSpawn;
		randomSpawnsWeight[spawnLocationIndex] = randomSpawnWeightFor( randomSpawn );
		if( randomSpawnsWeight[spawnLocationIndex] > maximumWeight )
			maximumWeight = randomSpawnsWeight[spawnLocationIndex];
		spawnLocationIndex++;
	}

	for( spawnLocationIndex = 0 ; spawnLocationIndex < amountOfPlayerSpawnLocations ; spawnLocationIndex++ )
		log( "RLOG: randomSpawnsWeight[spawnLocationIndex] =" @ randomSpawnsWeight[spawnLocationIndex] );

//	Spawn location selection.
	log( "RLOG: maximumWeight =" @ maximumWeight );
	randomSpawn = none;
	for( spawnLocationIndex = 0 ; spawnLocationIndex < amountOfPlayerSpawnLocations ; spawnLocationIndex++ )
		if( randomSpawnsWeight[spawnLocationIndex] == maximumWeight )
			if( randomSpawn == none )
				randomSpawn = randomSpawns[spawnLocationIndex];
			else
				{
					log( "RLOG: nextRandomSpawn More than one maximum" );
					if( rand( 2 ) == 1 ) randomSpawn = randomSpawns[spawnLocationIndex];
				}

	return randomSpawn;
}

function moveToRandomSpawn( Controller aPlayer )
// Moves aPlayer to a random spawn location.
{
	local KFRandomSpawn newPlayerSpawn;

	newPlayerSpawn = self.nextRandomSpawn();

	if ( aPlayer != none && aPlayer.Pawn != none )
	{
		aPlayer.SetLocation( newPlayerSpawn.Location );
		aPlayer.Pawn.SetLocation( newPlayerSpawn.Location );
	}
}

function setupWaveWeaponSpawns()
// Setups wave's random weapon spawns.
{
	local int groupIndex, index;
	local KFRandomItemSpawn randomSpawn;

	forEach DynamicActors( Class'KFRandomItemSpawn',randomSpawn )
	{
		groupIndex = waveWeaponGroupIndex();
		log( "RLOG: groupIndex = " @ groupIndex );
		for ( index = 0;index <= 7; index++ )
		{
			randomSpawn.default.PickupClasses[index] = weaponGroups[groupIndex].weaponPickupClassToUse();
			randomSpawn.PickupClasses[index] = weaponGroups[groupIndex].weaponPickupClassToUse();
		}
	}
}

function int waveWeaponGroupIndex()
// Returns the weapon group to use when deciding item spawning.
{
	local int currentWeaponGroup; // Maximum tier weapon group for current wave
	local int groupWeightTotal; // Total weight of receiver's weapon group classes
	local int randomIndex,tally,index;

	currentWeaponGroup = maximumTierWeaponGroupIndex();
	log( "RLOG: currentWeaponGroup = " @ currentWeaponGroup );

// Definitive weapon group selection
	for( index = 0 ; index < ArrayCount( weaponGroups ) ; index++ )
		groupWeightTotal += weaponGroups[index].weight;

	randomIndex = rand( groupWeightTotal + 1 );
	tally = weaponGroups[0].weight;

	index = 0;
	while ( index < currentWeaponGroup && tally < randomIndex )
	{
		index++;
		Tally += weaponGroups[index].weight;
	}

	return index;
}

function int maximumTierWeaponGroupIndex()
// Returns maximum tier weapon group index for current wave.
{
	log( "RLOG: FinalWave = " @ FinalWave );
	log( "RLOG: WaveNum = " @ WaveNum );
	log( "RLOG: KFGameLength = " @ KFGameLength );
	log( "RLOG: GL_Short = " @ GL_Short );
	log( "RLOG: GL_Normal = " @ GL_Normal );
	log( "RLOG: GL_Long = " @ GL_Long );
	log( "RLOG: GL_Custom = " @ GL_Custom );

/*
	FinalWave counts first wave as 1 (IE: FinalWave of a GL_Short game is 4.
	WaveNum counts first wave as 0 (IE: WaveNum of the last wave of a GL_Short game is 3.
*/
	if( FinalWave > 1 && WaveNum+1 == 1 )
		return 0;
	if( KFGameLength == GL_Short )
		return WaveNum;
	else if( KFGameLength == GL_Normal )
	{
		if( WaveNum+1 >= 2 || WaveNum+1 <= 3 )
			return 1;
		else if( WaveNum+1 >= 4 || WaveNum+1 <= 6 )
			return 2;
		else
			return 3;
	}
	else if( KFGameLength == GL_Long )
	{
		if( WaveNum+1 >= 2 || WaveNum+1 <= 4 )
			return 1;
		else if( WaveNum+1 >= 5 || WaveNum+1 <= 8 )
			return 2;
		else
			return 3;
	}
	else
		return 2;
}

State matchInProgress
{
	function openShops()
	{
		if( !bRandomItemSpawnMechanism )
		{
			damageScaling = 0;
			super.openShops();
		}
	}

	function closeShops()
	{
		if( !bRandomItemSpawnMechanism )
		{
			damageScaling = originalDamageScaling;
			super.closeShops();
		}
	}

	function Timer()
	{
		if(bRandomItemSpawnMechanism && level.timeSeconds > lastItemShuffleTime + 15.0)
			setupPickups();
		super.timer();
	}

	function DoWaveEnd()
	{
		super.doWaveEnd();
		bNotifiedLastManStanding = true;
		if( bRandomItemSpawnMechanism )
		{
//			This is hardcoded to be done on countdown 5, which wont exist since TimeBetweenWaves == 1
			InvasionGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;
			bDidTraderMovingMessage = true;
			bDidMoveTowardTraderMessage = true;
		}
	}

	function SetupPickups()
	{
		local float currentGameDifficulty;

		log("RLOG: setupPickups - l.tSeconds =" @ level.timeSeconds);
		log("RLOG: setupPickups - lastItemShuffleTime =" @ lastItemShuffleTime);
		if( bRandomItemSpawnMechanism )
		{
			lastItemShuffleTime = level.timeSeconds;
			currentGameDifficulty = GameDifficulty;
			setupWaveWeaponSpawns();
			GameDifficulty = 1.0;
		}

		super.setupPickups();

		if( bRandomItemSpawnMechanism )
			GameDifficulty = currentGameDifficulty;
	}
}

event InitGame( string options,out string error )
{
	super.initGame( options,error );

	friendlyFireScale = default.FriendlyFireScale;

	if( bRandomItemSpawnMechanism )
	{
		bDidTraderMovingMessage = true;
		bDidMoveTowardTraderMessage = true;
		TimeBetweenWaves = 1;
	}
}

event BroadcastLocalizedMessage( class<LocalMessage> MessageClass, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	if( bRandomItemSpawnMechanism && messageClass == class'KFMod.WaitingMessage' )
		super.broadcastLocalizedMessage( class'KFDMMayhem.MHWaitingMessage',switch,relatedPRI_1,relatedPRI_2,optionalObject );
	else
		super.broadcastLocalizedMessage( messageClass,switch,relatedPRI_1,relatedPRI_2,optionalObject );
}

function bool changeTeam( Controller other,int num,bool bNewTeam )
{
	return super( TeamGame ).changeTeam( other,num,bNewTeam );
}

function byte pickTeam( byte num,Controller C )
{
	log("RLOG: PickTeam");
	return super( TeamGame ).pickTeam( num,c );
}

function int reduceDamage( int damage,pawn injured,pawn instigatedBy,vector hitLocation,out vector momentum,class<DamageType> damageType )
{
	local float tempFriendlyFireScale;

	log( "RLOG: original damage =" @ damage );

//	KFGameType assumes everyone its on the same team
	if( MHHumanPawn( injured ) != none && MHHumanPawn( instigatedBy ) != none &&
	injured.playerReplicationInfo.team.teamIndex == instigatedBy.playerReplicationInfo.team.teamIndex )
		tempFriendlyFireScale = FriendlyFireScale;

	super.reduceDamage( damage,injured,instigatedBy,hitLocation,momentum,damageType );

	if( MHHumanPawn( injured ) != none && MHHumanPawn( instigatedBy ) != none &&
	injured.playerReplicationInfo.team.teamIndex == instigatedBy.playerReplicationInfo.team.teamIndex )
		FriendlyFireScale = tempFriendlyFireScale;

	if( MHHumanPawn( injured ) != none && MHHumanPawn( instigatedBy ) != none )
		damage *= damageScaling;

	log( "RLOG: reduced damage =" @ damage );

	return damage;
}

function ScoreKill(Controller Killer, Controller Other)
{
	local PlayerReplicationInfo OtherPRI;
	local float KillScore;

	OtherPRI = Other.PlayerReplicationInfo;
	if ( OtherPRI != None )
	{
		OtherPRI.NumLives++;
		OtherPRI.Score -= (OtherPRI.Score * (GameDifficulty * 0.05));	// you Lose 35% of your current cash on suicidal, 15% on normal.
//		OtherPRI.Team.Score -= (OtherPRI.Score * (GameDifficulty * 0.05));

		if (OtherPRI.Score < 0 )
			OtherPRI.Score = 0;
		if (OtherPRI.Team.Score < 0 )
			OtherPRI.Team.Score = 0;

		OtherPRI.Team.NetUpdateTime = Level.TimeSeconds - 1;
//		OtherPRI.bOutOfLives = true;
//		if( Killer!=None && Killer.PlayerReplicationInfo!=None && Killer.bIsPlayer )
		if( Killer!=None && Killer.PlayerReplicationInfo!=None && Killer.bIsPlayer &&
		other.bIsPlayer && killer.PlayerReplicationInfo.Team.TeamIndex == other.PlayerReplicationInfo.Team.TeamIndex &&
		!bTeamGame )
			BroadcastLocalizedMessage(class'KFInvasionMessage',1,OtherPRI,Killer.PlayerReplicationInfo);
		else if( Killer==None || Monster(Killer.Pawn)==None )
			BroadcastLocalizedMessage(class'KFInvasionMessage',1,OtherPRI);
		else BroadcastLocalizedMessage(class'KFInvasionMessage',1,OtherPRI,,Killer.Pawn.Class);
		CheckScore(None);
	}

	if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreKill(Killer, Other);

	if ( MonsterController(Killer) != None )
		return;

	if( (killer == Other) || (killer == None) )
	{
		if ( Other.PlayerReplicationInfo != None )
		{
			Other.PlayerReplicationInfo.Score -= 1;
			Other.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
			ScoreEvent(Other.PlayerReplicationInfo,-1,"self_frag");
		}
	}

	if ( Killer==None || !Killer.bIsPlayer || (Killer==Other) )
		return;

	if ( Other.bIsPlayer )
	{
		if( killer.PlayerReplicationInfo.Team.TeamIndex != other.PlayerReplicationInfo.Team.TeamIndex )
			Killer.PlayerReplicationInfo.Team.Score += 1;
		else
//		Killer.PlayerReplicationInfo.Score -= 5;
//		Killer.PlayerReplicationInfo.Team.Score -= 2;
		Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
		ScoreEvent(Killer.PlayerReplicationInfo, -5, "team_frag");
		return;
	}
	if ( LastKilledMonsterClass == None )
		KillScore = 1;
	else if(Killer.PlayerReplicationInfo !=none)
	{
		KillScore = LastKilledMonsterClass.Default.ScoringValue;

		// Scale killscore by difficulty
		if ( GameDifficulty >= 7.0 ) // Suicidal
		{
			KillScore *= 0.65;
		}
		else if ( GameDifficulty >= 4.0 ) // Hard
		{
			KillScore *= 0.85;
		}
		else if ( GameDifficulty >= 2.0 ) // Normal
		{
			KillScore *= 1.0;
		}
		else //if ( GameDifficulty == 1.0 ) // Beginner
		{
			KillScore *= 2.0;
		}

		// Increase score in a short game, so the player can afford to buy cool stuff by the end
		if( KFGameLength == GL_Short )
		{
			KillScore *= 1.75;
		}

		KillScore = Max(1,int(KillScore));
		Killer.PlayerReplicationInfo.Kills++;
		Killer.PlayerReplicationInfo.Score += KillScore;
//		Killer.PlayerReplicationInfo.Team.Score += KillScore;
		Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
		TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "tdm_frag");
		if( KFPlayerReplicationInfo(Killer.PlayerReplicationInfo)!=None )
			KFPlayerReplicationInfo(Killer.PlayerReplicationInfo).ThreeSecondScore+=KillScore;
	}
	if (Killer.PlayerReplicationInfo !=none && Killer.PlayerReplicationInfo.Score < 0)
		Killer.PlayerReplicationInfo.Score = 0;
}

//Should be empty anyways.
function DiscardInventory( Pawn Other );

function addDefaultInventory(Pawn playerPawn)
{
	local int index;
	local Inventory oldItem,newItem;
	local class <KFWeaponPickup> weaponPickupClass;

	if(bRandomItemSpawnMechanism || MHPlayerController(playerPawn.controller).lastPawnsInventory == none)
	{
		super.addDefaultInventory(playerPawn);
		if(bRandomItemSpawnMechanism && WaveNum >= 1)
		{
			weaponPickupClass = (New class'MHSpawnGroup').weaponPickupClassToUse();
			newItem = spawn(weaponPickupClass.default.inventoryType);
			if(newItem != none)
			{
				newItem.giveTo(playerPawn);
				newItem.PickupFunction(playerPawn);
				playerPawn.controller.switchToBestWeapon();
			}
		}
		return;
	}

//	Creating new inventory identically to the old one from the controller (see also MHHumanPawn.died).
	for(oldItem = MHPlayerController(playerPawn.controller).lastPawnsInventory;oldItem != none;oldItem = oldItem.Inventory)
	{
		newItem = Spawn(oldItem.class);

		if(newItem != none && !newItem.isA('Ammunition'))
		{
			newItem.GiveTo(playerPawn);
			newItem.PickupFunction(playerPawn);
/*
			if(KFWeapon(newItem) != none)
			{
				KFWeapon(newItem).sellValue = float(class<KFWeaponPickup>(InventoryClass.default.PickupClass).default.Cost) * SellValueScale * 0.75;
			}
*/
			for(index = 0;index < 2 /*NUM_FIRE_MODES*/;index++)
			{
				log("RLOG: AmmoAmountSingle:" @ Weapon(newItem).ammoAmount(index));
				if(Weapon(oldItem).ammoAmount(index) != Weapon(newItem).AmmoAmount(index))
				{
					if(Weapon(oldItem).ammoAmount(index) > Weapon(newItem).ammoAmount(index))
						Weapon(newItem).addAmmo(Weapon(oldItem).AmmoAmount(index) - Weapon(newItem).AmmoAmount(index),index);
					else
						Weapon(newItem).consumeAmmo(index,Weapon(newItem).AmmoAmount(index) - Weapon(oldItem).AmmoAmount(index));
				}
				log("RLOG: AmmoAmountSingle:" @ Weapon(newItem).ammoAmount(index));
			}
		}
	}

	playerPawn.controller.switchToBestWeapon();

	while(MHPlayerController(playerPawn.controller).lastPawnsInventory != none)
		MHPlayerController(playerPawn.controller).lastPawnsInventory.Destroy();
	MHPlayerController(playerPawn.controller).lastPawnsInventory = none;

}

function SetupWave()
{
	local int i,j;
	local float NewMaxMonsters;
	//local int m;
	local float DifficultyMod, NumPlayersMod;
	local int UsedNumPlayers;

	if ( WaveNum > 15 )
	{
		SetupRandomWave();
		return;
	}

	TraderProblemLevel = 0;
	rewardFlag=false;
	ZombiesKilled=0;
	WaveMonsters = 0;
	WaveNumClasses = 0;
	NewMaxMonsters = Waves[WaveNum].WaveMaxMonsters;

	if(bLimitAmountOfSpecimens)
		DifficultyMod = 0.7;
	else
		// scale number of zombies by difficulty
		if ( GameDifficulty >= 7.0 ) // Suicidal
		{
			DifficultyMod=1.7;
		}
		else if ( GameDifficulty >= 4.0 ) // Hard
		{
			DifficultyMod=1.3;
		}
		else if ( GameDifficulty >= 2.0 ) // Normal
		{
			DifficultyMod=1.0;
		}
		else //if ( GameDifficulty == 1.0 ) // Beginner
		{
			DifficultyMod=0.7;
		}

	UsedNumPlayers = NumPlayers + NumBots;

	// Scale the number of zombies by the number of players. Don't want to
	// do this exactly linear, or it just gets to be too many zombies and too
	// long of waves at higher levels - Ramm
	switch ( UsedNumPlayers )
	{
		case 1:
			NumPlayersMod=1;
			break;
		case 2:
			NumPlayersMod=2;
			break;
		case 3:
			NumPlayersMod=2.75;
			break;
		case 4:
			NumPlayersMod=3.5;
			break;
		case 5:
			NumPlayersMod=4;
			break;
		case 6:
			NumPlayersMod=4.5;
			break;
		default:
			NumPlayersMod=UsedNumPlayers*0.8; // in case someone makes a mutator with > 6 players
	}

	NewMaxMonsters = NewMaxMonsters * DifficultyMod * NumPlayersMod;

	TotalMaxMonsters = Clamp(NewMaxMonsters,5,800);  //11, MAX 800, MIN 5

	MaxMonsters = Clamp(TotalMaxMonsters,5,MaxZombiesOnce);
	//log("****** "$MaxMonsters$" Max at once!");

	KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonsters=TotalMaxMonsters;
	KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonstersOn=true;
	WaveEndTime = Level.TimeSeconds + Waves[WaveNum].WaveDuration;
	AdjustedDifficulty = GameDifficulty + Waves[WaveNum].WaveDifficulty;

	j = ZedSpawnList.Length;
	for( i=0; i<j; i++ )
		ZedSpawnList[i].Reset();
	j = 1;
	SquadsToUse.Length = 0;

	for ( i=0; i<InitSquads.Length; i++ )
	{
		if ( (j & Waves[WaveNum].WaveMask) != 0 )
		{
			SquadsToUse.Insert(0,1);
			SquadsToUse[0] = i;

			// Ramm ZombieSpawn debugging
			/*for ( m=0; m<InitSquads[i].MSquad.Length; m++ )
			{
			   log("Wave "$WaveNum$" Squad "$SquadsToUse.Length$" Monster "$m$" "$InitSquads[i].MSquad[m]);
			}
			log("****** "$TotalMaxMonsters);*/
		}
		j *= 2;
	}

	// Save this for use elsewhere
	InitialSquadsToUseSize = SquadsToUse.Length;
	bUsedSpecialSquad=false;
	SpecialListCounter=1;

	//Now build the first squad to use
	BuildNextSquad();
}

defaultproperties
{
     bNotifiedLastManStanding=True
     KFHints(5)="The Scrake. Yes, that IS a chainsaw he's carrying…  nothing subtle about him!"
     KFHints(7)="The Bloat. Not too hard to kill, but its' bile is poisonous, so make sure you keep out of range!"
     KFHints(12)="The Gorefast - tends to live up to its' name, so watch out for it speeding in towards you."
     KFHints(15)="You can use your medic gun to heal mobs attacking enemies."
     DefaultPlayerClassName="KFDMMayhem.MHHumanPawn"
     HUDType="KFDMMayhem.MHHUDKillingFloor"
     MutatorClass="KFDMMayhem.KFDMMayhemMut"
     PlayerControllerClass=Class'KFDMMayhem.MHPlayerController'
     PlayerControllerClassName="KFDMMayhem.MHPlayerController"
}
