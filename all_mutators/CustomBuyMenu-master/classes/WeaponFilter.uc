class WeaponFilter extends KFGui.KFQuickPerkSelect;

var CBMSaleList listRef;
var KFTab_BuyMenu   menuTab;
var automated   KFIndexedGUIImage               PerkSelectIcon6;
var automated   GUIImage                        PerkBack6;
var automated   KFIndexedGUIImage               PerkSelectIconAll;
var automated   GUIImage                        PerkBackAll;
var automated   GUILabel                        WeaponFilterLabel;
var int allWeaponsIndex;

function bool InternalOnClick(GUIComponent Sender) {
    if ( Sender.IsA('KFIndexedGUIImage')) {
        if (KFIndexedGUIImage(Sender).Index == allWeaponsIndex) {
            listRef.filterVeterancy= class'KFVeterancyTypes';
        } else {
            listRef.filterVeterancy= class'KFGameType'.default.LoadedSkills[KFIndexedGUIImage(Sender).Index];
        }
        listRef.Top= 0;
        listRef.Index= -1;
        menuTab.TheBuyable= None;
        menuTab.OnAnychange();
    }
    
    return false;   
}

function setPerkIcon(out KFIndexedGUIImage perkImage, int i) {
    perkImage.Index= i;
    perkImage.ImageColor.A = 255;
    if (listRef.filterVeterancy == class'KFGameType'.default.LoadedSkills[i]) {
        perkImage.Image= class'KFGameType'.default.LoadedSkills[i].default.OnHUDGoldIcon;
    } else {
        perkImage.Image= class'KFGameType'.default.LoadedSkills[i].default.OnHUDIcon;
    }
}

function bool MyOnDraw(Canvas C) {
    local int i;

    super.MyOnDraw(C);

    for (i = 0; i < class'KFGameType'.default.LoadedSkills.Length - 1; i++) {
        setPerkIcon(PerkSelectIcons[i], i);
    }
    setPerkIcon(PerkSelectIcon6, i);
    PerkSelectIconAll.Index= allWeaponsIndex;
    if (listRef.filterVeterancy == class'KFVeterancyTypes') {
        PerkSelectIconAll.ImageColor.A= 128;
    } else {
        PerkSelectIconAll.ImageColor.A= 255;
    }

    return false;
}

function ResizeIcons(Canvas C) {
    super.ResizeIcons(C);

    PerkBack6.WinWidth = (C.ClipY / C.ClipX) * BoxSizeX;
    PerkSelectIcon6.WinWidth= (C.ClipY / C.ClipX) * BoxSizeY;
    PerkBackAll.WinWidth = (C.ClipY / C.ClipX) * BoxSizeX;
    PerkSelectIconAll.WinWidth= (C.ClipY / C.ClipX) * BoxSizeY;
}

