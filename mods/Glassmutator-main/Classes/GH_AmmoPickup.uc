
// --------------------------------------------------------------
// GH_AmmoPickup
// --------------------------------------------------------------

// Ammo pickup for use in 'GlassHouse' maps.

// Extended so we can add it GlassHouseGameInfo's AmmoPickups array.
// (KFAmmoPickup looks for KFGameType).

// Author :  Alex Quick

// --------------------------------------------------------------


class GH_AmmoPickup extends KFAmmoPickup;


event PostBeginPlay()
{
  // Add to GlassHouseGameInfo.AmmoPickups array
  if (GlassHouseGameInfo(Level.Game) != none)
  {
    GlassHouseGameInfo(Level.Game).AmmoPickups[GlassHouseGameInfo(Level.Game).AmmoPickups.Length] = self;
    GotoState('Sleeping', 'Begin');
  }
}


defaultproperties
{
  bHidden=true
}