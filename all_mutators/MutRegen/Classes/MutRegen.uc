//=============================================================================
// MutRegen - regenerates players - By EvilDooinz aka Bruce303lee
//=============================================================================
class MutRegen extends Mutator;
 
var() globalconfig float HealthPerSecond;
var() globalconfig float ArmorPerSecond;
// Don't call Actor PreBeginPlay() for Mutator 
event PreBeginPlay()
{
    SetTimer(1.0,true);
}
 
function Timer()
{
    local Controller C;
 
    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
	if (C.Pawn != None && C.Pawn.Health < C.Pawn.HealthMax )
        {
            C.Pawn.Health = Min( C.Pawn.Health+HealthPerSecond, C.Pawn.HealthMax );
        }
	if (C.Pawn != None && C.Pawn.ShieldStrength < 100 )
        {
            C.Pawn.AddShieldStrength(ArmorPerSecond);
        }
    }
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.GameGroup, "HealthPerSecond", "HealthPerSecond", 0, 0, "Text",   "10;0.1:20");
	PlayInfo.AddSetting(default.GameGroup, "ArmorPerSecond", "ArmorPerSecond", 0, 0, "Text",   "10;0.1:20");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "HeatlthPerSecond":return "Amount of health players regenerate.";
		case "ArmorPerSecond":return "Amount of armor players regenerate.";
	}

	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     HealthPerSecond=10.000000
     ArmorPerSecond=10.000000
     GroupName="KF-Regen"
     FriendlyName="Regeneration Plus"
     Description="All players regenerate health and armor."
}
