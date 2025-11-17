//-----------------------------------------------------------
// This message is shown when the player uses Super Speed
//-----------------------------------------------------------
class MessageRTD extends LocalMessage;

var localized string Message;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    return MessageObject(OptionalObject).Message;
	//if (Switch == 0)
	//	return Default.Message;
}

defaultproperties
{
     Message="Super Speed!"
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=1
     DrawColor=(G=0,R=0)
     PosY=0.700000
}
