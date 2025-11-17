//-----------------------------------------------------------
//
//-----------------------------------------------------------
class GUISelectClass extends UT2K4GUIPage;

var automated GuiButton		berserker,demolition,supportspecialist,medic,sharpshooter,commando,firebug;
var GUIComponent Selected;
vAR BOOL bchosen;


function bool SelectHuman(GUIComponent Sender)
{
    zombieplayercontroller(self.Controller.ViewportOwner.Actor).Modifyclass(playerowner());
	bchosen=true;
	Controller.CloseMenu(false);
	return true;
}

function bool ButtonClick(GUIComponent Sender)
{
	Selected = Sender;
	ChoosePerk();
	Return True;
}

function ChoosePerk()
{
	Switch( Selected )
	{
		case controls[3]:zombieplayercontroller(self.Controller.ViewportOwner.Actor).perk('berserker');break;
		case controls[4]:zombieplayercontroller(self.Controller.ViewportOwner.Actor).perk('fieldmedic');break;
		case controls[5]:zombieplayercontroller(self.Controller.ViewportOwner.Actor).perk('supportspecialist');break;
		case controls[6]:zombieplayercontroller(self.Controller.ViewportOwner.Actor).perk('commando');break;
		case controls[7]:zombieplayercontroller(self.Controller.ViewportOwner.Actor).perk('firebug');break;
		case controls[8]:zombieplayercontroller(self.Controller.ViewportOwner.Actor).perk('demolitions');break;
		case controls[9]:zombieplayercontroller(self.Controller.ViewportOwner.Actor).perk('sharpshooter');break;
	}
}

function bool SelectClassType(GUIComponent Sender)
{
    zombieplayercontroller(self.Controller.ViewportOwner.Actor).Modifyspecimen(playerowner());
	bchosen=true;
	Controller.CloseMenu(false);
	return true;
}

function bool CloseClick(GUIComponent Sender)
{
    //Local InvMenuTracker MT;
    local KFPlayerReplicationInfo PRI;

    PRI = KFPlayerReplicationInfo(PlayerOwner().PlayerReplicationInfo);

	Controller.CloseMenu(false);
	return true;
}

function myOnClose(optional bool bCanceled)
{
	if(bchosen==false)
		zombieplayercontroller(self.Controller.ViewportOwner.Actor).Modifyclass(playerowner());
	Super.OnClose(bCanceled);	
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent( MyController, MyOwner );
}

