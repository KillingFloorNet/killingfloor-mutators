Class KFSPRIFixed extends KFPlayerReplicationInfo;

var float LastSwitchTime;
var bool bMonsterVPlayerMode,bEnteredMessageGiven;

replication
{
	// Things the server should send to the client.
	reliable if ( bNetDirty && bNetOwner && (Role == Role_Authority) )
		bMonsterVPlayerMode;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	if( Level.NetMode!=NM_Client && Level.NetMode!=NM_StandAlone )
		bMonsterVPlayerMode = Class'DoomGameType'.Default.bMonsterVSPlayers;
}
simulated function SetGRI(GameReplicationInfo GRI);

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	if( Level.NetMode==NM_Client )
	{
		if( Level.TimeSeconds>5 ) // Never message initial players.
		{
			if( bOnlySpectator )
				Level.GetLocalPlayerController().ClientMessage(Class'KFGameMessages'.Static.GetString(17,Self));
			else Level.GetLocalPlayerController().ClientMessage(Class'KFGameMessages'.Static.GetString(1,Self));
		}
		bEnteredMessageGiven = true;
	}
}
simulated function Destroyed()
{
	if( bEnteredMessageGiven && Level.NetMode!=NM_DedicatedServer )
		Level.GetLocalPlayerController().ClientMessage(Class'KFGameMessages'.Static.GetString(4,Self));
	Super.Destroyed();
}

final function BecomeMonster()
{
	if( LastSwitchTime>Level.TimeSeconds || bOnlySpectator || !bMonsterVPlayerMode )
		return;
	LastSwitchTime = Level.TimeSeconds+6.f;
	SetMonster(PlayerController(Owner));
}
function SetMonster( PlayerController PC )
{
	local DoomPawns D;
	local bool bWasDoomMob;

	D = FindDoomMob();
	if( D==None )
		return;
	bWasDoomMob = (DoomPawns(PC.Pawn)!=None);
	if( PC.Pawn!=None )
		PC.Pawn.Suicide();
	DoomController(D.Controller).FreezePawn(false);
	D.Controller.Pawn = None;
	D.Controller.Destroy();
	D.Controller = None;
	PC.Possess(D);
	PC.ClientSetRotation(D.Rotation);
	if( !bWasDoomMob )
		Level.Game.Broadcast(Self,PlayerName@"joined the monsters.");
}
final function DoomPawns FindDoomMob()
{
	local Controller C;
	local array<DoomPawns> DPList;

	for( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if( DoomController(C)!=None && DoomPawns(C.Pawn)!=None && C.Pawn.Health>0 )
			DPList[DPList.Length] = DoomPawns(C.Pawn);
	}
	if( DPList.Length==0 )
		return None;
	return DPList[Rand(DPList.Length)];
}
function Timer()
{
	local Controller C;

	SetTimer(0.5 + FRand(), False);
	UpdatePlayerLocation();
	C = Controller(Owner);
	if( C==None )
		Return;
	if( C.Pawn==None )
		PlayerHealth = 0;
	else if( Monster(C.Pawn)!=None ) // Show in percent how much HP got.
		PlayerHealth = int((float(C.Pawn.Health)/float(C.Pawn.Default.Health))*100.f);
	else PlayerHealth = C.Pawn.Health;

	if( !bBot )
	{
		if ( !bReceivedPing )
			Ping = Min(int(0.25 * float(C.ConsoleCommand("GETPING"))),255);
	}
}

defaultproperties
{
}
