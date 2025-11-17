//=============================================================================
// SpiderBall.
//=============================================================================
class SpiderBall extends ImpFlameBall;

auto state Flying
{
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local FlameExpSpid s;
	
		if ( (Role == ROLE_Authority) && (FRand() < 0.5) )
			MakeNoise(1.0); //FIXME - set appropriate loudness
	
		s = Spawn(class'FlameExpSpid',,,HitLocation+HitNormal*9);
		s.RemoteRole = ROLE_None;
		Destroy();
	}
}

defaultproperties
{
     MyDamage=Class'DoomPawnsKF.SpiBurned'
     Speed=1000.000000
     Damage=35.000000
     LightHue=83
     LightSaturation=50
     Texture=Texture'DoomPawnsKF.Spider.APLSA0'
     DrawScale=1.500000
}
