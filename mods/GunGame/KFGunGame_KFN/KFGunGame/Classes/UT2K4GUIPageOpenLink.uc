class UT2K4GUIPageOpenLink extends UT2K4GUIPage;

var int phase;

event Opened(GUIComponent Sender)
{
	phase = 0;

	SetTimer(1.0f, True);
	
	Super.Opened(Sender);
}

event Timer()
{
	local GUIController C;

	C = Controller;
    
	if ( phase == 0 )
	{
		C.ViewportOwner.Console.ConsoleCommand("start"@"https://killingfloor.net/?utm_source=killingfloor-mutators");
		phase = 1;
	}
	else
	{
		SetTimer(0.0f, False);
	}
}