Class DemonTeleport extends KeyPoint;

var() edfindable DoomPawns TheMonster;
var() bool bTriggerOnceOnly,bPissOffAtTriggerer;
var() float TeleportDelay;
var DemonTeleport NextTeleporter;
var bool bDisabled;

function PostBeginPlay()
{
	if( TheMonster!=None )
	{
		if( TheMonster.InitPose!=None )
		{
			if( TheMonster.InitPose.TeleportList==None )
				TheMonster.InitPose.TeleportList = Self;
			else TheMonster.InitPose.TeleportList.AddTeleporter(Self);
		}
		else if( TheMonster.TeleportList==None )
			TheMonster.TeleportList = Self;
		else TheMonster.TeleportList.AddTeleporter(Self);
	}
}
function NotifyNewPawn( DoomPawns Doomi )
{
	TheMonster = Doomi;
	if( NextTeleporter!=None )
		NextTeleporter.NotifyNewPawn(Doomi);
}
function Reset()
{
	SetTimer(0,False);
	bDisabled = False;
}
event Trigger( Actor Other, Pawn EventInstigator )
{
	if( bDisabled )
		Return;
	if( bTriggerOnceOnly )
		bDisabled = True;
	Instigator = EventInstigator;
	if( TeleportDelay==0 )
		Timer();
	else SetTimer(TeleportDelay,False);
}
function Timer()
{
	if( TheMonster!=None && TheMonster.Health>0 )
	{
		if( !TheMonster.SetLocation(Location) )
			Return;
		TheMonster.SetRotation(Rotation);
		Spawn(class'TeleportEffects');
		if( TheMonster.Controller!=None )
		{
			TheMonster.Controller.FocalPoint = TheMonster.Location+vector(Rotation)*2000;
			if( bPissOffAtTriggerer )
				TheMonster.Controller.SeePlayer(Instigator);
		}
	}
}
function AddTeleporter( DemonTeleport Other )
{
	if( NextTeleporter!=None )
		NextTeleporter.AddTeleporter(Other);
	else NextTeleporter = Other;
}

defaultproperties
{
     bTriggerOnceOnly=True
     bPissOffAtTriggerer=True
     bStatic=False
     bNoDelete=True
     Style=STY_Modulated
     bDirectional=True
}
