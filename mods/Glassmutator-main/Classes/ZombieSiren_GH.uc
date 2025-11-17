// --------------------------------------------------------------
// ZombieSiren_GH
// --------------------------------------------------------------

// Modified Type of Siren for use in the glasshouse map.

// Author :  Alex Quick

// --------------------------------------------------------------


class ZombieSiren_GH extends ZombieSiren_STANDARD;


// Scales the damage this Zed deals by the difficulty level
function float DifficultyDamageModifer()
{
  return 1.0;
}


// Scales the health this Zed has by the difficulty level
function float DifficultyHealthModifer()
{
  return 1.0;
}


function float DifficultyHeadHealthModifer()
{
  return 1.0;
}


defaultproperties
{
  ScreamRadius=1000
  ScreamForce=150000
  ScreamDamage=10
  GroundSpeed=150.000000
}