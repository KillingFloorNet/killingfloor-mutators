class WTFEquipM79CFFire extends M79Fire;

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local KFPlayerReplicationInfo KFPRI;
	
	KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
	if (KFPRI != none)
	{
		ProjectileClass=Class'WTF.WTFEquipM79CFClusterBombProjectile';
	}
	else
		ProjectileClass=Class'WTF.WTFEquipM79CFClusterBombProjectile';
		
	return Super.SpawnProjectile(Start,Dir);
}

defaultproperties
{
}
