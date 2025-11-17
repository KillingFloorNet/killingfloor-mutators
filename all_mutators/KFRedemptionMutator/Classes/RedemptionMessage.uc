class RedemptionMessage extends CriticalEventPlus;

var() localized string RedeemMessage;

static function string GetString (optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	return Default.RedeemMessage;
}

defaultproperties
{
     RedeemMessage="You have been Redeemed!"
     DrawColor=(B=0,G=0,R=220)
     StackMode=SM_Down
     PosY=0.800000
}
