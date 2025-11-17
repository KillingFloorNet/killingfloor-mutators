// --------------------------------------------------------------
// GlassHouseGameInfo
// --------------------------------------------------------------

// GameType scripts for 'Glasshouse' maps.

// Author :  Alex Quick

// --------------------------------------------------------------


class GlassHouseGameInfo extends xTeamGame;
// KFGameType;

#exec OBJ LOAD FILE=KillingFloorTextures.utx
#exec OBJ LOAD FILE=KillingFloorWeapons.utx
#exec OBJ LOAD FILE=KillingFloorHUD.utx
#exec OBJ LOAD FILE=KFX.utx
#exec OBJ LOAD FILE=KFMaterials.utx
#exec OBJ LOAD FILE=KillingFloorLabTextures.utx
#exec OBJ LOAD FILE=KillingFloorStatics.usx
#exec OBJ LOAD FILE=EffectsSM.usx
#exec OBJ LOAD FILE=PatchStatics.usx
#exec OBJ LOAD FILE=KF_pickups2_Trip.usx
#exec OBJ LOAD FILE=KF_generic_sm.usx
#exec OBJ LOAD FILE=KF_Weapons_Trip_T.utx
#exec OBJ LOAD FILE=KF_Weapons2_Trip_T.utx
#exec OBJ LOAD FILE=KF_Weapons3rd_Trip_T.utx
#exec OBJ LOAD FILE=KF_Weapons3rd2_Trip_T.utx
#exec OBJ LOAD FILE=KFPortraits.utx
#exec OBJ LOAD FILE=KF_Soldier_Trip_T.utx
#exec OBJ LOAD FILE=kf_generic_t.utx
#exec OBJ LOAD FILE=kf_gore_trip_sm.usx
#exec OBJ LOAD FILE=KF_PlayerGlobalSnd.uax


// Pickup Management - from KFMod.KFGameType
var array<KFRandomItemSpawn> WeaponPickups;
var array<KFAmmoPickup> AmmoPickups;

var array<PlayerStart> HighestRedPlayerStarts, HighestBluePlayerstarts;

var float HighestRedSpawnZ,HighestBlueSpawnZ;

var bool bDebugPlayerSpawning;

var int RemainingSpawnPoints[2];

var int InitialSpawnPoints[2];

// ZED time - from KFMod.KFGameType

var   bool  bZEDTimeActive;         // We're currently in a ZedTime slomo event
var   float CurrentZEDTimeDuration; // Remaining time of current ZedTime event
var() float ZEDTimeDuration;        // How long a ZedTime slomo event will last
var() float ZedTimeSlomoScale;      // What percentage of normal game speed to slow down the game during ZedTime
var   float LastZedTimeEvent;       // The last time we had a Zed Time event
var   int   ZedTimeExtensionsUsed;  // Number of Zed Time extensions used(Chaining effect for killing other Zeds while Zed Time is active)
var   bool  bSpeedingBackUp;        // We're coming out of zed time


// Random Zombie spawning (in buildings) -----------------------------------

var float LastRandomZSpawnTime;

var int RandomBuildingZEDs[2];

var float RandomZombieSpawnInterval;

var int MaxRandomZombiesPerTeam;

var array<GlassMoverPlus> AllTiles;


static function bool UseDynamicLightFX()
{
  return false;
}


function PostBeginPlay()
{
  super.PostBeginPlay();
  ReCalcBestPlayerSpawns();
}

// Notification that a tile has been killed - Called in GlassMoverPlus.DoTileDeath()
// Let's add a slow-motion effect in here for fun :)

