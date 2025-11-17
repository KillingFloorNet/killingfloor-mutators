// A very simple AI!
Class FloodLightAI extends AIController;

var FloodLight Turret;

function Restart()
{
	Super.Restart();
	Turret = FloodLight(Pawn);
	GoToState('Fall1');
}

final function GoNextOrders()
{
	GoToState('Idle');
}


State Fall1
{
Ignores SeePlayer,HearNoise,SeeMonster;
Begin:
	//log("Fall1: Begin");
	WaitForLanding();
	Sleep(1.5);
	GoNextOrders();
}

state Idle
{
Ignores SeePlayer,HearNoise,SeeMonster;
Begin:
	Sleep(0.25);
	//log("Idle: Begin");
}

function NotifyGotFlipped( bool bFlipNow )
{
	if( bFlipNow )
		GoToState('BecameFlipped');
}

State BecameFlipped
{
Ignores SeePlayer,SeeMonster,HearNoise;

	function NotifyGotFlipped( bool bFlipNow )
	{
		if( !bFlipNow && Turret.bHasGodMode )
		{
			Turret.Health = Turret.FloodLightHealth;
			GoToState('Idle');
		}
	}
	function BeginState()
	{
		local Controller C;

		Pawn.Health = 0;
		SetTimer(0.05,True);
		For( C=Level.ControllerList; C!=None; C=C.NextController )
			C.NotifyKilled(None,Self,Pawn);
	}
	function EndState()
	{
	}

Begin:
	//log("BecameFlipped: Begin");
	Sleep(0);
	Pawn.AmbientSound = None;
	SetTimer(0,False);
	//Turret.SpawnSparksEffects();
	if( Turret.bNoAutoDestruct )
		Stop;
	Sleep(5);
	Pawn.Died(None,class'DamageType',Pawn.Location);
}
