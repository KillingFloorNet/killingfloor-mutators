class CWPPageQuit extends BlackoutWindow;

var CWPInteraction MyInteraction;
var automated GUIButton b_Yes, b_No;
var automated GUILabel l_QuitDesc;

function InitComponent(GUIController MyController, GUIComponent MyOwner) {
	Super.InitComponent(MyController, MyOwner);

	b_Yes.bAutoSize = true;
	b_Yes.SizingCaption = "Yes";
	b_Yes.AutoSizePadding.HorzPerc = 3.0;
	b_Yes.AutoSizePadding.VertPerc = 0.5;
}

function InternalOnOpen() {
	local KFInvasionLoginMenu LoginMenu;
	local CWPMidGamePanel MyPanel;
	
	if (Controller != None)
		LoginMenu = KFInvasionLoginMenu(Controller.FindMenuByClass(class'KFGui.KFInvasionLoginMenu'));

	if (LoginMenu != None)
		MyPanel = CWPMidGamePanel(LoginMenu.c_Main.FindPanelClass(class'CWPMut.CWPMidGamePanel'));

	if (MyPanel != None)
		MyInteraction = MyPanel.MyInteraction;
		
	if (MyInteraction == None)
		Controller.CloseMenu();
}

function bool InternalOnClick(GUIComponent Sender) {
	if (Sender == b_Yes) {
		if (MyInteraction != None)
			MyInteraction.ClearAll();
		else
			Controller.CloseMenu();
	}
	else {
		Controller.CloseMenu();
	}

	return true;
}

function bool InternalOnPreDraw(Canvas C) {
	local float w, h, x1, x2, y, center, spacing;

	w = b_Yes.ActualWidth();
	h = b_Yes.ActualHeight();
	center = ActualLeft() + ActualWidth() / 2;
	spacing = ActualWidth() / 4 - w / 2;
	x1 = ActualLeft() + spacing;
	x2 = center + spacing;
	y = ActualTop() + 0.9 * ActualHeight() - h;
	
	b_Yes.SetPosition(x1, y, w, h, true);
	b_No.SetPosition(x2, y, w, h, true);

	return Super.InternalOnPreDraw(C);
}

defaultproperties {
	Begin Object Class=GUIButton Name=YesButton
		Caption="Yes"
		WinTop=0.750000
		WinWidth=0.147268
		WinHeight=0.048769
		TabOrder=1
		bBoundToParent=True
		bNeverFocus=True
		OnClick=CWPPageQuit.InternalOnClick
	End Object
	b_Yes=GUIButton'CWPPageQuit.YesButton'

	Begin Object Class=GUIButton Name=NoButton
		Caption="No"
		TabOrder=2
		bBoundToParent=True
		bNeverFocus=True
		OnClick=CWPPageQuit.InternalOnClick
	End Object
	b_No=GUIButton'CWPPageQuit.NoButton'

	Begin Object Class=GUILabel Name=QuitDesc
		Caption="Clear all custom priorities, switch to the default functions and remove the tab?"
		TextAlign=TXTA_Center
		TextColor=(B=255,G=255,R=255)
		WinTop=0.426042
		WinHeight=32.000000
		RenderWeight=4.000000
	End Object
	l_QuitDesc=GUILabel'CWPPageQuit.QuitDesc'

	WinTop=0.375
	WinLeft=0.15
	WinHeight=0.2
	WinWidth=0.7
	OnOpen=CWPPageQuit.InternalOnOpen
}