function TileDied(GlassMoverPlus Tile, Actor Killer)
{
  local float SlomoChance;
  local Controller C;
  local float Dist,MaxDist;
  local int PlayersInRange;
  local Controller KillerController;
  local int KillerTeam;

  if (Killer == none)
  {
    return;
  }

  // Only slow the game down if you're shooting at an enemy's building tiles
  KillerController = Controller(Killer);
  if (KillerController != none)
  {
    KillerTeam = KillerController.GetTeamNum();
  }

  MaxDist = 250;

  // If this tile was destroyed really close to a player, there's a chance the game will go
  // into slow motion. The more players near the destroyed tile and the closer they are,
  // the higher that chance.

  for (C = Level.ControllerList; C != none; C = C.NextController)
  {
    if(C.Pawn != none && C.GetTeamNum() != KillerTeam )
    {
      Dist = VSize(Tile.Location - C.Pawn.Location);
      if(Dist <= MaxDist)
      {
        SlomoChance += ((1.f - FClamp(Dist/MaxDist,0.f,1.f)) * 0.5) ;
        PlayersInRange ++ ;
      }
    }
  }

  if(PlayersInRange >= 2)
  {
    DramaticEvent(SlomoChance);
  }
}


// We only want to be doing this once - Store a list of all the GlassMovers in the map besides this one
function CacheTiles()
{
  local GlassMoverPlus Tile;

  foreach AllActors(class 'GlassMoverPlus', Tile)
  {
    AllTiles[AllTiles.length] = Tile;
  }
}


function RecalcBestPlayerSpawns()
{
  if (bDebugPlayerSpawning)
  {
    ClearStayingDebugLines();
  }

  FindHighestSpawnPoints(0);
  FindHighestSpawnPoints(1);

  InitialSpawnPoints[0] = RemainingSpawnPoints[0];
  InitialSpawnPoints[1] = RemainingSpawnPoints[1];
}


// Restart a player.
function RestartPlayer(Controller aPlayer)
{
  FindHighestSpawnPoints(aPlayer.GetTeamNum());
  super.RestartPlayer(aPlayer);
}


// Determine which playerstart is the highest in the map (and therefore the most desirable for spawning
// Used by RatePlayerStart.
function FindHighestSpawnPoints(byte TeamIdx)
{
  local PlayerStart_GH P;
  local NavigationPoint Nav;
  local float NavHeight;

  if (TeamIdx == 0)
  {
    HighestRedPlayerStarts.length = 0;
    HighestRedSpawnZ = -100000000;
  }
  else if(TeamIdx == 1)
  {
    HighestBluePlayerStarts.length = 0;
    HighestBlueSpawnZ = -100000000;
  }
  else
  {
    return ;  /// - no valid team index.
  }

  RemainingSpawnPoints[TeamIdx] = 0 ;

  // Figure out what the highest playerstart points are for each Team
  for (Nav = Level.NavigationPointList; Nav != none; Nav = Nav.NextNavigationPoint)
  {
    P = PlayerStart_GH(Nav);
    if (P != none && P.TeamNumber == TeamIdx)
    {
      // Disable playerspawns that are floating  ( Placed on a currently destroyed tile)
      P.bEnabled = !IsFloating(P);

      if (P.bEnabled)
      {
        if (P.DrawType != P.default.DrawType)
        {
          P.SetDrawType(P.default.DrawType);
        }

        if (!P.bGroundLevelSpawn)
        {
          RemainingSpawnPoints[TeamIdx]++;
        }

        NavHeight = P.Location.Z;

        if (TeamIdx == 0 )
        {
          if (NavHeight > HighestRedSpawnZ)
          {
            HighestRedSpawnZ = NavHeight;
          }
        }
        else if (TeamIdx == 1)
        {
          if (NavHeight > HighestBlueSpawnZ)
          {
            HighestBlueSpawnZ = NavHeight;
          }
        }
      }
      else
      {
        if (P.DrawType == P.default.DrawType)
        {
          P.SetDrawType(DT_none);
        }
      }
    }
  }

  // We display this replicated value on the HUD.
  GH_GRI(GameReplicationInfo).SetRemainingSpawns(TeamIdx, Round((float(RemainingSpawnPoints[TeamIdx]) / float(InitialSpawnPoints[TeamIdx])) * 100));
  if (RemainingSpawnPoints[TeamIdx] == 0)
  {
    OutOfSpawns(TeamIdx);
  }

  // log("Number of spawn points remaining for Team" @ TeamIdx @ "is" @ RemainingSpawnPoints[TeamIdx]);
  // log("Current Highest Red spawn Z is :" @ HighestRedSpawnZ);
  // log("Current Highest Blue spawn Z is :" @ HighestBlueSpawnZ);
}


