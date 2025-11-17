class InvBTrap extends Inventory;

var() float TTL;
var() float TimeLived;

function Timer()
{
    TimeLived = TimeLived+1;

    if (TimeLived >= TTL)
    {        
        Destroy();
    }
}

function InitTimer(float time)
{
    TTL = time;

	if(Instigator.Controller != None)  /// Против спама в серверном логе об Accessed None 'Controller'. Sir Arthur
		Instigator.Controller.Gotostate('Nogoal');  /// оригинал

	Instigator.Velocity*=0;
	Instigator.Acceleration*=0;
    SetTimer(1.0, true);
}

function Destroyed()
{
	if(Instigator.Controller != None)  /// Против спама в серверном логе об Accessed None 'Controller'. Sir Arthur
		Instigator.Controller.Gotostate('ZombieHunt');  /// оригинал

	Super.Destroyed();
}

defaultproperties
{
}
