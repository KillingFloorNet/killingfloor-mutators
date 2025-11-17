/**
 * Author:      Marco
 * Home repo:   https://github.com/InsultingPros/BitCore
 */
class GameSongBase extends Object
    abstract
    config(User);

#exec Texture Import File=Textures\GradColor.pcx name=BG_GradColor Mips=Off
#exec Texture Import File=Textures\CubeLine.pcx name=BG_CubeLine Mips=Off MASKED=1 ALPHA=1
#exec Texture Import File=Textures\Dot_C.pcx name=BG_DotC Mips=Off

var Material BGMaterials[3];

struct FModeLevel {
    var() array<Sound> FX;
    var() int Up, Down;
    var() bool bExplosions;
};
var() array<FModeLevel> Modes;

struct FSongSection {
    var() Sound FX;
    var() float BeatsDuration;
    var transient float ActualDuration;
};
var() array<FSongSection> Sections;
var() array<byte> SongOrder;

struct FBeatEntry {
    var byte Type, PCount;
    var int PBeat;
    var float SX, SY, EX, EY, AnTime, BegTime, Sine, WS, SinOf;
    var transient float CalcAnTime, CalcBegTime;
};
var() array<FBeatEntry> BeatList;
var() float BeatsPerMin, ChallengeLength;
var() int StartingBeatIndex;
var() localized string StageName;
var transient float CalcBeatsPerMin;
var transient bool bHasInit;
var config bool bCompleted;

static function InitSong() {
    local int i;

    default.bHasInit = true;
    default.CalcBeatsPerMin = 60.f / default.BeatsPerMin;

    for (i = 0; i < default.Sections.Length; ++i) {
        default.Sections[i].ActualDuration = default.Sections[i].BeatsDuration * default.CalcBeatsPerMin;
    }

    for (i = 0; i < default.BeatList.Length; ++i) {
        InitBeat(i);
    }
}

static function WriteSongProperties(FileLog L) {
    local int i;
    local FBeatEntry B;
    local string S;

    L.Logf(Chr(9) $ "StartingBeatIndex=" $ default.StartingBeatIndex);
    L.Logf("");

    for (i = 0; i < default.SongOrder.Length; ++i) {
        L.Logf(Chr(9) $ "SongOrder(" $ i $ ")=" $ default.SongOrder[i]);
    }

    L.Logf("");

    for (i = 0; i < default.BeatList.Length; ++i) {
        B = default.BeatList[i];
        S = "Type=" $ B.Type $ ",SX=" $ B.SX $ ",SY=" $ B.SY $ ",EX=" $ B.EX $ ",EY=" $ B.EY $ ",AnTime=" $ B.AnTime;

        if (i >= default.StartingBeatIndex) {
            S $= ",BegTime=" $ B.BegTime;
        }

        if (B.PCount > 0) {
            S $= ",PBeat=" $ B.PBeat $ ",PCount=" $ B.PCount;
        }

        // For waver and roller, add sine and radius
        if (B.Type == 4 || B.Type == 5 || B.Type == 9) {
            S $= ",Sine=" $ B.Sine $ ",WS=" $ B.WS;

            if (B.SinOf != 0) {
                S $= ",SinOf=" $ B.SinOf;
            }
        }
        // Add challenge type.
        else if (B.Type == 11) {
            S $= ",Sine=" $ int(B.Sine);
        }

        L.Logf(Chr(9) $ "BeatList(" $ i $ ")=(" $ S $ ")");
    }
}

static function int AddNewBeat(
    float StartTime,
    float ScreenTime,
    float StartX,
    float StartY,
    float EndX,
    float EndY,
    byte BeatType,
    out int iParent
) {
    local int i, j;

    if (iParent >= 0) {
        StartTime = 0.f;

        if (default.BeatList[iParent].PCount == 0) {
            i = default.StartingBeatIndex;
            default.BeatList[iParent].PBeat = i;
            default.BeatList[iParent].PCount = 1;
        } else {
            // Must place it in-between and move all other beat references.
            i = default.BeatList[iParent].PBeat + default.BeatList[iParent].PCount;

            for (j = 0; j < default.BeatList.Length; ++j) {
                if (j != iParent && default.BeatList[j].PCount > 0 && default.BeatList[j].PBeat >= i) {
                    ++default.BeatList[i].PBeat;
                }
            }

            ++default.BeatList[iParent].PCount;
        }

        default.BeatList.Insert(i, 1);

        if (iParent >= i) {
            ++iParent;

        }
        ++default.StartingBeatIndex;
    } else {
        for (i = default.StartingBeatIndex; i < default.BeatList.Length; ++i) {
            if (default.BeatList[i].BegTime > StartTime) {
                default.BeatList.Insert(i, 1);
                break;
            }
        }

        if (i == default.BeatList.Length) {
            default.BeatList.Length = i + 1;
        }
    }

    default.BeatList[i].SX = StartX;
    default.BeatList[i].SY = StartY;
    default.BeatList[i].EX = EndX;
    default.BeatList[i].EY = EndY;
    default.BeatList[i].BegTime = StartTime;
    default.BeatList[i].AnTime = ScreenTime;
    default.BeatList[i].Type = BeatType;
    InitBeat(i);

    return i;
}