// The specified team ran out of spawns - Their team's lives are now finite
function OutOfSpawns(byte TeamIndex)
{
  local int i;

  for (i = 0; i < GameReplicationInfo.PRIArray.length; i++)
  {
    if (GameReplicationInfo.PRIArray[i].Team.Teamindex == TeamIndex)
    {
      // GameReplicationInfo.PRIArray[i].bOutOfLives = true;
      GameReplicationInfo.PRIArray[i].NumLives = 1;
    }
  }

  // so that CheckMaxLives() will be called.
  MaxLives = 1;

  // Blow up any remaining tiles
  DestroyBuilding(TeamIndex);
}


function DestroyBuilding( byte TeamIndex)
{
  local GlassMoverPlus Tiles;
  local name EventName;

  foreach AllActors(class'GlassMoverPlus', Tiles)
  {
    if (Tiles.TeamIdx == TeamIndex && !Tiles.IsDead())
    {
      Tiles.DoTileDeath();
      DramaticEvent(1.0);
    }
  }

  if (TeamIndex == 1)
  {
    Eventname = 'Building1Destroyed';
  }
  else
  {
    Eventname = 'Building0Destroyed';
  }

  TriggerEvent(EventName, self, none);
}

// FindPlayerStart()
// returns the 'best' player start for this player to start from.

// function NavigationPoint FindPlayerStart(Controller Player, optional byte InTeam, optional string incomingName)
// {
//   local NavigationPoint Start;
//   local Playerstart_GH  GHStart;
//   Start = super.FindPlayerStart(Player,InTeam,incomingName);
//   GHStart = PlayerStart_GH(Start);
//   if(GHStart != none)
//   {
//     if(GHStart.bGroundLevelSpawn)
//     {
//       OutOfSpawns(InTeam);
//     }
//   }
//   return Start;
// }


// Rate whether player should choose this NavigationPoint as its start
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
  local float AdjustedRating, HighestTeamZ;
  local float ZTolerance;

  AdjustedRating = super.RatePlayerStart(N, Team, Player);

  if (Team == 0)
  {
    HighestTeamZ = HighestRedSpawnZ;
  }
  else if (Team == 1)
  {
    HighestTeamZ = HighestBlueSpawnZ;
  }

  if (PlayerStart(N) != none && PlayerStart(N).bEnabled)
  {
    ZTolerance = 5.f;

    // Give priority to highest spawn point
    if ((HighestTeamZ - N.Location.Z ) <= ZTolerance )
    {
      AdjustedRating += 500000;
    }
  }

  return AdjustedRating;
}


function bool IsFloating(Actor A)
{
  local vector Start, End;
  local float TraceDist;
  local bool Result;
  local Actor HitActor;
  local vector HitLoc, HitNormal, PlayerExtent;
  local class<Pawn>	DefaultPawnClass;

  // check that it's not floating in the air and gonna drop the player 100 feet ..
  TraceDist = 2500.f;
  Start = A.Location;
  End = A.Location - (TraceDist * Vect(0, 0, 1));

  // Result = FastTrace(End,Start);

  DefaultPawnClass = class<Pawn>(DynamicLoadObject(DefaultPlayerClassName, class'class'));

  PlayerExtent.Z = DefaultPawnClass.default.CollisionHeight;
  PlayerExtent.X = DefaultPawnClass.default.CollisionRadius;
  PlayerExtent.Y = DefaultPawnClass.default.CollisionRadius;

  HitActor = Trace(HitLoc, HitNormal, End, Start, true, PlayerExtent);
  Result = !HitActor.bWorldGeometry || (Abs(Start.Z - HitLoc.Z) >= (DefaultPawnClass.default.MaxFallSpeed / 3));

  if (bDebugPlayerSpawning)
  {
    if (Result)
    {
      DrawStayingDebugLine(Start, End, 255, 0, 0); // SLOW! Use for debugging only!
    }
    else
    {
      if (GlassMoverPlus(HitActor) == none)
      {
        log("Trace hit :" @ HitActor);
      }

      DrawStayingDebugLine(Start, HitLoc ,0, 255, 0); // SLOW! Use for debugging only!
    }
  }

  return Result;
}


