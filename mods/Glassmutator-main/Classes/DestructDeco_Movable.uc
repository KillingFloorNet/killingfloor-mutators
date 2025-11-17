// --------------------------------------------------------------
// DestructDeco_Movable
// --------------------------------------------------------------

// Non-static Destructable actor. Uses simple falling physics.

// Author :  Alex Quick

// --------------------------------------------------------------


class DestructDeco_Movable extends GlassMoverPlus;


defaultproperties
{
  Health=1000
  bStatic=false
  bWorldGeometry=false
  Physics=PHYS_Falling
  bBounce=true
  Mass=1.000000
}