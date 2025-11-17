/**
 * Author:      Marco
 * Home repo:   https://github.com/InsultingPros/BitCore
 */
class BitGameRep extends ReplicationInfo;

var BitGameRep Spectating;
var transient array<BitGameRep> RepList,Spectators;
var BitGameWindow ActiveWindow;
var PlayerController PlayerOwner;
var byte RequestID,SendOffset;
var transient HiScoresGame ReqGame;
var int ReqOffset,MaxOffset;
var class<GameSongBase> CurrentGame;
var bool bReceivedInitial;

replication {
    reliable if (Role == ROLE_Authority)
        RespondClientRank, ClientReceiveHS, ClientReceivedAll, ClientGetSpec,
        ClientBeginSpecMode, ClientReceiveSpec, ClientSectionChange,
        ClientModeChange, ClientInitialStats, ClientFireLaser;

    unreliable if (Role == ROLE_Authority)
        ClientBeatCombo, ClientStatsChange;

    reliable if (Role < ROLE_Authority)
        ServerClosedMenu, ServerSubmitScores, ServerReqScores, ServerStartedGame,
        ServerReqSpecs, ClientBeginSpectate, ServerChangeSec, ServerBeatCombo,
        ServerModeChange, ServerStatsChange, ServerInitialStats, ServerFireLaser;
}

function PostBeginPlay() {
    PlayerOwner = PlayerController(Owner);
}

simulated function PostNetBeginPlay() {
    if (
        Level.NetMode == NM_Client ||
        (PlayerOwner != none && Level.GetLocalPlayerController() == PlayerOwner)
    ) {
        Level.GetLocalPlayerController().ClientOpenMenu(string(class'BitGameWindow'));
        ActiveWindow = class'BitGameWindow'.default.NewMenu;
        class'BitGameWindow'.default.NewMenu = none;

        if (ActiveWindow != none) {
            ActiveWindow.RepActor = self;
        }
    }
}

simulated function Destroyed() {
    if (Level.NetMode != NM_Client && Spectating != none) {
        Spectating.EndSpectate(self);
    }

    if (ActiveWindow != none) {
        ActiveWindow.RepActor = none;
        GUIController(Level.GetLocalPlayerController().Player.GUIController).RemoveMenu(ActiveWindow, true);
        ActiveWindow = none;
    }
}

function ServerClosedMenu() {
    Destroy();
}

// Submit new highscore.
function ServerSubmitScores(class<GameSongBase> GameClass, int Score, byte Progress) {
    if (GameClass == none || GameClass == class'GameSongBase' || Score < 0 || Progress > 100) {
        return;
    }

    RespondClientRank(
        class'HiScoresManager'.static.SubmitNewScore(PlayerController(Owner),
            GameClass.name,
            Score,
            Progress
        )
    );
}

simulated function RespondClientRank(int Index) {
    if (ActiveWindow != none) {
        ActiveWindow.ClientRank = Index;
    }
}

// Client request for high score list.
simulated final function ClientCheckScores(class<GameSongBase> GameClass, int Offset) {
    ++RequestID;
    ServerReqScores(RequestID, GameClass, Offset);
}

function ServerReqScores(byte ReqID, class<GameSongBase> GameClass, int Offset) {
    if (GameClass == none || GameClass == class'GameSongBase' || Offset < 0 ) {
        return;
    }

    RequestID = ReqID;
    if (ReqGame == none || ReqGame.name != GameClass.name) {
        ReqGame = class'HiScoresManager'.static.FindScoresGame(GameClass.name);
    }

    if (Offset >= ReqGame.S.Length) {
        Offset = 0;
    }

    ReqOffset = Offset;
    MaxOffset = Min(ReqOffset + 20, ReqGame.S.Length);
    SendOffset = 0;
    GoToState('RepScores', 'Begin');
}

simulated function ClientReceiveHS(
    byte ReqID,
    byte ID,
    int Entry,
    string N,
    int Score,
    byte Progress
) {
    if (RequestID == ReqID && ActiveWindow != none) {
        if (ActiveWindow.HiScores.Length <= ID) {
            ActiveWindow.HiScores.Length = ID + 1;
        }

        ActiveWindow.HiScores[ID].Index = (Entry + 1);
        ActiveWindow.HiScores[ID].Score = Score;
        ActiveWindow.HiScores[ID].Progress = Progress;
        ActiveWindow.HiScores[ID].PlayerName = N;

        if (Entry < ActiveWindow.CurrentScorePage) {
            ActiveWindow.CurrentScorePage = Entry;
        }
    }
}

simulated function ClientReceivedAll(byte ReqID) {
    if (RequestID == ReqID && ActiveWindow != none) {
        ActiveWindow.bHighScoresReceived = true;
    }
}

