class MutGameType extends KFGameType;

var bool StupidKFManiacsCanSuckMyDick;
var int MatchOverDelay;


state MatchOver
{
  function Timer ()
  {
    local Controller C;

    if ( MatchOverDelay > 0 )
    {
      MatchOverDelay--;
      return;
    }

    if ( !StupidKFManiacsCanSuckMyDick && (WaveNum != FinalWave) )
    {
      StupidKFManiacsCanSuckMyDick = True;
      KillZeds();
      TotalMaxMonsters = 0;
      NumMonsters = 0;

      if ( InvasionGameReplicationInfo(GameReplicationInfo)!=None )
        InvasionGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum - 1;
      
      InitialWave = WaveNum - 1;
      
      if ( KFGameReplicationInfo(GameReplicationInfo)!=None )
        KFGameReplicationInfo(GameReplicationInfo).EndGameType = 0;
      
      StartMatch();
      bWaveInProgress = False;
      
      for ( C = Level.ControllerList; C != none; C = C.NextController )
      {
        if ( C.PlayerReplicationInfo!=None && !C.PlayerReplicationInfo.bOnlySpectator )
        {
          C.PlayerReplicationInfo.Score = Max(MinRespawnCash,int(C.PlayerReplicationInfo.Score));
          if ( PlayerController(C) != None )
          {
          PlayerController(C).GotoState('PlayerWaiting');
          PlayerController(C).SetViewTarget(C);
          PlayerController(C).ClientSetBehindView(False);
          PlayerController(C).bBehindView = False;
          PlayerController(C).ClientSetViewTarget(C.Pawn);
          C.PlayerReplicationInfo.bOutOfLives = False;
          C.PlayerReplicationInfo.NumLives = 1;
          }
          C.ServerReStartPlayer();
        }
      }
      bWaveInProgress = True;
    }
    else
    Super.Timer();
  }
}

defaultproperties
{
  MatchOverDelay = 6
}