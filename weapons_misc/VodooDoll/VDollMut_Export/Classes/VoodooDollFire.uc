class VoodooDollFire extends KFHighROFFire;

var float SelfDamageScale;
var int shotsFired;

function DoTrace(Vector Start, Rotator Dir1)
{
	local Vector X, Y, Z;
	local Pawn Victims, Nearest;
	local float FriendlyDist, NearestDist, Damage, DiffAngle;
	local Vector Dir, LookDir;

	++shotsFired;
	// End:0x36 Loop:False
	if (shotsFired > 1)
	{
		Log("Shots fired in loop:" @ string(shotsFired));
	}
	// End:0x44
	else
	{
		Log("Start loop");
	}
	
	Weapon.GetViewAxes(X, Y, Z);
	Damage = float(Rand(DamageMax - DamageMin) + DamageMin);
	
	// End:0xad Loop:False
	if (shotsFired > 1)
	{
		Damage += Damage * 0.05 * float(Min(40, shotsFired) - 1);
	}
	
	Nearest = none;
	
	// End:0x266
	foreach Instigator.VisibleCollidingActors(class'Pawn', Victims, MaxRange())
	{
		// End:0x265 Loop:False
		if(Victims != Instigator && (!Instigator.Controller.SameTeamAs(Victims.Controller)) && (Victims.Health > 0))
		{
			LookDir = Normal(vector(Instigator.GetViewRotation()));
			Dir = Normal(Victims.Location - Instigator.Location);
			DiffAngle = LookDir Dot Dir;
			// End:0x1c0 Loop:False
			if(DiffAngle < 0.50)
			{
				Log("Shot would miss " $ string(Victims) $ " DiffAngle = " $ string(DiffAngle));
				continue;
			}
			// End:0x266
			else
			{
				FriendlyDist = VSizeSquared(Instigator.Location - Victims.Location);
				// End:0x265 Loop:False
				if(!Victims.bDeleteMe && (Nearest == none || (FriendlyDist < NearestDist)))
				{
					Nearest = Victims;
					NearestDist = FriendlyDist;
					Log("New nearest pawn" @ string(Nearest) @ " at dist " $ string(NearestDist));
				}
			}
			continue;
		}		
	}
	
	// End:0x2af Loop:False
	if (Nearest != none)
	{
		Nearest.TakeDamage(int(Damage), Instigator, Nearest.Location, Momentum * X, DamageType);
	}
	// End:0x2f0
	else
	{
		Instigator.TakeDamage(int(Damage * SelfDamageScale), Instigator, Instigator.Location, Momentum * X, DamageType);
	}
}

state FireLoop
{
	function BeginState()
	{
		local float RandPitch;
		
		super.BeginState();
		shotsFired = 0;
		
		// End:0x3d Loop:False
		if (bRandomPitchFireSound)
		{
			RandPitch = FRand() * RandomPitchAdjustAmt;
			// End:0x3d Loop:False
			if (FRand() < 0.50)
			{
				RandPitch *= -1.00;
			}
		}
		
		//Weapon.PlayOwnedSound(FireSound, 3, TransientSoundVolume,, TransientSoundRadius, 1.00 + RandPitch, false);
		Weapon.PlayOwnedSound(FireSound, SLOT_Interact, TransientSoundVolume, , TransientSoundRadius, 1.00 + RandPitch, false);
	}
}

defaultproperties
{
	SelfDamageScale=0.20
	bFiringDoesntAffectMovement=true
	RecoilVelocityScale=0.00
	StereoFireSound=Sound'KFPlayerSound.zpain1' //'voostab'
	DamageType=class'VoodooDamType'
	DamageMin=70
	DamageMax=100
	TransientSoundVolume=255.00
	TransientSoundRadius=10.00
	FireLoopAnim=Fire1Loop
	FireEndAnim=Fire1End
	FireSound=Sound'KFPlayerSound.zpain1' //'voostab'
	FireForce=""
	FireRate=0.40
	AmmoClass=class'VoodooDollAmmo'
}