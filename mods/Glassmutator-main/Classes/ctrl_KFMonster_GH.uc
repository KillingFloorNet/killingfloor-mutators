// --------------------------------------------------------------
// KFMonsterController_GH
// --------------------------------------------------------------

// Modified Type of KFMonsterController for use in the glasshouse map.
// Gives charging zombies the ability to leap great distances to reach
// players.

// this code is going to be copy pasted across all Monster controllers,
// because I don't know how else I can get it to take effect for all monsters
//  classes short of modifing KFMod.KFMonsterController and recompiling the main
// KFMod/KFChar script packages. At which point i'm making a mod instead of
// a mutator, right?

// Author :  Alex Quick

// --------------------------------------------------------------

class ctrl_KFMonster_GH extends KFMonsterController;

var bool bPerformingLeap;

var bool bSeeThroughWalls;


function JumpThroughRoof();


function bool EnemyVisible()
{
  return bSeeThroughWalls || super.EnemyVisible();
}


function bool FindNewEnemy()
{
  local Pawn BestEnemy;
  local bool bSeeNew, bSeeBest;
  local float BestDist, NewDist;
  local Controller PC;

  if (KFM.bNoAutoHuntEnemies)
    return false;
  if (KFM.bCannibal && pawn.Health < (1.0 - KFM.FeedThreshold) * pawn.HealthMax || Level.Game.bGameEnded)
  {
    return super.FindNewEnemy();
  }
  else
  {
    for (PC = Level.ControllerList; PC != none; PC = PC.NextController)
    {
      if (PC.bIsPlayer && (PC.Pawn != none) && PC.Pawn.Health > 0)
      {
        if (BestEnemy == none)
        {
          BestEnemy = PC.Pawn;
          if (BestEnemy != none)
          {
            BestDist = VSize(BestEnemy.Location - Pawn.Location);
            bSeeBest = CanSee(BestEnemy) || bSeeThroughWalls;
          }
        }
        else
        {
          NewDist = VSize(PC.Pawn.Location - Pawn.Location);
          if (!bSeeBest || (NewDist < BestDist))
          {
            bSeeNew = CanSee(PC.Pawn) || bSeeThroughWalls;
            if (NewDist < BestDist)
            {
              BestEnemy = PC.Pawn;
              BestDist = NewDist;
              bSeeBest = bSeeNew;
            }
          }
        }
      }
    }
  }

  if (BestEnemy == Enemy)
    return false;

  if (BestEnemy != none)
  {
    ChangeEnemy(BestEnemy, CanSee(BestEnemy) || bSeeThroughWalls);
    return true;
  }
  return false;
}


// KFMonsterController Implementation of Set Enemy
// FIX, TWI added optional 'MonsterHateChanceOverride' parameter
function bool SetEnemy(Pawn NewEnemy, optional bool bHateMonster, optional float MonsterHateChanceOverride)
{
  if (!bHateMonster && KFHumanPawnEnemy(NewEnemy) != none && KFHumanPawnEnemy(NewEnemy).AttitudeToSpecimen <= ATTITUDE_Ignore)
    return false; // In other words, dont attack human pawns as long as they dont damage me or hates me.
  if (KFM.Intelligence >= BRAINS_Mammal && Enemy != none && NewEnemy != none && NewEnemy != Enemy && NewEnemy.Controller != none && NewEnemy.Controller.bIsPlayer)
  {
    if (LineOfSightTo(Enemy) && VSize(Enemy.Location - Pawn.Location) < VSize(NewEnemy.Location - Pawn.Location))
      return false;
    Enemy = none;
  }
  // Get pissed at this fucker..
  if (bHateMonster && KFMonster(NewEnemy) != none && NewEnemy.Controller != none && (NewEnemy.Controller.Target == Self || FRand() < 0.15) && NewEnemy.Health > 0 && VSize(NewEnemy.Location - Pawn.Location) < 1500 && LineOfSightTo(NewEnemy))
  {
    ChangeEnemy(NewEnemy, CanSee(NewEnemy));
    return true;
  }
  if (MonsterControllerSetEnemy(NewEnemy, bHateMonster))
  {
    if (!bTriggeredFirstEvent)
    {
      bTriggeredFirstEvent = true;
      if (KFM.FirstSeePlayerEvent != '')
        TriggerEvent(KFM.FirstSeePlayerEvent, Pawn, Pawn);
    }
    return true;
  }
  return false;
}


