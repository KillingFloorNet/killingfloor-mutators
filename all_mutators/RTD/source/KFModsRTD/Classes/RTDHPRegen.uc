//-----------------------------------------------------------
//
//-----------------------------------------------------------
class RTDHPRegen extends RTDFaceBase;

static simulated function ModifyPawn(Pawn Other)
{
    local int TTL;
    local InvRTDHPRegen RR;

    TTL = 10 + Rand(21); // 10-30 seconds of regen

    if (Other.Role != ROLE_Authority)
        return;

    RR = KFHumanPawn(Other).spawn(class'InvRTDHPRegen', Other,,,rot(0,0,0));
	RR.GiveTo(Other);
	RR.RegenAmount = 5;
	RR.SetInterval(1);
    RR.StartTimer(TTL);
}

defaultproperties
{
     CurrentMessage="found some healing herbs."
     CurrentPersonalMessage="You found some healing herbs. They'll regenerate your HP for a short amount of time."
     Message="found some healing herbs."
     PersonalMessage="You found some healing herbs. They'll regenerate your HP for a short amount of time."
     FaceType=1
}
