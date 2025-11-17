//-----------------------------------------------------------
// Base for catching chat messages
//-----------------------------------------------------------
class ChatterSpectator extends MessagingSpectator dependson(MutChatter);
var array<ChatterListener> Listeners;
event PostBeginPlay()
{
  Super.PostBeginPlay();
}


//== InitPlayerReplicationInfo ================================================
/**
Initialize the PRI.
*/
//=============================================================================

function InitPlayerReplicationInfo()
{
  Super.InitPlayerReplicationInfo();

  PlayerReplicationInfo.PlayerName = "ChatterSpectator";

}

//== ClientVoiceMessage =======================================================
/**
@ignore.
*/
//=============================================================================

//function ClientVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID);
//function ClientVoiceMessage(
//== TeamMessage ==============================================================
/**
Forward the chat message.
*/
//=============================================================================

function TeamMessage(PlayerReplicationInfo PRI, coerce string Message, name Type)
{

  if ( PRI != None && PRI != PlayerReplicationInfo )
  {
    ProcessMessage(PRI, Message, Type);
    return;
  }
}
 /*
static function AddListener(ChatterListener listener)
{
    MutChatter.static.AddListener(listener);
}
 */
function ProcessMessage(PlayerReplicationInfo PRI, coerce string Message, name Type)
{
    local int i;

    for (i = 0;i < Listeners.Length; i++)
    {
        if (Listeners[i] == None)
            continue;

        Listeners[i].OnMessage(Message, Type, PRI);
    }
}
/*
function ClientMessage(coerce string Message, optional name Type)
{

}

function ReceiveLocalizedMessage(class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{

}

function RoundHasEnded()
{

}
*/

defaultproperties
{
}
