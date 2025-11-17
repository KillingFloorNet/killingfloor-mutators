// --------------------------------------------------------------
// ZombieHusk_GH
// --------------------------------------------------------------

// Modified Type of Husk for use in the glasshouse map.
// Able to fire at players without direct line of sight.

// Author :  Alex Quick

// --------------------------------------------------------------


class ZombieHusk_GH extends ZombieHusk_STANDARD;


defaultproperties
{
  bDirectHitWall=true
  ControllerClass=class'ctrl_Husk_GH'
}