class TSCSharedMessages extends CriticalEventPlus;

var(Message) localized string strEnemyShop;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    switch (Switch) {
        case 1:     return default.strEnemyShop;
    }
    return "";
}

defaultproperties
{
     strEnemyShop="Can not trade in enemy shop!"
     DrawColor=(B=64,G=64,R=200)
     PosY=0.850000
     FontSize=3
}
