class WeldBotMenu extends LargeWindow/*GUIPage*/
	dependson(WeldBot);

var automated GUIButton bFollowMe, bStay, bWeldDoors, bExit;
var automated GUICheckBoxButton cFollowMe, cWeldDoors, cStay;
var automated GUISlider		sDistance;
var automated GUILabel		lDist, lBotName;
var automated GUIEditBox	eBotName;
var localized string Caption;

var WeldBot.EState selectedState;
var WeldBotReplicationInfo RepInfo;
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
function SetupStateBtns(WeldBot.EState State)
{
	if (State==Follow)
	{
		cFollowMe.bChecked=true;
		bFollowMe.DisableMe();
		bStay.EnableMe();
		bWeldDoors.EnableMe();
		cStay.bChecked=false;
		cWeldDoors.bChecked=false;
	}
	else if (State==Stay)
	{
		cStay.bChecked=true;
		bStay.DisableMe();
		bFollowMe.EnableMe();
		bWeldDoors.EnableMe();
		cFollowMe.bChecked=false;
		cWeldDoors.bChecked=false;
	}
	else if (State==WeldDoors)
	{
		cWeldDoors.bChecked=true;
		bWeldDoors.DisableMe();
		bFollowMe.EnableMe();
		bStay.EnableMe();
		cFollowMe.bChecked=false;
		cStay.bChecked=false;
	}
}
//--------------------------------------------------------------------------------------------------
event HandleParameters(string Param1, string Param2)
{
	foreach PlayerOwner().DynamicActors(class'WeldBotReplicationInfo',RepInfo)
	{
		if (RepInfo.OwnerPC == PlayerOwner())
		{
			selectedState	= RepInfo.BotState;
			SetupStateBtns(selectedState);
			sDistance.SetValue(RepInfo.Distance);
			break;
		}
	}
	if (RepInfo == none)
	{
		PlayerOwner().ClientMessage("Error: Cant find WeldBot.RepInfo, so exit GUI");
		PlayerOwner().ClientCloseMenu(true, false); //CloseAll(false,true);
	}
}
//--------------------------------------------------------------------------------------------------
function OnOpen()
{
	t_WindowTitle.SetCaption(Caption);
	Super.OnOpen();
}
//--------------------------------------------------------------------------------------------------
function OnClose(optional Bool bCancelled)
{
	// Отправляем новые настройки через консоль mutate (а мутатор WeldBotMut должен их поймать)
	RepInfo.SetParams(selectedState, sDistance.value, eBotName.TextStr);
	//PlayerOwner().ConsoleCommand("mutate WeldBot"@StateToString(selectedState)@sDistance.Value,false);
	Super.OnClose(bCancelled);
}
//--------------------------------------------------------------------------------------------------
function bool InternalOnClick(GUIComponent Sender)
{
	local PlayerController PC;
	PC = PlayerOwner();
	
	switch (GUIButton(Sender))
	{
		case bFollowMe:
			selectedState=Follow;
			SetupStateBtns(selectedState);
			return true;
			break;
		case bStay:
			selectedState=Stay;
			SetupStateBtns(selectedState);
			return true;
			break;
		case bWeldDoors:
			selectedState=WeldDoors;
			SetupStateBtns(selectedState);
			return true;
			break;
		case bExit:
			PC.ClientCloseMenu(True,False); //CloseAll(false,true);
			break;
	}
    return false;
}
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------

