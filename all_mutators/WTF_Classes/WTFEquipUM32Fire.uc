class WTFEquipUM32Fire extends M32Fire;

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local KFPlayerReplicationInfo KFPRI;
	
	KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
	if (KFPRI != none)
	{
		ProjectileClass=Class'WTF.WTFEquipUM32Proj';
	}
	else
		ProjectileClass=Class'WTF.WTFEquipUM32Proj';
		
	return Super.SpawnProjectile(Start,Dir);
}

defaultproperties
{
}
