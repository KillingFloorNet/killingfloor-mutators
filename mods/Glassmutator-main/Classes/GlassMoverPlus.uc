// --------------------------------------------------------------
// Glass Mover Plus
// --------------------------------------------------------------

// Destructable mesh actor for use in 'Glasshouse' maps.
// Originally conceived as a subclass of 'KFGlassMover', hence the name.

// Author :  Alex Quick

// --------------------------------------------------------------


class GlassMoverPlus extends StaticMeshActor
  placeable;
  // Actor

// #exec OBJ LOAD FILE=GlassHouseSM.usx

// seconds delay before a broken pane of glass re-appears
var() float RespawnTime;

// controls which team this tile belongs to.
var() byte TeamIdx;

// assign a support role to this tile in the building's structure.
// determines how many tiles it takes with it when destroyed
enum ESupportType
{
  ST_None,      // does not support other tiles in any way (Windows, window frames)
  ST_Trivial,   // provides minimal support to other tiles around it (concrete wall section)
  ST_Important, // provides support to a large number of other tiles in the area (metal girder)
  ST_Critical,  // provides critical support to an entire section of the building (foundation girders)
};

var () ESupportType SupportGrade, InstigatorGrade;


// Destruction FX ---------------------------------------------------------

var class<DoorGib> GibClass;

var vector DeathMomentum;

var int NumGiblets;

var float GibVelocityScale;

// Damage scaling vars --------------------------------------------------------

// if true, this actor can only be damaged by explosive weapons
var bool bExplosiveDamageOnly;

// amount to scale damage received from non-explosive projectile weapons (only used if bExplosiveDamageOnly is false)
var float SmallArmsDmgScaling;

// amount to scale damage received from Bloat Bile
var float AcidDmgScaling;

// amount to scale damage received from fire
var float FireDmgScaling;

// amount to scale damage received from Siren Screams
var() float ScreamDmgScaling;

// amount to scale all damage received, as a factor of the server's  current / max player count
var float PlayerDamageScaling;

var float GlobalDamageModifier;

// ------------------------------------------------------------------------------
// if true this tile will spawn a 'roof light' projector that will toggle when it is destroyed (simulate a dynamic sunlight effect)
var(TileLight) bool bRoofLightTile;

var(TileLight) float TL_Brightness;

var(TileLight) float TL_Radius;

var(TileLight) float TL_Saturation;

var(TileLight) float TL_Hue;

var GH_RoofTileProjector TileLight;

var SunLight LevelSun;

// Emitter to spawn when the actor 'breaks'
var() class <Emitter> DestructionEmitter;

// amount of damage this actor can sustain before breaking
var() int Health;

var bool bDestroyed, bClientDestroyed;

var bool bPendingClientTearOff, bPendingTearoff;

enum EObjectMaterialType
{
  OMT_Wood,
  OMT_Glass,
  OMT_Concrete,
  OMT_Metal
};
var() EObjectMaterialType ObjMaterialType;


// Antiportal control - from UnrealGame.DestroyableObjective_SM

var array<AntiPortalActor> AntiPortals;
var() name AntiPortalTag;

replication
{
  reliable if (Role == ROLE_Authority)
    bDestroyed, bPendingTearoff;
}


// wrapper for determining if this actor has been hidden from view
simulated function bool IsHidden()
{
  return DrawType == DT_None;
}


simulated function bool IsDead()
{
  return Health <= 0;
}


// reset actor to initial state - used when restarting level without reloading.
function Reset()
{
  super.Reset();
  AdjustAntiPortals();
}


simulated function PostBeginPlay()
{
  super.PostBeginPlay();

  if (Base != none)
  {
    log(Base);
  }

  switch(ObjMaterialType)
  {
    case OMT_Wood:
      Health = 100;
      SmallArmsDmgScaling = 0.5f;
      AcidDmgScaling = 25.f;
      ScreamDmgScaling = 5.f;
      // DestructionEmitter = class 'ROEffects.PanzerfaustHitConcrete';
      break;
    case OMT_Glass:
      Health = 25;
      SmallArmsDmgScaling = 1.f;
      AcidDmgScaling = 25.f;
      ScreamDmgScaling = 5.f;
      DestructionEmitter = class 'KFMod.BreakWindowGlassEmitter';
      break;
    case OMT_Concrete:
      Health = 300;
      SmallArmsDmgScaling = 0.15;
      AcidDmgScaling = 25.f;
      ScreamDmgScaling = 5.f;
      // DestructionEmitter = class 'ROEffects.PanzerfaustHitConcrete';
      break;
    case OMT_Metal:
      Health = 400;
      SmallArmsDmgScaling = 0 ;
      AcidDmgScaling = 25.f ;
      ScreamDmgScaling = 2.5f ;
      // DestructionEmitter = class 'ROEffects.PanzerfaustHitConcrete';
      break;
  }

  if (SupportGrade == ST_Critical)
  {
    Health *= 2;
  }

  SpawnTileLight();
  CacheAntiPortals();
  // FindSupportedTiles();
  SetTimer(1.0,false);
}


