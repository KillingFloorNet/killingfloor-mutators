//=============================================================================
// MutMoney - regenerates players cash - By EvilDooinz aka Bruce303lee
//=============================================================================
class MutMoney extends Mutator;
 
var() globalconfig float CashPerSecond;
var() globalconfig float MaximumCash;
// Don't call Actor PreBeginPlay() for Mutator 
event PreBeginPlay()
{
    SetTimer(1.0,true);
}
 
function Timer()
{
    local Controller C;
    local int cash;
    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
	cash = KFPlayerReplicationInfo( C.Pawn.PlayerReplicationInfo ).Score;
	if (C.Pawn != None && cash < MaximumCash )
        {
           KFPlayerReplicationInfo( C.Pawn.PlayerReplicationInfo ).Score += CashPerSecond;
        }
    }
}
static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.GameGroup, "CashPerSecond", "CashPerSecond", 0, 0, "Text",   "10;0.1:1000");
	PlayInfo.AddSetting(default.GameGroup, "MaximumCash", "MaximumCash", 0, 0, "Text",   "1600;0.1:16000");
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "CashPerSecond":return "Amount of cash given per second.";
		case "MaximumCash":return "Amount of to keep on hand.";
	}

	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     CashPerSecond=10.000000
     MaximumCash=1600.000000
     GroupName="KF-Money"
     FriendlyName="Money Regen"
     Description="All players regenerate cash."
}
