// --------------------------------------------------------------
// ZombieGorefast_GH
// --------------------------------------------------------------

// Modified Type of Gorefast for use in the glasshouse map.
// Leaps alot further than usual.

// Author :  Alex Quick

// --------------------------------------------------------------


class ZombieGorefast_GH extends ZombieGorefast_STANDARD;


event HitWall(vector HitNormal, actor HitWall)
{
  local GlassMoverPlus BreakableWall;

  BreakableWall = GlassMoverPlus(HitWall);

  if (BreakableWall != none && BreakableWall.ObjMaterialType == OMT_Glass)
  {
    BreakableWall.DoTileDeath();
  }
}


defaultproperties
{
  bDirectHitWall=true
  ControllerClass=class'ctrl_KFMonster_GH'
}