simulated	function CacheAntiPortals()
{
  local AntiPortalActor AntiPortalA;

  if (AntiPortalTag != '')
  {
    foreach AllActors(class'AntiPortalActor', AntiPortalA, AntiPortalTag)
      AntiPortals[AntiPortals.Length] = AntiPortalA;
  }
}


simulated function Rotator GetRelativeSunRotationFor(Actor A)
{
  local Rotator DesiredRot;

  DesiredRot = A.Rotation;

  foreach AllActors(class'SunLight', LevelSun)
  {
    break;
  }

  if (LevelSun != none)
  {
    DesiredRot = LevelSun.Rotation;
  }

  return DesiredRot;
}


simulated function SpawnTileLight()
{
  if (bRoofLightTile && class'GlassHouseGameInfo'.static.UseDynamicLightFX())
  {
    TileLight = spawn(class'GH_RoofTileProjector', self, tag,Location - (vect(0, 0, -15)), Rotation);
    if (TileLight != none)
    {
      TileLight.SetRotation(GetRelativeSunRotationFor(TileLight)) ;
      // TileLight.SetRotation(Rot(-16384,0,0)) ; // - pointing toward floor.
      // TileLight.LightSaturation = TL_Saturation;
      // TileLight.LightHue = TL_Hue;
      // TileLight.LightRadius = TL_Radius;
      // TileLight.LightBrightness = TL_Brightness;
      // TileLight.InitialBrightness = TL_Brightness;
    }
    else
    {
      log("WARNING - Failed to spawn Tile light for : " @ self);
    }
  }
}


function Timer()
{
  // bPendingTearoff = !bPendingTearoff;
  // bNetNotify = true;
  // immediate update of replicated vars.. I guess this is the UE2 approximation of bForceNetUpdate ?
  // NetUpdateTime = Level.TimeSeconds - 1;
}



// Network functions ============================================

simulated function PostNetBeginPlay()
{
  bClientDestroyed = bDestroyed;

  if (bDestroyed && !bClientDestroyed)
  {
    BreakTile();
  }

  bNetNotify = !bHidden;
}


simulated function PostNetReceive()
{
  if (bClientDestroyed != bDestroyed)
  {
    // log("Post Net Receive - : "@"bDestroyed:"$bDestroyed@"bClientDestroyed : "$bClientDestroyed) ;
    if (bDestroyed)
    {
      BreakTile();
    }
    else
    {
      RespawnTile();
    }

    bClientDestroyed = bDestroyed;
    AdjustAntiPortals();
    bNetNotify = false;
    RunClientOnly();
  }

  if (bPendingTearoff != bPendingClientTearOff)
  {
    bNetNotify = false;
    bPendingClientTearOff = bPendingTearoff;
    bTearoff = bPendingClientTearOff;
  }
}


// Antiportal control - from UnrealGame.DestroyableObjective_SM
simulated	function AdjustAntiPortals()
{
  local int i;

  if (AntiPortals.Length > 0)
  {
    if (!bDestroyed)
    {
      for (i = 0; i < AntiPortals.Length; i++)
      {
        if (AntiPortals[i].DrawType != DT_AntiPortal)
          AntiPortals[i].SetDrawType(DT_AntiPortal);
      }
    }
    else
    {
      for (i = 0; i < AntiPortals.Length; i++)
      {
        if (AntiPortals[i].DrawType != DT_None)
          AntiPortals[i].SetDrawType(DT_None);
      }
    }
  }
}


simulated function HitWall(Vector HitNormal, Actor Wall)
{
  local GlassMoverPlus WallTile;

  WallTile = GlassMoverPlus(Wall);
  if (WallTile != none)
  {
    // CheckSupportedTile(WallTile);
  }
}


