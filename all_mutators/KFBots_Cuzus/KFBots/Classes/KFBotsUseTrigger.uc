//=============================================================================
// To make it possible to order bots.
//=============================================================================
class KFBotsUseTrigger extends UseTrigger;

var KFInvBots Controller;
var transient float ReuseTimer,NextMessageTimer;

function PostBeginPlay()
{
	Controller = KFInvBots(Owner);
	SetTimer(1+FRand()*0.5,true);
}

function Timer()
{
	if(Controller.Pawn!=None && Base!=Controller.Pawn)
	{
		SetLocation(Controller.Pawn.Location);
		SetBase(Controller.Pawn);
	}
}

function UsedBy(Pawn user)
{
	if(ReuseTimer<Level.TimeSeconds && KFPawn(user)!=None && user.Health>0 && user.IsHumanControlled() && CanUse(user))
	{
		Controller.OrderBot(user.Controller);
		ReuseTimer = Level.TimeSeconds+0.2;
	}
}

function Touch(Actor Other)
{
	if( NextMessageTimer<Level.TimeSeconds && Controller.Pawn!=None && Controller.Pawn.Health>0 && KFPawn(Other)!=None && KFPawn(Other).Health>0 && KFPawn(Other).IsHumanControlled()
		&& CanUse(Pawn(Other)) )
	{
		Pawn(Other).ClientMessage("Press [Use] to order "$Controller.PlayerReplicationInfo.GetNameCallSign()$" to follow/stay/wander.");
		NextMessageTimer = Level.TimeSeconds+1.f;
	}
}

final function bool CanUse(Pawn Other)
{
	local vector HL,HN;
	
	return (Other.Trace(HL,HN,vector(Other.GetViewRotation())*140+Other.Location,Other.Location,true)==Controller.Pawn);
}

defaultproperties
{
	bOnlyAffectPawns=True
	CollisionRadius=100.000000
	CollisionHeight=100.000000
	bBlockHitPointTraces=False
}