//-----------------------------------------------------------
//
//-----------------------------------------------------------
class InvRTDTimeBased extends Inventory;
var() float TTL;
var() float TimeLived;
var() float TimerInterval;
var bool bStarted;
function PostBeginPlay()
{
	Super.PostBeginPlay();
}

function Timer()
{
    TimeLived = TimeLived+TimerInterval;


    if (!bStarted)
    {
        bStarted = true;
        OnStarted();
    }
    if (TimeLived >= TTL)
    {
        if (OnFinished())
            Destroy();
    }
}
function OnStarted()
{

}

function bool OnFinished()
{
    return true;
}
function SetInterval(float accuracy)
{
    TimerInterval = accuracy;
}
function StartTimer(float time)
{
    TTL = time;
    SetTimer(TimerInterval, true);
}
function OnStopped()
{

}
function StopTimer()
{
    SetTimer(0, false);
    OnStopped();
    bStarted=false;
}

defaultproperties
{
     TimerInterval=1.000000
}
