//////////////////////////////////////////


//		Gershom 'Blackcheetah' Ikpe

//		Specimenation Versus Gametype

//      Modified by metalMedved.com - custom-made weapons, skins and mutators

///////////////////////////////////////////
	
class zombieGameType extends KFGametype config;

#exec obj load file=../sounds/patchsounds.uax


var string SpecimenClass;

var() int ThisOnlySpecieNum, ZNum;
var bool botsadded,bspecimen,brestart,bsecondlevel,bsiren,bhighlevel,bfp,bkillthezeds;
Var() string numNames[16],num2Names[16];
var int numn,ScrakeUse,FPUse,SirenUse,FPTimer,SCTimer,BcanBroadcastNow;
var(Numbers) int HumanNums,SpecimenNums,PeopleNums,KillTimer;
var() int SwitchOvernum,Tries;
var bool bPlayerBoss, bLeave;
var string BossName;
var float Bosshealth, BossMaxHealth;
var ZombieBoss PlayerBoss;

var float TraderOpenTime,TraderCloseTime,LastTraderOpen,LastTraderCloseTime;
var ShopVolume OldShop;
var bool bTraderClosed;
var zTraderLure Lure;

var array<ZombieVolume> Volumes;

var bool bSpawnInShop, bTraderBr, bShowTrader;

var float LastPerkMessageTime, perkint, ShowTraderTime,TraderDist,BossSpawnTime;

/*******************/function postbeginplay()
{
	local betheclot mut;
	local ZombieVolume V;
	local int i;

	super.postbeginplay();
	
	foreach allactors(class'betheclot',mut)
		if(mut==none)
	basemutator=spawn(class'betheclot',,,);

	gamereplicationinfo.servername="[Versus b4]   "$gamereplicationinfo.default.servername;

	foreach allactors(class'ZombieVolume', V)
	{
		if( V != none )
		{
			Volumes.length = i + 1;
			Volumes[i] = V;
			i++;
		}
	}
	
	TraderCloseTime = class'betheclot'.default.TraderCloseTime * 60;
		
	if( maxspectators < 6)
	maxspectators=6;
}
function Openshops();
function DoWaveEnd();
function CloseShops();
function selectshop();
/*******************/function ZombieVolume FindSpawningVolume(optional bool bIgnoreFailedSpawnTime, optional bool bBossSpawning)
{

	if( !bShowTrader )
		return super.FindSpawningVolume(bIgnoreFailedSpawnTime,bBossSpawning);

}

/*******************/function Logout( Controller Exiting )
{


	TakeFromList(exiting);

	if(exiting.pawn!=none&&exiting.isa('playercontroller'))
	{
		exiting.bisplayer = true;
		exiting.bhiddened=true;
		exiting.pawn.destroy();
	}


	super.logout(exiting);


}

function bool AddBoss()
{
	local int ZombiesAtOnceLeft;
	local int numspawned;

	FinalSquadNum = 0;

    // Force this to the final boss class
	NextSpawnSquad.Length = 1;
	NextSpawnSquad[0] = Class<KFMonster>(DynamicLoadObject(EndGameBossClass,Class'Class'));

	//if( LastZVol==none )
	//{
		LastZVol = FindSpawningVolume(false, true);
		if(LastZVol!=None)
			LastSpawningVolume = LastZVol;
	//}
	BossSpawnTime=level.timeseconds;
	killallclot();

	kbroadcast("Patriarch can heal using the quickheal button",none,true);

	if(LastZVol == None)
	{
		LastZVol = FindSpawningVolume(true, true);
		if( LastZVol!=None )
			LastSpawningVolume = LastZVol;

		if( LastZVol == none )
		{
            //log("Error!!! Couldn't find a place for the Patriarch after 2 tries, trying again later!!!");
            TryToSpawnInAnotherVolume(true);
            return false;
		}
	}

    // How many zombies can we have left to spawn at once
    ZombiesAtOnceLeft = MaxMonsters - NumMonsters;

    //log("Patrarich spawn, MaxMonsters = "$MaxMonsters$" NumMonsters = "$NumMonsters$" ZombiesAtOnceLeft = "$ZombiesAtOnceLeft$" TotalMaxMonsters = "$TotalMaxMonsters);

	if(LastZVol.SpawnInHere(NextSpawnSquad,,numspawned,TotalMaxMonsters,32/*ZombiesAtOnceLeft*/,,true))
	{
        //log("Spawned Patriarch - numspawned = "$numspawned);

        NumMonsters+=numspawned;
        WaveMonsters+=numspawned;

        return true;
	}
    else
    {
        //log("Failed Spawned Patriarch - numspawned = "$numspawned);

        TryToSpawnInAnotherVolume(true);
        return false;
    }

}
/*******************/function takefromlist(controller c)
{
	local int i;


	for( i=0; i<16; i++ )
	{
	    if(num2names[i]!=""&&c.playerreplicationinfo!=none&&c.playerreplicationinfo.playername==num2names[i])
	    num2names[i]="";
	}

	for( i=0; i<16; i++ )
	{
		if(numnames[i]!=""&&c.playerreplicationinfo!=none&&c.playerreplicationinfo.playername==numnames[i])
		numnames[i]="";
	}

}

	/*******************/function bool AllinShop()
	{
		local kfhumanpawn p;
		local int i;
		
		foreach OldShop.touchingactors(class'kfhumanpawn', p)
		{
			if(p != none && p.health > 0 )
				i++;
		}
		
		if( i >= NoMoreLiving() && NoMoreLiving()>0)
		   return true;
		return false;
	}
	/*******************/function bool HalfinShop()
	{
		local kfhumanpawn p;
		local int i;
		
		foreach OldShop.touchingactors(class'kfhumanpawn', p)
		{
			if(p != none && p.health > 0 )
				i++;
		}
		
		if( float(NoMoreLiving()/i) <= 2 && NoMoreLiving()>=2 && i > 0)
		   return true;
		return false;
	}
	/*******************/function bool AllOutShop()
	{
		local kfhumanpawn p;
		local int i;
		
		foreach OldShop.touchingactors(class'kfhumanpawn', p)
		{
			if(p != none && p.health > 0 )
				i++;
		}
		
		if( i == 0 )
		   return true;
		return false;
	}
