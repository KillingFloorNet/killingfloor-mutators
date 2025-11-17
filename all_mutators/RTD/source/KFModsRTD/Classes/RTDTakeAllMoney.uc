//-----------------------------------------------------------
//
//-----------------------------------------------------------
class RTDTakeAllMoney extends RTDFaceBase;

static simulated function ModifyPawn(Pawn Other)
{
    if (Other.Role != ROLE_Authority)
        return;

    KFPlayerReplicationInfo( Other.PlayerReplicationInfo ).Score = 0;

    class'RTDAddMoney'.default.CurrentPersonalMessage=class'RTDAddMoney'.default.PersonalMessage;

}

defaultproperties
{
     CurrentMessage="lost all his money on gambling! Better luck next time!"
     CurrentPersonalMessage="You lost all your money!"
     Message="lost all his money on gambling! Better luck next time!"
     PersonalMessage="You lost all your money!"
     FaceType=3
}
