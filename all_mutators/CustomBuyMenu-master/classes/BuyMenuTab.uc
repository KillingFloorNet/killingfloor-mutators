class BuyMenuTab extends KFGui.KFTab_BuyMenu;

var bool doubleClick;

function SaleChange(GUIComponent Sender) {
    if (!doubleClick) {
        super.SaleChange(SendeR);
    } else {
        doubleClick= false;
    }
}

function bool SaleDblClick(GUIComponent Sender) {
    doubleClick= true;
    return super.SaleDblClick(Sender);
}

defaultproperties {
    Begin Object Class=CBMSaleListBox Name=SaleBox
        OnCreateComponent=SaleBox.InternalOnCreateComponent
        WinTop=0.064312
        WinLeft=0.672632
        WinWidth=0.325857
        WinHeight=0.674039
    End Object
    SaleSelect=CBMSaleListBox'CustomBuyMenu.BuyMenuTab.SaleBox'
}    
