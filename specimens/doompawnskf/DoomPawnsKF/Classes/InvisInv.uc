Class InvisInv extends Powerups;

function PickupFunction(Pawn Other)
{
	GoToState('Activated');
}
state Activated
{
	function PickupFunction(Pawn Other);

	function BeginState()
	{
		Pawn(Owner).Visibility = 1;
		xPawn(Owner).bInvis = true;
		SetTimer(1,true);
	}
	function EndState()
	{
		Pawn(Owner).Visibility = Pawn(Owner).Default.Visibility;
		xPawn(Owner).bInvis = false;
	}
	function Timer()
	{
		Charge-=1;
		if( Charge<=0 )
			Destroy();
	}
}

defaultproperties
{
     bDisplayableInv=True
     Charge=60
     bTravel=False
}
