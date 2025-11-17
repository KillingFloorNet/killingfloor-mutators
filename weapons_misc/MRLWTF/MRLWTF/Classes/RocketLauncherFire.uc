class RocketLauncherFire extends LAWFire;

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local Projectile P;

	if( FRand() <= 0.05 )
		P = Weapon.Spawn(Class'MRLWTF.RocketLauncherProjWTF',,, Start, Dir);
	else
		P = Weapon.Spawn(ProjectileClass,,, Start, Dir);

	if( P == None )
		return None;

	P.Damage *= DamageAtten;
	return P;
}

defaultproperties
{
     AmmoClass=Class'MRLWTF.RocketLauncherAmmo'
     ProjectileClass=Class'MRLWTF.RocketLauncherProjWTF'
}