// ===============================================================
event TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
  local class<KFWeaponDamageType> KFDamage;
  local bool bAcidDmg,bScreamDmg,bFireDmg;
  local float DamageScaleModifier;

  // log(self@"Health :"$Health@"took damage : "@Damage@"of type : "$damageType);

  if (IsDead())
  {
    return;
  }

  bAcidDmg = ClassIsChildOf(damageType, class'DamTypeVomit');
  bScreamDmg = ClassIsChildOf(damageType, class'SirenScreamDamage');
  bFireDmg = ClassIsChildOf(damageType, class'DamTypeBurned');

  if (bAcidDmg)
  {
    DamageScaleModifier =	AcidDmgScaling;
  }
  else if(bScreamDmg)
  {
    DamageScaleModifier =	ScreamDmgScaling;
  }
  else if(bFireDmg)
  {
    DamageScaleModifier =	FireDmgScaling;
  }
  else
  {
    DamageScaleModifier =	SmallArmsDmgScaling;
  }

  KFDamage = class<KFWeaponDamageType>(damageType);
  if (KFDamage != none)
  {
    if (KFDamage.default.bIsExplosive || ClassIsChildOf(InstigatedBy.class,class 'ZombieFleshPound'))		// hack - count Fleshpound damage as explosive for the moment.
    {
      // todo:  add special functionality for explosive weapons.
      DamageScaleModifier = 1.f;
    }
    else
    {
      if (bExplosiveDamageOnly)
      {
        return;
      }
    }
  }

  // Scale damage by player count. When there are more than two players in the game,  damage starts getting reduced ..
  DamageScaleModifier *= GetPlayerCountDamageScale();
  DamageScaleModifier *= GlobalDamageModifier;

  Damage = Max(Damage * DamageScaleModifier, 1);
  Health = Max(Health - Damage, 0);

  if (Health <= 0)
  {
    DeathMomentum = (Momentum + (VRand() * (0.5 * Momentum))) * GibVelocityScale;
    DoTileDeath(InstigatedBy.Controller);
    TriggerEvent(Event, Self, instigatedBy);
  }
}


function int GetTeamSize(byte TeamIndex, optional bool IncludeBots)
{
  local int i, Size;

  for (i = 0; i < Level.Game.GameReplicationInfo.PRIArray.length; i++)
  {
    if (Level.Game.GameReplicationInfo.PRIArray[i].Team.TeamIndex == TeamIndex && !Level.Game.GameReplicationInfo.PRIArray[i].bOutOfLives && !Level.Game.GameReplicationInfo.PRIArray[i].bOnlySpectator)
    {
      Size ++;
    }
  }

  return Size;
}


function float GetPlayerCountDamageScale()
{
  local float Current,Max;
  local float FinalDmgPct;
  local float MinDmgPct,MaxDmgPct;

  FinalDmgPct = 1.f;

  Current = float(Level.Game.NumPlayers + Level.Game.NumBots);
  if (Current > Level.IdealPlayerCountMin)
  {
    Max = Level.IdealPlayerCountMax; // float(Level.Game.MaxPlayers);

    MaxDmgPct = 1.f;
    MinDmgPct = 0.25;

    FinalDmgPct = FClamp((1.f - (Current / Max)) + MinDmgPct, MinDmgPct, MaxDmgPct);
    // log("Damage dealt to tile" @ self @ "will be scaled by : " @ FinalDmgPct);
  }

  return FinalDmgPct;
}


// Break this tile and all tiles linked to it
function DoTileDeath(optional Actor Killer)
{
  if (GlassHouseGameInfo(Level.Game) != none)
  {
    GlassHouseGameInfo(Level.Game).TileDied(self,Killer);
  }

  Health = 0;
  // bWorldGeometry = false;
  bNetNotify = true;
  RunSimulated();

  BreakTile();
  // DestroyLinkedTiles();
  // DestroySupportedTiles();
  CheckForFloatingTiles(Killer);
  BreakAIPaths(true);

  // JumpPawns();
}


