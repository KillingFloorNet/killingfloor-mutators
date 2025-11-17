class WTFEquipShotgun extends Shotgun;

function bool AllowReload()
{
	local WTFEquipShotgunFire FM0;
	if (bIsReloading) //doubletap reload to switch shell types anytime you can reload
	{
		FM0 = WTFEquipShotgunFire(FireMode[0]);
		if(FM0.GetShellType()==1)
		{
			PlayerController(Instigator.Controller).ReceiveLocalizedMessage(Class'WTFEquipBoomstickSwitchMessage',0); //loading slugs
			FM0.SetShellType(0);
		}
		else
		{
			PlayerController(Instigator.Controller).ReceiveLocalizedMessage(Class'WTFEquipBoomstickSwitchMessage',1); //loading shot
			FM0.SetShellType(1);
		}
		return false;
	}
	return super(KFWeapon).AllowReload();
}

defaultproperties
{
	FireModeClass(0)=Class'WTFEquipShotgunFire'
	Description="A deadly weapon"
	PickupClass=Class'WTFEquipShotgunPickup'
	ItemName="Shotgun profession"
}