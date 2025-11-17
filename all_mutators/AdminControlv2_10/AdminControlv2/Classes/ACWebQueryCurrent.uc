class ACWebQueryCurrent extends xWebQueryCurrent
	config;
	
function QueryCurrentConsole(WebRequest Request, WebResponse Response)
{
	local AdminControlMut ACMutator;
	local string SendStr;

	Super.QueryCurrentConsole(Request,Response);
	
	ACMutator = class'AdminControlMut'.Static.GetSelf(Spectator);
	SendStr = Request.GetVariable("SendText", "");
	ACMutator.PerformCommand(SendStr,Spectator,CurAdmin);
}
	

defaultproperties
{
}
