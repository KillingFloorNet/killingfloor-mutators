class JackSawBlade extends CrossbuzzsawBlade;

simulated state OnWall
{
	simulated function BeginState()
	{
        Super.BeginState();
        Destroy();
	}
}

defaultproperties
{
     HeadShotDamageMult=1.000000
     Speed=1000.000000
     MaxSpeed=1500.000000
     Damage=15.000000
}
