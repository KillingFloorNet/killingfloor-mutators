//=============================================================================
// Removing Tool Messages by Phada
//=============================================================================
class OneJobRemMsg extends OneJobNewMsg abstract;

var localized string PrePerkText, PostPerkText;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject) {
	if (RelatedPRI_1 != None && KFPlayerReplicationInfo(RelatedPRI_1) != None && KFPlayerReplicationInfo(RelatedPRI_1).ClientVeteranSkill != None)
		return default.Message[Switch]@default.PrePerkText@KFPlayerReplicationInfo(RelatedPRI_1).ClientVeteranSkill.default.VeterancyName$default.PostPerkText;

	return default.Message[Switch]$".";
}

defaultproperties
{
	DrawColor=(B=0,G=63,R=255,A=255)
	Message(0)="You cannot use the Syringe"
	Message(1)="You cannot use the Welder"
	PrePerkText="with"
	PostPerkText="'s perk."
}