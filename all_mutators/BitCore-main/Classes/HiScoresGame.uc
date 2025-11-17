/**
 * Author:      Marco
 * Home repo:   https://github.com/InsultingPros/BitCore
 */
class HiScoresGame extends Object
    PerObjectConfig
    config(BitCoreScores);

struct FScoreEntry {
    var config int P, S;
    var config byte G;
};
var config array<FScoreEntry> S;