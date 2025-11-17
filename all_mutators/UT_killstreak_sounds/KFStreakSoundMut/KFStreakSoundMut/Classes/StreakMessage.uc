class StreakMessage extends LocalMessage;

var array<string> Message;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject )
{
	if(Switch == 10)
		return Default.Message[Switch];
	return Eval(RelatedPRI_1!=None,RelatedPRI_1.PlayerName,"Someone")@Default.Message[Switch];
}

defaultproperties
{
     Message(0)="drew first blood"
     Message(1)="is on rampage"
     Message(2)="is on killing spree"
     Message(3)="is on monster kill"
     Message(4)="is unstoppable"
     Message(5)="is on ultra kill"
     Message(6)="is godlike!"
     Message(7)="is wicked sick!"
     Message(8)="is ludicrous!"
     Message(9)="is on HOLY SHIT!"
     Message(10)="Prepare to fight!"
     bIsUnique=True
     bFadeMessage=True
     Lifetime=4
     DrawColor=(B=0,G=0)
     StackMode=SM_Down
     PosY=0.800000
}
