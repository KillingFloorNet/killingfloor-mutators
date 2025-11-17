//================================================================================
// KFARGChatIcon
//================================================================================

class KFARGChatIcon extends Actor;


function PostBeginPlay ()
{
	if ( Level.Game.bTeamGame )
		{
    		if ( (Pawn(Owner) != None) && (Pawn(Owner).PlayerReplicationInfo.Team.TeamIndex == 0) )
    			{
      				Texture = Texture'Chat';
    			}
  		}
}

defaultproperties
{
     Texture=Texture'KFARGChat.Chat'
     DrawScale=0.500000
     Style=STY_Masked
}
