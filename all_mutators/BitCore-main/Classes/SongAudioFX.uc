/**
 * Author:      Marco
 * Home repo:   https://github.com/InsultingPros/BitCore
 */
class SongAudioFX extends Info
    transient;

var PlayerController LocalPlayer;

function PostBeginPlay() {
    LocalPlayer = Level.GetLocalPlayerController();
}

function Tick(float Delta) {
    SetLocation(LocalPlayer.CalcViewLocation);
}

final function ChangeModeNum(byte Num) {
    if (Num == 0) {
        SoundVolume = 64;
    } else {
        SoundVolume = 255;
    }
}

defaultproperties {
    RemoteRole=ROLE_None
    SoundRadius=99999
    SoundOcclusion=OCCLUSION_None
    SoundVolume=255
    bFullVolume=true
    TransientSoundVolume=1
    TransientSoundRadius=9999
}