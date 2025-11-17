Class MapSecretSpot extends Triggers
	Placeable;

var() bool bTouchNotify; // When touched by player, this secret was found (otherwise use trigger).
var() name EventOnAllFound;
var bool bHasBeenFound;

function PostBeginPlay()
{
	if( !bTouchNotify )
		SetCollision(False);
}
function Touch( Actor Other )
{
	if( KFPawn(Other)!=None && PlayerController(Pawn(Other).Controller)!=None )
		SecretFound(Pawn(Other).Controller.PlayerReplicationInfo);
}
function Trigger( Actor Other, Pawn EventInstigator )
{
	if( bHasBeenFound )
		return;
	if( EventInstigator!=None && EventInstigator.Controller!=None )
		SecretFound(EventInstigator.Controller.PlayerReplicationInfo);
	else SecretFound(None);
}
final function SecretFound( PlayerReplicationInfo Finder )
{
	local byte CountFound,TotalCount;
	local MapSecretSpot MS;

	if( bHasBeenFound )
		return;
	bHasBeenFound = true;
	if( bTouchNotify )
		SetCollision(False);
	foreach DynamicActors(Class'MapSecretSpot',MS)
	{
		if( MS.bHasBeenFound )
			CountFound++;
		TotalCount++;
	}
	TriggerEvent(Event,Self,None);
	if( TotalCount==CountFound )
	{
		foreach DynamicActors(Class'MapSecretSpot',MS)
			if( MS.EventOnAllFound!='' )
				TriggerEvent(MS.EventOnAllFound,MS,None);
		TotalCount = 100;
	}
	else TotalCount = Min((float(CountFound)/float(TotalCount)*100.f),99);
	BroadcastLocalizedMessage(Class'DoomSecretMessage',TotalCount,Finder);
}
function Reset()
{
	if( bTouchNotify )
		SetCollision(true);
	bHasBeenFound = false;
}

defaultproperties
{
     bTouchNotify=True
     bOnlyAffectPawns=True
}
