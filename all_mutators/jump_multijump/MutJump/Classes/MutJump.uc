//=============================================================================
// MutJump - Enables multi jumps - By EvilDooinz aka Bruce303lee
//=============================================================================
class MutJump extends Mutator;

var globalconfig int MultiJumpCount, MultiJumpBoost; // The number of multi-jumps allowed
 
Function Modifyplayer(pawn other)
{
   local Xpawn jumper; //Xpawn = changeable guy
   Super.ModifyPlayer(other);
   jumper = xPawn(other);
   if (jumper != None)
   {
    jumper.MaxMultiJump = MultiJumpCount;
    jumper.MultiJumpBoost = MultiJumpBoost;
   }
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.GameGroup, "MultiJumpCount", "MultiJumpCount", 0, 0, "Text",   "100;0.1:250");
	PlayInfo.AddSetting(default.GameGroup, "MultiJumpBoost", "MultiJumpBoost", 0, 0, "Text",   "250;0.1:250");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "MultiJumpCount":  return "Amount of jumps players start with.";
		case "MultiJumpBoost":	return "Amount of boost players get.";
	}

	return Super.GetDescriptionText(PropName);
}
defaultproperties
{
     MultiJumpCount=10
     MultiJumpBoost=50
 
     GroupName="KF-Jumper"
     FriendlyName="Multi Jump"
     Description="Changes your Multi-Jumping ability"
}
