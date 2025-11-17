////////////////////////////////////////////
//                                        //
// Share Cash Mutator 1.0 - (c) by Mutant //
//                                        //
////////////////////////////////////////////
class KFCashAward extends LocalMessage;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
     return "+ £"@Switch;
}

static function ClientReceive(
    PlayerController P,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
     P.ClientPlaySound(SoundGroup'KF_InventorySnd.Cash_Pickup',,,SLOT_Interact);
     Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

defaultproperties
{
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=5
     DrawColor=(B=80,G=200,R=80)
     StackMode=SM_Down
     PosX=0.890000
     FontSize=1
}
