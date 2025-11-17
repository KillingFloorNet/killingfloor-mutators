// --------------------------------------------------------------
// KFMonsterController_GH
// --------------------------------------------------------------

// Modified Type of KFMonsterController for use in the glasshouse map.
// Gives charging zombies the ability to leap great distances to reach
// players.

// this code is going to be copy pasted across all Monster controllers,
// because I don't know how else I can get it to take effect for all monsters
// classes short of modifing KFMod.KFMonsterController and recompiling the main
// KFMod/KFChar script packages. At which point i'm making a mod instead of
// a mutator, right?

// Author :  Alex Quick

// --------------------------------------------------------------

class ctrl_Boss_GH extends BossZombieController;


var bool bPerformingLeap;


// stub, to prevent crashing
function TryLeapToEnemy(){}


// In this state the zombie has a direct line of sight to the player and he's moving close enough to attack
state ZombieCharge
{
  function MayFall()
  {
    Super.MayFall();
    bPerformingLeap = LineOfSightTo(Enemy);
    // if bCanJump is true, the Native physics code takes over.  We don't really want that to happen when we're trying to leap.
    if (bPerformingLeap)
    {
      Pawn.bCanJump = false;
    }
  }

  function TryLeapToEnemy()
  {
    local float Dist, Speed;
    local float Gravity;
    local vector TestVelocity, FinalVelocity;

    if (bPerformingLeap)
    {
      if (Pawn.Physics != PHYS_Falling)
      {
        Gravity = FClamp(Pawn.PhysicsVolume.Gravity.Z, -Pawn.PhysicsVolume.TerminalVelocity, Pawn.PhysicsVolume.TerminalVelocity);

        Dist = VSize(Enemy.Location - Pawn.Location);
        Speed = Dist;
        if(Gravity < 0)
        {
          Speed += ((Abs(Gravity) * Dist) / Pawn.AccelRate);
        }

        TestVelocity =  Normal(Enemy.Location - Pawn.Location) * Speed;
        TestVelocity.Z += Pawn.JumpZ;
        FinalVelocity = TestVelocity;

        Pawn.Velocity = FinalVelocity;
        Pawn.SetPhysics(PHYS_Falling);

        bPlannedJump = true;
        bPerformingLeap = false;
        Focus = Enemy;
      }
    }
  }

  function Timer()
  {
    super.Timer();
    TryLeapToEnemy();
  }
}


defaultproperties{}