State MatchInProgress
{




	function bool BootShopPlayers()
	{
		local int i,j;
		local bool bRes;

		if(bSpawnInShop)
			return false;

		j = ShopList.Length;
		for( i=0; i<j; i++ )
		{
			if( ShopList[i].BootPlayers() )
				bRes = True;
		}
		Return bRes;
	}
	/*******************/function Timer()
	{

		super.Timer();

		if( TraderCloseTime < Level.Timeseconds - LastTraderCloseTime && !bTraderClosed && bWaveinprogress )
			 BroadcastLocalizedMessage(class'zTrader', 3);

	}
	
			/*******************/function OpenShops()
	{
		local Controller C;

		if( !bTraderBr )
			return;


		bTraderBr = false;

        if ( KFGameReplicationInfo(GameReplicationInfo).CurrentShop == none )
        {
            SelectShop();
        }

		//KFGameReplicationInfo(GameReplicationInfo).CurrentShop.OpenShop();

		// Tell all players to start showing the path to the trader
		For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( C.Pawn!=None && C.Pawn.Health>0 )
			{
				
				   
				if( KFPlayerController(C) !=None )
				{
					KFPlayerController(C).SetShowPathToTrader(true);

					// Have Trader tell players that the Shop's Open
					if ( WaveNum < FinalWave )
					{
						KFPlayerController(C).ClientLocationalVoiceMessage(C.PlayerReplicationInfo, none, 'TRADER', 2);
					}
					else
					{
						KFPlayerController(C).ClientLocationalVoiceMessage(C.PlayerReplicationInfo, none, 'TRADER', 3);
					}

					//Hints
					KFPlayerController(C).CheckForHint(31);
					HintTime_1 = Level.TimeSeconds + 11;
				}
			}
			
			if(!IsSpecimen(C) && KFPlayerController(C)!=none && C.Pawn==None && !C.PlayerReplicationInfo.bOnlySpectator)
			{
				restartplayer(C);
				KFPlayerController(C).SetShowPathToTrader(true);
			}
		}
	}

	/*******************/function CloseShops()
	{
		local Controller C;

		if( !bTraderBr )
			return;


		bTraderBr = false;

		SelectShop();

		// Tell all players to stop showing the path to the trader
		For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( C.Pawn!=None && C.Pawn.Health>0 )
			{
				c.pawn.setcollision(true,true,true);
				   
				if( KFPlayerController(C) !=None )
				{
					KFPlayerController(C).SetShowPathToTrader(false);

					if ( WaveNum < FinalWave - 1 )
					{
						// Have Trader tell players that the Shop's Closed
						KFPlayerController(C).ClientLocationalVoiceMessage(C.PlayerReplicationInfo, none, 'TRADER', 6);
					}
				}
			}
		}
	}


	/*******************/function tick(float d)
	{
    
		local string perkname;

		if(4 < level.timeseconds - BossSpawnTime )
			viewingboss=none;

		switch( perkint )
		{
			case 0:perkname="commando";break;
			case 1:perkname="berserker";break;
			case 2:perkname="fieldmedic";break;
			case 3:perkname="sharpshooter";break;
			case 4:perkname="demolitions";break;
			case 5:perkname="supportspecialist";break;
			case 6:perkname="berserker";break;
			case 7:perkname="firebug";break;
		}
		bNoLateJoiners = false;

		if( playerboss != none && playerboss.health <= 0 )
			{
				wavenum++;
				EndGame(none,"Timelimit");
				return;
			}
		super.tick(d);
	

		if( 30 < level.timeseconds - LastPerkMessageTime ) 
		{
			perkint=(perkint+1)%8;
			LastPerkMessageTime  = level.timeseconds;
			KBroadCast("Type 'perk "$perkname$"' in console or 'Say "$perkname$"' for "$perkname$" perk",none,true);
		}

		if(TraderDist>0)
		TraderDist-=1;
	
		humannums=getplayers();
		specimennums=getspecimens();
		peoplenums=getpeople();


		if(maxplayers>32)
		maxplayers=32;

	  
	

		scrakeuse=gettypenum('awesomescrake');
		sirenuse=gettypenum('awesomesiren');
		fpuse=gettypenum('awesomefleshpound');

		tick2();
	}

		
		
	function ShowTrader()
	{
		LOCAL CONTROLLER C;

		TraderDist=250;
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( playercontroller(C) == none)
				continue;

				playercontroller(C).SetViewTarget(Lure);
				playercontroller(C).ClientSetViewTarget(lure);
				playercontroller(C).bbehindview=FALSE;
				playercontroller(C).ClientSetBehindView(FALSE);
		}
		bShowTrader=true;
		ShowTraderTime=level.timeseconds;
		KillAllClot();
	}	
		

	/*******************/function tick2()
	{
			
		local Controller C;
		local bool bOneMessage;
		local Bot B;

		for ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( playercontroller(C) == none)
				continue;
				
			if( !bshowtrader && KFHumanPawn(C.pawn) != none && viewingboss == none)
				{
					playercontroller(C).SetViewTarget(c.pawn);
					playercontroller(C).ClientSetViewTarget(c.pawn);
					playercontroller(C).bbehindview=FALSE;
					playercontroller(C).ClientSetBehindView(FALSE);
				}

			//ZombiePlayercontroller(C).drawnums(specimennums,humannums);

			if( bShowTrader && 4 > level.timeseconds - ShowTraderTime)
			{

				Lure.setlocation(gettrader().location+vect(0,0,50)+TraderDist*vector(gettrader().rotation));
					playercontroller(C).SetViewTarget(Lure);
					playercontroller(C).ClientSetViewTarget(lure);
					playercontroller(C).bbehindview=FALSE;
					playercontroller(C).ClientSetBehindView(FALSE);
			}
			else if( bShowTrader && 4 < level.timeseconds - showtradertime )
			{
					playercontroller(C).SetViewTarget(c.pawn);
					playercontroller(C).ClientSetViewTarget(c.pawn);
					playercontroller(C).bbehindview=FALSE;
					playercontroller(C).ClientSetBehindView(FALSE);
				Lure.setlocation(gettrader().location+150*vector(gettrader().rotation));
			}
		}
		if( bShowTrader && 5 < level.timeseconds - showtradertime )
			bShowTrader = false;

		if( TraderCloseTime < Level.Timeseconds - LastTraderCloseTime && bTraderClosed && bWaveinprogress && wavenum < finalwave)
		{
			bTraderBr=true;
			kfgamereplicationinfo(gamereplicationinfo).CurrentShop.OpenShop();
			OldShop = kfgamereplicationinfo(gamereplicationinfo).CurrentShop;
			bTraderClosed = false;
			OpenShops();
			BroadcastLocalizedMessage(class'zTrader', 3);
			LastTraderOpen = level.timeseconds;
			Lure = spawn(class'zTraderLure',,,gettrader().location+vect(0,0,50)+250*vector(gettrader().rotation));
			Lure.setrotation( rotator(gettrader().location - lure.location) );
			ShowTrader();
			for ( C=Level.ControllerList; C!=None; C=C.NextController )
			{
				if( C.isa('bot') )
					Bot(C).GOTOSTATE('TraderHunt', 'Begin');
			}
		}
		else if( TraderCloseTime < Level.Timeseconds - LastTraderCloseTime && AllInShop() && !bTraderClosed && bWaveinprogress)
		{
			if( 7 < level.timeseconds - LastTraderOpen )
			{
				bTraderBr=true;
				OldShop = kfgamereplicationinfo(gamereplicationinfo).CurrentShop;
				//killallzed();
				wavenum++;
				DoWaveEnd();
				bSpawnInShop=true;
				totalmaxmonsters=0;
				kfgamereplicationinfo(gamereplicationinfo).maxmonsters=0;
				nummonsters=0;
				bTraderClosed = true;
				OpenShops();
				Lure.Destroy();
				bLeave = false;
				LastTraderCloseTime = level.timeseconds;
				WaveCountDown = 40;
				Oldshop.closeshop();
				StartGameMusic(false);	

					for ( C=Level.ControllerList; C!=None; C=C.NextController )
					{
						/*if( C.bisplayer == true && c.pawn == none&&!C.PlayerReplicationInfo.bOnlySpectator)
						{
							restartplayer(C);
						}*/
						if( monstercontroller(c) !=none )
							c.gotostate('ZombieRoam');
						if( Zombieplayercontroller(c) != none) zombieplayercontroller(c).greaseplaysound(sound'PerkAchieved',true,64);
					}
			}
			bSpawnInShop=true;
		}
		else if( TraderCloseTime < Level.Timeseconds - LastTraderCloseTime && HalfInShop() && !bTraderClosed && bWaveinprogress)
		{
			if( 30 < level.timeseconds - LastTraderOpen )
			{
				bTraderBr=true;
				OldShop = kfgamereplicationinfo(gamereplicationinfo).CurrentShop;
				//killallzed();
				wavenum++;
				DoWaveEnd();
				bSpawnInShop=true;
				kbroadcast("Trader cannot wait!",none,false);
				totalmaxmonsters=0;
				kfgamereplicationinfo(gamereplicationinfo).maxmonsters=0;
				nummonsters=0;
				bTraderClosed = true;
				OpenShops();
				Lure.Destroy();
				bLeave = false;
				LastTraderCloseTime = level.timeseconds;
				WaveCountDown = 40;
				Oldshop.closeshop();
				StartGameMusic(false);
					for ( C=Level.ControllerList; C!=None; C=C.NextController )
					{
						if( C.bisplayer == true && c.pawn == none&&!C.PlayerReplicationInfo.bOnlySpectator)
						{
							restartplayer(C);
						}
						if( monstercontroller(c) !=none )
							c.gotostate('ZombieRoam');
						if( Zombieplayercontroller(c) != none) zombieplayercontroller(c).greaseplaysound(sound'PerkAchieved',true,64);
					}
			}
		}
		else if( 40 < Level.Timeseconds - LastTraderCloseTime && bTraderClosed && !bWaveinprogress )
		{
			bTraderBr=true;
			CloseShops();
			OldShop.OpenShop();
			bTraderClosed = false;
			LastTraderCloseTime = level.timeseconds;
			bleave = true;
			wavecountdown=0;
			
			StartGameMusic(false);
			bWaveInProgress = true;
			KFGameReplicationInfo(GameReplicationInfo).bWaveInProgress = true;

				// Randomize the ammo pickups again
				if( WaveNum > 0 )
				{
					SetupPickups();
				}

				if( WaveNum == FinalWave && bUseEndGameBoss )
				{
				    StartWaveBoss();
				}
				else
				{
					SetupWave();

					for ( C = Level.ControllerList; C != none; C = C.NextController )
					{
						if ( PlayerController(C) != none )
						{
							PlayerController(C).LastPlaySpeech = 0;

							if ( KFPlayerController(C) != none )
							{
								KFPlayerController(C).bHasHeardTraderWelcomeMessage = false;
							}
						}

						if ( Bot(C) != none )
						{
							B = Bot(C);
							InvasionBot(B).bDamagedMessage = false;
							B.bInitLifeMessage = false;

							if ( !bOneMessage && (FRand() < 0.65) )
							{
								bOneMessage = true;

								if ( (B.Squad.SquadLeader != None) && B.Squad.CloseToLeader(C.Pawn) )
								{
									B.SendMessage(B.Squad.SquadLeader.PlayerReplicationInfo, 'OTHER', B.GetMessageIndex('INPOSITION'), 20, 'TEAM');
									B.bInitLifeMessage = false;
								}
							}
						}
					}
			    }

			
		}
		else if( bLeave && !bTraderClosed && bWaveinprogress && AllOutShop())
		{
			if( 1 < level.timeseconds - LastTraderOpen )
			{
				OldShop.CloseShop();
				bTraderClosed = true;
				bLeave = false;
				bSpawnInShop=false;
				//StartGameMusic(true);
				oldshop.bootplayers();
			}
		}
		else if( 30 < Level.timeseconds - LastTraderCloseTime && bLeave && !bTraderClosed && bWaveinprogress && !AllOutShop())
		{
			oldshop.bootplayers();
		}
		else LastTraderOpen = level.timeseconds;
		

	}
		function DoWaveEnd()
	{
		local Controller C;
		local KFDoorMover KFDM;
		local Controller Survivor;
		local int SurvivorCount;

        // Only reset this at the end of wave 0. That way the sine wave that scales
        // the intensity up/down will be somewhat random per wave
        if( WaveNum < 1 )
        {
            WaveTimeElapsed = 0;
        }

		if ( !rewardFlag )
			RewardSurvivingPlayers();

		/*if( bDebugMoney )
		{
			log("$$$$$$$$$$$$$$$$ Wave "$WaveNum$" TotalPossibleWaveMoney = "$TotalPossibleWaveMoney,'Debug');
			log("$$$$$$$$$$$$$$$$ TotalPossibleMatchMoney = "$TotalPossibleMatchMoney,'Debug');
			TotalPossibleWaveMoney=0;
		}*/

		// Clear Trader Message status
		bDidTraderMovingMessage = true;
		bDidMoveTowardTraderMessage = true;

		bWaveInProgress = false;
		bWaveBossInProgress = false;
		bNotifiedLastManStanding = false;

		kfgamereplicationinfo(gamereplicationinfo).wavenumber = wavenum;
		KFGameReplicationInfo(GameReplicationInfo).bWaveInProgress = false;

		WaveCountDown = Max(TimeBetweenWaves,1);
		KFGameReplicationInfo(GameReplicationInfo).TimeToNextWave = WaveCountDown;

		for ( C = Level.ControllerList; C != none; C = C.NextController )
		{
			if ( C.PlayerReplicationInfo != none )
			{
				C.PlayerReplicationInfo.bOutOfLives = false;
				C.PlayerReplicationInfo.NumLives = 0;

				if ( KFPlayerController(C) != none )
				{
					if ( KFPlayerReplicationInfo(C.PlayerReplicationInfo) != none )
					{
						KFPlayerController(C).bChangedVeterancyThisWave = false;

						if ( KFPlayerReplicationInfo(C.PlayerReplicationInfo).ClientVeteranSkill != KFPlayerController(C).SelectedVeterancy )
						{
							KFPlayerController(C).SendSelectedVeterancyToServer();
						}
					}
				}

				if ( C.Pawn != none )
				{
					if ( C.bisplayer )
					{
						Survivor = C;
						SurvivorCount++;
					}
				}
				else if ( !C.PlayerReplicationInfo.bOnlySpectator )
				{
					C.PlayerReplicationInfo.Score = Max(MinRespawnCash,int(C.PlayerReplicationInfo.Score));

					if(C.bisplayer)
						restartplayer(C);
					
					if( PlayerController(C) != none )
					{
						PlayerController(C).GotoState('PlayerWaiting');
						PlayerController(C).SetViewTarget(C);
						PlayerController(C).ClientSetBehindView(false);
						PlayerController(C).bBehindView = False;
						PlayerController(C).ClientSetViewTarget(C.Pawn);
					}

					if(!C.isa('bot'))
					C.ServerReStartPlayer();
				}

				if ( KFPlayerController(C) != none )
				{
					if ( KFSteamStatsAndAchievements(PlayerController(C).SteamStatsAndAchievements) != none )
					{
						KFSteamStatsAndAchievements(PlayerController(C).SteamStatsAndAchievements).WaveEnded();
					}

                    // Don't broadcast this message AFTER the final wave!
                    if( WaveNum < FinalWave )
                    {
						KFPlayerController(C).bSpawnedThisWave = false;
						BroadcastLocalizedMessage(class'KFMod.WaitingMessage', 2);
					}
					else if ( WaveNum == FinalWave )
					{
						KFPlayerController(C).bSpawnedThisWave = false;
					}
					else
					{
						KFPlayerController(C).bSpawnedThisWave = true;
					}
				}
			}
		}

		if ( Level.NetMode != NM_StandAlone && Level.Game.NumPlayers > 1 &&
			 SurvivorCount == 1 && Survivor != none && KFSteamStatsAndAchievements(Playercontroller(Survivor).SteamStatsAndAchievements) != none )
		{
			KFSteamStatsAndAchievements(Playercontroller(Survivor).SteamStatsAndAchievements).AddOnlySurvivorOfWave();
		}

		bUpdateViewTargs = True;

		//respawn doors
		foreach DynamicActors(class'KFDoorMover', KFDM)
			KFDM.RespawnDoor();
	}
	/*******************/function bool CheckMaxLives(PlayerReplicationInfo Scorer)
	{
		local Controller C;
		local Controller Living;
		local byte AliveCount;

		if ( MaxLives > 0 )
		{
			for ( C=Level.ControllerList; C!=None; C=C.NextController )
			{
				if ( (C.PlayerReplicationInfo != None) && C.bIsPlayer && !C.PlayerReplicationInfo.bOutOfLives && !C.PlayerReplicationInfo.bOnlySpectator)
				{
					AliveCount++;
					if( Living==None )
						Living = C;
				}
			}
			if ( (AliveCount<=0) && bSpawnInShop==false)
			{
				/*if( Tries < 3 && wavenum < finalwave)
				{
					BroadcastLocalizedMessage(class'zWaitingMessage', 3);

					
					tries++;
					killallzed();
					totalmaxmonsters=0;
					kfgamereplicationinfo(gamereplicationinfo).maxmonsters=0;
					nummonsters=0;
					bTraderClosed = true;
					SelectShop();
					OldShop = kfgamereplicationinfo(gamereplicationinfo).CurrentShop;
					oldshop.closeshop();
					OpenShops();
					bSpawnInShop=true;
					Lure.Destroy();
					bLeave = false;
					LastTraderCloseTime = level.timeseconds;
					WaveCountDown = 40;
					kfgamereplicationinfo(gamereplicationinfo).maxmonsters=0;
					nummonsters=0;

					IF( wavenum > 0 )
					{
						wavenum--;
					}

					DoWaveEnd();
					for ( C=Level.ControllerList; C!=None; C=C.NextController )
					{
						if(C.playerreplicationinfo != none && C.playerreplicationinfo.score < 1000)
						   C.playerreplicationinfo.score += 500;
					}
					return false;
				}
				else {*/
						for( C=Level.ControllerList;C!=None;C=C.NextController )
						{
							if (KFPlayerController(C)!= none)
							KFPlayerController(C).NetPlayMusic("KFMenu", MapSongHandler.FadeInTime,MapSongHandler.FadeOutTime);
						}

						EndGame(Scorer,"LastMan");
						return true;
				     
						
			}
			else if( !bNotifiedLastManStanding && AliveCount==1 && Living!=None )
			{
				bNotifiedLastManStanding = true;
				PlayerController(Living).ReceiveLocalizedMessage(Class'KFLastManStandingMsg');
			}
		}
		return false;
	}
	/*******************/function bool UpdateMonsterCount() // To avoid invasion errors.
	{
		local Controller C;
		local int i,j;

		For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( C.Pawn!=None && C.Pawn.Health>0 )
			{
				if( Monster(C.Pawn)!=None && !c.pawn.isa('awesomeclot') && wavenum < finalwave|| zombieboss(c.pawn)!=none)
					i++;
				else j++;
			}
		}
		NumMonsters = i;
		Return (j>0);
	}	
}


