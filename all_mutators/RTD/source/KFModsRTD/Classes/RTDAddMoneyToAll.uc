//-----------------------------------------------------------
// Add Money dice face for the 'Roll The Dice' mutator
// by Sinnerg - sinnerg@kfmods.com - Copyright 2009
//-----------------------------------------------------------
class RTDAddMoneyToAll extends RTDFaceBase;

// The function gets triggered when a player gets this face
// up
static simulated function ModifyPawn(Pawn Other)
{
    local int AddMoney;
    local PlayerController P;

    // Check if we are running on the server side
    if (Other.Role != ROLE_Authority)
        return;

    // Calculate the amount money the player gets
    AddMoney = 100 + Rand(401); // Between 100-500 money
	ForEach Other.DynamicActors(class'PlayerController', P)
	{
        if ((P.Pawn != None) && (KFHumanPawn(P.Pawn) != None) && (P.Pawn.PlayerReplicationInfo != None) && (P.Pawn.Health > 0))
        {
            // The amount of 'money' is stored in the 'Score' field
            // Give the player the additional money
            KFPlayerReplicationInfo( P.Pawn.PlayerReplicationInfo ).Score += AddMoney;
        }
	}

    // Set the message to be shown in the chat box
    SetMessage(default.Message);

    // Set the message to be shown in the center of the screen
    // of the triggering player
    SetPersonalMessage(default.PersonalMessage);
}

// Override the properties

defaultproperties
{
     Message="found a dumpster full of money and decides to share the wealth! Money money money!"
     PersonalMessage="You just found a dumpster full of money and felt like sharing."
     FaceType=5
}
