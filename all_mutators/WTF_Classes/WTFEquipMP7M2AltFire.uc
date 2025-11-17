class WTFEquipMP7M2AltFire extends MP7MAltFire;

var KFPlayerReplicationInfo KFPRI;

event ModeDoFire()
{
	if (Instigator == None)
		return;
		
	KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
	if (KFPRI != none && KFPRI.ClientVeteranSkill == Class'SRVetFieldMedic')
	{
		FireRate=0.25;
		AmmoPerFire=100;
		bWaitForRelease=False;
	}
	else
	{
		FireRate=0.25;
		AmmoPerFire=100;
		bWaitForRelease=False;
	}
	
	Super.ModeDoFire();
}

defaultproperties
{
}
