// --------------------------------------------------------------
// ZombieFleshPoundBase_GH
// --------------------------------------------------------------

// Modified Type of Fleshpound for use in the glasshouse map.
// Able to smash tiles when enraged.

// Author :  Alex Quick

// --------------------------------------------------------------


class ZombieBoss_GH extends ZombieBoss_STANDARD;


event HitWall(vector HitNormal, actor HitWall)
{
  local GlassMoverPlus BreakableWall;

  if (bChargingPlayer)
  {
    BreakableWall = GlassMoverPlus(HitWall);
    if (BreakableWall != none )
    {
      // If we've run into a wall destroy it
      if (Abs(Hitnormal.Z) <= 0.1)
      {
        BreakableWall.DoTileDeath();
      }
    }
  }
}


defaultproperties
{
  bDirectHitWall=true
  ControllerClass=class'ctrl_Boss_GH'
}