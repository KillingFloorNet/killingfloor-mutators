// Incendiary M79
class ScrnM79Inc extends GoldenM79GrenadeLauncher;

defaultproperties
{
     AppID=0
     FireModeClass(0)=Class'ScrnBalanceSrv.ScrnM79IncFire'
     Description="A classic Vietnam era grenade launcher. Launches incendiary grenades."
     Priority=95
     PickupClass=Class'ScrnBalanceSrv.ScrnM79IncPickup'
     ItemName="M79 Incendiary"
}
