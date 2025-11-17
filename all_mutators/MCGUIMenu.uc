class MCGUIMenu extends LargeWindow;
var MonsterConfig MC;

// основные контроллы
var GUIVertScrollBar	VScroll;
var int					ScrollPos;
var GUIButton			bExit, bSave;

struct GUIParamEditBox
{
	var GUILabel	label;
	var GUIEditBox	ebox;
	var string		Name;
	var int			WinTop;
};
var array<GUIParamEditBox> paramsEBox;

struct GUILabelS
{
	var GUILabel	label;
	var string		Name;
	var int			WinTop;
};
var array<GUILabelS> labels;

var int ExitBtnAreaHeight;	// высота области кнопок OK Cancel (не прокручивается скроллом)
var int gap;				// дефолтный зазор
var int rowH, colW;		// стандартная высота и ширина контрола
var int eboxW; // стандартная ширина eboxa



var bool bInitialized;
var GUIButton B1;
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
event HandleParameters(string Param1, string Param2)
{
	log("HandleParameters"@ActualHeight()@t_WindowTitle.ActualHeight());
	foreach PlayerOwner().DynamicActors(class'MonsterConfig', MC)
		break;
	if (MC==none)
	{
		PlayerOwner().ClientMessage("MCGUIMenu: MonsterConfig not found, so exit");
		PlayerOwner().ClientCloseMenu(True,False); //CloseAll(false,true);
		return;
	}

	gap = 2;
	ExitBtnAreaHeight = 90;
	rowH = 30;
	colW = 160;
	eboxW = 60;
	
	bInitialized = false;
	SetTimer(0.5, false);
	//SetupGUIValues();
}
//--------------------------------------------------------------------------------------------------
// вызывает первоначальную иницилазацию контроллов
function Timer()
{
	if (!bInitialized)
	{
		InitControls();
		bInitialized = true;
	}
}
//--------------------------------------------------------------------------------------------------
// Создает и инициализирует стандартные контроллы
function InitControls()
{
	local int row;
	if (VScroll==none)
	{
		VScroll = GUIVertScrollBar(AddComponent("XInterface.GUIVertScrollBar"));
		VScroll.bBoundToParent=true;
		VScroll.bNeverScale = true;
		VScroll.bScaleToParent = false;
		VScroll.ScalingType = SCALE_Y;
		VScroll.PositionChanged = PositionChanged;
		VScroll.ItemCount = 1200;
		VScroll.ItemsPerPage = 400;
	}
	if (bExit==none)
	{
		bExit = GUIButton(AddComponent("XInterface.GUIButton"));
		bExit.bBoundToParent=true;
		bExit.bNeverScale = true;
		bExit.Caption = "Cancel";
	}
	if (bSave==none)
	{
		bSave = GUIButton(AddComponent("XInterface.GUIButton"));
		bSave.bBoundToParent=true;
		bSave.bNeverScale = true;
		bSave.Caption = "OK";
	}
	
	row=1;
	InitLabel(1,2,row,1,"Game", TXTA_Center);
	InitLabel(3,2,row,1,"MapInfo", TXTA_Center);
	row+=2;
	InitParam(1,2,row,1,"GIFakedPlayersNum");
	InitParam(1,2,row,1,"GIFakedPlayersNum2");
	
	ReInitControls();
}
//--------------------------------------------------------------------------------------------------
function ReInitControls()
{
	local int i;

	VScroll.WinTop=t_WindowTitle.ActualHeight()+1;
	VScroll.WinHeight = ActualHeight() - VScroll.WinTop - ExitBtnAreaHeight + 1;
	VScroll.WinWidth=30;
	VScroll.WinLeft=ActualWidth() - VScroll.WinWidth - 3;
	
	bExit.WinLeft = ActualWidth() / 2 + gap;
	bExit.WinWidth = ActualWidth() / 2 - gap*2;
	bExit.WinHeight = ExitBtnAreaHeight - gap*2;
	bExit.WinTop = ActualHeight() - ExitBtnAreaHeight + gap;
	
	bSave.WinLeft = gap;
	bSave.WinWidth = ActualWidth() / 2 - gap*2;
	bSave.WinHeight = ExitBtnAreaHeight - gap*2;
	bSave.WinTop = ActualHeight() - ExitBtnAreaHeight + gap;
	
	
	for (i=labels.length-1; i>=0; --i)
		ScrollComponent(labels[i].label, labels[i].WinTop);
	for (i=paramsEBox.length-1; i>=0; --i)
	{
		ScrollComponent(paramsEBox[i].label, paramsEBox[i].WinTop);
		ScrollComponent(paramsEBox[i].ebox, paramsEBox[i].WinTop);
	}
	/*ScrollComponent(B1, B1.default.WinTop);
	B1.Caption = t_WindowTitle.ActualHeight()@ActualHeight()@VScrol  l.WinTop@VScroll.WinHeight;*/
}
//--------------------------------------------------------------------------------------------------
// ресайз будет запрещен. от этого мало толку
function SetPosition( float NewLeft, float NewTop, float NewWidth, float NewHeight, optional bool bForceRelative )
{
	Super.SetPosition(NewLeft, NewTop, NewWidth, NewHeight, bForceRelative);
	ReInitControls();
}
//--------------------------------------------------------------------------------------------------
// если крутится скролл
function PositionChanged(int NewPos)
{
	ScrollPos = NewPos;
	ReInitControls();
}
//--------------------------------------------------------------------------------------------------
function ScrollComponent(GUIComponent L, int WTop)
{
	if (L==none) return;

	L.WinTop = WTop - ScrollPos;

	if (L.WinTop + L.WinHeight > ActualHeight() - ExitBtnAreaHeight - 3 // если ниже допустимого
	 || L.WinTop < t_WindowTitle.ActualHeight()+3) // или выше допустимого
		L.bVisible = false;
	else
		L.bVisible = true;
}
//--------------------------------------------------------------------------------------------------
function InitComponentBase(GUIComponent L, int Top, int Height, int Left, int Width)
{
	L.bBoundToParent = true;
	L.bNeverScale = true;
	L.WinTop = Top;
	L.WinHeight = Height;
	L.WinLeft = Left;
	L.WinWidth = Width;
}
//--------------------------------------------------------------------------------------------------
function InitLabelBase(out GUILabel L, string Caption, int Top, int Height, int Left, int Width, eTextAlign A)
{
	if (L==none)
		L = GUILabel(AddComponent("XInterface.GUILabel"));
	InitComponentBase(L,Top,Height,Left,Width);
	L.Caption = Caption;
	L.bNeverFocus = true;
	L.VertAlign = TXTA_Center;
	L.TextAlign = A;
	L.TextColor.R=255;
	L.TextColor.G=255;
	L.TextColor.B=255;
	L.TextColor.A=255;
	
	L.FontScale = FNS_Small;
	L.Style = Controller.GetStyle("EditBox", L.FontScale);
}
//--------------------------------------------------------------------------------------------------
function InitEBoxBase(out GUIEditBox E, int Top, int Height, int Left, int Width, eTextAlign A)
{
	if (E==none)
		E = GUIEditBox(AddComponent("XInterface.GUIEditBox"));
	InitComponentBase(E, Top,Height,Left,Width);
	
	E.FontScale = FNS_Small;
	E.Style = Controller.GetStyle("EditBox", E.FontScale);
	
	//E.TextAlign = A;
}
//--------------------------------------------------------------------------------------------------
function InitLabel(int col, int ncols, int row, int nrows, string Name, eTextAlign A)
{
	local int i,j,idx;
	
	for (i=labels.length-1; i>=0; --i)
		if (labels[i].Name == Name)
			{ idx = i; break; } // если лэйбл с этим name уже существует
	if (i<0)
	{
		j = labels.length;
		labels.insert(j,1);
		idx = j;
	}

	// сохраняем дефолтную позицию для работы скролла
	labels[idx].WinTop = gap + (row-1)*rowH;
	labels[idx].WinTop += t_WindowTitle.ActualHeight()+5;
	
	InitLabelBase(labels[idx].label, 
		Name,
		labels[idx].WinTop, // TOP
		nrows*rowH,			// Height
		gap + (col-1)*colW,	// Left
		ncols*colW,
		A );		// Width
}
//--------------------------------------------------------------------------------------------------
function InitParam(int col, int ncols, int row, int nrows, string Name)
{
	local int i, idx;
	for (i=paramsEBox.length; i>=0; --i)
		if (paramsEBox[i].Name == Name)
			{idx=i;break;}
	if (i<0)
	{
		idx = paramsEBox.Length;
		paramsEBox.Insert(idx,1);
	}

	paramsEBox[idx].WinTop = gap + (row-1)*rowH;
	paramsEBox[idx].WinTop += t_WindowTitle.ActualHeight()+5;
	
	InitLabelBase(paramsEBox[idx].label,
					Name,
					paramsEBox[idx].WinTop, // TOP
					nrows*rowH,			// Height
					gap + (col-1)*colW,	// Left
					ncols*colW - (eboxW + gap), 		// Width
					TXTA_Left );
	InitEBoxBase(paramsEBox[idx].ebox,
					paramsEBox[idx].WinTop, // TOP
					nrows*rowH,			// Height
					gap + (col-1)*colW + (ncols*colW) - eboxW,	// Left
					eboxW,		// Width
					TXTA_Center);
}
//--------------------------------------------------------------------------------------------------
function InitComponent( GUIController MyController, GUIComponent MyOwner )
{
	log("InitComponent"@ActualHeight()@t_WindowTitle.ActualHeight());
	Super.InitComponent( MyController, MyOwner );
}
//--------------------------------------------------------------------------------------------------
function OnOpen()
{
	log("OnOpen()"@ActualHeight()@t_WindowTitle.ActualHeight());
}
//--------------------------------------------------------------------------------------------------
function bool InternalOnKeyEvent( out byte Key, out byte KeyState, float Delta )
{
	local Interactions.EInputKey iKey;

	iKey = EInputKey(Key);
	
	log("InternalOnKeyEvent"@string(Key)@string(iKey));
	
	if ( KeyState == 3 && ikey == IK_MouseWheelUp )   { VScroll.WheelUp();   return true; }
	if ( KeyState == 3 && ikey == IK_MouseWheelDown ) { VScroll.WheelDown(); return true; }
	if ( KeyState != 1 ) return false;
	return false;
}
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
defaultproperties
{
	WindowName="Monster Config"
	bResizeWidthAllowed=true
    bResizeHeightAllowed=true
    bMoveAllowed=true
    DefaultLeft=100
    DefaultTop=100
    DefaultWidth=724
    DefaultHeight=645
    bRequire640x480=False
	
	OnOpen = OnOpen
	
	//bNeverScale = true
	//bScaleToParent = false
	WinWidth=0.670293
	WinHeight=0.569336
	WinLeft=0.146113
	WinTop=0.185547
	
	bAllowedAsLast=True // If this is true, closing this page will not bring up the main menu if last on the stack.	
    bPersistent=False // If set in defprops, page is kept in memory across open/close/reopen
	bRestorable=False // When the GUIController receives a call to CloseAll(), should it reopen this page the next time main is opened?
}