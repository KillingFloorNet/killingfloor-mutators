//-----------------------------------------------------------
// Add Money dice face for the 'Roll The Dice' mutator
// by Sinnerg - sinnerg@kfmods.com - Copyright 2009
//-----------------------------------------------------------
class RTDAddAmmo extends RTDFaceBase;

// The function gets triggered when a player gets this face
// up
static simulated function ModifyPawn(Pawn Other)
{
    local int AddAmmo;

    // Check if we are running on the server side
    if (Other.Role != ROLE_Authority)
        return;

    // Calculate the amount (%) of ammo the player gets (per gun/weapon)
    AddAmmo = 10 + Rand(51); // Between 10-50% ammo

    GiveAmmo(Other, AddAmmo);

    // Set the message to be shown in the chat box
    SetMessage(default.Message);

    // Set the message to be shown in the center of the screen
    // of the triggering player
    SetPersonalMessage(default.PersonalMessage);
}

static function GiveAmmo(Pawn pawn,float Percentage)
{
    local KFHumanPawn human;
    Local Inventory Inv;

    human =  KFHumanPawn(pawn);

	for (Inv = human.Inventory; Inv != None; Inv = Inv.Inventory)
	{
	    if ((KFAmmunition(Inv) != None) && (KFAmmunition(Inv).AmmoAmount < KFAmmunition(Inv).MaxAmmo))// && (FragAmmo(Inv) == None) )
	    {
	       KFAmmunition(Inv).AmmoAmount += KFAmmunition(Inv).MaxAmmo / 100 * Percentage;
	       if (KFAmmunition(Inv).AmmoAmount > KFAmmunition(Inv).MaxAmmo)
	           KFAmmunition(Inv).AmmoAmount = KFAmmunition(Inv).MaxAmmo;
	    }
	}
}

// Override the properties

defaultproperties
{
     Message="found some ammo!"
     PersonalMessage="You have found some ammo. Enjoy!"
     FaceType=1
}
