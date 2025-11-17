class CBMInteractionVanilla extends CBMInteractionBase;

function bool isTraderTime() {
    return !KFGameReplicationInfo(ViewportOwner.Actor.GameReplicationInfo).bWaveInProgress;
}

defaultproperties {
    buyMenuClass="CustomBuyMenu.BuyMenu"
}