// When a tile is destroyed we need to make sure that any tiles it was supporting are
// also removed, or the building will appear to be "floating
function CheckForFloatingTiles(Actor Killer)
{
  local vector StartUp,EndUp,StartDown,EndDown,HitLocUp,HitLocDown,HitNormal;
  local float TraceUpDist;
  local Actor UpActor,DownActor;
  local GlassMoverPlus HitTileUp;
  local float MaxDrop;	// maximum allowed 'gap' between tiles. else destroy.
  local float Drop;
  local bool bDebugFloatingTiles;
  // local array<GlassMoverPlus> PendingDestructionTiles;
  local vector Extent;
  local int NumTraces,i,ReTraceAttempts;
  local float SupportRadius;

  HitTileUp = self;
  MaxDrop = 10.f;
  bDebugFloatingTiles = false;

  TraceUpDist = 1500; // HitTileUp.CollisionHeight * 2;
  StartUp = HitTileUp.Location + (vect(0,0,1) * (0.5 * CollisionHeight));
  EndUp = StartUp + (TraceUpDist * Vect(0,0,1));

  NumTraces = 5;

  switch (SupportGrade)
  {
    case ST_None:       SupportRadius = 25.f;     break;
    case ST_Trivial:    SupportRadius = 50.f;     break;
    case ST_Important:  SupportRadius = 100.f;    break;
    case ST_Critical:   SupportRadius = 1000.f;   break;
  }

  Extent = vect(1, 1, 0) * SupportRadius;

  for (i = 0; i < NumTraces; i++)
  {
    // Trace up
    UpActor = Trace(HitLocUp, HitNormal, EndUp, StartUp, true, Extent);
    if (UpActor != none)
    {
      // Hit another tile. Now trace down
      // to see if it's floating (it probably is..)..
      HitTileUp = GlassMoverPlus(UpActor);
      if (HitTileUp != none)
      {
        StartDown = HitLocUp;
        EndDown = StartDown - (TraceUpDist * Vect(0, 0, 1));

        if (bDebugFloatingTiles)
        {
          DrawStayingDebugLine(StartUp, HitLocUp, 255, 255,255);
          DrawStayingDebugLine(StartUp, HitLocUp, 255, 255,255);
          DrawStayingDebugLine(StartUp, HitLocUp, 255, 255,255);
        }

        DownActor = Trace(HitLocDown, HitNormal, EndDown, StartDown, true, (vect(1, 1, 0) * CollisionRadius * 0.9));
        Drop = VSize(HitLocDown - StartDown);

        // there's nothing stable underneath this tile, so it's floating... kill it.
        if (Drop > MaxDrop || (DownActor != none && !DownActor.bWorldGeometry))
        {
          // // We are not supporting this tile , so skip over it instead of destroying.
          // if(HitTileUp.SupportGrade  > SupportGrade && ReTraceAttempts < 10)
          // {
          //   StartUp = HitTileUp.Location + (vect(0,0,1) * (0.5 * HitTileUp.CollisionHeight));
          //   EndUp = StartUp + (TraceUpDist * Vect(0,0,1));

          //   // roll the loop back one step so we can keep going up
          //   i -- ;
          //   ReTraceAttempts ++;

          // }
          // else
          // {
          //	HitTileUp.InstigatorGrade = SupportGrade;
            HitTileUp.DoTileDeath(Killer); // recursive.
            ReTraceAttempts = 0;
        //	}

          if (bDebugFloatingTiles)
          {
            DrawStayingDebugLine(StartDown, HitLocDown, 255, 0, 0);
          }
        }
        else
        {
          if (bDebugFloatingTiles)
          {
            // something's there. we're good ..
            // (shouldn't really be getting here in the first place tho)
            DrawStayingDebugLine(StartDown, HitLocDown, 0, 255, 0);
          }
        }
      }
    }
  }
}