defaultproperties
{
     Begin Object Class=GUIButton Name=obFollowMe
         Caption="Follow me"
         Hint="Bot will follow you"
         WinTop=0.262151
         WinLeft=0.031200
         WinWidth=0.300000
         WinHeight=0.289493
         TabOrder=2
         bBoundToParent=True
         bScaleToParent=True
         OnClick=WeldBotMenu.InternalOnClick
         OnKeyEvent=obFollowMe.InternalOnKeyEvent
     End Object
     bFollowMe=GUIButton'chippo.WeldBotMenu.obFollowMe'

     Begin Object Class=GUIButton Name=obStay
         Caption="Stay here"
         Hint="Bot will stay"
         WinTop=0.262151
         WinLeft=0.352068
         WinWidth=0.300000
         WinHeight=0.289493
         TabOrder=3
         bBoundToParent=True
         bScaleToParent=True
         OnClick=WeldBotMenu.InternalOnClick
         OnKeyEvent=obStay.InternalOnKeyEvent
     End Object
     bStay=GUIButton'chippo.WeldBotMenu.obStay'

     Begin Object Class=GUIButton Name=obWeldDoors
         Caption="Hold doors"
         Hint="Bot will weld near doors"
         WinTop=0.262151
         WinLeft=0.672068
         WinWidth=0.300000
         WinHeight=0.289493
         TabOrder=4
         bBoundToParent=True
         bScaleToParent=True
         OnClick=WeldBotMenu.InternalOnClick
         OnKeyEvent=obWeldDoors.InternalOnKeyEvent
     End Object
     bWeldDoors=GUIButton'chippo.WeldBotMenu.obWeldDoors'

     Begin Object Class=GUIButton Name=obExit
         Caption="Exit"
         WinTop=0.702259
         WinLeft=0.031564
         WinWidth=0.938479
         WinHeight=0.250866
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         OnClick=WeldBotMenu.InternalOnClick
         OnKeyEvent=obExit.InternalOnKeyEvent
     End Object
     bExit=GUIButton'chippo.WeldBotMenu.obExit'

     Begin Object Class=GUICheckBoxButton Name=ocFollowMe
         Hint="Bot will follow you"
         WinTop=0.110756
         WinLeft=0.139200
         WinWidth=0.081720
         WinHeight=0.140587
         bTabStop=False
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=False
         bCaptureMouse=False
         bNeverFocus=True
         bMouseOverSound=False
         OnKeyEvent=ocFollowMe.InternalOnKeyEvent
     End Object
     cFollowMe=GUICheckBoxButton'chippo.WeldBotMenu.ocFollowMe'

     Begin Object Class=GUICheckBoxButton Name=ocWeldDoors
         Hint="Bot will weld near doors"
         WinTop=0.110756
         WinLeft=0.776964
         WinWidth=0.081720
         WinHeight=0.140587
         bTabStop=False
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=False
         bCaptureMouse=False
         bNeverFocus=True
         bMouseOverSound=False
         OnKeyEvent=ocWeldDoors.InternalOnKeyEvent
     End Object
     cWeldDoors=GUICheckBoxButton'chippo.WeldBotMenu.ocWeldDoors'

     Begin Object Class=GUICheckBoxButton Name=ocStay
         Hint="Bot will stay"
         WinTop=0.110756
         WinLeft=0.466965
         WinWidth=0.081720
         WinHeight=0.140587
         bTabStop=False
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=False
         bCaptureMouse=False
         bNeverFocus=True
         bMouseOverSound=False
         OnKeyEvent=ocStay.InternalOnKeyEvent
     End Object
     cStay=GUICheckBoxButton'chippo.WeldBotMenu.ocStay'

     Begin Object Class=GUISlider Name=osDistance
         MinValue=50000.000000
         MaxValue=600000.000000
         Hint="Maximum bot distance"
         WinTop=0.570598
         WinLeft=0.294765
         WinWidth=0.660323
         WinHeight=0.118925
         TabOrder=5
         bBoundToParent=True
         bScaleToParent=True
         OnClick=osDistance.InternalOnClick
         OnMousePressed=osDistance.InternalOnMousePressed
         OnMouseRelease=osDistance.InternalOnMouseRelease
         OnKeyEvent=osDistance.InternalOnKeyEvent
         OnCapturedMouseMove=osDistance.InternalCapturedMouseMove
     End Object
     sDistance=GUISlider'chippo.WeldBotMenu.osDistance'

     Begin Object Class=GUILabel Name=lDistance
         Caption="Range:"
         TextColor=(B=255,G=255,R=255)
         VertAlign=TXTA_Center
         WinTop=0.570598
         WinLeft=0.054765
         WinWidth=0.230324
         WinHeight=0.118925
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     lDist=GUILabel'chippo.WeldBotMenu.lDistance'

     Begin Object Class=GUILabel Name=lBname
         Caption="Bot name:"
         TextColor=(B=255,G=255,R=255)
         VertAlign=TXTA_Center
         WinTop=0.570598
         WinLeft=0.054765
         WinWidth=0.230324
         WinHeight=0.118925
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     lBotName=GUILabel'chippo.WeldBotMenu.lBname'

     Begin Object Class=GUIEditBox Name=clEditBox
         WinTop=0.570598
         WinLeft=0.054765
         WinWidth=0.230324
         WinHeight=0.118925
         bBoundToParent=True
         bScaleToParent=True
         bCaptureMouse=True
         bMouseOverSound=False
         OnActivate=clEditBox.InternalActivate
         OnDeActivate=clEditBox.InternalDeactivate
         OnKeyType=clEditBox.InternalOnKeyType
         OnKeyEvent=clEditBox.InternalOnKeyEvent
     End Object
     eBotName=GUIEditBox'chippo.WeldBotMenu.clEditBox'

     Caption="Bot control console"
     bMoveAllowed=True
     DefaultLeft=0.110313
     DefaultTop=0.057916
     DefaultWidth=0.779688
     DefaultHeight=0.847083
     bRequire640x480=False
     bAllowedAsLast=True
     WinTop=0.057916
     WinLeft=0.110313
     WinWidth=500.000000
     WinHeight=250.000000
}