state MatchOver
{

	/*******************/function BossLaughtIt()
	{
		local Controller C;

		For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if( KFMonster(C.Pawn)!=None && C.Pawn.Health>0 && KFMonster(C.Pawn).SetBossLaught() )
				Return;

			if( C.isa('playercontroller') && c.bisplayer == false)
				C.bisplayer = true;
		}
	}
}
/*******************/function int ReduceDamage(int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{

	local KFPlayerController PC;

	if( injured.isa('awesomeclot') )
		return 0;

	if ( KFPawn(instigatedBy) != none && KFMonster(Injured) != none )
	{

		if ( KFPlayerReplicationInfo(instigatedBy.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(instigatedBy.PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			Damage = KFPlayerReplicationInfo(instigatedBy.PlayerReplicationInfo).ClientVeteranSkill.Static.AddDamage(KFPlayerReplicationInfo(instigatedBy.PlayerReplicationInfo), KFMonster(Injured), KFPawn(instigatedBy), Damage, DamageType);
		}
		if(instigatedBy.controller != none && playercontroller(instigatedBy.controller) != none)
			DamageInf(damage,playercontroller(instigatedBy.controller));
	}
	else if ( KFPawn(Injured) != none )
	{
		if ( KFPlayerReplicationInfo(Injured.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Injured.PlayerReplicationInfo).ClientVeteranSkill != none )
		{
			Damage = KFPlayerReplicationInfo(Injured.PlayerReplicationInfo).ClientVeteranSkill.Static.ReduceDamage(KFPlayerReplicationInfo(Injured.PlayerReplicationInfo), KFPawn(Injured), KFMonster(instigatedBy), Damage, DamageType);
		}
		
		if( KFMonster(instigatedby) != none && KFMonster(instigatedby).playerreplicationinfo != none)
			{
				if(instigatedBy.controller != none && playercontroller(instigatedBy.controller) != none)
				DamageInf(damage,playercontroller(instigatedBy.controller));
				Zombiepri(instigatedby.playerreplicationinfo).damage += damage;
				if(zombieplayercontroller(instigatedBy.controller) != none)
					zombieplayercontroller(instigatedby.controller).greaseplaysound(sound'woodimpact4',true,64);
				DamageBroadcast(instigatedby.gethumanreadablename()$" > "$injured.gethumanreadablename()$"(+"$damage$")" ,none);
				instigatedby.playerreplicationinfo.score += Damage;
			}
	}


	if( instigatedby!=none&&injured!=none&&instigatedby.isa('awesomesiren')&&injured.isa('monster'))
      damage=0;
      
	if( instigatedby!=none&&injured!=none&&instigatedby.isa('kfhumanpawn')&&injured.isa('kfhumanpawn')&&injured!=instigatedby)
      damage=0;
	  
	if(instigatedby!=none&&injured!=none&&instigatedby.isa('monster')&&injured.isa('kfhumanpawn') &&
		KFPlayerReplicationInfo(Injured.PlayerReplicationInfo).ClientVeteranSkill==class'KFVetBerserker')
	{
		damage=float(damage)*1.2;
		//log("INC DAMAGE FOR ZERK");
	}

	// This stuff cuts thru all the B.S
	if ( DamageType == class'DamTypeVomit' || DamageType == class'DamTypeWelder' || DamageType == class'SirenScreamDamage' || instigatedby.isa('monster')/* || instigatedby.isa('kfhumanpawn')*/)
	{
		if(instigatedby.isa('monster')&&instigatedby.controller!=none&&instigatedby.controller.isa('zombieplayercontroller'))
			kfplayerreplicationinfo(instigatedby.playerreplicationinfo).kills+=damage;
			return damage;
	}

	//if(instigatedby!=none&&injured!=none&&instigatedby.isa('kfhumanpawn')&&injured.isa('monster'))
    //  damage=damage*1.4;
	
	if ( Monster(Injured) != None )
	{
		if ( instigatedBy != None )
		{
			PC = KFPlayerController(instigatedBy.Controller);
			if ( Class<KFWeaponDamageType>(damageType) != none && PC != none )
			{
				Class<KFWeaponDamageType>(damageType).Static.AwardDamage(KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements), Clamp(Damage, 1, Injured.Health));
			}
		}

		return Damage;
	}

	return damage;
}

/*******************/function AddGameSpecificInventory(Pawn p);



/*******************/function scorekill(controller killer,controller other)
{

	local PlayerReplicationInfo OtherPRI;
	local float KillScore;


	OtherPRI = Other.PlayerReplicationInfo;
	if ( OtherPRI != None  && !other.pawn.isa('awesomeclot'))
	{
		log("scorekill");
		if( other.bisplayer )
		{
			OtherPRI.NumLives++;
			OtherPRI.Score -= (OtherPRI.Score * (GameDifficulty * 0.05));	// you Lose 35% of your current cash on suicidal, 15% on normal.
			OtherPRI.Team.Score -= (OtherPRI.Score * (GameDifficulty * 0.05));

			if (OtherPRI.Score < 0 )
				OtherPRI.Score = 0;
			if (OtherPRI.Team.Score < 0 )
				OtherPRI.Team.Score = 0;

			OtherPRI.Team.NetUpdateTime = Level.TimeSeconds - 1;
			OtherPRI.bOutOfLives = true;
		}
		if( Killer!=None && Killer.PlayerReplicationInfo!=None && Killer.bIsPlayer )
			BroadcastLocalizedMessage(class'zInvasionMessage',1,OtherPRI,Killer.PlayerReplicationInfo,Other.Pawn.Class);
		else if( Killer==None || Monster(Killer.Pawn)==None )
			BroadcastLocalizedMessage(class'zInvasionMessage',1,OtherPRI);
		else BroadcastLocalizedMessage(class'zInvasionMessage',1,OtherPRI,,Killer.Pawn.Class);
		CheckScore(None);
	}

	if ( GameRulesModifiers != None )
		GameRulesModifiers.ScoreKill(Killer, Other);

	if ( MonsterController(Killer) != None )
		return;

	if( (killer == Other && killer.bisplayer) || (killer == None))
	{
		if ( Other.PlayerReplicationInfo != None )
		{
			Other.PlayerReplicationInfo.Score -= 1;
			Other.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
			ScoreEvent(Other.PlayerReplicationInfo,-1,"self_frag");
		}
	}


	if ( Other.bIsPlayer && other.playerreplicationinfo != none)
	{
		Killer.PlayerReplicationInfo.Score -= 5;
		Killer.PlayerReplicationInfo.Team.Score -= 2;
		Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
		ScoreEvent(Killer.PlayerReplicationInfo, -5, "team_frag");
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
		Killer.PlayerReplicationInfo.Team.Score += KillScore;
		Killer.PlayerReplicationInfo.NetUpdateTime = Level.TimeSeconds - 1;
		Killer.PlayerReplicationInfo.Team.NetUpdateTime = Level.TimeSeconds - 1;
		TeamScoreEvent(Killer.PlayerReplicationInfo.Team.TeamIndex, 1, "tdm_frag");
		if( KFPlayerReplicationInfo(Killer.PlayerReplicationInfo)!=None )
			KFPlayerReplicationInfo(Killer.PlayerReplicationInfo).ThreeSecondScore+=KillScore;
	}
	if (Killer.PlayerReplicationInfo !=none && Killer.PlayerReplicationInfo.Score < 0)
		Killer.PlayerReplicationInfo.Score = 0;

	
	if(killer != none && killer.bisplayer && killer != other)
    	{
		//other.bisplayer=true;
		
		//if( other != none )
		Switch( Other.Pawn.Class )
		{
			Case Class'ZClot':Zombiepri( killer.playerreplicationinfo).Clotskilled++;break;
			Case Class'awesomeBloat':Zombiepri( killer.playerreplicationinfo).Bloatskilled++;break;
			Case Class'awesomeGoreFast':Zombiepri( killer.playerreplicationinfo).Gorefastskilled++;break;
			Case Class'awesomeStalker':Zombiepri( killer.playerreplicationinfo).Stalkerskilled++;break;
			Case Class'awesomeSiren':Zombiepri( killer.playerreplicationinfo).Sirenskilled++;break;
			Case Class'awesomeHusk':Zombiepri( killer.playerreplicationinfo).Huskskilled++;break;
			Case Class'awesomeCrawler':Zombiepri( killer.playerreplicationinfo).Crawlerskilled++;break;
			Case Class'awesomeScrake':Zombiepri( killer.playerreplicationinfo).Scrakeskilled++;break;
			Case Class'awesomeFleshPound':Zombiepri( killer.playerreplicationinfo).FleshPoundskilled++;break;
		} 
	}

	if(other.isa('playercontroller')&&IsSpecimen(other))
    	{
		log("scorekill");
		other.pawn.lifespan=1.0;
		
		if( zombieplayercontroller(other) != none && other.pawn != none)
		{							
			zombieplayercontroller(other).bReadySpecimen = false;
			zombiepri(other.playerreplicationinfo).bReadySpecimen = false;
		}
				
		if(other.pawn.isa('awesomefleshpound'))
		fpuse--;
		if(other.pawn.isa('awesomesiren'))
		sirenuse--;
		if(other.pawn.isa('awesomescrake'))
		scrakeuse--;

		totalmaxmonsters--;
		if(killer != none && killer != other )
		Broadcast(Self,ParseKillMessage(GetNameOf(Killer.Pawn),GetNameOf(Other.Pawn),class'damagetype'.Default.DeathString),'DeathMessage');

		other.bisplayer = false;

		if( other.pawn != none )
		other.unpossess();

	}

	if(other != none && other.isa('playercontroller')&&other.pawn.isa('kfhumanpawn')&&killer.pawn.isa('monster')&&killer.isa('playercontroller'))
    {
		killer.playerreplicationinfo.score=other.playerreplicationinfo.score+5;
	}
}

/*******************/function KBroadcast(string msg,optional sound plays,optional bool bnotbroadcast)
{
	local controller C;


	for ( C = Level.ControllerList; C != None; C = C.NextController )
	{
		if(c!=none&&playercontroller(C)!=none)
		{

			if(bnotbroadcast==false)
			{
				PlayerController(C).ClearProgressMessages();
				PlayerController(C).SetProgressTime(6);
				PlayerController(C).SetProgressMessage(0, Msg, class'Canvas'.Static.MakeColor(255,50,50));
			}

			
				PlayerController(C).clientplaysound(plays,true,64);
				PlayerController(C).clientmessage(msg);
				bcanbroadcastNow=0;
			
		}

	}

}
/*******************/function DamageInf(int damage, playercontroller pc)
{

	zombieplayercontroller(pc).NewDamage(damage);

}
/*******************/function DamageBroadcast(string msg,optional sound plays)
{

	local controller C;

	For(C = Level.ControllerList; C != none; C = C.nextcontroller)
	{
			if( C.pawn != none && c.isa('playercontroller') )
			{
				zombieplayercontroller(C).addSHit(msg);
				zombieplayercontroller(C).greaseplaysound(plays,true,64);
			}
	}
}

/*******************/function int NoMoreLiving()
{
	local controller C;
	local int i;

	for ( C = Level.ControllerList; C != None; C = C.NextController )
	{
		if(c.isa('controller')&&C.bisplayer==true&&c.playerreplicationinfo.boutoflives==false&&kfpawn(c.pawn) != none)
		{
			i++;
        	}


	}

	return i;
}

/*******************/function bool CanBeSpecimen(controller c,class<actor> a)
{
	local float z,w;

	w=wavenum;
	z=finalwave;
	if(w/z>=0.6&&a==class'awesomefleshpound'&&fpuse<1)
	return true;
	else if(w/z>=0.4&&a==class'awesomescrake'&&scrakeuse<2)
	return true;
	else if(w/z>=0.2&&a==class'awesomesiren'&&sirenuse<1)
	return true;
	else if(w/z>=0.1&&(a==class'awesomestalker'&&gettypenum('awesomestalker')<2||a==class'awesomehusk'&&gettypenum('awesomehusk')<2||a==class'awesomestalker'&&gettypenum('awesomestalker')<2||a==class'awesomecrawler'&&gettypenum('awesomecrawler')<2))
	return true;
	else if((a==class'awesomegorefast'||a==class'awesomebloat'&&gettypenum('awesomebloat')<2))
	return true;
	else {return false;}

}
/*******************/function float GetSpecimens()
{
	local controller C;
	local int i;

	for ( C = Level.ControllerList; C != None; C = C.NextController )
	{
		 if(c.isa('playercontroller')&&c.bhiddened==false&&!c.isa('monstercontroller'))
		 {
			i++;
         }
	}
	return i;
}
/*******************/function float GetTypeNum(name type)
{
	local controller C;
	local int i;

	for ( C = Level.ControllerList; C != None; C = C.NextController )
	{
			if(c.isa('playercontroller')&&c.pawn!=none&&c.pawn.isa(type))
		{
			i++;
		 }
	}

	return i;
}


	/*******************/function PlayerUpdate(playercontroller c)
	{

	    	local vector Tloc;
    		local rotator TRot;
		local playercontroller pc;
		local kfmonster km;
		local controller CR;


		
			For(CR = Level.ControllerList; CR != none; CR = CR.nextcontroller)
			{
				if( CR.pawn != none && !CR.isa('monstercontroller'))
				{
					zombieplayercontroller(c).Drawpawn(CR.pawn);
				}
			}
				

			if(IsSpecimen(C) && wavenum == finalwave && ThereIsABoss()&& c.bhiddened==false)
			{ 


			
				pc=c;
				if(pc == none)
				   return;
					   
				if(pc.pawn!=none)
				pc.pawn.gibbedby(none);

				pc.unpossess();

				pc.bisplayer=false;
				pc.pawn=FindBoss();

				pc.clientrestart(pc.pawn);

				pC.possess(FindBoss());
				pc.playerreplicationinfo.team = teams[1];
				pc.pawn.playerreplicationinfo=pc.playerreplicationinfo;
				pc.pawn.controller = pc;
			
				zombieboss(pc.pawn).MakeGrandEntry();
			
				KBroadcast(pc.playerreplicationinfo.GetHumanReadableName()$" is the patriarch");
				PlayerBoss = zombieboss(pc.pawn);
				BossName = pc.playerreplicationinfo.gethumanreadablename();
				BossMaxHealth = playerboss.health;

				
			}  
				

				if(PlayerBoss  == none)
				PlayerBoss = zombieboss(findboss());
	           if(IsSpecimen(C) && c.bhiddened==false&& ( c.pawn==none && zombiepri(c.playerreplicationinfo) != none
        	      || C.pawn != none 
       		       	&& C.pawn.isa('awesomeclot') && zombiepri(c.playerreplicationinfo) != none && (zombiepri(c.playerreplicationinfo).bReadySpecimen )
               		|| !bwaveinprogress && c.pawn == none || finalwave == wavenum && playerboss != none ) && isinstate('matchinprogress') && zombiepri(c.playerreplicationinfo) != none )
		      {

		
				IF(C.PLAYErreplicationinfo == none || !IsSpecimen(C))
				return;


	
					if( C != none && c.pawn == none )
					{
						C.GotoState('Playerwaiting');
						//PlayerController(C).SetViewTarget(C);
						//PlayerController(C).ClientSetBehindView(false);
						
						//PlayerController(C).ClientSetViewTarget(C.Pawn);
					}
     
				brestart=true;

		
				c.bisplayer=false;
			
				if( zombiepri(c.playerreplicationinfo).bReadySpecimen || c.pawn == none )
					{
						if( zombiepri(c.playerreplicationinfo).bReadySpecimen && awesomeclot(c.pawn) != none && bwaveinprogress )
					   	{ 
							Tloc = c.pawn.location;
							TRot = c.pawn.rotation;
							zombiepri(c.playerreplicationinfo).numlives=1;
							c.Pawn.gibbedby(none);
							c.bisplayer=false;
							zombiepri(c.playerreplicationinfo).boutoflives = false;
							zombieplayercontroller(c).bReadySpecimen = true;
							zombiepri(c.playerreplicationinfo).bReadySpecimen = true;
							KM=restartc(c, Tloc, TRot);
							
						}
						else if( c.pawn == none )
							{
								KM=restartc(c);
							}
					}
				If(KM!=none&&!KM.controller.isa('playercontroller'))
				{
					c.unpossess();
					zombiepri(c.playerreplicationinfo).bReadySpecimen = FALSE;
					c.possess(km);
					c.pawn = km;
					if( km.isa('awesomeclot') )
					zombieplayercontroller(c).ClotFly();
					
				}
	
			
			
	
		} 
			
		 	if( !bshowtrader && c!=none&&c.pawn!=none && c.bisplayer==false && c.pawn.isa('monster') && viewingboss == none)
			{			
				c.bbehindview=true;
				c.ClientSetBehindView(true);
				c.setviewtarget(c.pawn);
			}
			ELSE 
			{
				if( !bshowtrader && C.pawn != none && viewingboss == none)
				{
					C.SetViewTarget(c.pawn);
					C.ClientSetViewTarget(c.pawn);
					c.bbehindview=FALSE;
					c.ClientSetBehindView(FALSE);
				}
			}
	}



exec /*******************/function SetWavenum(int num)
{

	wavenum=num;


}
/*******************/function float GetPeople()
{
	local controller C;
	local int i;

	for ( C = Level.ControllerList; C != None; C = C.NextController )
	{
		if(c.isa('controller')&&c.playerreplicationinfo!=none&&c.playerreplicationinfo.bonlyspectator==false&&(c.isa('playercontroller')||c.isa('bot')))
		{
			i++;
        }
	}
	return i;
}
/*******************/function float GetPlayers()
{
	local controller C;
	local int i;

	for ( C = Level.ControllerList; C != None; C = C.NextController )
	{
		if(c.isa('controller')&&c.bhiddened==true&&c.bisplayer==true&&(Isplayer(c)||C.isa('bot') ))
		 {
				i++;
         }
	}
	return i;
}

/*******************/function bool IsSpecimen(controller c)
{
	local int i;

	
	for( i=0; i<16; i++ )
	{
		if(c.playerreplicationinfo != none && c.playerreplicationinfo.playername==numnames[i])
		{ return true;}
	}

		return false;
}

/*******************/function BecomeSpecimen(controller c)
{
		local int i;


	for( i=0; i<16; i++ )
	{
		if(c.playerreplicationinfo.playername==numnames[i])
		 return;
	}
	for( i=0; i<16; i++ )
	{
	  if(numnames[i]==""&&numnames[i]!=c.playerreplicationinfo.playername)
		 {numnames[i]=c.playerreplicationinfo.playername;return;}
	}
}

/*******************/function bool IsPlayer(controller c)
{
	local int i;

	for( i=0; i<16; i++ )
	{
	  if(c.playerreplicationinfo != none && c.playerreplicationinfo.playername==num2names[i])
		 {return true;}
	}

	
	return false;
}

/*******************/function Becomeplayer(controller c)
{
	local int i;

	for( i=0; i<16; i++ )
	{
	  if(c.playerreplicationinfo.playername==num2names[i])
		 return;
	}
	for( i=0; i<16; i++ )
	{
	  if(num2names[i]==""&&num2names[i-1]!=c.playerreplicationinfo.playername)
		 {num2names[i]=c.playerreplicationinfo.playername;return;}
	}
}

/*******************/function timer()
{

	super.timer();
	

	maxplayers=class'betheclot'.default.COOPmaxplayers;

	if( !isinstate('Matchinprogress') )
	LastTraderCloseTime = level.timeseconds;
	
	if(!bwaveinprogress||wavenum==finalwave)
		bkillthezeds=false;
		
	if(bkillthezeds)
	{KillTimer++;}

	
	if( playerboss != none )
	{
	
	BossHealth = PlayerBoss.health;
	
	ZombieGamereplicationinfo(gamereplicationinfo).BossHealth = BossHealth;
	ZombieGamereplicationinfo(gamereplicationinfo).BossMaxHealth = BossMaxHealth;
	ZombieGamereplicationinfo(gamereplicationinfo).BossName = BossName;
	
	}
	ZombieGamereplicationinfo(gamereplicationinfo).bkillthezeds = bkillthezeds;
	ZombieGamereplicationinfo(gamereplicationinfo).killtimer = killtimer;
	
	
	
	bcanbroadcastnow++;
}

/*******************//*function AddDefaultInventory( pawn PlayerPawn )
{

	if( playerpawn.controller.isa('playercontroller') )
	{
		PlayerPawn.giveweapon("KFMod.knife");
		PlayerPawn.giveweapon("KFMod.dualies");
	}
    PlayerPawn.giveweapon("KFMod.syringe");
    PlayerPawn.giveweapon("KFMod.welder");
    PlayerPawn.giveweapon("KFMod.frag");
    PlayerPawn.giveweapon("KFMod.frag");
    SetPlayerDefaults(PlayerPawn);



}*/

/*******************/function bool ThereIsABoss()
{
	local awesomepat z;

	foreach allactors(class'awesomepat',z)
	if(z!=none&&!z.controller.isa('playercontroller')&&z.health>0)
	   return true;
	else return false;
	
	return false;   


}


/*******************/function pawn FindBoss()
{
	local awesomepat z;

	foreach allactors(class'awesomepat',z)
	if(z!=none&&!z.controller.isa('playercontroller')&&z.health>0)
	   return z;


}
/*******************/function ZombieVolume GetVolume()
{

	local controller c;
	local int i;
	local ZombieVolume ReturnVolume;
	local ZombieVolume LastReturnVolume;
	
	
	For( C = Level.ControllerList; C != none; C = C.NextController )
	{
		if( c.pawn != none && c.bisplayer && kfmonster(c.pawn) == none)
		{
			for( i = 0; i < Volumes.length; i++ )
			{
				if( Volumes[i] != none && ReturnVolume == none 
				    && !Volumes[i].PlayerCanSeePoint( Volumes[i].location, class'zombieclot') 
				    && vsize( Volumes[i].location - c.pawn.location ) > 400 )
				{
					ReturnVolume = Volumes[i];
				}
				else if( Volumes[i] != none && ReturnVolume != none && vsize( Volumes[i].location - c.pawn.location ) <
				         vsize( REturnVolume.location - c.pawn.location ) && vsize( Volumes[i].location - c.pawn.location ) > 400)
				{
					ReturnVolume = Volumes[i];
					
					if( vsize( Volumes[i - 1].location - c.pawn.location ) < 1500 && vsize( Volumes[i - 1].location - c.pawn.location ) > 400)
					LastReturnVolume = Volumes[i - 1];
				}
			}
			break;
		}
	}

	if(ReturnVolume != none && LastReturnVolume != none && Frand() > 0.75)
		return LastReturnVolume;
	else if(ReturnVolume != none )
		return ReturnVolume;
	else log(" No volume ");

}

/*******************/function kfmonster restartc(controller aplayer, optional vector Targetlocation, optional rotator TargetRotation)
{

	local int d;
	local vector loc;
	local zweapon wp;
	local kfmonster KM;

	if( isplayer(aplayer) )
		return none;

	log("restartc");
	
	specimenclass=class'betheclot'.default.specieclass;

    d=rand(105);
    
    if( aplayer.pawn == none && !zombiepri(aplayer.playerreplicationinfo).bReadySpecimen)
	loc = GetVolume().location;
	else if( Targetlocation.x != 0 )
	{
		loc = Targetlocation;
		//loc.z+=30;
	}
	else loc = GetVolume().location;
	
	if(specimenclass=="awesome_gorefast")
	thisonlyspecienum=1;
	else if(specimenclass=="awesome_bloat")
	thisonlyspecienum=2;
	else if(specimenclass=="awesome_crawler")
	thisonlyspecienum=3;
	else if(specimenclass=="awesome_stalker")
	thisonlyspecienum=4;
	else if(specimenclass=="awesome_husk")
	thisonlyspecienum=8;
	else if(specimenclass=="awesome_siren")
	thisonlyspecienum=5;
	else if(specimenclass=="awesome_scrake")
	thisonlyspecienum=6;
	else if(specimenclass=="awesome_fleshpound")
	thisonlyspecienum=7;
	else if(specimenclass=="awesome_none")
	thisonlyspecienum=0;

		
	if( !zombiepri(aplayer.playerreplicationinfo).bReadySpecimen || bwaveinprogress==false)
		{ 

			if( aplayer.pawn != none && aplayer.pawn.isa('awesomeclot') )
				return none;
	  

		if ( PlayerController(aPlayer) != None )
			PlayerController(aplayer).bBehindView = true;
			

			 
			 //if ( aPlayer.Pawn == None )
			KM = Spawn(class'awesomeclot',,,loc,);
			aplayer.playerreplicationinfo.team = teams[0];

	    
			 aPlayer.bisplayer=false;
			 km.linkmesh(skeletalmesh'kf_freaks_trip.clot_freak');



		  }
	else if(ZombiePRI(aplayer.playerreplicationinfo).bFP && wavenum!=finalwave)
	{ 
		KM = Spawn(class'Awesomefleshpound',,,loc,TargetRotation);
		
		ZombiePRI(aplayer.playerreplicationinfo).bFP=false;

		if ( PlayerController(aPlayer) != None )
			PlayerController(aplayer).bBehindView = true;
		
		//fpuse++;
	  
		km.linkmesh(skeletalmesh'kf_freaks_trip.fleshpound_freak');
		if ( PlayerController(aPlayer) != None )
			PlayerController(aPlayer).clientplaysound(Sound'FP_Challenge');
	       
		km.ambientsound=Sound'FP_IdleLoop';
	}
	else if(ZombiePRI(aplayer.playerreplicationinfo).bSC && wavenum!=finalwave)
	{ 
		//if ( aPlayer.Pawn == None )
			KM = Spawn(class'Awesomescrake',,,loc,TargetRotation);

		ZombiePRI(aplayer.playerreplicationinfo).bSC=false;
			
		if ( PlayerController(aPlayer) != None )
			PlayerController(aplayer).bBehindView = true;
		//scrakeuse++;

		km.linkmesh(skeletalmesh'kf_freaks_trip.Scrake_freak');
		km.ambientsound=Sound'scrake_chainsaw_idle';	
	}
	else if(wavenum==finalwave||d<10&&thisonlyspecienum==0||thisonlyspecienum==1)
	{

		//if ( aPlayer.Pawn == None )
			KM =  Spawn(class'awesomegorefast',,,loc,TargetRotation);

	  

		if ( PlayerController(aPlayer) != None )
			PlayerController(aplayer).bBehindView = true;

	    

				aPlayer.bisplayer=false;
			 km.linkmesh(skeletalmesh'kf_freaks_trip.gorefast_freak');

	}
	else if(d<30&&CanBeSpecimen(aplayer,class'awesomebloat')&&thisonlyspecienum==0||thisonlyspecienum==2)
	{

		//if ( aPlayer.Pawn == None )
			KM = Spawn(class'Awesomebloat',,,loc,TargetRotation);

	  

		if ( PlayerController(aPlayer) != None )
			PlayerController(aplayer).bBehindView = true;

	    

			aPlayer.bisplayer=false;
			 km.linkmesh(skeletalmesh'kf_freaks_trip.bloat_freak');

	}
	else if(d<50&&CanBeSpecimen(aplayer,class'awesomecrawler')&&thisonlyspecienum==0||thisonlyspecienum==3)
	{

		//if ( aPlayer.Pawn == None )
			KM = Spawn(class'Awesomecrawler',,,loc,TargetRotation);

	  

		if ( PlayerController(aPlayer) != None )
			PlayerController(aplayer).bBehindView = true;

	    

			 aPlayer.bisplayer=false;
			 km.linkmesh(skeletalmesh'kf_freaks_trip.crawler_freak');

			km.ambientsound=Sound'crawler_idle';
	}

	else if(d<70&&CanBeSpecimen(aplayer,class'awesomestalker')&&thisonlyspecienum==0||thisonlyspecienum==4)
	{

		//if ( aPlayer.Pawn == None )
			KM = Spawn(class'Awesomestalker',,,loc,TargetRotation);

	  

		if ( PlayerController(aPlayer) != None )
			PlayerController(aplayer).bBehindView = true;

	    

			 aPlayer.bisplayer=false;
			 km.linkmesh(skeletalmesh'kf_freaks_trip.stalker_freak');

	       
	 }
	else if(d<80&&CanBeSpecimen(aplayer,class'awesomehusk')&&thisonlyspecienum==0||thisonlyspecienum==8)
	{

		//if ( aPlayer.Pawn == None )
			KM = Spawn(class'Awesomehusk',,,loc,TargetRotation);

	  

		if ( PlayerController(aPlayer) != None )
			PlayerController(aplayer).bBehindView = true;

	    

			aPlayer.bisplayer=false;
			 km.linkmesh(skeletalmesh'kf_freaks2_trip.burns_freak');

	       
	 }
	else if(d<90&&CanBeSpecimen(aplayer,class'awesomesiren')&&thisonlyspecienum==0||thisonlyspecienum==5)
	{ 
		//if ( aPlayer.Pawn == None )
			KM = Spawn(class'Awesomesiren',,,loc,TargetRotation);

	  

		if ( PlayerController(aPlayer) != None )
			PlayerController(aplayer).bBehindView = true;

	 
	sirenuse++;
	 
			 aPlayer.pawn.linkmesh(skeletalmesh'kf_freaks_trip.Siren_freak');       
			PlayerController(aPlayer).ambientsound=Sound'Siren_IdleLoop';
	if ( PlayerController(aPlayer) != None )
			PlayerController(aPlayer).clientplaysound(sound'Siren_Challenge');
	}
	else if(d<=95&&CanBeSpecimen(aplayer,class'awesomescrake')&&thisonlyspecienum==0||thisonlyspecienum==6)
	{ 
		//if ( aPlayer.Pawn == None )
			KM = Spawn(class'Awesomescrake',,,loc,TargetRotation);

	  

		if ( PlayerController(aPlayer) != None )
			PlayerController(aplayer).bBehindView = true;
		scrakeuse++;



			 km.linkmesh(skeletalmesh'kf_freaks_trip.Scrake_freak');
			 km.ambientsound=Sound'scrake_chainsaw_idle';	
	}
	else if(d>95&&CanBeSpecimen(aplayer,class'awesomefleshpound')&&thisonlyspecienum==0&&fpuse<1||thisonlyspecienum==7)
		   { 
			KM = Spawn(class'Awesomefleshpound',,,loc,TargetRotation);

	  

		if ( PlayerController(aPlayer) != None )
			PlayerController(aplayer).bBehindView = true;
		fpuse++;
	  
			 km.linkmesh(skeletalmesh'kf_freaks_trip.fleshpound_freak');
			 if ( PlayerController(aPlayer) != None )
			PlayerController(aPlayer).clientplaysound(Sound'FP_Challenge');
	       
		  km.ambientsound=Sound'FP_IdleLoop';}

	else { 

	   		//if ( aPlayer.Pawn == None )
			KM = Spawn(class'awesomegorefast',,,loc,TargetRotation);

	  

		if ( PlayerController(aPlayer) != None )
			PlayerController(aplayer).bBehindView = true;

	    

				aPlayer.bisplayer=false;
			 km.linkmesh(skeletalmesh'kf_freaks_trip.gorefast_freak');
			 
		  }
		  
	/*else if(true)
	{ 
		KM = Spawn(class'Awesomepat',,,loc,TargetRotation);

		if ( PlayerController(aPlayer) != None )
			PlayerController(aplayer).bBehindView = true;

		aPlayer.bisplayer=false;
		km.linkmesh(skeletalmesh'kf_freaks_trip.patriarch_freak');		
	}*/

	wp=spawn(class'zweapon');
	km.weapon=wp;
	km.default.jumpz=450;

	zombieplayercontroller(aplayer).greaseplaysound(sound'PerkAchieved',true,64);
	aPlayer.gotostate('playerwalking');

	if( !km.isa('awesomeclot') )
	   aplayer.playerreplicationinfo.team = teams[1];
	   
	km.meleerange=70;
	return km;
}

/*******************/function Bot SpawnBot(optional string botName)
{
	local KFInvasionBot NewBot;
	local RosterEntry Chosen;
	local UnrealTeamInfo BotTeam;

	BotTeam = GetBotTeam();
	Chosen = BotTeam.ChooseBotClass(botName);

	if (Chosen.PawnClass == None)
		Chosen.Init(); //amb
	NewBot = Spawn(class 'zBot');

	if ( NewBot != None )
		InitializeBot(NewBot,BotTeam,Chosen);

	// Decide if bot should be a veteran.
	if ( LoadedSkills.Length > 0 && KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo) != None )
		KFPlayerReplicationInfo(NewBot.PlayerReplicationInfo).ClientVeteranSkill = LoadedSkills[Rand(LoadedSkills.Length)];

	NewBot.PlayerReplicationInfo.Score = StartingCash;

	return NewBot;
}



/*******************/function SetupWave()
{
	local int i,j;
	local float NewMaxMonsters;
	//local int m;
	local float DifficultyMod, NumPlayersMod;
	local int UsedNumPlayers;
	local controller C;

	if ( WaveNum > 15 )
	{
		SetupRandomWave();
		return;
	}
	bkillthezeds=false;
	killtimer=0;


	if(CanBeSpecimen(none,class'awesomescrake')&&bhighlevel==false)
	{
		bhighlevel=true;
		kbroadcast("Scrake Time");
		For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if(KFPlayerController(C)!=none)
				ZombiePRI(KFPlayerController(C).PlayerReplicationInfo).bSC = true;
		}
	}
	if(CanBeSpecimen(none,class'awesomefleshpound')&&bfp==false)
	{
		bfp=true;
		kbroadcast("Fleshpound Time");
		For( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if(KFPlayerController(C)!=none)
				ZombiePRI(KFPlayerController(C).PlayerReplicationInfo).bFP = true;
		}
	}

	//DestroyClots();

	TraderProblemLevel = 0;
	rewardFlag=false;
	ZombiesKilled=0;
	WaveMonsters = 0;
	WaveNumClasses = 0;
	NewMaxMonsters = Waves[WaveNum].WaveMaxMonsters;

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

    UsedNumPlayers = getplayers();

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

    NewMaxMonsters = 2500;

    TotalMaxMonsters = Clamp(NewMaxMonsters,2500,2500); 

	MaxMonsters = Clamp(TotalMaxMonsters,5,15);
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

exec /*******************/function Arena(string name)
{

	class'betheclot'.default.specieclass=name;
}

/*******************/function RestartPlayer(controller aplayer)
{
	if( !IsSpecimen(aplayer) )
	{

		/*if( OldShop != none && !Allinshop() && !bSpawnInShop)
		{
			aPlayer.PlayerReplicationInfo.bOutOfLives = True;
			aPlayer.PlayerReplicationInfo.NumLives = 1;
			if(aplayer.isa('playercontroller'))
			aPlayer.GoToState('Spectating');
			Return;
		}
		else    if( OldShop != none && bTraderClosed && bSpawnInShop)*/
			//{
			//	aPlayer.PlayerReplicationInfo.bOutOfLives = false;
			//	aPlayer.PlayerReplicationInfo.NumLives = 3;
				//aPlayer.GoToState('playerwaiting');
			//}
		if( aplayer.pawn == none )
		Super.RestartPlayer(aPlayer);

		//if ( aplayer.isa('playercontroller') && (aplayer.Pawn != None) && aplayer.Pawn.CheatWalk() )
		//playercontroller(aplayer).ClientReStart(aplayer.Pawn);


	}

	/*if ( KFHumanPawn(aPlayer.Pawn) != none )
	{
		KFHumanPawn(aPlayer.Pawn).VeterancyChanged();
	}
		
	else return;*/

	if( Aplayer.isa('bot') && aplayer.pawn != none)
	{

			if( KFPlayerReplicationInfo(aplayer.PlayerReplicationInfo).ClientVeteranSkill.default.perkindex == 2 )
			Aplayer.pawn.giveweapon("kfmod.winchester");
			else if( KFPlayerReplicationInfo(aplayer.PlayerReplicationInfo).ClientVeteranSkill.default.perkindex == 3 )
			Aplayer.pawn.giveweapon("kfmod.bullpup");
			else if( KFPlayerReplicationInfo(aplayer.PlayerReplicationInfo).ClientVeteranSkill.default.perkindex == 1 )
			Aplayer.pawn.giveweapon("kfmod.Shotgun");
			else if( KFPlayerReplicationInfo(aplayer.PlayerReplicationInfo).ClientVeteranSkill.default.perkindex == 5 )
			Aplayer.pawn.giveweapon("kfmod.Flamethrower");
			else if( KFPlayerReplicationInfo(aplayer.PlayerReplicationInfo).ClientVeteranSkill.default.perkindex == 0 )
			Aplayer.pawn.giveweapon("kfmod.MP7MMedicGun");
			else if( KFPlayerReplicationInfo(aplayer.PlayerReplicationInfo).ClientVeteranSkill.default.perkindex == 4 )
			Aplayer.pawn.giveweapon("kfmod.chainsaw");			
			else if( KFPlayerReplicationInfo(aplayer.PlayerReplicationInfo).ClientVeteranSkill.default.perkindex == 6 )
			Aplayer.pawn.giveweapon("kfmod.ak47assaultrifle");

			Aplayer.pawn.giveweapon("kfmod.single");	

			Aplayer.pawn.giveweapon("kfmod.Frag");
	}
	
	/*if( aplayer.pawn != none && zombieskilled > 0 && GetTrader() != none)
	   aplayer.pawn.setlocation(GetTrader().location + 100 * vector(GetTrader().Rotation));
	   else if( aplayer.pawn != none && zombieskilled > 0 && Oldshop != none)
			Kbroadcast("No Shop Trader Mesh"); 
	return;*/
	
}
/*******************/function WeaponLocker GetTrader()
{
	local weaponlocker T, Picked;
	
	foreach allactors(class'WeaponLocker', T)
	{	
		if(OldShop != none && T != none && picked == none)
		{
			Picked = T;
		}
		else if( picked != none && vsize(T.location - OldShop.location) < vsize(Picked.location - OldShop.location) )
		{
			Picked = T;
		}
	}
	
	return Picked;
}
exec /*******************/function howmany()
{
	kbroadcast("Specimens: "$specimennums$"   Players:"$humannums$"   Total:"$peoplenums);
}
/*******************/function killallClot()
{

	local kfmonster cl;


	foreach allactors(class'kfmonster', cl)
	{
		if(cl!=none&&cl.controller.isa('monstercontroller')&&!cl.isa('zombieboss'))
		  { 
			  cl.controller.Pawn.KilledBy(cl);
			  //KBroadcast("Specimen Starvation Occuring");
		  }
	}

}


// Jesus is Lord

defaultproperties
{
     TraderOpenTime=10.000000
     TraderCloseTime=120.000000
     bTraderClosed=True
     EndGameBossClass="awesomeclot2.awesomepat"
     FinalWave=4
     TeamAIType(0)=Class'AwesomeClot2.zTeamAI'
     TeamAIType(1)=Class'AwesomeClot2.zTeamAI'
     DefaultPlayerClassName="awesomeclot2.ZHuman"
     ScoreBoardType="awesomeclot2.zombieScoreBoard"
     HUDType="Awesomeclot2.zhud"
     PlayerControllerClass=Class'AwesomeClot2.zombiePlayerController'
     PlayerControllerClassName="AwesomeClot2.ZombiePlayerController"
     GameReplicationInfoClass=Class'AwesomeClot2.ZombieGameReplicationinfo'
     GameName="Versus 200 B4"
}