// Performs a series of traces to determine if there is anything nearby the supplied tile
// which could support it.  Returns false if the tile is floating
function bool IsTileSupported(GlassMoverPlus InTile, optional bool bCheckBaseOnly)
{
  local vector Extent;
  local vector HitLocation,HitNormal;
  local vector TraceStart,TraceEnd;
  local Actor HitActor;
  local float CheckDist;
  local float SupportRating;
  local ESupportType SupporterStrength;
  // local int TraceDownIterations;
  local float MinDesiredRating;
  // local float HitDist;
  local GlassMoverPlus HitTile;

  CheckDist = 10.f;
  MinDesiredRating = 1.f;

  Extent.Z = InTile.CollisionHeight;
  Extent.X = InTile.CollisionRadius;
  Extent.Y = InTile.CollisionRadius;

  if (bCheckBaseOnly)
  {
    TraceStart = InTile.Location - (vect(0, 0, 1) * (InTile.CollisionHeight * 0.5));
    TraceEnd = TraceStart - (CheckDist * vect(0, 0, 1));
    HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true, Extent * 0.9);

    HitTile = GlassMoverPlus(HitActor);
    if (HitTile != none)
    {
      return HitTile.SupportGrade >= SupportGrade;
    }

    return HitActor != none && HitActor.bWorldGeometry;
  }

  // Check above (Weakest form of support)
  TraceStart = InTile.Location + (vect(0, 0, 1) * (InTile.CollisionHeight * 0.5));
  TraceEnd = TraceStart + (CheckDist * vect(0, 0, 1));
  HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true, Extent);

  if (CanSupportMe(HitActor, SupporterStrength))
  {
    SupportRating += 0.1;
    if (SupportRating >= MinDesiredRating)
    {
      return true;
    }
  }

  // To the left
  TraceStart = InTile.Location + (vect(1, 0 ,0) * (InTile.CollisionHeight * 0.5));
  TraceEnd = TraceStart + (CheckDist * vect(1, 0, 0));
  HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true, Extent);

  if (CanSupportMe(HitActor, SupporterStrength))
  {
    SupportRating += 0.25;
    if (SupporterStrength > SupportGrade)
    {
      SupportRating += 0.1;
    }

    if (SupportRating >= MinDesiredRating)
    {
      return true;
    }
  }

  // To the right
  TraceStart = InTile.Location - (vect(1, 0, 0) * (InTile.CollisionHeight * 0.5));
  TraceEnd = TraceStart - (CheckDist * vect(1, 0, 0));
  HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true, Extent);

  if (CanSupportMe(HitActor, SupporterStrength))
  {
    SupportRating += 0.25;
    if (SupporterStrength > SupportGrade)
    {
      SupportRating += 0.1;
    }

    if (SupportRating >= MinDesiredRating)
    {
      return true;
    }
  }

  // To the front
  TraceStart = InTile.Location + (vect(0, 1, 0) * (InTile.CollisionHeight * 0.5));
  TraceEnd = TraceStart + (CheckDist * vect(0, 1, 0));
  HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true, Extent);

  if (CanSupportMe(HitActor, SupporterStrength))
  {
    SupportRating += 0.25;
    if (SupporterStrength > SupportGrade)
    {
      SupportRating += 0.1;
    }

    if (SupportRating >= MinDesiredRating)
    {
      return true;
    }
  }

  // To the back
  TraceStart = InTile.Location - (vect(0, 1, 0) * (InTile.CollisionHeight * 0.5));
  TraceEnd =	TraceStart - (CheckDist * vect(0, 1, 0));
  HitActor = Trace(HitLocation, HitNormal, TraceEnd, TraceStart, true, Extent);

  if (CanSupportMe(HitActor, SupporterStrength))
  {
    SupportRating += 0.25;
    if (SupporterStrength > SupportGrade)
    {
      SupportRating += 0.1;
    }

    if (SupportRating >= MinDesiredRating)
    {
      return true;
    }
  }

  return SupportRating >= MinDesiredRating;
}


// Wrapper for determining if a given actor is capable of supporting this tile
function bool CanSupportMe(Actor A, optional out ESupportType SupportTileStrength)
{
  local GlassMoverPlus SupportTile;
  local bool WorldGeo;

  if (A == none)
  {
    return false;
  }

  SupportTile = GlassMoverPlus(A);
  if (SupportTile != none)
  {
    SupportTileStrength = SupportTile.SupportGrade;
    return !SupportTile.IsDead() && SupportTile.SupportGrade >= SupportGrade && IsTileSupported(SupportTile, true);
  }

  WorldGeo = A.bWorldGeometry && A.bBlockActors;
  if (WorldGeo)
  {
    SupportTileStrength = ST_Critical;
  }

  return WorldGeo;
}


// Some sort of bug with Pawn physics where if they are crouching they will just float in the air, even if there's nothing underneath them ..
// Let's remind them that they should in fact be falling ..
function JumpPawns()
{
  local Actor A;

  foreach BasedActors(class'Actor', A)
  {
    A.SetPhysics(PHYS_Falling);
    A.Velocity.Z += 10;
  }
}


// Respawn this tile and all tiles linked to it
function DoTileRespawn()
{
  if (IsDead())
  {
    // bWorldGeometry = true;
    bNetNotify = true;
    RunSimulated();
    RespawnTile();
    BreakAIPaths(false);
  }
}


// Notify bots that the pathnodes this tile supported are currently unuseable
function BreakAIPaths(bool BreakPaths)
{
  local NavigationPoint P;
  // local PlayerStart PS;

  foreach BasedActors(class'NavigationPoint', P)
  {
    P.bBlocked = BreakPaths;
  }
}


