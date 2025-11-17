class tdmmutator extends Mutator config;

var globalconfig int TDMMaxPlayers,minplayers;
var globalconfig int goalscore,timelimit;
var localized string GUIDisplayText[2]; // Config property label names
var localized string GUIDescText[2];    // Config property long descriptions
var globalconfig bool CanvIP; 
// If you have any drop lists then you will want to add a localized array
// variable whose element count matches the number of selections within the drop list.
var localized string GUISelectOptions[2];
var globalconfig float friendlyfirescale;

function postBeginPlay()
{

local string currentmap;
local kflevelrules kl;


foreach allactors(class'kflevelrules', kl)
if(kl!=none)
kl.destroy();

spawn(class'zLevelRules');

if(kfteamdeathmatch(level.game)==none)
{
currentmap=GetURLMap(false);

level.servertravel("dm-blackhawk?game=ksstrike.kfteamdeathmatch",true);

}


}

static function string GetDisplayText(string PropName) {
  // The value of PropName passed to the function should match the variable name
  // being configured.
  switch (PropName) {
    case "Max players":  return default.GUIDisplayText[0];
    case "score limits":  return default.GUIDisplayText[1];
  }
 
}

static function FillPlayInfo(PlayInfo PlayInfo) {
  Super.FillPlayInfo(PlayInfo);  // Always begin with calling parent
 
PlayInfo.AddSetting("Max Players", "tdmmaxplayers", "Max Players", 0, 0, "Text", "3;0:32",);
PlayInfo.AddSetting("Score Limit", "goalscore", "Score Limit", 0, 0, "Text", "3;0:999",);
PlayInfo.AddSetting("Time Limit", "Timelimit", "Time Limit", 0, 0, "Text", "3;0:999",);
PlayInfo.AddSetting("VIP Mode", "canvip", "VIP Mode", 0, 0, "Check", "3;0:999",);
PlayInfo.AddSetting("Friend Fire Scale", "friendlyfirescale", "Friend Fire Scale", 0, 0, "Text", "3;0:999",);
PlayInfo.AddSetting("Mininum Players", "minplayers", "Mininum Players", 0, 0, "Text", "3;0:999",);

}

defaultproperties
{
     TDMMaxPlayers=12
     MinPlayers=6
     GoalScore=15
     TimeLimit=20
     GUIDisplayText(0)="Max Players"
     GUIDisplayText(1)="Score limit"
     GUIDescText(0)="How many players allowed in game"
     GUIDescText(1)="What score to go to win"
     CanvIP=True
     GroupName="KF-Thugman"
     FriendlyName="Killing Floor Team Strikes Version July 1st"
     Description="Shoot Each other"
}
