class WeldBotMessage extends LocalMessage;

var localized string Message[8];

static function string GetString (optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	return Default.Message[Switch];
}

defaultproperties
{
     Message(0)="Can't deploy here"
     Message(1)="Welding bot deployed"
     Message(2)="Welding bot destroyed"
     Message(3)="Follow you"
     Message(4)="I will be here"
     Message(5)="Well, keep doors here"
     Message(6)="You are not my owner!"
     Message(7)="You are my new owner!"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=4
     DrawColor=(B=170,G=170,R=170)
     StackMode=SM_Down
     PosY=0.800000
}
