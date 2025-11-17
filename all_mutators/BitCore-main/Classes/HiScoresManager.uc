/**
 * Author:      Marco
 * Home repo:   https://github.com/InsultingPros/BitCore
 */
class HiScoresManager extends Object
    config(BitCoreScores);

struct FPlayerEntry {
    var config string N, I;
};
var config array<FPlayerEntry> P;
var config int MaxScoreEntires;
var transient array<HiScoresGame> Ref;
var bool bDirty;

static final function int SubmitNewScore(
    PlayerController PC,
    name GameName,
    int Score,
    byte Progress
) {
    local HiScoresGame S;
    local int i, N, j;

    N = GetPlayerByID(PC.GetPlayerIDHash(), PC.PlayerReplicationInfo.PlayerName);
    S = FindScoresGame(GameName);

    for (i = 0; i < S.S.Length; ++i) {
        if (Score >= S.S[i].S) {
            S.S.Insert(i, 1);

            // Remove old record.
            for (j = (i + 1); j < S.S.Length; ++j) {
                if (N == S.S[j].P) {
                    S.S.Remove(j, 1);
                    break;
                }
            }
            break;
        }
        // Has old record with better score.
        else if (N == S.S[i].P) {
            return -2;
        }
    }

    if (i == S.S.Length) {
        if (i >= default.MaxScoreEntires) {
            return -1;
        }

        S.S.Length = i + 1;
    }

    // Prune any excessive entries.
    if (S.S.Length > default.MaxScoreEntires) {
        S.S.Length = default.MaxScoreEntires;
    }

    // Add/update player entry.
    if (N == -1) {
        N = GetPlayerByID(PC.GetPlayerIDHash(), PC.PlayerReplicationInfo.PlayerName, true);
    }
    S.S[i].P = N;
    S.S[i].S = Score;
    S.S[i].G = Progress;
    S.SaveConfig();

    if (default.bDirty) {
        default.bDirty = false;
        StaticSaveConfig();
    }

    return i + 1;
}

static final function int GetPlayerByID(string ID, string N, optional bool bAdd) {
    local int i;

    for (i = (default.P.Length - 1); i >= 0; --i) {
        if (default.P[i].I == ID) {
            if (default.P[i].N != N) {
                default.P[i].N = N;
                default.bDirty = true;
            }
            break;
        }
    }

    if (i == -1 && bAdd) {
        i = default.P.Length;
        default.P.Length = i + 1;
        default.P[i].N = N;
        default.P[i].I = ID;
        default.bDirty = true;
    }

    return i;
}

static final function HiScoresGame FindScoresGame(name N) {
    local int i;

    for (i = (default.Ref.Length - 1); i >= 0; --i) {
        if (default.Ref[i].name == N)   break;
    }

    if (i < 0) {
        i = default.Ref.Length;
        default.Ref.Length = i + 1;
        default.Ref[i] = new (none, string(N)) class'HiScoresGame';
    }

    return default.Ref[i];
}

defaultproperties {
    MaxScoreEntires=100
}