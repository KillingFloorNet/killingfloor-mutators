Class InitialPose extends Actor;

var int InitialHealth;
var class<DoomPawns> PawnClass;
var DemonTeleport TeleportList;
var DoomCarcass MyCarcass;

function Reset()
{
	local DoomPawns D;

	SetTimer(0,false);
	D = Spawn(PawnClass,,,Location,Rotation);
	if( D==None ) Return;
	D.Health = InitialHealth;
	D.Event = Event;
	D.Tag = Tag;
	D.InitPose = Self;
	TeleportList.NotifyNewPawn(D);
}
function Timer()
{
	local DoomPawns D;

	D = Spawn(PawnClass,,,Location,Rotation);
	if( D==None )
	{
		SetTimer(5,false);
		return;
	}
	if( MyCarcass!=None )
	{
		Spawn(class'TeleportEffects',,,MyCarcass.Location);
		MyCarcass.Destroy();
	}
	Spawn(class'TeleportEffects',,,Location);
	D.Health = InitialHealth;
	D.InitPose = Self;
	D.bRespawnMe = true;
	TeleportList.NotifyNewPawn(D);
}

defaultproperties
{
     bHidden=True
     RemoteRole=ROLE_None
}