// Glasshouse Zombie Spawning  =======================================================

// Street level spawning - These functions are for (re)spawning zombies
// that were placed at street level by the LD.

// Respawn Zombies on the street level that are killed by players
function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn)
{
  local KFMonster ZombiePawn;

  ZombiePawn = KFMonster(KilledPawn);
  if (ZombiePawn != none )
  {
    // Dead zombie was spawned by the gameinfo, not the LD. Don't respawn it
    if (ZombiePawn.Tag == 'RedTeam')
    {
      RandomBuildingZEDs[0] --;
    }
    else if (ZombiePawn.Tag == 'BlueTeam')
    {
      RandomBuildingZEDs[1] --;
    }
    else
    {
      // LD placed zombie. respawn it
      SpawnAZombie(ZombiePawn.class, GetRandomStreetZSpawnLoc());
    }
  }

  super.NotifyKilled(Killer, Killed, KilledPawn);
}


function bool	SpawnAZombie(class<KFMonster> ZType, vector SpawnLoc, optional int ReceivingTeam, optional bool bDisplayNotification, optional name SpawnTag)
{
  local KFMonster NewZombie;

  if (VSize(SpawnLoc) > 0)
  {
    NewZombie = spawn(ZType,, SpawnTag, SpawnLoc);
    if (NewZombie != none && bDisplayNotification)
    {
      BroadcastLocalizedMessage(class'GH_Msg_ZombieWarning', ReceivingTeam);
    }
  }
  else
  {
    log("Warning - Could not find valid spawn point for New Zombie of type"@ZType);
  }

  return NewZombie != none;
}


function vector GetRandomStreetZSpawnLoc()
{
  local GH_ZombieRespawnNode Spawner;
  local array<GH_ZombieRespawnNode> SpawnList;
  // local NavigationPoint Nav;
  // local int i;

  forEach AllActors(class'GH_ZombieRespawnNode', Spawner)
  {
    SpawnList[SpawnList.length] = Spawner;
  }

  return SpawnList[rand(SpawnList.length)].Location;
}


// Random Building spawning - These functions are for randomly spawning zombies
// in players buildings during the match.
// --------------------------------------------------------------------------------------

function bool CanSpawnRandomZFor(byte Team)
{
  if (Team <= 1 && RandomBuildingZEDs[Team] < MaxRandomZombiesPerTeam && Level.TimeSeconds - LastRandomZSpawnTime >= RandomZombieSpawnInterval)
  {
    return true;
  }

  return false;
}


function vector GetRandomBuildingSpawnLoc(byte Team)
{
  local NavigationPoint N;
  local PlayerStart_GH P;
  local array<PlayerStart_GH>	PotentialSpots;

  for (N = Level.NavigationPointList; N != none; N = N.nextNavigationPoint)
  {
    P = PlayerStart_GH(N);
    if (P != none && !P.bGroundLevelSpawn && P.TeamNumber == Team && !P.PlayerCanSeeMe())
    {
      PotentialSpots[PotentialSpots.length] = P;
    }
  }

  return PotentialSpots[rand(PotentialSpots.length)].Location;
}