// Inform server client started or ended a game.
function ServerStartedGame(class<GameSongBase> GameClass) {
    local int i;

    // End any spectators that are active.
    for (i = 0; i < Spectators.Length; ++i) {
        if (Spectators[i] != none) {
            Spectators[i--].SpectatePlayer(none);
        }
    }

    Spectators.Length = 0;
    CurrentGame = GameClass;
}

// Client request for spectate list.
simulated final function ClientCheckSpec() {
    ServerReqSpecs(++RequestID);
}

function ServerReqSpecs(byte ReqID) {
    local BitGameRep R;

    RequestID = ReqID;
    MaxOffset = 0;

    foreach DynamicActors(class'BitGameRep', R) {
        if (R != self && R.PlayerOwner != none) {
            if ((MaxOffset + 1) > RepList.Length) {
                RepList.Length = MaxOffset + 1;
            }

            RepList[MaxOffset++] = R;
        }
    }

    GoToState('RepSpectator','Begin');
}

simulated function ClientGetSpec(
    byte ReqID,
    PlayerReplicationInfo PRI,
    class<GameSongBase> GameType
) {
    local int i;

    if (RequestID != ReqID || PRI == none || ActiveWindow == none)   return;

    i = ActiveWindow.SpecClients.Length;
    ActiveWindow.SpecClients.Length = i + 1;
    ActiveWindow.SpecClients[i].PlayerName = PRI.PlayerName;

    if (GameType == none || GameType == class'GameSongBase') {
        ActiveWindow.SpecClients[i].ID = -1;
    } else {
        ActiveWindow.SpecClients[i].ID = PRI.PlayerID;
        ActiveWindow.SpecClients[i].GameName = GameType.default.StageName;
        ActiveWindow.SpecClients[i].CurrentGame = GameType;
    }
}

function ClientBeginSpectate(int PlayerID) {
    local BitGameRep R;

    foreach DynamicActors(class'BitGameRep', R) {
        if (
            R != self &&
            R.PlayerOwner != none &&
            R.PlayerOwner.PlayerReplicationInfo != none &&
            R.PlayerOwner.PlayerReplicationInfo.PlayerID == PlayerID
        ) {
            if (R.CurrentGame == none) {
                PlayerOwner.ClientMessage("Can't spectate this player: they're not in game.");
            } else {
                SpectatePlayer(R);
            }

            return;
        }
    }

    PlayerOwner.ClientMessage("Can't spectate this player: can't find the desired player.");
}

final function SpectatePlayer(BitGameRep Other) {
    if (Spectating == Other)    return;

    if (Spectating != none) {
        Spectating.EndSpectate(self);
    }

    Spectating = Other;
    bReceivedInitial = false;

    if (Spectating != none) {
        Spectating.BeginSpectate(self);
    }
}

final function BeginSpectate(BitGameRep Other) {
    local PlayerReplicationInfo PRI;

    Spectators[Spectators.Length] = Other;

    if (PlayerOwner != none && Other.PlayerOwner != none) {
        PRI = Other.PlayerOwner.PlayerReplicationInfo;
    }

    ClientReceiveSpec(Spectators.Length,PRI);
    Other.ClientBeginSpecMode(CurrentGame);
}

final function EndSpectate(BitGameRep Other) {
    local int i;

    for (i = (Spectators.Length - 1); i >= 0; --i) {
        if (Spectators[i] == Other || Spectators[i] == none) {
            Spectators.Remove(i, 1);
        }
    }

    ClientReceiveSpec(Spectators.Length, none);
    Other.ClientBeginSpecMode(none);
}

simulated function ClientBeginSpecMode(class<GameSongBase> GameClass) {
    if (ActiveWindow != none) {
        if (GameClass != none) {
            ActiveWindow.StartSpectateSong(GameClass);
        } else {
            ActiveWindow.EndSpectateSong();
        }
    }
}

simulated function ClientReceiveSpec(byte Total, PlayerReplicationInfo PRI) {
    if (ActiveWindow != none && ActiveWindow.IsPlayingGame()) {
        if (PRI != none) {
            Level.GetLocalPlayerController().ClientMessage(
                PRI.PlayerName $
                " has begun spectating you."
            );
        }

        ActiveWindow.NotifySpecCount(Total);
    }
}

// Spectator replication
function ServerChangeSec(byte Index) {
    local int i;

    for (i = (Spectators.Length - 1); i >= 0; --i) {
        Spectators[i].ClientSectionChange(Index);
    }
}

function ServerBeatCombo(byte X, byte Y, int Combo) {
    local int i;

    for (i = (Spectators.Length - 1); i >= 0; --i) {
        Spectators[i].ClientBeatCombo(X, Y, Combo);
    }
}

