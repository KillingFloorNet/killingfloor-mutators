class WTFPerksMutPerkPokerMessages extends CriticalEventPlus;

var() localized string SwitchMessage[10];

static function string GetString (optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
  if ( (Switch >= 0) && (Switch <= 9) )
  {
	return Default.SwitchMessage[Switch];
  }
}

defaultproperties
{
     SwitchMessage(0)="Cant poke perks during the wave!"
     SwitchMessage(1)="Use the Perk Poker in equip group 5 to pick your perk."
     DrawColor=(G=255,R=255)
     FontSize=4
}
