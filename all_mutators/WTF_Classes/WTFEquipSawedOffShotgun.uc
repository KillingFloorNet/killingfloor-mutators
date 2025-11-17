class WTFEquipSawedOffShotgun extends WTFEquipBoomStick;

#exec OBJ LOAD FILE=WTFTex2.utx

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
     FireModeClass(0)=Class'WTF.WTFEquipSawedOffShotgunAltFire'
     FireModeClass(1)=Class'WTF.WTFEquipSawedOffShotgunFire'
     AmmoClass(0)=Class'WTF.WTFEquipSawedOffShotgunAmmo'
     PickupClass=Class'WTF.WTFEquipSawedOffShotgunPickup'
     ItemName="Sawed-Off Shotgun"
     Skins(0)=Texture'WTFTex2.SawedOffShotgun.SawedOffShotgun'
}
