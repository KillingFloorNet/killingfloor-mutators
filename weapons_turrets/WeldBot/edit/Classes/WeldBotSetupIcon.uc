//================================================================================
// KFARGChatIcon
//================================================================================
class WeldBotSetupIcon extends Actor;

function PostBeginPlay ()
{
	Texture = Texture'SetupIcon';
}

defaultproperties
{
     Texture=Texture'chippo.SetupIcon'
     DrawScale=0.500000
     Style=STY_Masked
}
