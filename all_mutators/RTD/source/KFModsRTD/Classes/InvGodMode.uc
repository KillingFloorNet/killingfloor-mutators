//-----------------------------------------------------------
//
//-----------------------------------------------------------
class InvGodMode extends Inventory;
var() float TTL;
var() float TimeLived;
function PostBeginPlay()
{
	Super.PostBeginPlay();

    if (KFHumanPawn(PlayerController(Instigator.Controller).Pawn) == None)
    {
        Destroy();
        return;
    }

    PlayerController(Instigator.Controller).bGodMode = true;
}

function Timer()
{
    TimeLived = TimeLived+1;

    if (TimeLived >= TTL)
    {
        PlayerController(Instigator.Controller).bGodMode = false;
        class'MutRTD'.static.MessagePlayer(PlayerController(Instigator.Controller), " You are no longer invincible!");
        Destroy();
    }
}

function InitTimer(float time)
{
    TTL = time;
    SetTimer(1.0, true);
}

defaultproperties
{
}
