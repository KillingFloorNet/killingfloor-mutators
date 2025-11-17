static function class<Grenade> GetNadeType(KFPlayerReplicationInfo KFPRI)
{
    if(Class'Utilities'.Static.HasItem(KFHumanPawn(KFPRI.Owner.Pawn), 'VipItem'))
        return class'DemolitionNade';
    return class'SupportNade';
}