// MonsterController Implementation of SetEnemy - Split out from KFMonsterController.SetEnemy and renamed for clarity.
function bool	MonsterControllerSetEnemy(Pawn NewEnemy , optional bool bHateMonster)
{
  local float EnemyDist;
  local bool bNewMonsterEnemy;

  if ((NewEnemy == none) || (NewEnemy.Health <= 0) || (NewEnemy.Controller == none) || (NewEnemy == Enemy))
    return false;

  bNewMonsterEnemy = bHateMonster && (Level.Game.NumPlayers < 4) && !Monster(Pawn).SameSpeciesAs(NewEnemy) && !NewEnemy.Controller.bIsPlayer;
  if (!NewEnemy.Controller.bIsPlayer	&& !bNewMonsterEnemy)
    return false;

  if ((bNewMonsterEnemy && LineOfSightTo(NewEnemy)) || (Enemy == none) || !EnemyVisible())
  {
    ChangeEnemy(NewEnemy, CanSee(NewEnemy) || bSeeThroughWalls);
    return true;
  }

  if (!CanSee(NewEnemy) && !bSeeThroughWalls)
    return false;

  if (!bHateMonster && (Monster(Enemy) != none) && NewEnemy.Controller.bIsPlayer)
    return false;

  EnemyDist = VSize(Enemy.Location - Pawn.Location);
  if (EnemyDist < Pawn.MeleeRange)
    return false;

  if (EnemyDist > 1.7 * VSize(NewEnemy.Location - Pawn.Location))
  {
    ChangeEnemy(NewEnemy, CanSee(NewEnemy) || bSeeThroughWalls);
    return true;
  }
  return false;
}


state ZombieHunt
{
  function Timer()
  {
    super.Timer();

    // if(!Pawn.PlayerCanSeeMe() && Enemy != none && Pawn.Location.Z < Enemy.Location.Z &&
    // Abs(Pawn.Location.Z - Enemy.Location.Z) >= 150 )
    // {
    //   GlassHouseGameinfo(Level.Game).TeleportZombieAbovePlayer(Pawn,Enemy.Location) ;
    // }

    if (Enemy != none && Enemy.Location.Z < Pawn.Location.Z && VSize(Enemy.Location - Location) <= (Pawn.CollisionRadius * 3))
    {
      JumpThroughRoof();
    }
  }

  function JumpThroughRoof()
  {
    local GlassMoverPlus RoofTile;

    if (Pawn.Base != none)
    {
      RoofTile = GlassMoverPlus(Pawn.Base);
      if (RoofTile != none)
      {
        RoofTile.DoTileDeath();
        Pawn.bCanJump = true;
      }
    }
  }
}


// In this state the zombie has a direct line of sight to the player and he's moving close enough to attack
state ZombieCharge
{
  function MayFall()
  {
    local bool ShouldLeap;

    super.MayFall();

    ShouldLeap = LineOfSightTo(Enemy) && Focus == Enemy;
    // if bCanJump is true, the Native physics code takes over.  We don't really want that to happen when we're trying to leap.
    if (ShouldLeap)
    {
      Pawn.bCanJump = false;
      LeapToward(Enemy);
    }
  }

  function EnemyNotVisible()
  {
    if (bSeeThroughWalls)
    {
      return;
    }

    super.EnemyNotVisible();
  }
}


