//=============================================================================
// New Tool Messages by Phada
//=============================================================================
class OneJobNewMsg extends LocalMessage abstract;

var localized string Message[2];

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject) {
	return default.Message[Switch];
}

defaultproperties
{
	bIsSpecial=False
	DrawColor=(B=0,G=191,R=255,A=255)
	Message(0)="You can now use the Syringe!"
	Message(1)="You can now use the Welder!"
}