defaultproperties {
    allWeaponsIndex= -1

    Begin Object Class=GUILabel Name=Filter
        WinTop=0.005
        WinLeft=0.6690
        WinWidth=0.329761
        WinHeight=0.05
        Caption="Weapon Filters"
        TextAlign=TXTA_Center
        TextFont="UT2MenuFont"
        TextColor=(R=175,G=176,B=158,A=255)
    End Object
    WeaponFilterLabel=Filter

    Begin Object class=GUIImage Name=PBAll
        WinWidth=0.04
        WinHeight=0.04
        WinLeft=0.70
        WinTop=0.0504
        Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
        ImageStyle=ISTY_Scaled
        Renderweight=0.5
    End Object
    PerkBackAll=PBAll

    Begin Object class=GUIImage Name=PB0
        WinWidth=0.04
        WinHeight=0.04
        WinLeft=0.735
        WinTop=0.0504
        Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
        ImageStyle=ISTY_Scaled
        Renderweight=0.5
    End Object
    PerkBack0=PB0   
    
    Begin Object class=GUIImage Name=PB1
        WinWidth=0.04
        WinHeight=0.04
        WinLeft=0.77
        WinTop=0.0504
        Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
        ImageStyle=ISTY_Scaled
        Renderweight=0.5
    End Object
    PerkBack1=PB1   

    Begin Object class=GUIImage Name=PB2
        WinWidth=0.04
        WinHeight=0.04
        WinLeft=0.805
        WinTop=0.0504
        Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
        ImageStyle=ISTY_Scaled
        Renderweight=0.5
    End Object
    PerkBack2=PB2   

    Begin Object class=GUIImage Name=PB3
        WinWidth=0.04
        WinHeight=0.04
        WinLeft=0.84
        WinTop=0.0504
        Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
        ImageStyle=ISTY_Scaled
        Renderweight=0.5
    End Object
    PerkBack3=PB3   

    Begin Object class=GUIImage Name=PB4
        WinWidth=0.04
        WinHeight=0.04
        WinLeft=0.875
        WinTop=0.0504
        Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
        ImageStyle=ISTY_Scaled
        Renderweight=0.5
    End Object
    PerkBack4=PB4   

    Begin Object class=GUIImage Name=PB5
        WinWidth=0.04
        WinHeight=0.04
        WinLeft=0.91
        WinTop=0.0504
        Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
        ImageStyle=ISTY_Scaled
        Renderweight=0.5
    End Object
    PerkBack5=PB5

    Begin Object class=GUIImage Name=PB6
        WinWidth=0.04
        WinHeight=0.04
        WinLeft=0.945
        WinTop=0.0504
        Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
        ImageStyle=ISTY_Scaled
        Renderweight=0.5
    End Object
    PerkBack6=PB6

    Begin Object class=KFIndexedGUIImage Name=PSIAll
        WinWidth=0.040
        WinHeight=0.040
        WinLeft=0.70
        WinTop=0.0524
        Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
        ImageStyle=ISTY_Scaled
        Renderweight=0.6
        OnClick=InternalOnClick
    End Object
    PerkSelectIconAll=PSIAll

    Begin Object class=KFIndexedGUIImage Name=PSI0
        WinWidth=0.040
        WinHeight=0.040
        WinLeft=0.735
        WinTop=0.0524
        Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
        ImageStyle=ISTY_Scaled
        Renderweight=0.6
        OnClick=InternalOnClick
    End Object
    PerkSelectIcon0=PSI0            
    
    Begin Object class=KFIndexedGUIImage Name=PSI1
        WinWidth=0.040
        WinHeight=0.040
        WinLeft=0.77
        WinTop=0.0524
        Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
        ImageStyle=ISTY_Scaled
        Renderweight=0.6
        OnClick=InternalOnClick
    End Object
    PerkSelectIcon1=PSI1            
    
    Begin Object class=KFIndexedGUIImage Name=PSI2
        WinWidth=0.040
        WinHeight=0.040
        WinLeft=0.805
        WinTop=0.0524
        Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
        ImageStyle=ISTY_Scaled
        Renderweight=0.6
        OnClick=InternalOnClick
    End Object
    PerkSelectIcon2=PSI2            
    
    Begin Object class=KFIndexedGUIImage Name=PSI3
        WinWidth=0.040
        WinHeight=0.040
        WinLeft=0.84
        WinTop=0.0524
        Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
        ImageStyle=ISTY_Scaled
        Renderweight=0.6
        OnClick=InternalOnClick
    End Object
    PerkSelectIcon3=PSI3            
    
    Begin Object class=KFIndexedGUIImage Name=PSI4
        WinWidth=0.040
        WinHeight=0.040
        WinLeft=0.875
        WinTop=0.0524
        Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
        ImageStyle=ISTY_Scaled
        Renderweight=0.6
        OnClick=InternalOnClick
    End Object
    PerkSelectIcon4=PSI4            
    
    Begin Object class=KFIndexedGUIImage Name=PSI5
        WinWidth=0.040
        WinHeight=0.040
        WinLeft=0.91
        WinTop=0.0524
        Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
        ImageStyle=ISTY_Scaled
        Renderweight=0.6
        OnClick=InternalOnClick
    End Object
    PerkSelectIcon5=PSI5

    Begin Object class=KFIndexedGUIImage Name=PSI6
        WinWidth=0.040
        WinHeight=0.040
        WinLeft=0.945
        WinTop=0.0524
        Image=Texture'KF_InterfaceArt_tex.Menu.Perk_box_unselected'
        ImageStyle=ISTY_Scaled
        Renderweight=0.6
        OnClick=InternalOnClick
    End Object
    PerkSelectIcon6=PSI6
}
