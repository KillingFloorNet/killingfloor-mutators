class UT2K4GUIPageOpenLink extends UT2K4GUIPage;

var int phase;

event Opened(GUIComponent Sender)
{
    phase = 0;

	SetTimer(1.0f, true);
	
	super.Opened(Sender);
}

event Timer()
{
    local GUIController C;

	C = Controller;
    
    if (phase == 0)
    {
        C.ViewportOwner.Console.ConsoleCommand("start" @ "https://cuzus.net/?utm_source=mutator&utm_medium=link&utm_campaign=gungame");
        phase = 1;
    }
    else
    {
        SetTimer(0.0f, false);
    }
}