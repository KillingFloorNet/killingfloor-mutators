class WTFEquipUM32AltFire extends M32Fire;

//only for demos
event ModeDoFire()
{
	local KFPlayerReplicationInfo KFPRI;
	
	KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
	Super.ModeDoFire();
}

defaultproperties
{
     ProjectileClass=Class'WTF.WTFEquipUM32ProximityMine'
}
