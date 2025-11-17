class WTFEquipMP7M2AltFire extends MP7MAltFire;

event ModeDoFire()
{
	if (Instigator == None)
		return;
	FireRate=0.25;
	AmmoPerFire=100;
	bWaitForRelease=False;
	Super.ModeDoFire();
}

defaultproperties
{
}