// Switch this actor's remote role to simulated and bump up its net priority so that changes in its properties have a chance to reach clients
function RunSimulated()
{
  RemoteRole = Role_SimulatedProxy;
  NetUpdateFrequency = 100;
  // SetTimer(1.0,false);
}


// Called when the tile's health drops to zero
// Disable collision on this tile, hide the staticmesh and play a particle effect
simulated function BreakTile()
{
  bDestroyed = true;

  SetDrawType(DT_None);
  // SetStaticmesh(staticmesh 'GlassHouseSM.StaticMeshes.WoodPieces_Square');
  SetCollision(false,false,false);
  bHidden = true;

  ToggleRoofLight(true);
  // immediate update of replicated vars.. I guess this is the UE2 approximation of bForceNetUpdate ?
  NetUpdateTime = Level.TimeSeconds - 1;

  AdjustAntiPortals();

  if (Level.NetMode != NM_DedicatedServer)
  {
    // log("Spawning Destruction Emitter of Class : "@DestructionEmitter);
    Spawn(DestructionEmitter);
    SpawnTileGibs();
  }
}


simulated function SpawnTileGibs()
{
  local DoorGib Giblet;
  local int i;
  local float GibOffset;

  if (GibClass == none)
    return;

  GibOffset = 100.f;

  for (i = 0; i < NumGiblets; i++)
  {
    Giblet = spawn(GibClass,,, Location + VRand() * GibOffset, RotRand(true));

    if (Giblet != none)
    {
      Giblet.SetDrawScale(Giblet.DrawScale * 1.5);
      Giblet.Velocity = DeathMomentum;
      Giblet.LifeSpan = 5.f;
    }
  }
}


simulated	function ToggleRoofLight(bool On)
{
  if (TileLight != none)
  {
    if (On)
    {
      TileLight.ActivateLight();
    }
    else
    {
      TileLight.ResetLight();
    }
  }
}


// return the actor to a role of none - low network consumption settings
function RunClientOnly()
{
  RemoteRole = Role_None;
  NetUpdateFrequency = 0;
  // SetTimer(1.0, false);
}


// Called via Trigger on Wave end - Brings this tile 'back to life' (Resets Health, Collision and DrawType settings)
simulated function RespawnTile()
{
  bDestroyed = false;

  bHidden = false;
  SetDrawType(DT_StaticMesh);
  Health = default.Health;
  SetCollision(true,true,true);

  ToggleRoofLight(false);

  // immediate update of replicated vars.. I guess this is the UE2 approximation of bForceNetUpdate ?
  NetUpdateTime = Level.TimeSeconds - 1;
}


// Destroyed tiles will re-appear when triggered
// function Trigger( actor Other, pawn EventInstigator )
// {
//   log(self@"was just triggered .");

//   if (IsDead())
//   {
//     RespawnTile();
//   }

//   TriggerEvent(Event, Self, EventInstigator);
// }



// Retrieves a list of the other (visible) GlassMover actors in the supplied radius
simulated function GetNearbyTiles(float Radius, out array<GlassMoverPlus> NearbyTiles)
{
  local int i;
  local GlassMoverPlus Tile;
  local float Dist;
  local GlassHouseGameInfo GlassGame;

  GlassGame = GlassHouseGameinfo(Level.Game);

  if (GlassGame != none)
  {
    for (i = 0; i < GlassGame.AllTiles.length; i++)
    {
      Tile = GlassGame.AllTiles[i];
      Dist = VSize(Tile.Location - Location);
      if (Tile != self && Dist <= Radius && !Tile.IsDead() && Tile.Location.Z > Location.Z)
      {
        NearbyTiles[NearbyTiles.length] = Tile;
      }
    }
  }
}


defaultproperties
{
  SupportGrade=ST_Trivial
  GibClass=Class'KFMod.DoorGibMetalA'
  NumGiblets=10
  GibVelocityScale=0.001000
  SmallArmsDmgScaling=1.000000
  AcidDmgScaling=1.000000
  FireDmgScaling=10.000000
  ScreamDmgScaling=1.000000
  GlobalDamageModifier=1.000000
  Health=100
  bNoDelete=true
  bNetTemporary=true
  bAlwaysRelevant=true
  bOnlyDirtyReplication=true
  RemoteRole=ROLE_None
  NetUpdateFrequency=0.000000
  DrawScale=2.000000
  bCanBeDamaged=true
  bCollideWorld=true
  bPathColliding=true
}