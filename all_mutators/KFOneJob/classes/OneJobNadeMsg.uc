//=============================================================================
// Nades Amount Message by Phada
//=============================================================================
class OneJobNadeMsg extends OneJobNewMsg abstract;

var localized string MidText, PostText, NoPerkText;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject) {
	if (RelatedPRI_1 != None && KFPlayerReplicationInfo(RelatedPRI_1) != None && KFPlayerReplicationInfo(RelatedPRI_1).ClientVeteranSkill != None)
		return default.Message[0]@Switch@default.MidText@KFPlayerReplicationInfo(RelatedPRI_1).ClientVeteranSkill.default.VeterancyName$default.PostText;

	return default.Message[0]@Switch@default.MidText$default.NoPerkText;
}

defaultproperties
{
	DrawColor=(B=127,G=127,R=63,A=255)
	Message(0)="You begin with only"
	MidText="Grenade(s) with"
	PostText="'s perk."
	NoPerkText="out any perk."
}