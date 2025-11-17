//-----------------------------------------------------------
// Add Money dice face for the 'Roll The Dice' mutator
// by Sinnerg - sinnerg@kfmods.com - Copyright 2009
//-----------------------------------------------------------
class RTDSantaHat extends RTDFaceBase;

// The function gets triggered when a player gets this face
// up
static simulated function ModifyPawn(Pawn Other)
{
    // Check if we are running on the server side
    if (Other.Role != ROLE_Authority)
        return;


    // Set the message to be shown in the chat box
    SetMessage(default.Message);

    // Set the message to be shown in the center of the screen
    // of the triggering player
    SetPersonalMessage(default.PersonalMessage);

    ModifyPlayer(Other);
}
static function ModifyPlayer(Pawn Other)
{
    local ActorSantaHat SH;
    local xPawn ThePawn;
	local string SkelName, MeshName;

    if(xPawn(Other) != None)
    {
    	ThePawn = xPawn(Other);
    	SkelName = ThePawn.Species.static.GetRagSkelName(ThePawn.GetMeshName());
    	MeshName = string(ThePawn.Mesh);

        SH = Other.Spawn(class'ActorSantaHat',Other);
        ThePawn.AttachToBone(SH,'Head');

        if(SkelName == "Female2")
        {
            if(MeshName == "HumanFemaleA.EgyptFemaleB")
                SH.SetRelativeLocation(vect(30,5,0));
            else if(MeshName == "HumanFemaleA.MercFemaleB")
                SH.SetRelativeLocation(vect(15,2,0));
            else if(MeshName == "HumanFemaleA.NightFemaleA")
                SH.SetRelativeLocation(vect(16,0,0));
            else if(MeshName == "ThunderCrash.MercFemale2")
                SH.SetRelativeLocation(vect(15,1,-1));
            else if(MeshName == "Hellions.Hellion_Gitty")
                SH.SetRelativeLocation(vect(14,1,0));
            else if(MeshName == "NewNightmare.Ophelia")
                SH.SetRelativeLocation(vect(22,-2,0));
            else
                SH.SetRelativeLocation(vect(16,3,0));
        }
        else if(SkelName == "Skaarj")
        {
            if(MeshName == "SkaarjAnims.SkaarjUT2004")
                SH.SetRelativeLocation(vect(22,-3,0));
            else if(MeshName == "SkaarjAnims.Skaarj2")
                SH.SetRelativeLocation(vect(22,-3,0));
            else if(MeshName == "SkaarjAnims.Skaarj3")
                SH.SetRelativeLocation(vect(22,-3,0));
            else if(MeshName == "SkaarjAnims.Skaarj4")
                SH.SetRelativeLocation(vect(22,-3,0));
            else
                SH.SetRelativeLocation(vect(26,3,0));
        }
        else if(SkelName == "Male2")
        {
            if(MeshName == "HumanMaleA.EgyptMaleA")
                SH.SetRelativeLocation(vect(22,-2,0));
            else if(MeshName == "HumanMaleA.EgyptMaleB")
                SH.SetRelativeLocation(vect(24,-2,0));
            else if(MeshName == "HumanMaleA.MercMaleB")
                SH.SetRelativeLocation(vect(20,0,0));
            else if(MeshName == "HumanMaleA.NightMaleB")
                SH.SetRelativeLocation(vect(40,0,-2));
            else if(MeshName == "ThunderCrash.Mercfemale1")
                SH.SetRelativeLocation(vect(23,7,0));
            else if(MeshName == "Hellions.Hellion_Garrett")
                SH.SetRelativeLocation(vect(22,-2,0));
            else if(MeshName == "Hellions.Hellion_Kane")
                SH.SetRelativeLocation(vect(20,-2,0));
            else
                SH.SetRelativeLocation(vect(18,-2,0));
        }
        else if(SkelName == "Jugg2")
        {
            if(MeshName == "Jugg.JuggFemaleB")
                SH.SetRelativeLocation(vect(22,2,0));
            else
                SH.SetRelativeLocation(vect(20,-2,0));
        }
        else if(SkelName == "Alien2")
        {
            if(MeshName == "Aliens.AlienFemaleA")
                SH.SetRelativeLocation(vect(24,0,0));
            else if(MeshName == "Aliens.AlienMaleB")
                SH.SetRelativeLocation(vect(25,0,0));
            else if(MeshName == "Aliens.AlienFemaleB")
                SH.SetRelativeLocation(vect(27,1,0));
            else
                SH.SetRelativeLocation(vect(22,0,0));
        }
        else if(SkelName == "Bot2")
        {
            if(MeshName == "Bot.BotB")
                SH.SetRelativeLocation(vect(12,0,0));
            else if(MeshName == "Bot.BotD")
                SH.SetRelativeLocation(vect(17,-3,0));
            else if(MeshName == "XanRobots.XanM02")
                SH.SetRelativeLocation(vect(20,0,0));
            else if(MeshName == "XanRobots.EnigmaM")
                SH.SetRelativeLocation(vect(20,0,0));
            else if(MeshName == "XanRobots.XanF02")
                SH.SetRelativeLocation(vect(18,0,0));
            else if(MeshName == "XanRobots.XanM03")
                SH.SetRelativeLocation(vect(22,0,0));
            else
                SH.SetRelativeLocation(vect(15,0,0));
        }

        SH.SetRelativeLocation(vect(8,-1.5,0));
        SH.SetRelativeRotation(rot(-16384,0,0));
    /*
        if(MeshName == "HumanFemaleA.EgyptFemaleB")
            SH.SetRelativeRotation(rot(-16384,5000,0));
        else if(MeshName == "HumanMaleA.NightMaleB")
            SH.SetRelativeRotation(rot(-16384,2000,0));
        else if(MeshName == "SkaarjAnims.SkaarjUT2004")
            SH.SetRelativeRotation(rot(-16384,3000,0));
        else if(MeshName == "SkaarjAnims.Skaarj2")
            SH.SetRelativeRotation(rot(-16384,3000,0));
        else if(MeshName == "SkaarjAnims.Skaarj3")
            SH.SetRelativeRotation(rot(-16384,3000,0));
        else if(MeshName == "SkaarjAnims.Skaarj4")
            SH.SetRelativeRotation(rot(-16384,3000,0));
        else if(MeshName == "ThunderCrash.MercFemale2")
            SH.SetRelativeRotation(rot(-16384,7000,0));
        else if(MeshName == "Hellions.Hellion__Female_Rae")
            SH.SetRelativeRotation(rot(-16384,3000,0));
        else if(MeshName == "Hellions.Hellion_Gitty")
            SH.SetRelativeRotation(rot(-16384,3000,0));
        else if(MeshName == "Hellions.Hellion_Garrett")
            SH.SetRelativeRotation(rot(-16384,3000,0));
        else
            SH.SetRelativeRotation(rot(-16384,0,0));  */
    }
}

// Override the properties

defaultproperties
{
     Message="has found santa's hat! Ho ho ho!"
     PersonalMessage="You put on santa's hat."
}
