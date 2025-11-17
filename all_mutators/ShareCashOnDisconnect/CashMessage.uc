Class CashMessage extends LocalMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
    return "+ £"@Switch;
}

defaultproperties
{
    bIsUnique=True
    bFadeMessage=True
    Lifetime=5
    DrawColor=(R=80,G=200,B=80,A=255)
    StackMode=SM_Down
    PosX=0.8
    FontSize=1
}