//=============================================================================
// MutMaxHealth | Modifies the Max Health | By ViRUS
//=============================================================================
class MutMaxHealth extends Mutator;

var globalconfig int StartingHealth, MaximumHealth;
const NUM=2;
var localized string MaxHealthDescText[NUM];

Function Modifyplayer(pawn other)
{
   Local Xpawn x; //Xpawn = changeable guy
   Super.ModifyPlayer(other);
   X = xPawn(other);

   if (X != None)
   {
    x.Health = StartingHealth;
    x.HealthMax = MaximumHealth;
   }
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.GameGroup, "StartingHealth", default.MaxHealthDescText[0], 0, 0, "Text",   "100;0.1:999");
	PlayInfo.AddSetting(default.GameGroup, "MaximumHealth", default.MaxHealthDescText[1], 0, 0, "Text",   "500;0.1:999");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "StartingHealth":  return default.MaxHealthDescText[0];
		case "MaximumHealth":	return default.MaxHealthDescText[1];
	}

	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     StartingHealth=100
     MaximumHealth=250
     MaxHealthDescText(0)="Starting Health"
     MaxHealthDescText(1)="Maximum Health"
     GroupName="KF-Health"
     FriendlyName="Max Health"
     Description="Modifies the Max Health"
}
