//=============================================================================
// D64HellFlameBall.
//=============================================================================
class D64HellFlameBall extends HellFlameBall;

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local D64DoomExplosionKni s;

	s = spawn(class'D64DoomExplosionKni',,,HitLocation + HitNormal*16);	
 	s.RemoteRole = ROLE_None;
	MakeNoise(2.0);

 	Destroy();
}

defaultproperties
{
     Damage=90.000000
     ImpactSound=Sound'DoomPawnsKF.D64Snd.DSFIRXPL64'
     DrawScale=0.670000
}
