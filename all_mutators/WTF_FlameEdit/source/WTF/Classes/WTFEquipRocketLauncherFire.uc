class WTFEquipRocketLauncherFire extends LAWFire;

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local Projectile p;
	p = Weapon.Spawn(Class'WTFEquipRocketLauncherProjWTF',,, Start, Dir);
	if( p == None )
		return None;
	p.Damage *= DamageAtten;
	return p;
}

defaultproperties
{
	AmmoClass=Class'WTFEquipRocketLauncherAmmo'
	ProjectileClass=Class'WTFEquipRocketLauncherProj'
}
