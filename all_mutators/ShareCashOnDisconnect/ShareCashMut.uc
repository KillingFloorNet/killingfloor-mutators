Class ShareCashMut extends Mutator;

var private int StartingCash;

event PostBeginPlay()
{
    if(KFGameType(Level.Game)!=None)
        StartingCash=KFGameType(Level.Game).StartingCash;
}

function NotifyLogout(Controller Exiting)
{
    local int Cash;
    local int ShareCash;
    local Controller C;

    Cash=PlayerController(Exiting).PlayerReplicationInfo.Score;
    if(KFGameType(Level.Game)!=None && Exiting.bIsPlayer && Cash>StartingCash)
    {
        ShareCash=Cash/Level.Game.NumPlayers;
        for(C=Level.ControllerList; C!=None; C=C.NextController)
        {
            if(PlayerController(C)!=None)
            {
                KFPlayerReplicationInfo(PlayerController(C).PlayerReplicationInfo).Score+=ShareCash;
                PlayerController(C).ClientPlaySound(Class'CashPickup'.Default.PickupSound,True, 2.f);
                PlayerController(C).ReceiveLocalizedMessage(class'CashMessage', ShareCash);
            }
        }
    }
    Super.NotifyLogout(Exiting);
}

defaultproperties
{
    bAddToServerPackages=True
    GroupName="KF-ShareCash"
    FriendlyName="Share Cash Mutator"
    Description="Shares the money of exiting players with all other teammates alive."
}