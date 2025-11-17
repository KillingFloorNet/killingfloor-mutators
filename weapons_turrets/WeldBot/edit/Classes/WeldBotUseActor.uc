class WeldBotUseActor extends WeldBotHomeActor;

var WeldBot WeldBot;

simulated function PostBeginPlay()
{
    Texture = texture'SetupIcon';
}

simulated function UsedBy(Pawn user)
{
	if (WeldBot.bDebug) PlayerController(WeldBot.OwnerPawn.Controller).ClientMessage("WeldBotUseActor UsedBy`");
	WeldBot.UsedBy(user);
}

defaultproperties
{
     bHidden=False
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     Texture=Texture'chippo.SetupIcon'
     Style=STY_Masked
     CollisionRadius=80.000000
     CollisionHeight=20.000000
     bCollideActors=True
     bCollideWorld=True
}
