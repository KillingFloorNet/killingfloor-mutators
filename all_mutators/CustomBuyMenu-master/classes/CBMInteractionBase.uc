class CBMInteractionBase extends Interaction
    abstract;

var string buyMenuClass;

event NotifyLevelChange() {
    Master.RemoveInteraction(self);
}

function bool isTraderTime();

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta ) {
    local string alias;
    local ShopVolume shop;
    local bool touchingShopVolume;

    alias= ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key));
    if (Action == IST_Press && alias ~= "use" && isTraderTime()) {
        foreach ViewportOwner.Actor.Pawn.TouchingActors(class'ShopVolume', shop) {
            touchingShopVolume= true;
            break;
        }
        if (touchingShopVolume && Len(buyMenuClass) > 0) {
            ViewportOwner.Actor.ClientOpenMenu(buyMenuClass,,"MyTrader", string(KFHumanPawn(ViewportOwner.Actor.Pawn).MaxCarryWeight));
            return true;
        }
    }
    return false;
}

defaultproperties {
    bActive= true
}
