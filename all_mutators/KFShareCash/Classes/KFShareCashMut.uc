////////////////////////////////////////////
//                                        //
// Share Cash Mutator 1.0 - (c) by Mutant //
//                                        //
////////////////////////////////////////////
class KFShareCashMut extends Mutator;

var private int StartingCash;

event PostBeginPlay()
{
     if ( KFGameType(Level.Game) != None )
          StartingCash = KFGameType(Level.Game).StartingCash;

}

function NotifyLogout(Controller Exiting)
{
     local PlayerReplicationInfo PRI;
     local Controller C;
     local array<Controller> shareWith;
     local int cash;
     local int i, l;

     PRI = Exiting.PlayerReplicationInfo;
     if ( KFGameType(Level.Game) != None && Exiting.bIsPlayer && PRI != None && PRI.Score > StartingCash )
     {
          cash = PRI.Score;

          for( C=Level.ControllerList; C!=None; C=C.NextController )
          {
               PRI = C.PlayerReplicationInfo;
               if ( C != Exiting && C.bIsPlayer && PRI != None && !PRI.bOutOfLives && !PRI.bIsSpectator )
               {
                    shareWith[l] = C;
                    l++;
               }
          }

          if ( l > 0 && cash > 0 )
          {
               cash /= l;

               for ( i=0; i<l; i++ )
               {
                    shareWith[i].PlayerReplicationInfo.Score += cash;

                    if ( PlayerController(shareWith[i]) != None )
                         PlayerController(shareWith[i]).ReceiveLocalizedMessage(class'KFShareCash.KFCashAward', cash);
               }
          }
     }

     Super.NotifyLogout(Exiting);
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-ShareCash"
     FriendlyName="Share Cash"
     Description="Shares the money of exiting players with all other teammates alive."
}
