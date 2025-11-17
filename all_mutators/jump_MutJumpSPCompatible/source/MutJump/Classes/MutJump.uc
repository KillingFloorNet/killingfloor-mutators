class MutJump extends Mutator config(MutJump);

var config int MultiJumpCount, MultiJumpBoost;

function Modifyplayer(pawn other)
{
	local KFHumanPawn jumper;
	Super.ModifyPlayer(other);
	jumper = KFHumanPawn(other);
	if(jumper != None)
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
	MultiJumpCount=20
	MultiJumpBoost=100
	GroupName="KF-Jumper"
	FriendlyName="Multi Jump"
	Description="Changes your Multi-Jumping ability"
}