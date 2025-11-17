class GH_GRI extends KFGameReplicationInfo;


var private float RemainingSpawnPct[2];


replication
{
  reliable if (Role == ROLE_Authority && bNetDirty)
    RemainingSpawnPct;
}


// Accessor functions for retrieving the value of RemainingSpawnPoints
function SetRemainingSpawns(byte TeamNum, int Amount)
{
  RemainingSpawnPct[TeamNum] = Amount;
}


simulated function float GetRemainingSpawns(byte TeamNum)
{
  return RemainingSpawnPct[TeamNum];
}


defaultproperties{}