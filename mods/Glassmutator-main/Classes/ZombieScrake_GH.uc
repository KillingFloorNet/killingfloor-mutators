// --------------------------------------------------------------
// ZombieScrake_GH
// --------------------------------------------------------------

// Modified Type of Scrake for use in the glasshouse map.
// Able to smash tiles when charging players.

// Author :  Alex Quick

// --------------------------------------------------------------


class ZombieScrake_GH extends ZombieScrake_STANDARD;


event HitWall(vector HitNormal, actor HitWall)
{
  local GlassMoverPlus BreakableWall;

  if (bCharging)
  {
    BreakableWall = GlassMoverPlus(HitWall);
    if (BreakableWall != none)
    {
      // If we've run into a wall destroy it
      if (Abs(Hitnormal.Z) <= 0.25)
      {
        BreakableWall.DoTileDeath();
      }
    }
  }
}


defaultproperties
{
  bDirectHitWall=true
  ControllerClass=class'ctrl_SC_GH'
}