defaultproperties
{
     bRenderWorld=True
     bPersistent=True
     bAllowedAsLast=True
     OnClose=GUISelectClass.myOnClose
     Begin Object Class=FloatingImage Name=FloatingFrameBackground
         Image=Texture'KillingFloor2HUD.Menu.menuBackground'
         DropShadow=None
         ImageStyle=ISTY_Scaled
         WinTop=0.400000
         WinLeft=0.350000
         WinWidth=0.300000
         WinHeight=0.300000
         RenderWeight=0.000003
     End Object
     Controls(0)=FloatingImage'AwesomeClot2.GUISelectClass.FloatingFrameBackground'

     Begin Object Class=GUIButton Name=ClassSelectButton
         Caption="HUMAN"
         Hint="Want a shotgun?."
         WinTop=0.600000
         WinLeft=0.200000
         WinWidth=0.200000
         OnClick=GUISelectClass.SelectHuman
         OnKeyEvent=ClassSelectButton.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'AwesomeClot2.GUISelectClass.ClassSelectButton'

     Begin Object Class=GUIButton Name=ClassSelectspecimen
         Caption="SPECIMEN"
         Hint="Selected the Specimen you want?."
         WinTop=0.600000
         WinLeft=0.600000
         WinWidth=0.200000
         OnClick=GUISelectClass.SelectClassType
         OnKeyEvent=ClassSelectspecimen.InternalOnKeyEvent
     End Object
     Controls(3)=GUIButton'AwesomeClot2.GUISelectClass.ClassSelectspecimen'

     /*Begin Object Class=GUIButton Name=berserkerButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Berserker"
         StyleName="ListSelection"
         Hint="Use Berserker perk."
         WinTop=0.200000
         WinLeft=0.200000
         WinWidth=0.200000
         TabOrder=1
         bFocusOnWatch=True
         OnClick=GUISelectClass.ButtonClick
         OnKeyEvent=berserkerButton.InternalOnKeyEvent
     End Object
     Controls(4)=GUIButton'AwesomeClot2.GUISelectClass.berserkerButton'

     Begin Object Class=GUIButton Name=medicButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Field Medic"
         StyleName="ListSelection"
         Hint="Use Field Medic perk."
         WinTop=0.250000
         WinLeft=0.200000
         WinWidth=0.200000
         TabOrder=2
         bFocusOnWatch=True
         OnClick=GUISelectClass.ButtonClick
         OnKeyEvent=medicButton.InternalOnKeyEvent
     End Object
     Controls(5)=GUIButton'AwesomeClot2.GUISelectClass.medicButton'

     Begin Object Class=GUIButton Name=supportspecialistButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Support specialist"
         StyleName="ListSelection"
         Hint="Use support specialist perk."
         WinTop=0.300000
         WinLeft=0.200000
         WinWidth=0.200000
         TabOrder=3
         bFocusOnWatch=True
         OnClick=GUISelectClass.ButtonClick
         OnKeyEvent=supportspecialistButton.InternalOnKeyEvent
     End Object
     Controls(6)=GUIButton'AwesomeClot2.GUISelectClass.supportspecialistButton'

     Begin Object Class=GUIButton Name=commandoButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Commando"
         StyleName="ListSelection"
         Hint="Use commando perk."
         WinTop=0.350000
         WinLeft=0.200000
         WinWidth=0.200000
         TabOrder=4
         bFocusOnWatch=True
         OnClick=GUISelectClass.ButtonClick
         OnKeyEvent=commandoButton.InternalOnKeyEvent
     End Object
     Controls(7)=GUIButton'AwesomeClot2.GUISelectClass.commandoButton'

     Begin Object Class=GUIButton Name=firebugButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Firebug"
         StyleName="ListSelection"
         Hint="Use firebug perk."
         WinTop=0.400000
         WinLeft=0.200000
         WinWidth=0.200000
         TabOrder=5
         bFocusOnWatch=True
         OnClick=GUISelectClass.ButtonClick
         OnKeyEvent=firebugButton.InternalOnKeyEvent
     End Object
     Controls(8)=GUIButton'AwesomeClot2.GUISelectClass.firebugButton'

     Begin Object Class=GUIButton Name=demolitionButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Demolitions"
         StyleName="ListSelection"
         Hint="Use Demolitions perk."
         WinTop=0.450000
         WinLeft=0.200000
         WinWidth=0.200000
         TabOrder=6
         bFocusOnWatch=True
         OnClick=GUISelectClass.ButtonClick
         OnKeyEvent=demolitionButton.InternalOnKeyEvent
     End Object
     Controls(9)=GUIButton'AwesomeClot2.GUISelectClass.demolitionButton'

     Begin Object Class=GUIButton Name=sharpshooterButton
         CaptionAlign=TXTA_Left
         CaptionEffectStyleName="TextButtonEffect"
         Caption="Sharpshooter"
         StyleName="ListSelection"
         Hint="Use sharpshooter perk."
         WinTop=0.500000
         WinLeft=0.200000
         WinWidth=0.200000
         TabOrder=7
         bFocusOnWatch=True
         OnClick=GUISelectClass.ButtonClick
         OnKeyEvent=sharpshooterButton.InternalOnKeyEvent
     End Object
     Controls(10)=GUIButton'AwesomeClot2.GUISelectClass.sharpshooterButton'*/

     WinTop=0.000000
     WinHeight=1.000000
     bMouseOverSound=True
}
