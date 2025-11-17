class WTFEquipSawedOffShotgun extends WTFEquipBoomStick;



// can't use slugs with this weapon
function bool AllowReload()
{
	if (super(KFWeapon).AllowReload())
	{
		SetPendingReload();
		return true;
	}
	return false;
}

defaultproperties
{
	Weight=5.000000
	FireModeClass(0)=Class'WTFEquipSawedOffShotgunAltFire'
	FireModeClass(1)=Class'WTFEquipSawedOffShotgunFire'
	AmmoClass(0)=Class'WTFEquipSawedOffShotgunAmmo'
	PickupClass=Class'WTFEquipSawedOffShotgunPickup'
	ItemName="Sawed-Off Shotgun"
	Skins(0)=Texture'WTF_A.SawedOffShotgun.SawedOffShotgun'
	SkinRefs(0)="WTF_A.SawedOffShotgun.SawedOffShotgun"
}
