// CustomServerDetails Extension example
// Author        : Shtoyan
// Home Repo     : https://github.com/InsultingPros/CustomServerDetailsExtension
// License       : https://www.gnu.org/licenses/gpl-3.0.en.html
class CustomServerDetailsExtension extends base_GR;

function getServerDetails(out GameInfo.serverResponseLine serverState) {
    // let's inject game difficulty to server info
    if (kfgt != none) {
        addSD(serverState, "Difficulty", GetDifficultyName(kfgt.GameDifficulty));
    }
}

private final function string GetDifficultyName(float GameDifficulty) {
    switch (GameDifficulty) {
        case 1.0:
            return "Beginner";
        case 2.0:
            return "Normal";
        case 4.0:
            return "Hard";
        case 5.0:
            return "Suicidal";
        case 7.0:
            return "HOE";
        default:
            return "UNKNOWN DIFFICULTY";
    }
}