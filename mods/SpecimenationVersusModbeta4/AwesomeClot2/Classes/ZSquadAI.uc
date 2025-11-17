class ZSquadAI extends KFSquad;



function bool AssignSquadResponsibility(Bot B) 
{
	
	if ( PlayerController(SquadLeader) != None && PlayerController(SquadLeader).pawn!=none && PlayerController(SquadLeader).pawn.isa('kfmonster'))
	   squadleader = none;
	   
	if( zombiegametype(Level.game).Lure != none && !B.isinstate('TraderHunt') )
					{
						ZBot(B).GoToTrader();
						return true;
					}
	else if ( (SquadObjective == None) || SquadObjective.bDisabled || !SquadObjective.bActive || !UnrealMPGameInfo(Level.Game).CanDisableObjective( SquadObjective ) )
    {
        Team.AI.FindNewObjectiveFor(self,true);
        if ( (SquadObjective == None) || SquadObjective.bDisabled || !SquadObjective.bActive )
        {
            if ( (PlayerController(SquadLeader) != None)  )
            {
                return TellBotToFollow(B,SquadLeader);
            }
            else if ( B.Enemy == None && B.Pawn !=none && !B.Pawn.bStationary )
            {
                // suggest inventory hunt
                if ( B.FindInventoryGoal(0) )
                {
                    B.SetAttractionState();
                    return true;
                }
            }
            
            	

            return false;
        }
    }
	
       return super.AssignSquadResponsibility(b);
}

defaultproperties
{
     GatherThreshold=0.000000
     MaxSquadSize=3
     bRoamingSquad=False
     bAddTransientCosts=True
}
