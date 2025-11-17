// --------------------------------------------------------------
// GH_RandomItemSpawn
// --------------------------------------------------------------

// Item/Weapon pickup for use in 'GlassHouse' maps.
// Extended so we can add it GlassHouseGameInfo's WeaponPickups array.

// Author :  Alex Quick

// --------------------------------------------------------------


class GH_RandomItemSpawn extends KFRandomItemSpawn;


event PostBeginPlay()
{
  super.PostBeginPlay();

  // Add to GlassHouseGameInfo.WeaponPickups array
  if (GlassHouseGameInfo(Level.Game) != none)
  {
    GlassHouseGameInfo(Level.Game).WeaponPickups[GlassHouseGameInfo(Level.Game).WeaponPickups.Length] = self;
    DisableMe();
  }
}


function bool RandomEnabled(int CurrentWave, int FinalWave)
{
  return true;
}


defaultproperties{}