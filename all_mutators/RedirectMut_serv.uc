// Flame
// http://killingfloor.ru/xforum/threads/ideja-dlja-mutatora-riderekt.3479/#post-94595
Class RedirectMut extends Mutator Config(RedirectMut);

var config string NewAddress;

simulated function PostBeginPlay()
{
	local PlayerController PC;
	if(Level.NetMode == NM_Client)
	{
		PC=Level.GetLocalPlayerController();
		PC.ConsoleCommand("open"@NewAddress);
	}
}

defaultproperties
{
	NewAddress="127.0.0.1:7707"
	GroupName="KF-RedirectMut"
	FriendlyName="RedirectMut"
	Description="RedirectMut"
	bAddToServerPackages=True
	bAlwaysRelevant=True
	RemoteRole=ROLE_SimulatedProxy
}