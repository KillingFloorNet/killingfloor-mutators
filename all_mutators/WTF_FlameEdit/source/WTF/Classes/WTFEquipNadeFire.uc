class WTFEquipNadeFire extends FragFire;

#exec OBJ LOAD FILE=WTF_A

var KFPlayerReplicationInfo KFPRI;

//OVERRIDING FOR MY CUSTOM NADE TYPES
function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local Projectile g;
	local vector X, Y, Z;
	local float pawnSpeed;

	KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
	if (KFPRI != none)
	{
		if (KFPRI.ClientVeteranSkill.Name == 'SRVetFirebug')
			g = Weapon.Spawn(Class'WTFEquipNadeFlame', instigator,, Start, Dir);
		else if (KFPRI.ClientVeteranSkill.Name == 'SRVetCommando')
			g = Weapon.Spawn(Class'WTFEquipNadeStun', instigator,, Start, Dir);
		else if (KFPRI.ClientVeteranSkill.Name == 'SRVetDemolitions')
			g = Weapon.Spawn(Class'WTFEquipNadeHE', instigator,, Start, Dir);
		else if (KFPRI.ClientVeteranSkill.Name == 'SRVetSupportSpec')
			g = Weapon.Spawn(Class'WTFEquipNadeHE', instigator,, Start, Dir);
		else if (KFPRI.ClientVeteranSkill.Name == 'SRVetBerserker')
			//g = Weapon.Spawn(Class'WTFEquipNadeImpact', instigator,, Start, Dir);
			g = Weapon.Spawn(Class'WTFEquipNadeThrowingKnife', instigator,, Start, Dir);
	}

	if (g == None)
	{
		g = Weapon.Spawn(Class'WTFEquipNadePlain', instigator,, Start, Dir);
	}

	if (g != None)
	{
		Weapon.GetViewAxes(X,Y,Z);
		pawnSpeed = X dot Instigator.Velocity;

		if ( Bot(Instigator.Controller) != None )
		{
			g.Speed = mHoldSpeedMax;
		}
		else
		{
			g.Speed = mHoldSpeedMin + HoldTime*mHoldSpeedGainPerSec;
		}

		g.Speed = FClamp(g.Speed, mHoldSpeedMin, mHoldSpeedMax);
		g.Speed = pawnSpeed + g.Speed;
		g.Velocity = g.Speed * Vector(Dir);
		//g.Damage *= DamageAtten;
	}

	return g;
}

defaultproperties
{
     ProjectileClass=Class'WTFEquipNadePlain'
}