// Teleports the specified zombie pawn to the nearest available ZombieVolume
// that has a higher Z position than the supplied location
function TeleportZombieAbovePlayer(Pawn InZombie, vector EnemyLoc)
{
  local ZombieVolume Vol, BestVol;
  local float BestDist, Dist;

  // WTF?!
  return;

  foreach AllActors(class'ZombieVolume', Vol)
  {
    if (Vol.Location.Z > EnemyLoc.Z && !Vol.PlayerCanSeeMe())
    {
      Dist = VSize(EnemyLoc - Vol.Location);
      if (BestDist == 0 || Dist < BestDist)
      {
        BestDist = Dist;
        BestVol = Vol;
      }
    }
  }

  if (BestVol != none)
  {
    InZombie.SetLocation(BestVol.Location);
  }
}


// =====================================================================================

// state MatchInProgress
// {
//    function DoWaveEnd()
//   {
//     //log(" ======================= WAVE JUST ENDED (GLASS HOUSE GAME INFO) ============================================= ");
//     super.DoWaveEnd();
//     RespawnBrokenTiles();
//   }

//   function RespawnBrokenTiles()
//   {
//     local GlassMoverPlus Tile;

//     foreach AllActors(class 'GlassMutator.GlassMoverPlus', Tile)
//     {
//       Tile.DoTileRespawn();
//       }
//   }


//   // Setup the random ammo pickups
//   // - overriding this 'cuz there's an accessed none that causes the game to hang if the LD hasn't placed any Ammo pickups.
//   function SetupPickups()
//   {
//     if(AmmoPickups.length == 0 || AmmoPickups[0] == none)
//     {
//       return;
//     }

//     super.SetupPickups();
//   }
// }


// == KFGameType Code ================================================================================================================================

// Everything below here is copied directly from KMod.KFGameType. (with a few exceptions)
// Functionality like weapon and ammunition spawning that we need for GlassHouse

function MaybeSpawnAZombie()
{
  local int UnLuckyTeam;
  local name TeamName;

  UnLuckyTeam = Max(Rand(2), 0);
  if (CanSpawnRandomZFor(UnLuckyTeam))
  {
    if (UnLuckyTeam < 1)
    {
      Teamname = 'RedTeam';
    }
    else
    {
      Teamname = 'BlueTeam';
    }

    if (SpawnAZombie(class'ZombieSiren_GH', GetRandomBuildingSpawnLoc(UnLuckyTeam), UnLuckyTeam, true, TeamName))
    {
      LastRandomZSpawnTime = Level.TimeSeconds;
      RandomBuildingZEDs[UnLuckyTeam]++;
    }
  }
}


state MatchInProgress
{
  function BeginState()
  {
    SetupPickups();
    super.BeginState();
  }

  function Timer()
  {
    super.Timer();
    // MaybeSpawnAZombie();
  }

  // Setup the random ammo pickups - Copied from KFMod.KFGameType
  function SetupPickups()
  {
    local int NumWeaponPickups, NumAmmoPickups, Random, i, j;
    local int m;

    // Randomize Available Ammo Pickups
    // if ( GameDifficulty >= 5.0 ) // Suicidal and Hell on Earth
    // {
    //   NumWeaponPickups = WeaponPickups.Length * 0.1;
    //   NumAmmoPickups = AmmoPickups.Length * 0.1;
    // }
    // else if ( GameDifficulty >= 4.0 ) // Hard
    // {
    //   NumWeaponPickups = WeaponPickups.Length * 0.2;
    //   NumAmmoPickups = AmmoPickups.Length * 0.35;
    // }
    // else if ( GameDifficulty >= 2.0 ) // Normal
    // {
    //   NumWeaponPickups = WeaponPickups.Length * 0.3;
    //   NumAmmoPickups = AmmoPickups.Length * 0.5;
    // }
    // else // Beginner
    // {
    NumWeaponPickups = WeaponPickups.Length * 0.5;
    log("Weapon Pickups To spawn :" @ NumWeaponPickups);
    NumAmmoPickups = AmmoPickups.Length * 0.65;
    // }

    // Always have at least 1 pickup
    NumWeaponPickups = Max(1, NumWeaponPickups);
    NumAmmoPickups = Max(1, NumAmmoPickups);

    // reset all the of the pickups
    for (m = 0; m < WeaponPickups.Length ; m++)
    {
      WeaponPickups[m].DisableMe();
    }

    for (m = 0; m < AmmoPickups.Length ; m++)
    {
      AmmoPickups[m].GotoState('Sleeping', 'Begin');
    }

    // Ramdomly select which pickups to spawn
    for (i = 0; i < NumWeaponPickups && j < 10000; i++)
    {
      Random = Rand(WeaponPickups.Length);

      if (!WeaponPickups[Random].bIsEnabledNow)
      {
        WeaponPickups[Random].EnableMe();
      }
      else
      {
        i--;
      }

      j++;
    }

    for (i = 0; i < NumAmmoPickups && j < 10000; i++)
    {
      Random = Rand(AmmoPickups.Length);

      if ( AmmoPickups[Random].bSleeping )
      {
        AmmoPickups[Random].GotoState('Pickup');
      }
      else
      {
        i--;
      }

      j++;
    }
  }
}


