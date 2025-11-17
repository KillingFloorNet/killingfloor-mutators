class WeldBotMut extends Mutator;

var bool bDebug;
var bool bSetOverlay, bSetOverlayClient;

replication
{
	reliable if (ROLE==Role_Authority)
		bSetOverlay;
}
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
simulated function PostBeginPlay()
{
	local PlayerController PC;
	if (!bSetOverlayClient)
	{
		bSetOverlayClient=true;
		if (Level != none)
		{
			PC = Level.GetLocalPlayerController();
			if (PC!=none && PC.myHud!=none)
				PC.myHud.AddHudOverlay(spawn(class'WeldBotHudOverlay'));
		}
	}
	bSetOverlay=true;
}
//--------------------------------------------------------------------------------------------------
simulated function PostNetReceive()
{
	local PlayerController PC;
	Super.PostNetReceive();
	if (bSetOverlay && bSetOverlayClient!=bSetOverlay)
	{
		bSetOverlayClient=true;
		PC = Level.GetLocalPlayerController();
		PC.myHud.AddHudOverlay(spawn(class'WeldBotHudOverlay'));
	}
}
//--------------------------------------------------------------------------------------------------
function WeldBot GetWeldBot(PlayerController PC)
{
	local KFPawn Pawn;
	local WeldBot WB;
	Pawn=KFPawn(PC.Pawn);
	if (Pawn!=none)
		foreach DynamicActors(class'WeldBot', WB)
			if (KFPawn(WB.OwnerPawn)==Pawn)
				return WB;
	return none;
}
//--------------------------------------------------------------------------------------------------
function Mutate(string input, PlayerController PC)
{//mutate WELDBOT Stay 4123.0000  //mutate WELDBOTNAME Welder Bot
	local int n,i;
	local WeldBot WB;
	local array<string> iSplit;
	local string cmd;
	local string tStr;
	if (bDebug) log("WBMut: Mutate input:"@input);
	n=Split(input," ",iSplit);
	if (n<2) return;
	cmd=Caps(iSplit[0]);
	if (cmd=="WELDBOT")
	{
		if (n<3)
			return;
		WB=GetWeldBot(PC);
		if (WB==none)
		{
			PC.ClientMessage("WBMut: WeldBot not found");
			return;
		}
		WB.SetParams(StringToState(iSplit[1]), float(iSplit[2]));
	}
	else if (cmd=="WELDBOTNAME")
	{
		log("WELDBOTNAME input"@input);
		if (n<2)
			return;
		WB=GetWeldBot(PC);
		if (WB==none)
		{
			PC.ClientMessage("WBMut: WeldBot not found");
			return;
		}
		tStr=iSplit[1];
		for (i=2; i<iSplit.Length; i++)
			tStr=tStr@iSplit[i];
		log("WELDBOTNAME tStr"@tStr);
		WB.SetBotName(tStr);
	}
	Super.Mutate(input, PC);
}
//--------------------------------------------------------------------------------------------------
static function WeldBot.EState StringToState(string input)
{
	if (caps(input)=="FOLLOW") return Follow;
	if (caps(input)=="STAY") return Stay;
	if (caps(input)=="WELDDOORS") return WeldDoors;
	return Stay;
}

defaultproperties
{
     bDebug=True
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     bNetNotify=True
}
