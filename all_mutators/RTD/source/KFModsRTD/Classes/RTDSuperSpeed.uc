//-----------------------------------------------------------
//
//-----------------------------------------------------------
class RTDSuperSpeed extends RTDFaceBase;

static simulated function ModifyPawn(Pawn Other)
{
    local int TTL;
    local float SpeedIncrease;
    local InvRTDSuperSpeed RR;

    TTL = 10 + Rand(21); // 10-30 seconds of super speed
    SpeedIncrease = 1150 + Rand(51); // 1.25-2x Speed
    SpeedIncrease = SpeedIncrease / 100; // To get a multiplier out of it :)

    if (Other.Role != ROLE_Authority)
        return;

    RR = KFHumanPawn(Other).spawn(class'InvRTDSuperSpeed', Other,,,rot(0,0,0));
	RR.GiveTo(Other);
	RR.SpeedIncrease = SpeedIncrease;
	RR.SetInterval(0.01);
    RR.StartTimer(TTL);
}

defaultproperties
{
     CurrentMessage="found a six-pack of Red Bull! ZZZZZING!!!"
     CurrentPersonalMessage="You feel faster. Enjoy the caffeine trip!"
     Message="found a six-pack of Red Bull! ZZZZZING!!!"
     PersonalMessage="You feel faster. Enjoy the caffiene trip!"
     FaceType=1
}
