//=============================================================================
// CacoFlameBall.
//=============================================================================
class CacoFlameBall extends ImpFlameBall;

auto state Flying
{
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local FlameExpCaco s;
	
		if ( (Role == ROLE_Authority) && (FRand() < 0.5) )
			MakeNoise(1.0); //FIXME - set appropriate loudness
	
		s = Spawn(class'FlameExpCaco',,,HitLocation+HitNormal*9);
		s.RemoteRole = ROLE_None;
		Destroy();
	}
}

defaultproperties
{
     MyDamage=Class'DoomPawnsKF.CacoBurned'
     Damage=40.000000
     Texture=Texture'DoomPawnsKF.Cacodemon.BAL2A0'
     DrawScale=1.200000
}