function ServerModeChange(byte Mode, bool bUp) {
    local int i;

    for (i = (Spectators.Length - 1); i >= 0; --i) {
        Spectators[i].ClientModeChange(Mode, bUp);
    }
}

function ServerStatsChange(int Combo, byte Multi, int Score) {
    local int i;

    for (i = (Spectators.Length - 1); i >= 0; --i) {
        Spectators[i].ClientStatsChange(Combo, Multi, Score);
    }
}

function ServerInitialStats(byte Section, float SecTime, byte Mode, int Score) {
    local int i;

    for (i = (Spectators.Length - 1); i >= 0; --i) {
        if (!Spectators[i].bReceivedInitial) {
            Spectators[i].bReceivedInitial = true;
            Spectators[i].ClientInitialStats(Section, SecTime, Mode, Score);
        }
    }
}

function ServerFireLaser(byte Dir, bool bRelease) {
    local int i;

    for (i = (Spectators.Length - 1); i >= 0; --i) {
        Spectators[i].ClientFireLaser(Dir, bRelease);
    }
}

simulated function ClientSectionChange(byte Index) {
    if (ActiveWindow != none && ActiveWindow.IsSpectatingGame()) {
        ActiveWindow.GC_Main.ChangeSongSection(Index);
    }
}

simulated function ClientBeatCombo(byte X, byte Y, int Combo) {
    local float FX, FY;

    if (ActiveWindow != none && ActiveWindow.IsSpectatingGame()) {
        FX = float(X) / 200.f;
        FY = float(Y) / 200.f;
        ActiveWindow.GC_Main.AddComboVis(FX, FY, Combo);
    }
}

simulated function ClientModeChange(byte Mode, bool bUp) {
    if (ActiveWindow != none && ActiveWindow.IsSpectatingGame()) {
        ActiveWindow.GC_Main.AlterMode(Mode, bUp);
    }
}

simulated function ClientStatsChange(int Combo, byte Multi, int Score) {
    if (ActiveWindow != none && ActiveWindow.IsSpectatingGame()) {
        ActiveWindow.GC_Main.BeatCombo = Combo;
        ActiveWindow.GC_Main.ScoreMultiplier = Multi;

        if (Score > ActiveWindow.GC_Main.PlayerScore) {
            // Using this function to allow visual FX for top scores.
            ActiveWindow.GC_Main.GiveScore(Score - ActiveWindow.GC_Main.PlayerScore);
        } else {
            ActiveWindow.GC_Main.PlayerScore = Score;
        }
    }
}

simulated function ClientInitialStats(byte Section, float SecTime, byte Mode, int Score) {
    if (ActiveWindow != none && ActiveWindow.IsSpectatingGame()) {
        ActiveWindow.GC_Main.PlayerScore = Score;
        ActiveWindow.GC_Main.PlayerModeNum = Mode;
        ActiveWindow.GC_Main.SetInitialOffset(Section, SecTime);
    }
}

simulated function ClientFireLaser(byte Dir, bool bRelease) {
    if (ActiveWindow != none && ActiveWindow.IsSpectatingGame()) {
        ActiveWindow.GC_Main.FireLaser(Dir, bRelease);
    }
}

auto state KeepAlive {
Begin:
    while (true) {
        Sleep(1.f);

        if (PlayerOwner == none || PlayerOwner.Player == none) {
            Destroy();
        }
    }
}

state RepScores {
Begin:
    while (ReqOffset < MaxOffset) {
        if (PlayerOwner == none || PlayerOwner.Player == none) {
            Destroy();
        }

        ClientReceiveHS(
            RequestID,
            SendOffset++,
            ReqOffset,
            class'HiScoresManager'.default.P[ReqGame.S[ReqOffset].P].N,
            ReqGame.S[ReqOffset].S,
            ReqGame.S[ReqOffset].G
        );
        ++ReqOffset;
        Sleep(0.01f);
    }

    ClientReceivedAll(RequestID);
    GoToState('KeepAlive');
}

state RepSpectator {
Begin:
    for (SendOffset = 0; SendOffset < MaxOffset; ++SendOffset) {
        if (PlayerOwner == none || PlayerOwner.Player == none) {
            Destroy();
        }

        if (RepList[SendOffset] != none && RepList[SendOffset].PlayerOwner != none) {
            ClientGetSpec(
                RequestID,
                RepList[SendOffset].PlayerOwner.PlayerReplicationInfo,
                RepList[SendOffset].CurrentGame
            );
        }

        Sleep(0.01f);
    }

    GoToState('KeepAlive');
}

defaultproperties {
    bAlwaysRelevant=false
    bSkipActorPropertyReplication=true
    bOnlyRelevantToOwner=true
    NetUpdateFrequency=4
    bOnlyDirtyReplication=true
}