// Called when a dramatic event happens that might cause slomo
// BaseZedTimePossibility - the attempted probability of doing a slomo event
function DramaticEvent(float BaseZedTimePossibility)
{
  local float RandChance;
  local float TimeSinceLastEvent;
  local Controller C;

  TimeSinceLastEvent = Level.TimeSeconds - LastZedTimeEvent;

  // Don't go in slomo if we were just IN slomo
  if (TimeSinceLastEvent < 10.0 && BaseZedTimePossibility != 1.0)
  {
    return;
  }

  if (TimeSinceLastEvent > 60)
  {
    BaseZedTimePossibility *= 4.0;
  }
  else if (TimeSinceLastEvent > 30)
  {
    BaseZedTimePossibility *= 2.0;
  }

  RandChance = FRand();
  // log("TimeSinceLastEvent = "$TimeSinceLastEvent$" RandChance = "$RandChance$" BaseZedTimePossibility = "$BaseZedTimePossibility);

  if (RandChance <= BaseZedTimePossibility)
  {
    bZEDTimeActive = true;
    bSpeedingBackUp = false;
    LastZedTimeEvent = Level.TimeSeconds;
    CurrentZEDTimeDuration = ZEDTimeDuration;

    SetGameSpeed(ZedTimeSlomoScale);

    for (C = Level.ControllerList; C != none; C = C.NextController)
    {
      if (KFPlayerController(C) != none)
      {
        KFPlayerController(C).ClientEnterZedTime();
      }

      if (C.PlayerReplicationInfo != none && KFSteamStatsAndAchievements(C.PlayerReplicationInfo.SteamStatsAndAchievements) != none)
      {
        KFSteamStatsAndAchievements(C.PlayerReplicationInfo.SteamStatsAndAchievements).AddZedTime(ZEDTimeDuration);
      }
    }
  }
}


// Overriden to handle ZEDTime zombie death slomo system
event Tick(float DeltaTime)
{
  local float TrueTimeFactor;
  local Controller C;

  if (bZEDTimeActive)
  {
    TrueTimeFactor = 1.1 / Level.TimeDilation;
    CurrentZEDTimeDuration -= DeltaTime * TrueTimeFactor;

    if (CurrentZEDTimeDuration < (ZEDTimeDuration * 0.166) && CurrentZEDTimeDuration > 0)
    {
      if (!bSpeedingBackUp)
      {
        bSpeedingBackUp = true;

        for (C = Level.ControllerList; C != none; C = C.NextController)
        {
          if (KFPlayerController(C) != none)
          {
            KFPlayerController(C).ClientExitZedTime();
          }
        }
      }

      SetGameSpeed(Lerp((CurrentZEDTimeDuration / (ZEDTimeDuration * 0.166)), 1.0, 0.2));
    }

    if (CurrentZEDTimeDuration <= 0)
    {
      bZEDTimeActive = false;
      bSpeedingBackUp = false;
      SetGameSpeed(1.0);
      ZedTimeExtensionsUsed = 0;
    }
  }
}


