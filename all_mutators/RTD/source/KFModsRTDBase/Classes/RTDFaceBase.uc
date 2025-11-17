//-----------------------------------------------------------
// RTDFaceBase
// by Sinnerg - sinnerg@kfmods.com - Copyright 2009
//
// Use this to create new 'faces' for the rtd's dice
//-----------------------------------------------------------
class RTDFaceBase extends Object;

// These 2 store the message that will be shown after the
// ModifyPawn() is called - modify them using SetMessage()
// and SetPlayerMessage()
var localized string CurrentMessage;
var localized string CurrentPersonalMessage;

// You can use these 2 to store the base text
// Example in default section add:
// Message = "gained a big bag of money!"
// PersonalMessage = "You just gained £"
var string Message;
var string PersonalMessage;

//    Possible Face Types: (is it good / bad / ...)
//
//    0   Very Good
//    1   Good
//    2   Bad
//    3   Very Bad
//    4   Neutral
//    5   Global Good   (Affects more than the player itself)
//    6   Global Bad    (Affects more than the player itself)
var() int FaceType;

//-----------------------------------------------------------
// Override this function. It'll get triggered when 'Other'
// gets this dice 'face' up
//
// Override this! - Default doesn't do much :)
//-----------------------------------------------------------
static simulated function ModifyPawn(Pawn Other)
{
    // Check if we are running on the server side
    if (Other.Role != ROLE_Authority)
        return; // No we are not

    // Message to show in the chat screen
    SetMessage(default.Message);
    // Message to show in the center of player who did the !rtd
    SetPersonalMessage(default.PersonalMessage);
}

//-----------------------------------------------------------
// Used to show a message to the player (on the center of his
// screen)
//-----------------------------------------------------------
static function MessagePlayer( PlayerController C, string Msg)
{
    Msg = right(Msg,len(Msg)-1);
    C.ClearProgressMessages();
	C.SetProgressTime(6);
	C.SetProgressMessage(0, ""@Msg, class'Canvas'.Static.MakeColor(255,255,255));
}

//-----------------------------------------------------------
// Call this within ModifyPawn() to change what message will
// be shown in the chat log (after the " rolls the dice and "
// message
//-----------------------------------------------------------
static function SetMessage(string message)
{
    default.CurrentMessage=message;
}

//-----------------------------------------------------------
// Call this within ModifyPawn() to change what message will
// be shown to the triggering player in the center of his
// screen
//-----------------------------------------------------------
static function SetPersonalMessage(string message)
{
    default.CurrentPersonalMessage=message;
}

// Define our defaults

defaultproperties
{
     Message="nothing happened! Better luck next time!"
     PersonalMessage="Nothing happened! :("
     FaceType=4
}
