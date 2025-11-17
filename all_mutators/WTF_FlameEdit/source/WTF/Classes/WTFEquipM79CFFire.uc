class WTFEquipM79CFFire extends M79Fire;

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local KFPlayerReplicationInfo KFPRI;
	KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
	if (KFPRI.ClientVeteranSkill.Name == 'SRVetFirebug')
		ProjectileClass=Class'WTFEquipM79CFIncindiaryProj';
	else
		ProjectileClass=Class'WTFEquipM79CFClusterBombProjectile';
	return Super.SpawnProjectile(Start,Dir);
}