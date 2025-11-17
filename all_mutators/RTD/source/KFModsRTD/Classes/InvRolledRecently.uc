//-----------------------------------------------------------
//
//-----------------------------------------------------------
class InvRolledRecently extends Inventory;
var() float TTL;
var() float TimeLived;
function PostBeginPlay()
{
	Super.PostBeginPlay();
}

function Timer()
{
    TimeLived = TimeLived+1;

    if (TimeLived >= TTL)
        Destroy();
}

function InitTimer(float time)
{
    TTL = time;
    SetTimer(1.0, true);
}

defaultproperties
{
}
