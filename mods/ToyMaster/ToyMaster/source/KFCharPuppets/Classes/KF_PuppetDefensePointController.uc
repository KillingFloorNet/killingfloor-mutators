class KF_PuppetDefensePointController extends AIController;

function InitPlayerReplicationInfo()
{
    super.InitPlayerReplicationInfo();
    PlayerReplicationInfo.SetPlayerName("Magic Crystal");
}

function MatchStarting()
{
    super.MatchStarting();
    if(PlayerReplicationInfo != none)
    {
        PlayerReplicationInfo.bOutOfLives = true;
    }
}

defaultproperties
{
     bIsPlayer=True
     PlayerReplicationInfoClass=Class'KFMod.KFPlayerReplicationInfo'
}
