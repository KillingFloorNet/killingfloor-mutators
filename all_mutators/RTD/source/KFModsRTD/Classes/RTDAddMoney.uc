//-----------------------------------------------------------
// Add Money dice face for the 'Roll The Dice' mutator
// by Sinnerg - sinnerg@kfmods.com - Copyright 2009
//-----------------------------------------------------------
class RTDAddMoney extends RTDFaceBase;

// The function gets triggered when a player gets this face
// up
static simulated function ModifyPawn(Pawn Other)
{
    local int AddMoney;

    // Check if we are running on the server side
    if (Other.Role != ROLE_Authority)
        return;

    // Calculate the amount money the player gets
    AddMoney = 100 + Rand(401); // Between 100-500 money

    // The amount of 'money' is stored in the 'Score' field
    // Give the player the additional money
    KFPlayerReplicationInfo( Other.PlayerReplicationInfo ).Score += AddMoney;

    // Set the message to be shown in the chat box
    // example: "has rolled the dice and... has found a bag of cash! Enjoy!"
    SetMessage(default.Message);

    // Set the message to be shown in the center of the screen
    // of the triggering player
    // example: "You gained £1000"
    SetPersonalMessage(default.PersonalMessage$AddMoney);
}

// Override the properties

defaultproperties
{
     Message="has found a bag of cash! Enjoy!"
     PersonalMessage="You gained £"
     FaceType=1
}
