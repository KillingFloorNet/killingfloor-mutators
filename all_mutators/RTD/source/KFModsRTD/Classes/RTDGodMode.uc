//-----------------------------------------------------------
//
//-----------------------------------------------------------
class RTDGodMode extends RTDFaceBase;

static simulated function ModifyPawn(Pawn Other)
{
    local int TTL;
    local InvGodMode RR;

    TTL = 10 + Rand(21); // 10-30 seconds of godmode

    if (Other.Role != ROLE_Authority)
        return;

    RR = KFHumanPawn(Other).spawn(class'InvGodMode', Other,,,rot(0,0,0));
	RR.GiveTo(Other);
    RR.InitTimer(TTL);

    class'RTDGodMode'.default.CurrentPersonalMessage=class'RTDGodMode'.default.PersonalMessage@TTL@"seconds!";
}

defaultproperties
{
     CurrentMessage="has reached divinity! G-G-G-GOD MODE!"
     Message="has reached divinity! G-G-G-GOD MODE!"
     PersonalMessage="You are now invincible for"
     FaceType=0
}