// spawn and initialize a bot
function Bot SpawnBot(optional string botName)
{
  local GH_Bot NewBot;
  local RosterEntry Chosen;
  local UnrealTeamInfo BotTeam;

  BotTeam = GetBotTeam();
  Chosen = BotTeam.ChooseBotClass(botName);

  if (Chosen.PawnClass == none)
    Chosen.Init(); //amb
  NewBot = spawn(class'GH_Bot');

  if (NewBot != none)
    InitializeBot(NewBot, BotTeam, Chosen);

  return NewBot;
}


function WeaponPickedUp(KFRandomItemSpawn PickedUp)
{
  local int Random, i;

  if (PickedUp == none)
  {
    return;
  }

  PickedUp.DisableMe();

  for (i = 0; i < 10000; i++)
  {
    Random = Rand(WeaponPickups.Length);

    if (WeaponPickups[Random] != PickedUp && !WeaponPickups[Random].bIsEnabledNow)
    {
      WeaponPickups[Random].EnableMeDelayed(30.0 / float(GetNumPlayers()));
      return;
    }
  }

  PickedUp.EnableMeDelayed(30.0 / float(GetNumPlayers()));
}


function AmmoPickedUp(KFAmmoPickup PickedUp)
{
  local int Random, i;

  for (i = 0; i < 10000; i++)
  {
    Random = Rand(AmmoPickups.Length);

    if (AmmoPickups[Random] != PickedUp && AmmoPickups[Random].bSleeping)
    {
      AmmoPickups[Random].GotoState('Sleeping', 'DelayedSpawn');
      return;
    }
  }

  PickedUp.GotoState('Sleeping', 'DelayedSpawn');
}


// function OverrideInitialBots()
// {
//   InitialBots = 0;
// }


// fix log spam
static function Texture GetRandomTeamSymbol(int base)
{
  local string SymbolName;
  local int SymbolIndex, RawIndex;
  local array<string> TeamSymbols;
	local texture Result;

  class'CacheManager'.static.GetTeamSymbolList(TeamSymbols, true);

  // none!
  if (TeamSymbols.length == 0)
  {
    // warn("TeamSymbols.length was 0!");
    return none;
  }

  RawIndex = Rand(TeamSymbols.Length - base);
  SymbolIndex = base + RawIndex;
  if (SymbolIndex >= TeamSymbols.Length)
    SymbolIndex = RawIndex;

	SymbolName = TeamSymbols[SymbolIndex];
  result = Texture(DynamicLoadObject(SymbolName, class'Texture'));

  if (result == none)
		result = Texture(DynamicLoadObject(TeamSymbols[0], class'Texture'));
  if (result == none)
    warn("No Team Symbol! (TeamSymbols[0] is invalid)");
  return result;
}


defaultproperties
{
  GameName="Glasshouse"
  Description="In a world where buildings are constructed from the flimsiest materials imagineable, a new hero will arise! Or fall.  And go splat."
  Acronym="GH"
  HUDType="Glassmutator.HUD_Glasshouse"
  ZEDTimeDuration=4.000000
  RandomZombieSpawnInterval=60.000000
  MaxRandomZombiesPerTeam=1
  bSpawnInTeamArea=True
  DefaultVoiceChannel="Team"
  DefaultPlayerClassName="Glassmutator.PlayerPawn_GH"
  MapListType="Glassmutator.GHMapList"
  MapPrefix="GH"
  BeaconName="GH"
  DeathMessageClass=class'KFMod.KFDeathMessage'
  GameMessageClass=class'KFMod.KFGameMessages'
  MutatorClass="Glassmutator.GlassMut"
  PlayerControllerClass=class'GH_PlayerController'
  GameReplicationInfoClass=class'GH_GRI'
}