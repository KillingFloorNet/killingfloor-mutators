//=============================================================================
// MutMaxWeight | Modifies players Max Carry Weight | By ViRUS
//=============================================================================
class MutMaxWeight extends Mutator;
 
var() globalconfig int MaxWeight;
var localized string MaxWeightDescText;

event PreBeginPlay()
{
    SetTimer(1.0,true);
}
function Timer()
{
    local Controller C;
    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
	ModifyPawn(C.Pawn);
    }
}
function ModifyPawn(pawn other)
{
   KFHumanPawn(other).MaxCarryWeight = MaxWeight;
}
static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.GameGroup, "MaxWeight", default.MaxWeightDescText, 0, 0, "Text",   "20;20:40");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "MaxWeight":return default.MaxWeightDescText;
	}
	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     MaxWeightDescText="Max Weight"
     GroupName="KF-Weight"
     FriendlyName="Max Weight"
     Description="Modifies the Max Carry Weight"
}
