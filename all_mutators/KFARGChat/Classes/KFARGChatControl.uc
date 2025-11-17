//================================================================================
// KFARGChat Control
//================================================================================

class KFARGChatControl extends Inventory;


var Texture BeaconTexture;
var PlayerController Me;
var bool bTalking;
var KFARGChatIcon KFARGChatIcon;

simulated function PostBeginPlay ()
{
  Super.PostBeginPlay();
  bTalking = False;
  SetTimer(0.25,True);
}

simulated function Timer ()
{
  if ( Me != None )
  	{
    	if ( Me.bIsTyping &&  !bTalking )
	   		{
      			if ( Me.TeamBeaconTexture != None )
      				{
        				BeaconTexture = Me.TeamBeaconTexture;
        				Me.TeamBeaconTexture = None;
      				}
      			if ( KFARGChatIcon == None )
      				{
        				KFARGChatIcon = Spawn(Class'KFARGChatIcon',Me.Pawn);
        				
        				if ( KFARGChatIcon != None )
        					{
          						Me.Pawn.AttachToBone(KFARGChatIcon,'head');
        					}
      				}

      			bTalking = True;
    		}
    	else
    		{
      			if (  !Me.bIsTyping && bTalking )
      				{
        				if ( BeaconTexture != None )
        					{
          						Me.TeamBeaconTexture = BeaconTexture;
        					}
        				if ( KFARGChatIcon != None )
        					{
          						KFARGChatIcon.Destroy();
          						KFARGChatIcon = None;
        					}
        				bTalking = False;
      				}
    		}
  	}
  
  else
  	{
    	Me = PlayerController(Pawn(Owner).Controller);
  	}
}

simulated function Destroyed ()
{
	Super.Destroyed();
	if ( KFARGChatIcon != None )
		{
    		KFARGChatIcon.Destroy();
    		KFARGChatIcon = None;
  		}
}

defaultproperties
{
}
