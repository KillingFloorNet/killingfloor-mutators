class WTFEquipNadeFire extends FragFire;

#exec OBJ LOAD FILE=WTFSounds.uax

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
		if (KFPRI.ClientVeteranSkill == Class'SRVetFirebug')
			g = Weapon.Spawn(Class'WTF.WTFEquipNadeFlame', instigator,, Start, Dir);
		else if (KFPRI.ClientVeteranSkill == Class'SRVetCommando')
			g = Weapon.Spawn(Class'WTF.WTFEquipNadeStun', instigator,, Start, Dir);
		else if (KFPRI.ClientVeteranSkill == Class'SRVetDemolitions')
			g = Weapon.Spawn(Class'WTF.WTFEquipNadeHE', instigator,, Start, Dir);
		else if (KFPRI.ClientVeteranSkill == Class'SRVetSupportSpec')
			g = Weapon.Spawn(Class'WTF.WTFEquipNadeHE', instigator,, Start, Dir);
		else if (KFPRI.ClientVeteranSkill == Class'SRVetBerserker')
			//g = Weapon.Spawn(Class'WTF.WTFEquipNadeImpact', instigator,, Start, Dir);
			g = Weapon.Spawn(Class'WTF.WTFEquipNadeThrowingKnife', instigator,, Start, Dir);
	}

	if (g == None)
	{
		g = Weapon.Spawn(Class'WTF.WTFEquipNadePlain', instigator,, Start, Dir);
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
     ProjectileClass=Class'WTF.WTFEquipNadePlain'
}
