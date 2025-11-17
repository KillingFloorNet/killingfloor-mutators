//=============================================================================
// MarineController.
//=============================================================================
class MarineController extends DoomController;

State Idling
{
Ignores Tick,EnemyNotVisible;

	function BeginState()
	{
		if( Physics==PHYS_None )
		{
			if( Pawn.bCanFly )
				Pawn.SetPhysics(PHYS_Flying);
			else if( Pawn.PhysicsVolume.bWaterVolume )
				Pawn.SetPhysics(PHYS_Swimming);
			else Pawn.SetPhysics(PHYS_Falling);
		}
		Pawn.Enable('Bump');
		SetTimer(3+FRand(),True);
		Enemy = None;
	}
	function Timer()
	{
		local Monster P;

		ForEach VisibleCollidingActors(Class'Monster',P,2000,Pawn.Location)
			SeePlayer(P);
	}
}
function WarnOthers();
function bool SetEnemy( Pawn E, bool bHateEnemy ) // Simply.
{
	if( E==None || E.Health<=0 || Enemy==E ) Return false;
	if( E.Class==Pawn.Class || !E.IsA('Monster') ) Return false;
	Enemy = E;
	Return True;
}
function SeePlayer( Pawn Seen )
{
	if( SetEnemy(Seen,False) )
	{
		DoomPawns(Pawn).PlayAcquisitionSound();
		GoToState('AttackEnemy');
	}
}

defaultproperties
{
}
