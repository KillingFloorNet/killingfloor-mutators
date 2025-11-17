Class ATurretAI extends AIController;

var AmmoTurret Turret;
var transient float NextShotTime;
var() globalconfig float AmmoRateTime;

function Restart()
{
	Super.Restart();
	Turret = AmmoTurret(Pawn);
	AmmoRateTime = Turret.AmmoRateTime;
	GoToState('Idle');	
}

state Idle
{
	function BeginState()
	{
		SetTimer(AmmoRateTime,true);
	}
	
	function Timer()
	{
		if(Pawn.Health<=0)
			GoToState('BecameFlipped');
		
		Turret.PlayOpen();
		//log("AnimRepNum"@Turret.AnimRepNum@"NeedAmmo"@Turret.NeedAmmo);
		
		//if(Turret.AnimRepNum == 2 && Turret.NeedAmmo)
		//{		
			Turret.SpawnAmmo();
		//}
	}

Begin:
	Sleep(0.25);	
}

State BecameFlipped
{
Ignores SeePlayer,SeeMonster,HearNoise;

	function NotifyGotFlipped( bool bFlipNow )
	{
		if( !bFlipNow && Turret.bHasGodMode )
		{
			Turret.Health = Turret.TurretHealth;
			GoToState('Searching');
		}
	}
	function BeginState()
	{
		local Controller C;

		Pawn.Health = 0;
		Pawn.AmbientSound = Turret.AlarmNoiseSnd;
		For( C=Level.ControllerList; C!=None; C=C.NextController )
			C.NotifyKilled(None,Self,Pawn);
	}
	function EndState()
	{
	}	
Begin:
	Sleep(4);
	Pawn.AmbientSound = None;
	SetTimer(0,False);
	Turret.PlayTurretDied();
	if( Turret.bNoAutoDestruct )
		Stop;
	Sleep(16);
	Pawn.Died(None,class'DamageType',Pawn.Location);
}

defaultproperties
{
}