static final function InitBeat(int Index) {
    default.BeatList[Index].CalcAnTime = default.BeatList[Index].AnTime * default.CalcBeatsPerMin;
    default.BeatList[Index].CalcBegTime = default.BeatList[Index].BegTime * default.CalcBeatsPerMin;
}

static final function vector GetWaverAxis(int Index) {
    local vector A, B;

    A.X = default.BeatList[Index].SX;
    A.Y = default.BeatList[Index].SY;
    B.X = default.BeatList[Index].EX;
    B.Y = default.BeatList[Index].EY;
    A = Normal(B - A);
    B.X = A.Y;
    B.Y = -A.X;

    return B;
}

static function RenderBackground(Canvas C, byte Mode) {
    if (Mode == 0)  return;

    C.SetPos(0, 0);
    C.DrawColor = class'HUD'.default.WhiteColor;
    C.Style = 1; // Normal

    if (Mode == 2) {
        C.DrawTile(default.BGMaterials[0], C.ClipX, C.ClipY, 0, 0, 64, 64);
        C.SetPos(0, 0);
        C.Style = 5; // AlphaBlend
        C.DrawTile(default.BGMaterials[1], C.ClipX, C.ClipY, 0, 0, 256, 256);
    } else {
        C.DrawTile(default.BGMaterials[2], C.ClipX, C.ClipY, 0, 0, 64, 64);
    }
}

defaultproperties {
    Modes(0)=(Up=20,Down=14)
    Modes(1)=(Up=80,Down=11)
    Modes(2)=(Up=100,Down=5,bExplosions=true)
    ChallengeLength=32

    Begin Object class=FadeColor name=BG_FadeColorA
        Color1=(R=70,A=128)
        Color2=(B=120,G=2,R=11,A=128)
        FadePeriod=4.000000
        FadePhase=0.500000
        ColorFadeType=FC_Sinusoidal
    End Object

    Begin Object class=FadeColor name=BG_FadeColorB
        Color1=(G=80)
        Color2=(R=80)
        FadePeriod=4.000000
        ColorFadeType=FC_Sinusoidal
    End Object

    Begin Object class=Combiner name=BG_CombinerA
        CombineOperation=CO_Multiply
        Material1=Texture'BG_GradColor'
        Material2=FadeColor'BG_FadeColorA'
    End Object

    Begin Object class=Combiner name=BG_CombinerB
        CombineOperation=CO_Multiply
        Material1=FadeColor'BG_FadeColorB'
        Material2=Texture'BG_DotC'
    End Object

    Begin Object class=TexOscillator name=BG_TexOscallilatorA
        UOscillationRate=0.002640
        VOscillationRate=0.001852
        UOscillationPhase=0.500000
        UOscillationAmplitude=4.000000
        VOscillationAmplitude=4.000000
        VOscillationType=OT_Stretch
        UOffset=0.264300
        Material=Texture'BG_CubeLine'
    End Object

    Begin Object class=Combiner name=BG_CombinerC
        AlphaOperation=AO_Use_Alpha_From_Material2
        Material1=Combiner'BG_CombinerA'
        Material2=TexOscillator'BG_TexOscallilatorA'
    End Object

    Begin Object class=FinalBlend name=BG_FinalBlend
        FrameBufferBlending=FB_AlphaBlend
        Material=Combiner'BG_CombinerC'
    End Object

    Begin Object class=TexOscillator name=BG_TexOscallilatorB
        UOscillationRate=0.125400
        VOscillationRate=0.153220
        UOscillationAmplitude=1.500000
        VOscillationAmplitude=1.500000
        UOscillationType=OT_Stretch
        VOscillationType=OT_Stretch
        UOffset=32.000000
        VOffset=32.000000
        Material=Combiner'BG_CombinerB'
    End Object

    BGMaterials(0)=BG_TexOscallilatorB
    BGMaterials(1)=BG_FinalBlend

    Begin Object class=FadeColor name=BG_FadeColorC
        Color1=(B=103,G=14,R=87)
        Color2=(B=27,G=105,R=60)
        FadePeriod=4.000000
        ColorFadeType=FC_Sinusoidal
    End Object

    Begin Object class=Combiner name=BG_CombinerD
        CombineOperation=CO_Multiply
        Material1=Texture'BG_DotC'
        Material2=FadeColor'BG_FadeColorC'
    End Object

    Begin Object class=TexOscillator name=BG_TexOscallilatorC
        UOscillationRate=0.100000
        VOscillationRate=0.074530
        UOscillationPhase=5.000000
        VOscillationPhase=5.000000
        UOscillationAmplitude=-1.000000
        VOscillationAmplitude=-1.000000
        UOscillationType=OT_Stretch
        VOscillationType=OT_Stretch
        UOffset=32.000000
        VOffset=32.000000
        Material=Combiner'BG_CombinerD'
    End Object

    Begin Object class=TexRotator name=BG_TexRotatorA
        TexRotationType=TR_OscillatingRotation
        UOffset=32.000000
        VOffset=32.000000
        OscillationRate=(Yaw=1500)
        OscillationAmplitude=(Yaw=16000)
        OscillationPhase=(Yaw=255)
        Material=TexOscillator'BG_TexOscallilatorC'
    End Object

    BGMaterials(2)=BG_TexOscallilatorC
}