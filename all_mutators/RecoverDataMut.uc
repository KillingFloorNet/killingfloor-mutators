Class RecoverDataMut extends Mutator;

struct RecoverDataStruct
{
    var string Hash;
    var int StartTime;
    var int Cash;
    var int Kills;
    var bool bDoNotUpdate;
};
var array<RecoverDataStruct> Data;
var array<PlayerController> PendingPlayers;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    if(PlayerController(Other)!=None)
    {
        PendingPlayers[PendingPlayers.Length]=PlayerController(Other);
        SetTimer(0.1, False);
    }
    Return True;
}

function Timer()
{
    local RecoverDataStruct rds;
    local PlayerController PC;
    local string Hash;
    local int i, N;
    for(i=PendingPlayers.Length-1; i>=0; i--)
    {
        PC=PendingPlayers[i];
        if(PC!=None && PC.PlayerReplicationInfo!=None && PC.PlayerReplicationInfo.PlayerID>0)
        {
            Hash=PC.GetPlayerIDHash();
            N=PlayerPosInList(Hash);
            if(N<0)
            {
                rds.Hash=Hash;
                rds.StartTime=PC.PlayerReplicationInfo.StartTime;
                rds.Cash=PC.PlayerReplicationInfo.Score;
                rds.Kills=PC.PlayerReplicationInfo.Kills;
                Data[Data.Length]=rds;
            }
            else
            {
                Data[N].bDoNotUpdate=True;
                PC.PlayerReplicationInfo.StartTime=Data[N].StartTime;
                PC.PlayerReplicationInfo.Score=Data[N].Cash;
                PC.PlayerReplicationInfo.Kills=Data[N].Kills;
            }
        }
    }
    PendingPlayers.Length=0;
}

function NotifyLogout(Controller Exiting)
{
    local PlayerController PC;
    local string Hash;
    local int N;
    if(PlayerController(Exiting)!=None) PC=PlayerController(Exiting);
    if(PC!=None && PC.PlayerReplicationInfo!=None && PC.PlayerReplicationInfo.PlayerID>0)
    {
        Hash=PC.GetPlayerIDHash();
        N=PlayerPosInList(Hash);
        if(N>=0 && !Data[N].bDoNotUpdate) // ?
        {
            Data[N].Cash=PC.PlayerReplicationInfo.Score;
            Data[N].Kills=PC.PlayerReplicationInfo.Kills;
        }
    }
}

function int PlayerPosInList(string Hash)
{
    local int i;
    for(i=0; i<Data.Length; i++) if(Hash~=Data[i].Hash) Return i;
    Return -1;
}

defaultproperties
{
    GroupName="KF-RecoverData"
    FriendlyName="RecoverDataMut"
    Description="RecoverDataMut"
}