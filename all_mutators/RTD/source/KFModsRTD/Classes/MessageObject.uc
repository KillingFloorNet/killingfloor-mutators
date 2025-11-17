//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MessageObject extends Actor;
var string Message;
replication
{
  reliable if ( Role == ROLE_Authority )
    Message;
}
function BeginPlay()
{
    SetTimer(10, false);


}

function Timer()
{
    Destroy();
}

defaultproperties
{
     Message="Default message"
}
