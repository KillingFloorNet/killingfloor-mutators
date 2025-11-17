class M79GrenadeLauncher_GH extends M79GrenadeLauncher;

#exec OBJ LOAD FILE=ProjectileSounds.uax


simulated function bool HasAmmo()
{
  return super.HasAmmo() || AIController(Instigator.Controller) != none;
}

defaultproperties
{
  bKFNeverThrow=true
  bCanThrow=false
  FireModeClass(0)=class'M79Fire_GH'
  PickupClass=class'M79Pickup_GH'
}