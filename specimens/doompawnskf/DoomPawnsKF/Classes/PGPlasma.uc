//=============================================================================
// PGPlasma.
//=============================================================================
class PGPlasma extends ImpFlameBall;

auto state Flying
{
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local PlasmaBallExp s;
	
		if ( (Role == ROLE_Authority) && (FRand() < 0.5) )
			MakeNoise(1.0); //FIXME - set appropriate loudness
	
		s = Spawn(class'PlasmaBallExp',,,HitLocation+HitNormal*9);
		s.RemoteRole = ROLE_None;
		Destroy();
	}
}

defaultproperties
{
     MyDamage=Class'DoomPawnsKF.PlasmaZapped'
     Speed=900.000000
     Damage=25.000000
     LightHue=170
     LightSaturation=69
     Texture=Texture'DoomPawnsKF.PlasmaGun.PLSSB0'
     DrawScale=1.400000
}
