class VoodooDollFireSecondary extends SingleFire;

var float SelfDamageScale;

function DoTrace(Vector Start, Rotator Dir1)
{
	local Vector X, Y, Z;
	local Pawn Victims;
	local float Damage, DiffAngle; //FriendlyDist, 
	local bool damageDone;
	local Vector Dir, LookDir;

	Weapon.GetViewAxes(X, Y, Z);
	damageDone = false;
	// End:0x16f
	foreach Instigator.VisibleCollidingActors(class'Pawn', Victims, MaxRange())
	{
		// End:0x16e Loop:False
		if(Victims != Instigator && (!Instigator.Controller.SameTeamAs(Victims.Controller)) && (Victims.Health > 0))
		{
			LookDir = Normal(vector(Instigator.GetViewRotation()));
			Dir = Normal(Victims.Location - Instigator.Location);
			DiffAngle = LookDir Dot Dir;
			// End:0xfb Loop:False
			if(DiffAngle < 0.50)
			{
				continue;
			}
			// End:0x16f
			else
			{
				// End:0x16e Loop:False
				if(!Victims.bDeleteMe)
				{
					Damage = float(Rand(DamageMax - DamageMin) + DamageMin);
					Victims.TakeDamage(int(Damage), Instigator, Victims.Location, Momentum * X, DamageType);
					damageDone = true;
				}
			}
			continue;
		}		
	}
	// End:0x1d9 Loop:False
	if(!damageDone)
	{
		Damage = float(Rand(DamageMax - DamageMin) + DamageMin);
		Instigator.TakeDamage(int(Damage * SelfDamageScale), Instigator, Instigator.Location, Momentum * X, DamageType);
	}
}

defaultproperties
{
	SelfDamageScale=0.03
	ShellEjectClass=none
	StereoFireSound=Sound'KFPlayerSound.zpain1' //'voochant'
	DamageType=class'VoodooDamType'
	DamageMin=1300
	DamageMax=2000
	TransientSoundVolume=255.00
	TransientSoundRadius=10.00
	FireAnim=Fire2
	FireSound=Sound'KFPlayerSound.zpain1' //'voochant'
	FireRate=1.00
	AmmoClass=class'VoodooDollAmmo'
	AmmoPerFire=50
}