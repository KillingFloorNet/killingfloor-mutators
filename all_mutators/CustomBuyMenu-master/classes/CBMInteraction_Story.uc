class CBMInteraction_Story extends CBMInteractionBase;

function bool isTraderTime() {
    return KFPlayerController_Story(ViewportOwner.Actor).RemainingTraderTime > 0;
}

defaultproperties {
    buyMenuClass="CustomBuyMenu.BuyMenu_Story"
}
