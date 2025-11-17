//=============================================================================
// D64DoomRocket.
//=============================================================================
class D64DoomRocket extends DoomRocket;

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local D64DoomExplosion s;

	s = spawn(class'D64DoomExplosion',,,HitLocation + HitNormal*16);	
 	s.RemoteRole = ROLE_None;

	BlowUp(HitLocation);

 	Destroy();
}

defaultproperties
{
     Damage=500.000000
     MomentumTransfer=90000.000000
     SpawnSound=Sound'DoomPawnsKF.D64Snd.DSRLAUNC64'
}