// Converted from UDKPathing.cpp -> UBOOL AUDKJumpPad::CalculateJumpVelocity
function bool LeapToward(actor Target)
{
  local vector JumpVelocity;
  local vector Flight, FlightDir;
  local float FlightZ;
  local actor JumpTarget;
  local float FlightSize;
  local float Gravity;
  local float XYSpeed;
  local float ZSpeed;
  local bool bFailed;
  local bool bDecreasing;
  local float AdjustedJumpTime;
  local vector StartVel;
  local float StepSize;
  local float Step;
  local vector HumanSize;
  local float FlightTime;
  local vector TraceStart, TraceEnd;
  local float JumpTime;

  JumpTarget = Target;

  if (JumpTarget == none)
  {
    return false;
  }

  return false;

  HumanSize.X = Pawn.CollisionRadius;
  HumanSize.Z = Pawn.CollisionHeight;
  HumanSize.Y = Pawn.CollisionRadius;

  Flight = JumpTarget.Location - Pawn.Location;
  FlightZ = Flight.Z;
  Flight.Z = 0.f;
  FlightSize = VSize(Flight);

  if (FlightSize == 0.f)
  {
    return false;
  }

  JumpTime = 2.f;//FClamp(FlightSize/2500.f,0.25,2.0);
  Gravity = Pawn.PhysicsVolume.Gravity.Z;

  XYSpeed = FlightSize / JumpTime;
  ZSpeed = FlightZ / JumpTime - Gravity * JumpTime;

  // trace check trajectory
  bFailed = true;
  FlightDir = Flight / FlightSize;

  // look for unobstructed trajectory, by increasing or decreasing flighttime
  bDecreasing = true;
  AdjustedJumpTime = JumpTime;

  while (bFailed)
  {
    StartVel = XYSpeed * FlightDir + Vect(0, 0, 1) * ZSpeed;
    StepSize = 0.0625f;
    TraceStart = Pawn.Location;
    bFailed = false;

    // trace trajectory to make sure it isn't obstructed
    for (Step = 0.f; Step < 1.f; Step += StepSize)
    {
      FlightTime = (Step+StepSize) * AdjustedJumpTime;
      TraceEnd = Pawn.Location + StartVel*FlightTime + (Vect(0, 0, 1) * (Gravity * FlightTime * FlightTime));
      if (!FastTrace(TraceEnd,TraceStart))
      {
        bFailed = true;
        break;
      }

      TraceStart = TraceEnd;
    }

    if (bFailed)
    {
      if (bDecreasing)
      {
        AdjustedJumpTime -= 0.1f * JumpTime;
        if (AdjustedJumpTime < 0.5f * JumpTime)
        {
          bDecreasing = false;
          AdjustedJumpTime = JumpTime + 0.2f * JumpTime;
        }
      }
      else
      {
        AdjustedJumpTime += 0.2f * JumpTime;
        if (AdjustedJumpTime > 2.f * JumpTime)
        {
          // no valid jump possible
          return false;
        }

        XYSpeed = FlightSize / AdjustedJumpTime;
        ZSpeed = FlightZ / AdjustedJumpTime - Gravity * AdjustedJumpTime;
      }
    }
  }

  JumpVelocity = XYSpeed * FlightDir + Vect(0, 0, 1)  *ZSpeed;

  // log("Upating velocity of "@Pawn@" to :"@JumpVelocity);
  Pawn.Velocity = JumpVelocity;
  Pawn.SetPhysics(PHYS_Falling);
  bPerformingLeap = true;
  bPlannedJump = true;
  Focus = Target;

  return true;
}


function bool FindBestPathToward(Actor A, bool bCheckedReach, bool bAllowDetour)
{
  if ((!ActorReachable(A) || Abs(A.Location.Z - Pawn.Location.Z) >= Pawn.CollisionHeight) && !bPerformingLeap)
  {
    LeapToward(A);
  }

  return super.FindBestPathToward(A, bCheckedReach, bAllowDetour);
}


function bool NotifyLanded(vector HitNormal)
{
  bPerformingLeap = false;

  return super.NotifyLanded(HitNormal);
}


defaultproperties
{
  bSeeThroughWalls=true
}