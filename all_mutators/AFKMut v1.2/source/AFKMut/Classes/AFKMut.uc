class AFKMut extends Mutator
	config(UnitedMut);
	
var() config float AFKTimer;
var() config string KickMessage, KickMessagePlayer;
var() config bool bDebug, bKickSpectators;

struct pRecord
{
	var PlayerController PC;
	var vector Location;
	var rotator Rotation;
	var float Time;
	var bool bIsSpectator;
	var bool bOutOfLives;
	var int PlayerHealth;
};
var array<pRecord> Players;
var config array<string> AllowAFK;
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
function PreBeginPlay()
{
	if (bDebug) log("AFKMut loaded");
}
//--------------------------------------------------------------------------------------------------
function PostBeginPlay()
{
	settimer(2.0,true);
	SaveConfig();
}
//--------------------------------------------------------------------------------------------------
function bool UpdatePlayer(PlayerController PC)
{
	local int i;
	local bool bIn, bKick;
	for (i=0; i<Players.Length; i++)
	{
		if (Players[i].PC==PC)
		{
			if (bDebug && PC.Pawn!=none) log(PC.PlayerReplicationInfo.PlayerName@"loc"@PC.Location@"rot"@PC.Rotation);
			bIn=true;
			if (Players[i].bIsSpectator != PC.PlayerReplicationInfo.bIsSpectator
				|| Players[i].bOutOfLives != PC.PlayerReplicationInfo.bOutOfLives
				|| Players[i].PlayerHealth>0 != KFPlayerReplicationInfo(PC.PlayerReplicationInfo).PlayerHealth>0)
			{
				if (bDebug) log("changed state");
				//Players[i].Location = PC.Location;
				Players[i].Rotation = PC.Rotation;
				//Players[i].PRI = KFPlayerReplicationInfo(PC.PlayerReplicationInfo);
				Players[i].bIsSpectator = PC.PlayerReplicationInfo.bIsSpectator;
				Players[i].bOutOfLives = PC.PlayerReplicationInfo.bOutOfLives;
				Players[i].PlayerHealth = KFPlayerReplicationInfo(PC.PlayerReplicationInfo).PlayerHealth;
			}
			else if(/* Players[i].Location != PC.Location
				|| */Players[i].Rotation != PC.Rotation )
			{
				//Players[i].Location = PC.Location;
				Players[i].Rotation = PC.Rotation;
				Players[i].Time = Level.TimeSeconds;
				bKick=false;
			}
			if (Players[i].Time+AFKTimer < Level.TimeSeconds)
				bKick=true;
			if (bDebug) log(Players[i].PC.PlayerReplicationInfo.PlayerName@"AFK"@Level.TimeSeconds-Players[i].Time);
		}
	}
	if (!bIn)
	{
		Players.Insert(0,1);
		Players[0].PC = PC;
		//Players[0].Location = PC.Location;
		Players[0].Rotation = PC.Rotation;
		Players[0].Time = Level.TimeSeconds;
		//Players[0].PRI = KFPlayerReplicationInfo(PC.PlayerReplicationInfo);
		Players[i].bIsSpectator = PC.PlayerReplicationInfo.bIsSpectator;
		Players[i].bOutOfLives = PC.PlayerReplicationInfo.bOutOfLives;
		Players[i].PlayerHealth = KFPlayerReplicationInfo(PC.PlayerReplicationInfo).PlayerHealth;		
		bKick=false;
	}
	return bKick;
}
//--------------------------------------------------------------------------------------------------
function RemovePlayer(PlayerController PC)
{
	local int i;
	if (bDebug) log("RemovePlayer1"@PC.PlayerReplicationInfo.PlayerName@"In -> Players.Length = "@Players.Length);
	for (i=0; i<Players.Length; i++)
	{
		if (Players[i].PC==PC)
		{
			Players.Remove(i,1);
			i--;
		}
	}
	if (bDebug) log("RemovePlayer2"@PC.PlayerReplicationInfo.PlayerName@"In -> Players.Length = "@Players.Length);
}
//--------------------------------------------------------------------------------------------------
function bool bAllowAFK(string pName)
{
	local int i;
	for (i=0; i<AllowAFK.Length; i++)
	{
		if (Caps(pName)==AllowAFK[i])
		{
			if (bDebug) log(pName@"allowed AFK");
			return true;
		}
	}
	return false;
}
//--------------------------------------------------------------------------------------------------
function Timer()
{
	local PlayerController PC;
	
	foreach DynamicActors(class'PlayerController',PC)
	{
		if (PC.PlayerReplicationInfo==none)	continue;
		if (bAllowAFK(PC.PlayerReplicationInfo.PlayerName)) continue;		
		if (Caps(PC.PlayerReplicationInfo.PlayerName)=="WEBADMIN") continue;
		if (Caps(PC.PlayerReplicationInfo.PlayerName)=="CHATTERSPECTATOR") continue;
		if (Level.Game.AccessControl.IsAdmin(PC)) continue;
		if (!bKickSpectators) // из конфига
			if (PC.PlayerReplicationInfo.bIsSpectator) continue;

		
		if (UpdatePlayer(PC))
		{
			RemovePlayer(PC);
			if (PC != none)
				KickPlayer(PC,KickMessagePlayer);
		}
	}
	CleanupPlayer();
	
}
//--------------------------------------------------------------------------------------------------
function CleanupPlayer() // очищаем базу от дохлых плеер контроллеров
{
	local int i;
	for (i=0; i<Players.Length; i++)
	{
		if (Players[i].PC==none || Level.Game.AccessControl.IsAdmin(Players[i].PC))
		{
			Players.Remove(i,1);
			i--;
		}
	}
}
//--------------------------------------------------------------------------------------------------
function KickPlayer(PlayerController C, string message)
{
	//local Controller CTemp;
	local string pName;
	
	if (C != None && !Level.Game.AccessControl.IsAdmin(C) && NetConnection(C.Player)!=None )
    {
		if (C.PlayerReplicationInfo!=none)
			pName=C.PlayerReplicationInfo.PlayerName;
		C.ClientNetworkMessage("AC_Kicked",message);
		
		if (C.Pawn != none && Vehicle(C.Pawn) == none)
			C.Pawn.Destroy();
			
		if (C != None)
			C.Destroy();
		
		if (pName!="")
			Level.Game.Broadcast(Self,Repl(KickMessage,"%player%",pName));
    }
	
/*	for ( CTemp = Level.ControllerList; CTemp != None; CTemp = CTemp.NextController )
	{
		if( KFPlayerController(CTemp)!=None && KFHumanPawn(KFPlayerController(CTemp).Pawn) != none)
		{
			KFPlayerController(CTemp).ClientMessage(Repl(KickMessage, "%player%", KFPlayerController(C).PlayerReplicationInfo.PlayerName), 'DeathMessage');			
		}
	}
	return false;*/
}
//--------------------------------------------------------------------------------------------------
defaultproperties
{
	bDebug=false
	AFKTimer=120
	bKickSpectators=true
	KickMessage="%player% выкинут анти-АФК системой"
	KickMessagePlayer="Вы выкинуты анти-АФК системой"
	AllowAFK[0]="Admin1"
	AllowAFK[1]="Admin2"
}