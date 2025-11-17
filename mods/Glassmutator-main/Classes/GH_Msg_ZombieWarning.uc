// --------------------------------------------------------------
// GH_Msg_ZombieWarning
// --------------------------------------------------------------

// Notification that a zombie has spawned somewhere in your team's building.

// Author :  Alex Quick

// --------------------------------------------------------------


class GH_Msg_ZombieWarning extends LocalMessage;

var string ZombieWarningString;


static function string GetString(
  optional int Switch,
  optional PlayerReplicationInfo RelatedPRI_1,
  optional PlayerReplicationInfo RelatedPRI_2,
  optional Object OptionalObject
  )
{
  return default.ZombieWarningstring;
}


static simulated function ClientReceive(
  PlayerController P,
  optional int Switch,
  optional PlayerReplicationInfo RelatedPRI_1,
  optional PlayerReplicationInfo RelatedPRI_2,
  optional Object OptionalObject
  )
{
  if (switch == P.GetTeamNum())
  {
    super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
  }
}


defaultproperties
{
  ZombieWarningString="WARNING : A Super Siren found its way into your building!"
  bIsConsoleMessage=false
  bFadeMessage=true
  Lifetime=5
  DrawColor=(B=0,G=0)
  PosY=0.242000
  FontSize=2
}