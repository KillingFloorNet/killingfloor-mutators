/**
 * Author:      Marco
 * Home repo:   https://github.com/InsultingPros/BitCore
 */
class GameControls extends GUIMultiComponent;
///! BIT.TRIP.CORE gameplay and editor viewport.

#exec AUDIO IMPORT FILE="Sounds\ModeDown.wav" NAME="ModeDown" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\ModeUp.wav" NAME="ModeUp" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\MultiUp.wav" NAME="MultiUp" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\N_PaddleImpact1.wav" NAME="N_PaddleImpact1" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\BeatMiss.wav" NAME="BeatMiss" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\Challenge.wav" NAME="ChallengeDone" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\PowerUp.wav" NAME="PowerUp" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\PaddleDeath.wav" NAME="PaddleDeath" GROUP="FX"
#exec AUDIO IMPORT FILE="Sounds\Fireworks.wav" NAME="BitFireworks" GROUP="FX"

struct FDirectionPad {
    var transient float FireTimer, XPos, YPos, XSize, YSize, EndX, EndY;
};
var FDirectionPad DirectionPads[4];
var transient float OldXSize, OldYSize, CrossWidth;

struct FBeat {
    var float X, Y, CurTime;
    var int Index, TrailIndex;
};
var array<FBeat> Beats;

struct FBeatTrail {
    var float StartX, StartY, EndX, EndY, TrailTimer;
    var int BeatIndex;
};
var array<FBeatTrail> Trails;

struct FScoreVisual {
    var float X, Y, Time;
    var int Counter;
};
var array<FScoreVisual> ScoreVisuals;

struct FBeatExplosion {
    var byte Type, Num;
    var float X, Y, Time;
};
var array<FBeatExplosion> Explosions;

struct FNewScoreVisual {
    var float Time;
    var int Score, Multi;
};
var array<FNewScoreVisual> NewScoreVisuals, NewMultiVisuals;

var class<GameSongBase> CurrentSong;

var int PlayerScore, BeatCombo, ScoreMultiplier;

var int CurrentBeat, CurrentSection, SelectedBeatIndex, PlayerHits, PlayerMisses, ChallengeScore;
var float GameTimer, TotalSongTime, LastSeconds, CalcBeatsPerMin, SongSecTimer,
    LastFXTime, SectionDuration, BeatStartX, BeatStartY, BeatEndX ,BeatEndY,
    EndTravelTime, BeatTravelTime, LaserBlastTime, WaverSize, WaverSine,
    WaverSineOffset, BeatMidX, BeatMidY, ChallengeTimer, ChallengeLength,
    MenuFadeTime, ChallengeEndMsgTime, CompletedPrct;
var SongAudioFX AudioFX[2];
var byte SPlayerChan, BeatFXNum, BeatAddMode, NewBeatType, TripletRollerType,
    PlayerModeNum, PlayerChallengeMode, HoldingLaserButton, ChallengeBeats, NumSpectators;
var transient int LastBlastedBeat;
var color GreyLineColor, BeatColors[15];
var() localized string ChallengeNames[3];
var() array< class<GameSongBase> > AvailableGames;
var BitGameWindow WindowRefOwner;

const MAX_Spreaders=6;
struct FBeatExplSpread {
    var vector Spread[MAX_Spreaders];
};
var FBeatExplSpread ExplosionTypes[4];
var enum ECurrentGameMenu
{
    MENU_MainMenu,
    MENU_HiScores,
    MENU_Spectate,
    MENU_EndGame,
    MENU_InGame,
} CurrentGameMenu,PendingMenu;

var bool bIsDevMode, bPausedSong, bMakingHitCheck, bAddBeatsMode, bAddingBeat,
    bAutoFireMode, bNeedsHit, bFadeOutMenu, bScoresRequested, bIsSpectator,
    bStatsChanged, bWasMultiUp;

function Opened(GUIComponent Sender) {
    OnDraw = RenderGameMenu;
    bFadeOutMenu = false;
    CurrentGameMenu = MENU_MainMenu;
    CurrentSong = none;
    bIsSpectator = false;

    super.Opened(Sender);
}

function Closed(GUIComponent Sender, bool bCancelled) {
    StopSong();

    super.Closed(Sender, bCancelled);
}

function StartSong(class<GameSongBase> C) {
    local byte i, j;

    // Make sure no in-game music is playing in same time.
    PlayerOwner().ClientSetMusic("", MTRAN_FastFade);

    LastBlastedBeat = -1;
    NumSpectators = 0;

    if (!bIsSpectator) {
        OnStartedSong(C);
    } else {
        OnStartedSong(none);
    }

    OnDraw = RenderGameWindow;

    for (i = 0; i < ArrayCount(ExplosionTypes); ++i) {
        for (j = 0; j < MAX_Spreaders; ++j) {
            ExplosionTypes[i].Spread[j].X = 20.f - FRand() * 40.f;
            ExplosionTypes[i].Spread[j].Y = 20.f - FRand() * 40.f;
        }
    }

    WindowRefOwner.ClientRank = 0;
    ChallengeScore = -1;
    HoldingLaserButton = 255;
    PlayerChallengeMode = 0;
    PlayerHits = 0;
    PlayerMisses = 0;
    PlayerScore = 0;
    BeatCombo = 0;
    PlayerModeNum = 1;
    ScoreMultiplier = 1;
    GameTimer = 0.f;
    TotalSongTime = 0.f;
    Beats.Length = 0;
    Trails.Length = 0;
    ScoreVisuals.Length = 0;
    NewScoreVisuals.Length = 0;
    Explosions.Length = 0;
    bPausedSong = false;
    SelectedBeatIndex = -1;
    CurrentSong = C;

    if (!C.default.bHasInit) {
        C.static.InitSong();
    }

    CurrentBeat = C.default.StartingBeatIndex;
    CalcBeatsPerMin = C.default.CalcBeatsPerMin;
    LastSeconds = PlayerOwner().Level.TimeSeconds;
    BeatFXNum = 0;

    if (AudioFX[0] == none) {
        AudioFX[0] = PlayerOwner().Spawn(class'SongAudioFX');
        AudioFX[1] = PlayerOwner().Spawn(class'SongAudioFX');
    }

    AudioFX[0].ChangeModeNum(1);
    AudioFX[1].ChangeModeNum(1);
    ChallengeLength = C.default.ChallengeLength;
    StartAmbSound(C.default.Sections[C.default.SongOrder[0]].FX);
    SectionDuration = C.default.Sections[C.default.SongOrder[0]].ActualDuration;
    SongSecTimer = SectionDuration;
    CurrentSection = 1;

    if (bIsDevMode) {
        OnInitSongInfo(C.default.Sections.Length);
        OnSectionChange(0,C.default.SongOrder[0], SectionDuration / CalcBeatsPerMin);
    }
}

function StopSong() {
    Beats.Length = 0;
    Trails.Length = 0;

    if (AudioFX[0] != none) {
        AudioFX[0].Destroy();
        AudioFX[0] = none;
        AudioFX[1].Destroy();
        AudioFX[1] = none;
    }
}

function SetPaused(bool bPause) {
    bPausedSong = bPause;

    if (bPausedSong) {
        StartAmbSound(none);
    } else {
        StartAmbSound(CurrentSong.default.Sections[CurrentSong.default.SongOrder[CurrentSection - 1]].FX);
    }
}

function SaveFile() {
    local FileLog L;

    L = PlayerOwner().Spawn(class'FileLog');
    L.OpenLog("MusicData", "txt", true);
    CurrentSong.static.WriteSongProperties(L);
    L.Destroy();
    PlayerOwner().ClientMessage("Wrote UserLogs/MusicData.txt.");
}

simulated final function DoSoundFX(Sound S, optional byte Index) {
    if (++SPlayerChan == 3) {
        SPlayerChan = 0;
    }

    switch (SPlayerChan) {
        case 0:
            AudioFX[Index].PlaySound(S, SLOT_Misc);
            break;
        case 1:
            AudioFX[Index].PlaySound(S, SLOT_Pain);
            break;
        case 2:
            AudioFX[Index].PlaySound(S, SLOT_Talk);
            break;
    }
}

final function StartAmbSound(Sound S) {
    if (AudioFX[0].AmbientSound == none) {
        AudioFX[0].AmbientSound = S;
        AudioFX[1].AmbientSound = none;
    } else {
        AudioFX[0].AmbientSound = none;
        AudioFX[1].AmbientSound = S;
    }
}

function bool FocusFirst(GUIComponent Sender) {
    super(GUIComponent).SetFocus(none);

    return true;
}

function StartDev() {
    bIsDevMode = true;
    StartSong(CurrentSong);
}

function EndDev() {
    bIsDevMode = false;
    StartSong(CurrentSong);
}

final function SongOffsetChanged() {
    local int i, j;

    PlayerChallengeMode = 0;
    Beats.Length = 0;
    Trails.Length = 0;

    for (i = CurrentSong.default.StartingBeatIndex; i < CurrentSong.default.BeatList.Length; ++i)
    {
        if (GameTimer <= CurrentSong.default.BeatList[i].CalcBegTime) {
            break;
        } else if (GameTimer < (CurrentSong.default.BeatList[i].CalcBegTime + CurrentSong.default.BeatList[i].CalcAnTime)) {
            Beats.Length = j + 1;
            Beats[j].CurTime = GameTimer-CurrentSong.default.BeatList[i].CalcBegTime;
            InitBeat(j, i);
            ++j;
        }
    }
    CurrentBeat = i;
}

final function ModifySongOrder(byte NewFX) {
    CurrentSong.default.SongOrder[CurrentSection - 1] = Min(NewFX, CurrentSong.default.Sections.Length - 1);
    ModifySongSection(CurrentSection - 1);
}

final function ModifySongSection(int NewSection) {
    local int i;

    if (NewSection >= CurrentSong.default.SongOrder.Length) {
        // Add new section.
        CurrentSong.default.SongOrder.Length = NewSection + 1;
        CurrentSong.default.SongOrder[NewSection] = CurrentSong.default.SongOrder[NewSection - 1];
    }

    GameTimer = 0.f;

    if (!bPausedSong) {
        StartAmbSound(CurrentSong.default.Sections[CurrentSong.default.SongOrder[NewSection]].FX);
    }

    SectionDuration = CurrentSong.default.Sections[CurrentSong.default.SongOrder[NewSection]].ActualDuration;
    SongSecTimer = CurrentSong.default.Sections[CurrentSong.default.SongOrder[NewSection]].ActualDuration;

    for (i = 0; i < NewSection; ++i) {
        GameTimer += CurrentSong.default.Sections[CurrentSong.default.SongOrder[i]].ActualDuration;
    }

    TotalSongTime = GameTimer;
    SongOffsetChanged();
    CurrentSection = NewSection + 1;
    OnSectionChange(NewSection, CurrentSong.default.SongOrder[NewSection], SectionDuration / CalcBeatsPerMin);
}

// For spectator clients.
final function ChangeSongSection(byte NewSection) {
    local int i;

    // Error?
    if (NewSection >= CurrentSong.default.SongOrder.Length)    return;

    bPausedSong = false;
    GameTimer = 0.f;
    StartAmbSound(CurrentSong.default.Sections[CurrentSong.default.SongOrder[NewSection]].FX);
    SectionDuration = CurrentSong.default.Sections[CurrentSong.default.SongOrder[NewSection]].ActualDuration;
    SongSecTimer = CurrentSong.default.Sections[CurrentSong.default.SongOrder[NewSection]].ActualDuration;

    for (i = 0; i < NewSection; ++i) {
        GameTimer += CurrentSong.default.Sections[CurrentSong.default.SongOrder[i]].ActualDuration;
    }

    TotalSongTime = GameTimer;
    CurrentSection = NewSection + 1;
}

final function SetInitialOffset(byte Section, float Time) {
    ChangeSongSection(Section);
    SongSecTimer = Time;
    GameTimer += (SectionDuration - Time);
    SongOffsetChanged();
}

final function ModifySectionOffset(float Time) {
    local int i;

    Time = Time * CalcBeatsPerMin;
    GameTimer = 0.f;

    for (i = 0; i < (CurrentSection - 1); ++i) {
        GameTimer += CurrentSong.default.Sections[CurrentSong.default.SongOrder[i]].ActualDuration;
    }

    TotalSongTime = GameTimer;
    GameTimer += Time;
    SongSecTimer = SectionDuration - Time;
    SongOffsetChanged();
}

final function vector GetBeatHeading(out float Dist) {
    local vector A, B;

    A.X = BeatStartX;
    A.Y = BeatStartY;
    B.X = BeatEndX;
    B.Y = BeatEndY;
    A = B - A;
    Dist = VSize(A);

    return Normal(A);
}

final function float GetPulsatingAlpha(float Alpha) {
    // Beat that moves from 0-.25-.5-.75-.5-.25-.5-.75-1
    if (Alpha < 0.1)            return FMax(Alpha, 0.f) * 2.5;
    else if (Alpha < 0.15)      return 0.25;
    else if (Alpha < 0.225)     return 0.25 + (Alpha - 0.15) * 3.33333;
    else if (Alpha < 0.275)     return 0.5;
    else if (Alpha < 0.35)      return 0.5 + (Alpha - 0.275) * 3.33333;
    else if (Alpha < 0.4)       return 0.75;
    else if (Alpha < 0.475)     return 0.75 - (Alpha - 0.4) * 3.33333;
    else if (Alpha < 0.525)     return 0.5;
    else if (Alpha < 0.6)       return 0.5 - (Alpha - 0.525) * 3.33333;
    else if (Alpha < 0.65)      return 0.25;
    else if (Alpha < 0.725)     return 0.25 + (Alpha - 0.65) * 3.33333;
    else if (Alpha < 0.775)     return 0.5;
    else if (Alpha < 0.85)      return 0.5 + (Alpha - 0.775) * 3.33333;
    else if (Alpha < 0.9)       return 0.75;

    return FMin(0.75 + (Alpha - 0.9) * 2.5, 1.f);
}

final function float SnapToGrid(float Pos, float Size) {
    Pos /= Size;

    return (Round(Pos * 100.f) * 0.01f * Size);
}

final function vector CalcWaverOffset(float Alpha, int iBeat, int iParent) {
    return CurrentSong.static.GetWaverAxis(iParent) *
        Sin((Alpha+CurrentSong.default.BeatList[iParent].SinOf) * CurrentSong.default.BeatList[iParent].Sine) *
        CurrentSong.default.BeatList[iParent].WS;
}

final function vector CalcRollOffset(float Alpha, int iBeat, int iParent) {
    local vector V;

    if (CurrentSong.default.BeatList[iParent].WS == 0)    return vect(0, 0, 0);

    Alpha += CurrentSong.default.BeatList[iParent].SinOf;
    Alpha *= CurrentSong.default.BeatList[iParent].Sine * Pi;
    V.X = Sin(Alpha) * 0.75;
    V.Y = Cos(Alpha);

    return V * CurrentSong.default.BeatList[iParent].WS;
}

final function InitBeat(int VisIndex, int Index) {
    local int i;

    Beats[VisIndex].Index = Index;
    Beats[VisIndex].X = CurrentSong.default.BeatList[Index].SX;
    Beats[VisIndex].Y = CurrentSong.default.BeatList[Index].SY;

    // Add trail
    if (CurrentSong.default.BeatList[Index].Type == 7) {
        i = Trails.Length;
        Trails.Length = i + 1;
        Trails[i].StartX = Beats[VisIndex].X;
        Trails[i].StartY = Beats[VisIndex].Y;
        Trails[i].EndX = Trails[i].StartX;
        Trails[i].EndY = Trails[i].StartY;
        Trails[i].TrailTimer = 1.f;
        Trails[i].BeatIndex = VisIndex;
        Beats[VisIndex].TrailIndex = i;
    } else {
        Beats[VisIndex].TrailIndex = -1;
    }
}

final function RemoveBeat(int Index) {
    local int i;

    for (i = 0; i < Trails.Length; ++i) {
        if (Trails[i].BeatIndex == Index) {
            Trails[i].BeatIndex = -1;
            Trails[i].EndX = Beats[Index].X;
            Trails[i].EndY = Beats[Index].Y;
        } else if (Trails[i].BeatIndex > Index) {
            --Trails[i].BeatIndex;
        }
    }

    Beats.Remove(Index, 1);
}

final function RemoveTrail(int Index) {
    local int i;

    for (i = 0; i < Beats.Length; ++i) {
        if (Beats[i].TrailIndex == Index) {
            Beats[i].TrailIndex = -1;
        } else if (Beats[i].TrailIndex > Index) {
            --Beats[i].TrailIndex;
        }
    }

    Trails.Remove(Index, 1);
}

final function PreviewWaverLine(Canvas C) {
    local vector V, B, Last;
    local float D;

    B = GetBeatHeading(D);
    V.X = B.Y;
    V.Y = -B.X;
    V.X *= C.ClipX;
    V.Y *= C.ClipY;

    for (D = 0.f; D <= 1.025f; D += 0.05f) {
        B.X = Lerp(D, BeatStartX, BeatEndX);
        B.Y = Lerp(D, BeatStartY, BeatEndY);
        B += V * Sin((WaverSineOffset + D) * WaverSine * Pi) * WaverSize;

        if (D > 0.f) {
            if (D <= 0.5025) {
                class'HUD'.static.StaticDrawCanvasLine(
                    C,
                    Last.X + C.OrgX,
                    Last.Y + C.OrgY,
                    B.X + C.OrgX,
                    B.Y + C.OrgY,
                    class'HUD'.default.WhiteColor
                );
            } else {
                class'HUD'.static.StaticDrawCanvasLine(
                    C,
                    Last.X + C.OrgX,
                    Last.Y + C.OrgY,
                    B.X + C.OrgX,
                    B.Y + C.OrgY,
                    class'HUD'.default.GoldColor
                );
            }
        }

        Last = B;
    }
}

final function PreviewRollerLine(Canvas C) {
    local vector V, Last;
    local float D, A;

    for (D = 0.f; D <= 1.025f; D += 0.05f) {
        A = (WaverSineOffset + D) * WaverSine * Pi;
        V.X = Lerp(D, BeatStartX, BeatEndX) + Sin(A) * WaverSize * C.ClipX * 0.75;
        V.Y = Lerp(D, BeatStartY, BeatEndY) + Cos(A) * WaverSize * C.ClipY;

        if (D > 0.f) {
            if (D <= 0.5025) {
                class'HUD'.static.StaticDrawCanvasLine(
                    C,
                    Last.X + C.OrgX,
                    Last.Y + C.OrgY,
                    V.X + C.OrgX,
                    V.Y + C.OrgY,
                    class'HUD'.default.WhiteColor
                );
            } else {
                class'HUD'.static.StaticDrawCanvasLine(
                    C,
                    Last.X + C.OrgX,
                    Last.Y + C.OrgY,
                    V.X + C.OrgX,
                    V.Y + C.OrgY,
                    class'HUD'.default.GoldColor
                );
            }
        }
        Last = V;
    }

    for (D = 0.f; D <= 1.025f; D += 0.05f) {
        A = (WaverSineOffset + D) * WaverSine * Pi;
        V.X = Lerp(D, BeatStartX, BeatEndX) + Sin(A) * -WaverSize * C.ClipX * 0.75;
        V.Y = Lerp(D, BeatStartY, BeatEndY) + Cos(A) * -WaverSize * C.ClipY;

        if (D > 0.f) {
            if (D <= 0.5025) {
                class'HUD'.static.StaticDrawCanvasLine(
                    C,
                    Last.X + C.OrgX,
                    Last.Y + C.OrgY,
                    V.X + C.OrgX,
                    V.Y + C.OrgY,
                    class'HUD'.default.BlueColor
                );
            } else {
                class'HUD'.static.StaticDrawCanvasLine(
                    C,
                    Last.X + C.OrgX,
                    Last.Y + C.OrgY,
                    V.X + C.OrgX,
                    V.Y + C.OrgY,
                    class'HUD'.default.GoldColor
                );
            }
        }

        Last = V;
    }
}

final function RenderTrailer(Canvas C, int Index, float Width) {
    local float StartX, StartY, EndX, EndY;
    local byte RG;

    StartX = FMin(Trails[Index].StartX, Trails[Index].EndX) * C.ClipX * 0.01 - Width;
    StartY = FMin(Trails[Index].StartY, Trails[Index].EndY) * C.ClipY * 0.01 - Width;
    EndX = FMax(Trails[Index].StartX, Trails[Index].EndX) * C.ClipX * 0.01 + Width;
    EndY = FMax(Trails[Index].StartY, Trails[Index].EndY) * C.ClipY * 0.01 + Width;

    if (EndX <= 0 || EndY <= 0 || StartX >= C.ClipX || StartY >= C.ClipY)    return;

    RG = Trails[Index].TrailTimer * 200;
    C.Style = 3; // Translucent
    C.SetDrawColor(RG, RG, 0, 255);
    C.SetPos(StartX, StartY);
    C.DrawTileClipped(Texture'WhiteTexture', EndX - StartX, EndY - StartY, 0, 0, 1, 1);
    C.Style = 1;
}

final function InitPaddle(Canvas C, float ScreenScale) {
    local byte i;
    local float CrossH, CrossV, XScale;

    XScale = ScreenScale * 6.f;
    CrossV = C.ClipY * 0.5;
    CrossH = C.ClipX * 0.5;

    CrossWidth = XScale * 8.f;

    for (i = 0; i < 4; ++i) {
        if (i == 0 || i == 2) {
            DirectionPads[i].XSize = CrossH - (XScale * 4);
            DirectionPads[i].YSize = XScale * 2;

            if (i == 2) {
                DirectionPads[i].XPos = CrossH + (XScale * 4);
            }

            DirectionPads[i].YPos = CrossV - XScale;
        } else {
            DirectionPads[i].XSize = XScale * 2;
            DirectionPads[i].YSize = CrossV - (XScale * 4);

            if (i == 3) {
                DirectionPads[i].YPos = CrossV + (XScale * 4);
            }

            DirectionPads[i].XPos = CrossH - XScale;
        }

        DirectionPads[i].EndX = DirectionPads[i].XPos + DirectionPads[i].XSize;
        DirectionPads[i].EndY = DirectionPads[i].YPos + DirectionPads[i].YSize;
    }
}

final function float GetSectionTime() {
    return SectionDuration - SongSecTimer;
}

function bool RenderGameWindow(canvas C) {
    local float CX, CY, DeltaTime, Alpha, Scale, ScreenScale, X ,Y, OlX, OlY, MX, MY;
    local int i, Bi;
    local vector V;
    local string S;
    local bool bCanHit;

    if (CurrentSong == none) {
        StartSong(class'Discovery');
    }

    DeltaTime = FClamp(PlayerOwner().Level.TimeSeconds - LastSeconds, 0.f, 0.25f) / 1.1f;
    LastSeconds = PlayerOwner().Level.TimeSeconds;

    if (bFadeOutMenu) {
        if ((MenuFadeTime -= DeltaTime) <= 0.f) {
            C.SetPos(ActualLeft(WinLeft), ActualTop(WinTop));
            C.Style = 1;
            C.SetDrawColor(0, 0, 0, 255);
            C.DrawTile(Texture'WhiteTexture', ActualWidth(WinWidth), ActualHeight(WinHeight), 0, 0, 1, 1);
            // Do menu transition now.
            OpenUpMenu(PendingMenu);

            return false;
        }
    }

    if (bPausedSong) {
        DeltaTime = 0.f;
    } else {
        GameTimer += DeltaTime;
        SongSecTimer -= DeltaTime;
    }

    // Advance song.
    if (!bPausedSong && SongSecTimer <= 0.f) {
        // Reached to the end of song.
        if (CurrentSection >= CurrentSong.default.SongOrder.Length) {
            SetPaused(true);

            if (!bIsDevMode && !bIsSpectator) {
                if (!CurrentSong.default.bCompleted) {
                    CurrentSong.default.bCompleted = true;
                    CurrentSong.static.StaticSaveConfig();
                }

                if (WindowRefOwner.RepActor != none) {
                    WindowRefOwner.RepActor.ServerSubmitScores(CurrentSong, PlayerScore, 100);
                }

                CompletedPrct = 200; // Use above 100 to make sure player didn't lose just right at the end.
                SwitchToMenu(MENU_EndGame);
            }

            DeltaTime = 0.f;
        } else {
            StartAmbSound(CurrentSong.default.Sections[CurrentSong.default.SongOrder[CurrentSection]].FX);
            SectionDuration = CurrentSong.default.Sections[CurrentSong.default.SongOrder[CurrentSection]].ActualDuration;
            TotalSongTime += SectionDuration;
            SongSecTimer = SectionDuration;
            GameTimer = TotalSongTime;

            if (bIsDevMode) {
                OnSectionChange(CurrentSection, CurrentSong.default.SongOrder[CurrentSection], SectionDuration / CalcBeatsPerMin);
            } else if (NumSpectators > 0) {
                OnSectionChangeSpec(CurrentSection);
            }

            ++CurrentSection;
        }
    }

    if (bIsDevMode) {
        OnSongOffset((SectionDuration - SongSecTimer) / CalcBeatsPerMin);
    }

    CX = C.ClipX;
    CY = C.ClipY;
    C.OrgX = ActualLeft(WinLeft);
    C.OrgY = ActualTop(WinTop);
    C.ClipX = ActualWidth(WinWidth);
    C.ClipY = ActualHeight(WinHeight);

    // Draw background.
    C.Style = 1;
    C.SetPos(0, 0);
    C.SetDrawColor(0, 0, 0, 255);
    C.DrawTile(Texture'WhiteTexture', C.ClipX, C.ClipY, 0, 0, 1, 1);

    // Scale screen to fit aspect ratio 4:3
    X = C.ClipX / 4;
    Y = C.ClipY / 3;

    if (X > Y) {
        Scale = 1.f - (Y / X);
        C.OrgX += (Scale * C.ClipX * 0.5);
        C.ClipX -= Scale * C.ClipX;
    } else if (X < Y) {
        Scale = 1.f - (X / Y);
        C.OrgY += (Scale * C.ClipY * 0.5);
        C.ClipY -= Scale * C.ClipY;
    }

    if (bIsDevMode) {
        C.SetPos(0, 0);

        if (bIsDevMode && bAddBeatsMode) {
            C.SetDrawColor(0, 0, 20, 255);
        } else {
            C.SetDrawColor(0, 20, 0, 255);
        }

        C.DrawTile(Texture'WhiteTexture', C.ClipX, C.ClipY, 0, 0, 1, 1);
    } else {
        CurrentSong.static.RenderBackground(C, PlayerModeNum);
        C.Style = 1;
    }

    // Set scaling values for objects in-game
    ScreenScale = C.ClipY / 500.f;

    // Setup X-paddle
    if (OldXSize != C.ClipX || OldYSize != C.ClipY) {
        OldXSize = C.ClipX;
        OldYSize = C.ClipY;
        InitPaddle(C, ScreenScale);
    }

    // Editor
    if (bIsDevMode) {
        MX = Controller.MouseX - C.OrgX;
        MY = Controller.MouseY - C.OrgY;

        if (bMakingHitCheck) {
            SelectedBeatIndex = -1;
        }

        if (BeatAddMode == 1) {
            ++BeatAddMode;
            BeatStartX = SnapToGrid(MX, C.ClipX);
            BeatStartY = SnapToGrid(MY, C.ClipY);

            // Snap to screen edges.
            if (MX < 20) {
                BeatStartX = 0;
            } else if (MX > (C.ClipX - 20)) {
                BeatStartX = C.ClipX;
            }

            if (MY < 20) {
                BeatStartY = 0;
            } else if (MY > (C.ClipY - 20)) {
                BeatStartY = C.ClipY;
            }
        }

        if (BeatAddMode == 2 || BeatAddMode == 3) {
            X = SnapToGrid(MX, C.ClipX);
            Y = SnapToGrid(MY, C.ClipY);

            // Snap to middle line.
            if (Abs(X - (C.ClipX / 2)) < 25.f) {
                X = (C.ClipX / 2);
            } else if (Abs(Y - (C.ClipY / 2)) < 25.f) {
                Y = (C.ClipY / 2);
            }

            // Snap to straight lines.
            if (Abs(X - BeatStartX) < 25.f) {
                X = BeatStartX;
            } else if (Abs(Y - BeatStartY) < 25.f) {
                Y = BeatStartY;
            }

            class'HUD'.static.StaticDrawCanvasLine(
                C,
                BeatStartX + C.OrgX,
                BeatStartY + C.OrgY,
                X + C.OrgX,
                Y + C.OrgY,
                class'HUD'.default.WhiteColor
            );

            if (BeatAddMode == 3) {
                BeatEndX = X;
                BeatEndY = Y;
                ++BeatAddMode;
            }
        } else if (BeatAddMode == 4 || BeatAddMode == 5) {
            class'HUD'.static.StaticDrawCanvasLine(
                C,
                BeatStartX + C.OrgX,
                BeatStartY + C.OrgY,
                BeatEndX + C.OrgX,
                BeatEndY + C.OrgY,
                class'HUD'.default.WhiteColor
            );

            V = GetBeatHeading(OlX);
            BeatMidX = BeatEndX;
            BeatMidY = BeatEndY;

            if (NewBeatType == 3) {
                X = BeatEndX;
                Y = BeatEndY;
            } else if (NewBeatType == 2 || NewBeatType == 6 || NewBeatType == 8) {
                X = BeatEndX + V.X * OlX;
                Y = BeatEndY + V.Y * OlX;
            } else {
                X = BeatEndX + V.X * OlX * EndTravelTime;
                Y = BeatEndY + V.Y * OlX * EndTravelTime;
            }

            class'HUD'.static.StaticDrawCanvasLine(
                C,
                X + C.OrgX,
                Y + C.OrgY,
                BeatEndX + C.OrgX,
                BeatEndY + C.OrgY,
                class'HUD'.default.GoldColor
            );

            if (BeatAddMode == 5) {
                if (NewBeatType == 4 || NewBeatType == 5 || NewBeatType == 9) {
                    BeatEndX = X;
                    BeatEndY = Y;
                    ++BeatAddMode;
                    GoTo'PreviewSine';
                } else if (NewBeatType == 8) {
                    OlY = BeatTravelTime * 1.8;
                    OlX = BeatTravelTime * 2;
                } else if (NewBeatType == 3) {
                    OlY = 2;
                    OlX = 2 + BeatTravelTime;
                } else if (NewBeatType == 2 || NewBeatType == 6) {
                    OlY = BeatTravelTime;
                    OlX = BeatTravelTime * 4.f;
                } else {
                    OlY = BeatTravelTime;
                    OlX = (BeatTravelTime + BeatTravelTime * EndTravelTime);
                }

                i = CurrentSong.static.AddNewBeat(
                    (GameTimer / CalcBeatsPerMin) - OlY,
                    OlX,
                    (BeatStartX / C.ClipX) * 100.f,
                    (BeatStartY / C.ClipY) * 100.f,
                    (X / C.ClipX) * 100.f,
                    (Y / C.ClipY) * 100.f,
                    NewBeatType,
                    SelectedBeatIndex
                );

                // Challenge beat
                if (NewBeatType == 11) {
                    CurrentSong.default.BeatList[i].Sine = TripletRollerType;
                }

                BeatAddMode = 0;
            }
        } else if (BeatAddMode == 6 || BeatAddMode == 7) {
PreviewSine:
            class'HUD'.static.StaticDrawCanvasLine(
                C,
                BeatStartX + C.OrgX,
                BeatStartY + C.OrgY,
                BeatMidX + C.OrgX,
                BeatMidY + C.OrgY,
                class'HUD'.default.RedColor
            );

            if (NewBeatType == 4 || NewBeatType == 9) {
                PreviewWaverLine(C);
            }
            else {
                PreviewRollerLine(C);
            }

            if (BeatAddMode == 7)
            {
                OlY = (GameTimer / CalcBeatsPerMin) - BeatTravelTime;
                OlX = (BeatTravelTime + BeatTravelTime * EndTravelTime);
                i = CurrentSong.static.AddNewBeat(
                        OlY,
                        OlX,
                        (BeatStartX / C.ClipX) * 100.f,
                        (BeatStartY / C.ClipY) * 100.f,
                        (BeatEndX / C.ClipX) * 100.f,
                        (BeatEndY / C.ClipY) * 100.f,
                        NewBeatType,
                        SelectedBeatIndex
                    );

                if (NewBeatType == 4 || NewBeatType == 9) {
                    CurrentSong.default.BeatList[i].Sine = WaverSine * Pi;
                }
                else {
                    CurrentSong.default.BeatList[i].Sine = WaverSine;
                }

                CurrentSong.default.BeatList[i].WS = WaverSize * 100.f;
                CurrentSong.default.BeatList[i].SinOf = WaverSineOffset;

                if (NewBeatType == 5 && TripletRollerType > 0) {
                    i = CurrentSong.static.AddNewBeat(
                            OlY,
                            OlX,
                            (BeatStartX / C.ClipX) * 100.f,
                            (BeatStartY / C.ClipY) * 100.f,
                            (BeatEndX / C.ClipX) * 100.f,
                            (BeatEndY / C.ClipY) * 100.f,
                            5,
                            SelectedBeatIndex
                        );

                    CurrentSong.default.BeatList[i].Sine = WaverSine;
                    CurrentSong.default.BeatList[i].WS = WaverSize *- 100.f;
                    CurrentSong.default.BeatList[i].SinOf = WaverSineOffset;
                    CurrentSong.static.AddNewBeat(
                        OlY,
                        OlX,
                        (BeatStartX / C.ClipX) * 100.f,
                        (BeatStartY / C.ClipY) * 100.f,
                        (BeatEndX / C.ClipX) * 100.f,
                        (BeatEndY / C.ClipY) * 100.f,
                        5,
                        SelectedBeatIndex
                    );

                    if (TripletRollerType == 2) {
                        i = CurrentSong.static.AddNewBeat(
                            OlY,
                            OlX,
                            (BeatStartX / C.ClipX) * 100.f,
                            (BeatStartY / C.ClipY) * 100.f,
                            (BeatEndX / C.ClipX) * 100.f,
                            (BeatEndY / C.ClipY) * 100.f,
                            5,
                            SelectedBeatIndex
                        );

                        CurrentSong.default.BeatList[i].Sine = WaverSine;
                        CurrentSong.default.BeatList[i].WS = WaverSize * 50.f;
                        CurrentSong.default.BeatList[i].SinOf = WaverSineOffset;
                        i = CurrentSong.static.AddNewBeat(
                            OlY,
                            OlX,
                            (BeatStartX / C.ClipX) * 100.f,
                            (BeatStartY / C.ClipY) * 100.f,
                            (BeatEndX / C.ClipX) * 100.f,
                            (BeatEndY / C.ClipY) * 100.f,
                            5,
                            SelectedBeatIndex
                        );

                        CurrentSong.default.BeatList[i].Sine = WaverSine;
                        CurrentSong.default.BeatList[i].WS = WaverSize *- 50.f;
                        CurrentSong.default.BeatList[i].SinOf = WaverSineOffset;
                    }
                }
                BeatAddMode = 0;
            }
        }
    }

    // Update game actions.
    if (!bPausedSong) {
        i = Beats.Length;

        while (CurrentBeat < CurrentSong.default.BeatList.Length) {
            if (GameTimer < CurrentSong.default.BeatList[CurrentBeat].CalcBegTime)    break;

            Beats.Length = i + 1;
            InitBeat(i, CurrentBeat);
            Beats[i].CurTime = GameTimer - CurrentSong.default.BeatList[CurrentBeat].CalcBegTime - DeltaTime;
            ++CurrentBeat;
            ++i;
        }
    }

    // Draw trailers with dead beats.
    for (i = (Trails.Length - 1); i >= 0; --i) {
        if (Trails[i].BeatIndex == -1) {
            if ((Trails[i].TrailTimer -= DeltaTime) <= 0.f) {
                RemoveTrail(i);
                continue;
            }

            if (PlayerModeNum != 0) {
                RenderTrailer(C, i, ScreenScale * 3.f);
            }
        }
    }

    // Draw beats
    for (i = (Beats.Length - 1); i >= 0; --i) {
        Bi = Beats[i].Index;

        if (!bPausedSong) {
            if ((Beats[i].CurTime += DeltaTime) >= CurrentSong.default.BeatList[Bi].CalcAnTime) {
                // Must draw trailer here or it'll flicker for 1 frame.
                if (Beats[i].TrailIndex >= 0 && PlayerModeNum != 0) {
                    RenderTrailer(C, Beats[i].TrailIndex, ScreenScale * 3.f);
                }

                // MISS!
                // Give no penality for fake beats.
                if (!bIsDevMode && CurrentSong.default.BeatList[Bi].Type != 3) {
                    MissedBeat();
                }

                RemoveBeat(i);
                continue;
            }
        }

        // Cache old pos
        OlX = Beats[i].X * C.ClipX * 0.01f;
        OlY = Beats[i].Y * C.ClipY * 0.01f;

        // Update beat position
        Alpha = (Beats[i].CurTime / CurrentSong.default.BeatList[Bi].CalcAnTime);
        Scale = 4 * ScreenScale;
        bCanHit = (Alpha > 0.2);

        switch (CurrentSong.default.BeatList[Bi].Type) {
            case 12:
                // Make beat larger if it can split
                if (CurrentSong.default.BeatList[Bi].PCount > 0) {
                    Scale *= 2.f;
                }

                Beats[i].X = Lerp(Alpha, CurrentSong.default.BeatList[Bi].SX, CurrentSong.default.BeatList[Bi].EX);
                Beats[i].Y = Lerp(Alpha, CurrentSong.default.BeatList[Bi].SY, CurrentSong.default.BeatList[Bi].EY);
                break;

            case 8:
                X = Alpha;
                if (X < 0.9) {
                    X = Square(X / 0.9) * 0.5;
                } else {
                    X = 0.5 + (X - 0.9) * 5.f;
                }

                Beats[i].X = Lerp(X, CurrentSong.default.BeatList[Bi].SX, CurrentSong.default.BeatList[Bi].EX);
                Beats[i].Y = Lerp(X, CurrentSong.default.BeatList[Bi].SY, CurrentSong.default.BeatList[Bi].EY);
                break;

            case 6:
                bCanHit = true;

                if (Alpha < 0.1429) {
                    X = 0;
                } else if (Alpha < 0.2858) {
                    X = 0.5;
                } else if (Alpha < 0.4287) {
                    X = 1;
                } else if (Alpha < 0.5716) {
                    X = 0.5;
                } else if (Alpha < 0.7145) {
                    X = 0;
                } else if (Alpha < 0.8574) {
                    X = 0.5;
                } else {
                    X = 1;
                }

                Beats[i].X = Lerp(X, CurrentSong.default.BeatList[Bi].SX, CurrentSong.default.BeatList[Bi].EX);
                Beats[i].Y = Lerp(X, CurrentSong.default.BeatList[Bi].SY, CurrentSong.default.BeatList[Bi].EY);
                break;

            case 5:
                bCanHit = true;
                V = CalcRollOffset(Alpha, i, Bi);
                Beats[i].X = Lerp(Alpha, CurrentSong.default.BeatList[Bi].SX, CurrentSong.default.BeatList[Bi].EX) + V.X;
                Beats[i].Y = Lerp(Alpha, CurrentSong.default.BeatList[Bi].SY, CurrentSong.default.BeatList[Bi].EY) + V.Y;
                break;

            case 4:
                bCanHit = true;
                // no break???

            case 9:
                V = CalcWaverOffset(Alpha, i, Bi);
                Beats[i].X = Lerp(Alpha, CurrentSong.default.BeatList[Bi].SX, CurrentSong.default.BeatList[Bi].EX) + V.X;
                Beats[i].Y = Lerp(Alpha, CurrentSong.default.BeatList[Bi].SY, CurrentSong.default.BeatList[Bi].EY) + V.Y;
                break;

            case 3:
                X = (Beats[i].CurTime / CalcBeatsPerMin) * 0.5f;
                if (X < 1.f) {
                    Beats[i].X = Lerp(X, CurrentSong.default.BeatList[Bi].SX, CurrentSong.default.BeatList[Bi].EX);
                    Beats[i].Y = Lerp(X, CurrentSong.default.BeatList[Bi].SY, CurrentSong.default.BeatList[Bi].EY);
                } else {
                    Beats[i].X = CurrentSong.default.BeatList[Bi].EX;
                    Beats[i].Y = CurrentSong.default.BeatList[Bi].EY;
                }
                break;

            case 2:
                X = GetPulsatingAlpha(Alpha);
                Beats[i].X = Lerp(X, CurrentSong.default.BeatList[Bi].SX, CurrentSong.default.BeatList[Bi].EX);
                Beats[i].Y = Lerp(X, CurrentSong.default.BeatList[Bi].SY, CurrentSong.default.BeatList[Bi].EY);
                break;

            case 1:
                V.X = (GameTimer % 1.f);
                if (V.X < 0.5f) {
                    V.X = 1.f + V.X;
                } else {
                    V.X = 2.f - V.X;
                }
                Scale *= ((V.X * 2.f) + 1.f);

            case 7:
            default:
                Beats[i].X = Lerp(Alpha, CurrentSong.default.BeatList[Bi].SX, CurrentSong.default.BeatList[Bi].EX);
                Beats[i].Y = Lerp(Alpha, CurrentSong.default.BeatList[Bi].SY, CurrentSong.default.BeatList[Bi].EY);
                break;
        }

        // Render trailer.
        if (Beats[i].TrailIndex >= 0) {
            Trails[Beats[i].TrailIndex].EndX = Beats[i].X;
            Trails[Beats[i].TrailIndex].EndY = Beats[i].Y;

            if (PlayerModeNum != 0) {
                RenderTrailer(C, Beats[i].TrailIndex, ScreenScale * 3.f);
            }
        }

        // Render beat
        X = Beats[i].X * C.ClipX * 0.01f;
        Y = Beats[i].Y * C.ClipY * 0.01f;

        if ((X + Scale) > 0.f && (Y + Scale) > 0.f && (X - Scale) < C.ClipX && (Y - Scale) < C.ClipY) {
            if (bIsDevMode) {
                if (
                    bMakingHitCheck &&
                    SelectedBeatIndex == -1 &&
                    MX >= (X - Scale) &&
                    MX <=(X + Scale) &&
                    MY>=(Y - Scale) &&
                    MY<=(Y + Scale)
                ) {
                    SelectedBeatIndex = Bi;
                    bMakingHitCheck = false;
                }

                if (SelectedBeatIndex == Bi) {
                    C.SetPos(X - Scale * 2, Y - Scale * 2);
                    C.DrawColor = class'HUD'.default.WhiteColor;
                    C.DrawTileClipped(Texture'WhiteTexture', Scale * 4, Scale * 4, 0, 0, 1, 1);
                }
            }

            if (CurrentSong.default.BeatList[Bi].Type != 13 || ((GameTimer % 0.2) > 0.075)) {
                C.SetPos(X - Scale, Y - Scale);

                if (PlayerModeNum == 0) {
                    C.DrawColor = class'HUD'.default.WhiteColor;
                } else {
                    C.DrawColor = BeatColors[CurrentSong.default.BeatList[Bi].Type];
                }

                C.DrawTileClipped(Texture'WhiteTexture', Scale * 2, Scale * 2, 0, 0, 1, 1);
            }
        }

        if (bCanHit && !bPausedSong && (LaserBlastTime > 0.f || bAutoFireMode)) {
            // See if hit by player laser.
            // First sort movement delta in ascending order
            // Needs to swap
            if (X < OlX) {
                Alpha = X;
                OlX = X;
                X = Alpha;
            }

            // Needs to swap
            if (Y < OlY) {
                Alpha = Y;
                OlY = Y;
                Y = Alpha;
            }

            // Check all paddles
            for (Bi = 0; Bi < 4; ++Bi) {
                if (
                    (bAutoFireMode || DirectionPads[Bi].FireTimer > 0.f) &&
                    (OlX + Scale) > DirectionPads[Bi].XPos &&
                    (X - Scale) < DirectionPads[Bi].EndX &&
                    (OlY + Scale) > DirectionPads[Bi].YPos &&
                    (Y - Scale) < DirectionPads[Bi].EndY
                ) {
                    if (bAutoFireMode) {
                        DirectionPads[Bi].FireTimer = 0.125;
                    }

                    bNeedsHit = false;
                    HitBeat(i);
                    break;
                }
            }
        }
    }
    bMakingHitCheck = false;

    // Draw beat explosions.
    C.Style = 3; // Translucent
    for (i = (Explosions.Length - 1); i >= 0; --i) {
        if ((Explosions[i].Time -= DeltaTime) <= 0.f) {
            Explosions.Remove(i, 1);
        } else {
            Alpha = Explosions[i].Time * 2.f;
            C.DrawColor = BeatColors[Explosions[i].Type];
            C.DrawColor.R = float(C.DrawColor.R) * Alpha;
            C.DrawColor.G = float(C.DrawColor.G) * Alpha;
            C.DrawColor.B = float(C.DrawColor.B) * Alpha;
            Alpha = 1.f - Alpha;
            Scale = (1.f + (Alpha * 1.5)) * 4.f * ScreenScale;

            if (Explosions[i].Type == 1) {
                Scale *= 2.5f;
            }

            X = Explosions[i].X * C.ClipX;
            Y = Explosions[i].Y * C.ClipY;

            for (Bi = 0; Bi < MAX_Spreaders; ++Bi) {
                C.SetPos(
                    X - Scale + ExplosionTypes[Explosions[i].Num].Spread[Bi].X * Alpha,
                    Y - Scale + ExplosionTypes[Explosions[i].Num].Spread[Bi].Y * Alpha
                );
                C.DrawTileClipped(Texture'WhiteTexture', Scale * 2, Scale * 2, 0, 0, 1, 1);
            }
        }
    }

    // Render player controller X.
    for (i = 0; i < 4; ++i) {
        C.SetPos(DirectionPads[i].XPos, DirectionPads[i].YPos);

        if (DirectionPads[i].FireTimer > 0.f) {
            if (PlayerChallengeMode == 3 && HoldingLaserButton == i) {
                LaserBlastTime = 0.125;
                DirectionPads[i].FireTimer = 0.125;
                Bi = 255;
            } else {
                Bi = Min(36 + DirectionPads[i].FireTimer * 1800, 255);
            }

            if (PlayerModeNum == 0) {
                C.SetDrawColor(Bi, Bi, Bi, 255);
            } else {
                C.SetDrawColor(Bi, Bi, 36, 255);
            }
            DirectionPads[i].FireTimer -= DeltaTime;
        } else {
            C.DrawColor = GreyLineColor;
        }

        C.DrawTile(Texture'WhiteTexture', DirectionPads[i].XSize, DirectionPads[i].YSize, 0, 0, 1, 1);
    }

    // Mid cross
    C.Style = 1; // Normal

    if (PlayerModeNum == 0) {
        C.DrawColor = class'HUD'.default.WhiteColor;
    } else {
        C.DrawColor = class'HUD'.default.RedColor;
    }

    C.SetPos(DirectionPads[0].EndX, DirectionPads[0].YPos);
    C.DrawTile(Texture'WhiteTexture', CrossWidth, DirectionPads[0].YSize, 0, 0, 1, 1);
    C.SetPos(DirectionPads[1].XPos, DirectionPads[1].EndY);
    C.DrawTile(Texture'WhiteTexture', DirectionPads[0].YSize, CrossWidth, 0, 0, 1, 1);

    if (LaserBlastTime > 0.f) {
        LaserBlastTime = FMax(LaserBlastTime - DeltaTime, 0.f);

        if (LaserBlastTime <= 0 && bNeedsHit && !bIsSpectator) {
            bNeedsHit = false;

            if (!bIsDevMode && BeatCombo >= 10) {
                AddComboVis(0.25 + FRand() * 0.5, 0.25 + FRand() * 0.5, 0);
            }

            BeatCombo = 0;
        }
    }

    C.Font = Font'Engine.DefaultFont';

    if (PlayerChallengeMode > 0) {
        if ((ChallengeTimer -= DeltaTime) <= 0) {
            if (PlayerChallengeMode == 2) {
                ChallengeEndMsgTime = 3.f;
                ChallengeScore = ChallengeBeats * 1000;

                if (ChallengeScore > 0) {
                    GiveScore(ChallengeScore);
                }

                DoSoundFX(Sound'ChallengeDone', 1);
            }

            PlayerChallengeMode = 0;
        }

        if (ChallengeTimer > (ChallengeLength - 3.f)) {
            C.Style = 3; // Translucent
            i = (ChallengeTimer - ChallengeLength + 3.f) * 67;

            if (PlayerModeNum == 0) {
                C.SetDrawColor(i, i, i, 255);
            } else {
                C.SetDrawColor(0, i, i, 255);
            }

            C.Style = 3; // Translucent
            C.FontScaleX = ScreenScale * 5.f;
            C.FontScaleY = C.FontScaleX;
            C.TextSize(ChallengeNames[PlayerChallengeMode - 1], X, Y);
            C.SetPos((C.ClipX - X) * 0.5, C.ClipY * 0.35);
            C.DrawTextClipped(ChallengeNames[PlayerChallengeMode - 1]);
            C.FontScaleX = 1;
            C.FontScaleY = 1;
        }

        if (PlayerModeNum != 0) {
            // Draw cross with gold overlay.
            C.Style = 5; // Alpha
            i = Min(ChallengeTimer * 80, 255);
            C.SetDrawColor(255, 255, 0, i);

            C.SetPos(DirectionPads[0].EndX, DirectionPads[0].YPos);
            C.DrawTile(Texture'WhiteTexture', CrossWidth, DirectionPads[0].YSize, 0, 0, 1, 1);
            C.SetPos(DirectionPads[1].XPos, DirectionPads[1].EndY);
            C.DrawTile(Texture'WhiteTexture', DirectionPads[0].YSize, CrossWidth, 0, 0, 1, 1);
        }

        C.Style = 1; // Normal
    }

    // Network replication
    if (LastBlastedBeat >= 0) {
        if (NumSpectators > 0) {
            OnBeatCombo(
                Clamp(ScoreVisuals[LastBlastedBeat].X * 200.f, 0, 200),
                Clamp(ScoreVisuals[LastBlastedBeat].Y * 200.f, 0, 200),
                ScoreVisuals[LastBlastedBeat].Counter
            );
        }

        LastBlastedBeat = -1;
    }

    if (bStatsChanged) {
        if (NumSpectators > 0) {
            OnStatsChange(BeatCombo, ScoreMultiplier, PlayerScore);
        }

        bStatsChanged = false;
    }

    if (bIsDevMode) {
        // Draw rulers
        C.Style = 3; // Translucent
        C.SetDrawColor(16, 16, 16, 255);
        C.SetPos(C.ClipX * 0.125 - 1, 0);
        C.DrawTile(Texture'WhiteTexture', 2, C.ClipY, 0, 0, 1, 1);
        C.SetPos(C.ClipX * 0.25 - 1, 0);
        C.DrawTile(Texture'WhiteTexture', 2, C.ClipY, 0, 0, 1, 1);
        C.SetPos(C.ClipX * 0.375 - 1, 0);
        C.DrawTile(Texture'WhiteTexture', 2, C.ClipY, 0, 0, 1, 1);
        C.SetPos(C.ClipX * 0.625 - 1, 0);
        C.DrawTile(Texture'WhiteTexture', 2, C.ClipY, 0, 0, 1, 1);
        C.SetPos(C.ClipX * 0.75 - 1, 0);
        C.DrawTile(Texture'WhiteTexture', 2, C.ClipY, 0, 0, 1, 1);
        C.SetPos(C.ClipX * 0.875 - 1, 0);
        C.DrawTile(Texture'WhiteTexture', 2, C.ClipY, 0, 0, 1, 1);

        C.SetPos(0, C.ClipY * 0.125 - 1);
        C.DrawTile(Texture'WhiteTexture',C.ClipX, 2, 0, 0, 1, 1);
        C.SetPos(0, C.ClipY * 0.25 - 1);
        C.DrawTile(Texture'WhiteTexture',C.ClipX, 2, 0, 0, 1, 1);
        C.SetPos(0, C.ClipY * 0.375 - 1);
        C.DrawTile(Texture'WhiteTexture',C.ClipX, 2, 0, 0, 1, 1);
        C.SetPos(0, C.ClipY * 0.625 - 1);
        C.DrawTile(Texture'WhiteTexture',C.ClipX, 2, 0, 0, 1, 1);
        C.SetPos(0, C.ClipY * 0.75 - 1);
        C.DrawTile(Texture'WhiteTexture',C.ClipX, 2, 0, 0, 1, 1);
        C.SetPos(0, C.ClipY * 0.875 - 1);
        C.DrawTile(Texture'WhiteTexture',C.ClipX, 2, 0, 0, 1, 1);
        C.Style = 1; // Normal

        C.DrawColor = class'HUD'.default.BlueColor;
        C.SetPos(5, 5);
        C.DrawText("Time: " $ (GameTimer / CalcBeatsPerMin) $ " SecTime: " $ ((SectionDuration - SongSecTimer) / CalcBeatsPerMin));

        C.SetPos(5, 14);

        if (BeatAddMode == 2) {
            C.DrawText("+- Beat Travel time: " $ BeatTravelTime);
        } else if (BeatAddMode == 4) {
            C.DrawText("+- Beat DeadEnd time: " $ (BeatTravelTime * EndTravelTime));
        } else if (BeatAddMode == 6) {
            C.DrawText("+- Waver size: " $ WaverSize $ " */ Waver sine: " $ WaverSine $ " 12 Sine of: " $ WaverSineOffset);
        }

        C.SetPos(5, 23);

        switch (NewBeatType) {
            case 0:
                C.DrawText("Normal beat");
                break;
            case 1:
                C.DrawText("Large beat");
                break;
            case 2:
                C.DrawText("TikTok beat");
                break;
            case 3:
                C.DrawText("Halt'nDie beat");
                break;
            case 4:
                C.DrawText("Waver beat");
                break;
            case 5:
                C.DrawText("Spinning beat");
                break;
            case 6:
                C.DrawText("TikTokWarp beat");
                break;
            case 7:
                C.DrawText("Trail beat");
                break;
            case 8:
                C.DrawText("Speedy beat");
                break;
            case 9:
                C.DrawText("OrangeWaver beat");
                break;
            case 10:
                C.DrawText("Orange beat");
                break;
            case 11:
                C.DrawText("Challenge beat");
                C.CurX = 10;
                C.DrawText("345:" $ ChallengeNames[TripletRollerType]);
                break;
            case 12:
                C.DrawText("BlueSplit beat");
                break;
            case 13:
                C.DrawText("Flicker beat");
                break;
            default:
                C.DrawText("<UNKOWN> beat");
        }
    } else {
        if (bWasMultiUp) {
            bWasMultiUp = false;
            i = NewMultiVisuals.Length;
            NewMultiVisuals.Length = i + 1;
            NewMultiVisuals[i].Time = 2.f;
            NewMultiVisuals[i].Score = (BeatCombo + 10);
            NewMultiVisuals[i].Multi = ScoreMultiplier;
        }

        // Draw score and score multiplier
        C.Style = 3; // Translucent
        C.FontScaleX = ScreenScale * 4.f;
        C.FontScaleY = C.FontScaleX;

        // Draw combo counters on screen.
        for (i = (ScoreVisuals.Length - 1); i >= 0; --i) {
            if (PlayerModeNum == 0 || (ScoreVisuals[i].Time -= DeltaTime) <= 0) {
                ScoreVisuals.Remove(i, 1);
            } else {
                Bi = ScoreVisuals[i].Time * 200;
                C.SetDrawColor(0, Bi, Bi, 255);

                if (ScoreVisuals[i].Counter == 0) {
                    S = "MISS";
                } else {
                    S = "+" $ ScoreVisuals[i].Counter;
                }

                C.TextSize(S, X, Y);
                C.SetPos(
                    ScoreVisuals[i].X * C.ClipX - (X * 0.5),
                    ScoreVisuals[i].Y * C.ClipY - (Y * 0.5) - (1.f - ScoreVisuals[i].Time) * 8.f
                );
                C.DrawTextClipped(S);
            }
        }

        // Draw super score dropdowns
        for (i = (NewScoreVisuals.Length - 1); i >= 0; --i) {
            if (PlayerModeNum == 0 || (NewScoreVisuals[i].Time -= DeltaTime) <= 0) {
                NewScoreVisuals.Remove(i, 1);
            } else {
                Bi = NewScoreVisuals[i].Time * 100;
                C.SetDrawColor(0, Bi, Bi, 255);
                C.SetPos(2, 2 + (2.f - NewScoreVisuals[i].Time) * 20.f);
                C.DrawText(string(NewScoreVisuals[i].Score));
            }
        }

        // Draw multi-up dropdowns
        for (i = (NewMultiVisuals.Length - 1); i >= 0; --i) {
            if (PlayerModeNum == 0 || (NewMultiVisuals[i].Time -= DeltaTime) <= 0) {
                NewMultiVisuals.Remove(i, 1);
            } else {
                S = NewMultiVisuals[i].Score $ "X" $ NewMultiVisuals[i].Multi;
                C.TextSize(S, X, Y);
                Bi = NewMultiVisuals[i].Time * 100;
                C.SetDrawColor(0, Bi, Bi, 255);
                C.SetPos(C.ClipX - (X + 2), C.ClipY - (Y + 2) - (2.f - NewMultiVisuals[i].Time) * 20.f);
                C.DrawText(S);
            }
        }

        // Draw challenge bonus
        if (ChallengeScore >= 0) {
            if ((ChallengeEndMsgTime -= DeltaTime) <= 0.f) {
                ChallengeScore = -1;
            } else {
                Bi = Min(ChallengeEndMsgTime * 100.f, 250);
                C.SetDrawColor(0, Bi, Bi, 255);
                DrawCenteredText(C, "Challenge completed", C.ClipY * 0.25);
                DrawCenteredText(C, "+" $ ChallengeScore $ " bonus", C.ClipY * 0.55);
            }
        }

        // Draw score
        if (PlayerModeNum == 0) {
            C.DrawColor = class'HUD'.default.WhiteColor;
        } else {
            C.DrawColor = class'HUD'.default.CyanColor;
        }

        C.SetPos(2, 2);
        C.DrawText(PlayerScore);

        // Draw multiplier
        S = (BeatCombo + 10) $ "X" $ ScoreMultiplier;
        C.TextSize(S, X, Y);
        C.SetPos(C.ClipX - (X + 2), C.ClipY - (Y + 2));
        C.DrawText(S);

        // Draw spectator count
        if (NumSpectators > 0) {
            C.SetPos(C.ClipX * 0.6, 2);
            C.DrawText(NumSpectators);
        }

        C.FontScaleX = 1;
        C.FontScaleY = 1;

        // Draw mode bars
        if (!bIsSpectator) {
            X = (C.ClipX / 2 - 4);
            DrawBarLine(C, 2, C.ClipY - 10, X, 4, PlayerHits, CurrentSong.default.Modes[PlayerModeNum].Up);
            DrawBarLine(C, 2, C.ClipY - 5, X, 4, PlayerMisses, CurrentSong.default.Modes[PlayerModeNum].Down);
        }
    }

    if (bFadeOutMenu) {
        // Fade screen to black here.
        C.Style = 5; // Alpha
        C.SetPos(0, 0);
        C.SetDrawColor(0, 0, 0, Clamp(255 - (MenuFadeTime * 128.f), 0, 255));
        C.DrawTile(Texture'WhiteTexture', C.ClipX, C.ClipY, 0, 0, 1, 1);
    }

    C.OrgX = 0;
    C.OrgY = 0;
    C.ClipX = CX;
    C.ClipY = CY;

    return false;
}

final function DrawBarLine(Canvas C, float X, float Y, float XS, float YS, int Nom, int Denom) {
    local float A;

    if (Nom == 0)    return;

    A = FMin(float(Nom) / float(Denom), 1.f);
    C.SetPos(X, Y);
    C.DrawTile(Texture'WhiteTexture', XS * A, YS, 0, 0, 1, 1);
}

final function AddComboVis(float X, float Y, int Num) {
    local int i;

    i = ScoreVisuals.Length;
    ScoreVisuals.Length = i + 1;
    ScoreVisuals[i].X = X;
    ScoreVisuals[i].Y = Y;
    ScoreVisuals[i].Time = 1.f;
    ScoreVisuals[i].Counter = Num;
    LastBlastedBeat = i;
}

final function AddBeatExplosion(byte Type, float X, float Y) {
    local int i;

    i = Explosions.Length;
    Explosions.Length = i + 1;
    Explosions[i].Type = Type;
    Explosions[i].X = X * 0.01f;
    Explosions[i].Y = Y * 0.01f;
    Explosions[i].Time = 0.5f;
    Explosions[i].Num = Rand(ArrayCount(ExplosionTypes));
}

final function GiveScore(int Amount) {
    local int Old;

    Old = PlayerScore / 100000;
    PlayerScore += Amount;

    if (Old != (PlayerScore / 100000)) {
        Old = NewScoreVisuals.Length;
        NewScoreVisuals.Length = Old + 1;
        NewScoreVisuals[Old].Time = 2.f;
        NewScoreVisuals[Old].Score = PlayerScore;
    }
}

final function AlterMode(byte NewMode, bool bUp) {
    BeatFXNum = 0;

    if (bUp) {
        if (NumSpectators > 0) {
            OnModeUp(NewMode);
        }

        if (NewMode == CurrentSong.default.Modes.Length) {
            PlayerModeNum = NewMode - 1;
            PlayerHits = 0;
            ++ScoreMultiplier;
            DoSoundFX(Sound'MultiUp', 1);
            bWasMultiUp = true;
        } else {
            PlayerModeNum = NewMode;
            PlayerHits = 0;
            PlayerMisses = 0;
            DoSoundFX(Sound'ModeUp', 1);
            AudioFX[0].ChangeModeNum(NewMode);
            AudioFX[1].ChangeModeNum(NewMode);
        }
    } else {
        if (NumSpectators > 0) {
            OnModeDown(NewMode);
        }

        if (NewMode == 255) {
            // GAME OVER!
            if (!bIsSpectator) {
                CompletedPrct = (float(CurrentSection - 1) + ((SectionDuration-SongSecTimer) / SectionDuration)) / float(CurrentSong.default.SongOrder.Length) * 100.f;

                if (WindowRefOwner.RepActor != none ) {
                    WindowRefOwner.RepActor.ServerSubmitScores(CurrentSong, PlayerScore, Min(CompletedPrct, 99));
                }

                SwitchToMenu(MENU_EndGame);
            }

            DoSoundFX(Sound'PaddleDeath', 1);
        } else {
            PlayerModeNum = NewMode;
            PlayerHits = 0;
            PlayerMisses = 0;

            if (NewMode > 0) {
                DoSoundFX(Sound'ModeDown', 1);
            }

            AudioFX[0].ChangeModeNum(NewMode);
            AudioFX[1].ChangeModeNum(NewMode);
        }
    }
}

function HitBeat(int Num )
{
    local int j,iParent,Count,i;
    local bool bNoHitSound;

    // Spawn children.
    iParent = Beats[Num].Index;
    if (CurrentSong.default.BeatList[iParent].PCount>0 )
    {
        Count = CurrentSong.default.BeatList[iParent].PBeat+CurrentSong.default.BeatList[iParent].PCount;
        i = Beats.Length;
        Beats.Length = i+CurrentSong.default.BeatList[iParent].PCount;
        for(j=CurrentSong.default.BeatList[iParent].PBeat; j<Count; ++j )
        {
            InitBeat(i,j);
            Beats[i].CurTime = 0.f;
            ++i;
        }
        if (CurrentSong.default.BeatList[iParent].Type==12 )
            DoSoundFX(Sound'BitFireworks',1); // Blue split beat fireworks.
    }

    // Initiate challenge.
    if (CurrentSong.default.BeatList[iParent].Type==11 )
    {
        ChallengeTimer = ChallengeLength;
        ChallengeBeats = 0;
        PlayerChallengeMode = int(CurrentSong.default.BeatList[iParent].Sine)+1;
        DoSoundFX(Sound'PowerUp',1);
        bNoHitSound = true;
    }

    if (!bIsDevMode )
    {
        if (!bNoHitSound && PlayerChallengeMode==2 )
            ++ChallengeBeats;
        if (BeatCombo>=9 && !bIsSpectator )
            AddComboVis(Beats[Num].X*0.01,Beats[Num].Y*0.01,BeatCombo+1);
        if (CurrentSong.default.Modes[PlayerModeNum].bExplosions )
            AddBeatExplosion(CurrentSong.default.BeatList[iParent].Type,Beats[Num].X,Beats[Num].Y);
        RemoveBeat(Num);

        if (!bIsSpectator )
        {
            bStatsChanged = true;

            // Give additional boost with good combo going.
            if (BeatCombo>25 )
            {
                ++PlayerHits;
                if (BeatCombo>50 )
                    ++PlayerHits;
                if (BeatCombo>100 )
                {
                    ++PlayerHits;
                    if (BeatCombo>200 )
                        ++PlayerHits;
                    if (BeatCombo>500 )
                        ++PlayerHits;
                }
            }

            if (++PlayerHits>=CurrentSong.default.Modes[PlayerModeNum].Up )
                AlterMode(PlayerModeNum+1,true);

            GiveScore((BeatCombo+10)*ScoreMultiplier);
            ++BeatCombo;
        }
    }
    else RemoveBeat(Num);

    if (!bNoHitSound && LastFXTime!=LastSeconds ) // Don't overleap multiple sounds when hitting row of beats.
    {
        LastFXTime = LastSeconds;
        if (PlayerModeNum==0 )
            DoSoundFX(Sound'N_PaddleImpact1');
        else
        {
            DoSoundFX(CurrentSong.default.Modes[PlayerModeNum].FX[BeatFXNum]);
            if (++BeatFXNum==CurrentSong.default.Modes[PlayerModeNum].FX.Length )
                BeatFXNum = 0;
        }
    }
}

function MissedBeat() {
    if (!bIsDevMode && !bIsSpectator) {
        bStatsChanged = true;

        if (BeatCombo >= 10) {
            AddComboVis(0.25 + FRand() * 0.5, 0.25 + FRand() * 0.5, 0);
        }

        if (++PlayerMisses >= CurrentSong.default.Modes[PlayerModeNum].Down) {
            ScoreMultiplier = 1;

            if (PlayerModeNum == 0) {
                AlterMode(255, false);
            } else {
                AlterMode(PlayerModeNum - 1, false);
            }
        }
        BeatCombo = 0;
    }

    AudioFX[0].PlaySound(Sound'BeatMiss', SLOT_None);
}

final function DeleteBeat(int Index, optional bool bSub, optional out int OrgIndex) {
    local int i, Count;

    // First delete all children if there are any.
    if (CurrentSong.default.BeatList[Index].PCount > 0) {
        Count = CurrentSong.default.BeatList[Index].PBeat + CurrentSong.default.BeatList[Index].PCount;

        for (i = CurrentSong.default.BeatList[Index].PBeat; i < Count; ++i) {
            DeleteBeat(i, true, Index);
        }
    }

    // Make unreferenced by visuals.
    for (i = 0; i < Beats.Length; ++i) {
        if (Beats[i].Index == Index) {
            RemoveBeat(i--);
        } else if (Beats[i].Index > Index) {
            --Beats[i].Index;
        }
    }
    Explosions.Length = 0;

    // If were a child beat, make sure no parents are referencing to us.
    if (Index < CurrentSong.default.StartingBeatIndex) {
        if (!bSub) {
            Count = CurrentSong.default.BeatList.Length;

            for (i = 0; i < Count; ++i) {
                if (
                    CurrentSong.default.BeatList[i].PCount > 0 &&
                    Index >= CurrentSong.default.BeatList[i].PBeat &&
                    Index <= (CurrentSong.default.BeatList[i].PBeat + CurrentSong.default.BeatList[i].PCount)
                ) {
                    --CurrentSong.default.BeatList[i].PCount; // Simply reduce child beat count.
                    break;
                }
            }
        }
        --CurrentSong.default.StartingBeatIndex;
    }

    // Finally safe to remove beat.
    if (OrgIndex > Index) {
        --OrgIndex;
    }
    CurrentSong.default.BeatList.Remove(Index, 1);
}

final function FireLaser(byte Dir, bool bRelease) {
    if (bRelease) {
        if (bIsSpectator || Dir == HoldingLaserButton) {
            HoldingLaserButton = 255;

            if (NumSpectators > 0) {
                OnFireLaser(0, true);
            }
        }
    } else {
        LaserBlastTime = 0.125;

        // Dual directions
        if (PlayerChallengeMode == 1) {
            switch (Dir) {
                case 0:
                    DirectionPads[2].FireTimer = 0.125;
                    break;
                case 1:
                    DirectionPads[3].FireTimer = 0.125;
                    break;
                case 2:
                    DirectionPads[0].FireTimer = 0.125;
                    break;
                case 3:
                    DirectionPads[1].FireTimer = 0.125;
                    break;
            }
        } // Rotate paddle.
        else if (PlayerChallengeMode == 2 && !bIsSpectator) {
            --Dir;

            if (Dir == 255) {
                Dir = 3;
            }
        }

        DirectionPads[Dir].FireTimer = 0.125;

        // Mega laser.
        if (PlayerChallengeMode == 3) {
            HoldingLaserButton = Dir;
        } else {
            bNeedsHit = true;
        }

        if (NumSpectators > 0) {
            OnFireLaser(Dir, false);
        }
    }
}

function bool GameInputKey(out byte Key, out byte State, float delta)
{
    local byte CH;

    if (CurrentGameMenu!=MENU_InGame || bIsSpectator )
        return false;

    if (State==1 ) // Press
    {
        // PlayerOwner().ClientMessage("Key"@Key);

        switch(Key )
        {
        case 80: // P
            if (bIsDevMode )
                SetPaused(!bPausedSong);
            break;
        case 46: // Delete
            if (bIsDevMode && SelectedBeatIndex>=0 )
            {
                DeleteBeat(SelectedBeatIndex);
                SelectedBeatIndex = -1;
            }
            break;
        case 17: // Ctrl
            BeatAddMode = 0;
            if (bIsDevMode )
                bAddBeatsMode = !bAddBeatsMode;
            break;
        case 2: // Right mouse.
            if (bIsDevMode )
                BeatAddMode = 0;
            break;
        case 37: // Arrow keys
        case 38:
        case 39:
        case 40:
            if (!bNeedsHit || LaserBlastTime<=0 )
                FireLaser(Key-37,false);
            break;
        case 107: //+
            if (bIsDevMode )
            {
                if (BeatAddMode==2 )
                    IncrementFloat(BeatTravelTime,false);
                else if (BeatAddMode==4 )
                    IncrementFloat(EndTravelTime,false);
                else if (BeatAddMode==6 )
                    WaverSize+=0.025;
            }
            break;
        case 109: //-
            if (bIsDevMode )
            {
                if (BeatAddMode==2 )
                    IncrementFloat(BeatTravelTime,true);
                else if (BeatAddMode==4 )
                    IncrementFloat(EndTravelTime,true);
                else if (BeatAddMode==6 )
                    WaverSize-=0.025;
            }
            break;
        case 106: // *
            if (bIsDevMode )
            {
                if (BeatAddMode==6 )
                    WaverSine+=0.25;
            }
            break;
        case 111: // /
            if (bIsDevMode )
            {
                if (BeatAddMode==6 )
                    WaverSine-=0.25;
            }
            break;
        case 49: // 1
            if (bIsDevMode )
            {
                if (BeatAddMode==6 )
                    WaverSineOffset-=0.25;
            }
            break;
        case 50: // 2
            if (bIsDevMode )
            {
                if (BeatAddMode==6 )
                    WaverSineOffset+=0.25;
            }
            break;
        case 51: // 3
            TripletRollerType = 0;
            break;
        case 52: // 4
            TripletRollerType = 1;
            break;
        case 53: // 5
            TripletRollerType = 2;
            break;
        case 81: // Q
            CH = 1;
            break;
        case 87: // W
            CH = 2;
            break;
        case 69: // E
            CH = 3;
            break;
        case 82: // R
            CH = 4;
            break;
        case 84: // T
            CH = 5;
            break;
        case 89: // Y
            CH = 6;
            break;
        case 85: // U
            CH = 7;
            break;
        case 73: // I
            CH = 8;
            break;
        case 79: // O
            CH = 9;
            break;
        case 65: // A
            CH = 10;
            break;
        case 83: // S
            CH = 11;
            break;
        case 68: // D
            CH = 12;
            break;
        case 70: // F
            CH = 13;
            break;
        case 71: // G
            CH = 14;
            break;
        case 72: // H
            CH = 15;
            break;
        case 74: // J
            CH = 16;
            break;
        }
        if (CH>0 && bIsDevMode )
        {
            if (!bAddBeatsMode && SelectedBeatIndex>=0 )
                CurrentSong.default.BeatList[SelectedBeatIndex].Type = (CH-1);
            else NewBeatType = (CH-1);
        }
    }
    else if (State==3 ) // Release.
    {
        switch(Key )
        {
        case 37: // Arrow keys
        case 38:
        case 39:
        case 40:
            FireLaser(Key-37,true);
            break;
        }
    }
    return false;
}

// Key Strokes
function bool GameKeyStroke(out byte Key, optional string Unicode) {
    return false;
}

function bool GameMouseClick(GUIComponent Sender) {
    if (CurrentGameMenu != MENU_InGame) {
        bMakingHitCheck = !bFadeOutMenu;
    }
    else if (bIsDevMode) {
        if (bAddBeatsMode) {
            ++BeatAddMode;
        } else {
            bMakingHitCheck = true;
        }
    }

    return false;
}

final function IncrementFloat(out float V, bool bSubstract) {
    if (bSubstract) {
        if (V <= 0.5f) {
            V -= 0.05f;
        } else if (V <= 1.f) {
            V -= 0.25f;
        } else if (V <= 2.f) {
            V -= 0.5f;
        } else {
            V -= 1.f;
        }
    }
    else {
        if (V < 0.5f) {
            V += 0.05f;
        } else if (V < 1.f) {
            V += 0.25f;
        } else if (V < 2.f) {
            V += 0.5f;
        } else {
            V += 1.f;
        }
    }
}

final function SwitchToMenu(ECurrentGameMenu M, optional bool bInstant) {
    bIsSpectator = false;

    if (CurrentGameMenu == MENU_InGame) {
        OnStartedSong(none);
        SetPaused(true);
        PendingMenu = M;
        bFadeOutMenu = true;
        MenuFadeTime = 2.f;
    }
    else {
        bFadeOutMenu = true;
        MenuFadeTime = 1.f;
        PendingMenu = M;
    }

    if (bInstant) {
        MenuFadeTime = 0.f;
    }
}

final function OpenUpMenu(ECurrentGameMenu M) {
    bScoresRequested = false;
    WindowRefOwner.CurrentScorePage = 0;
    bFadeOutMenu = false;
    CurrentGameMenu = M;

    if (CurrentGameMenu == MENU_InGame) {
        StartSong(CurrentSong);
    }
    else {
        if (M == MENU_MainMenu) {
            CurrentSong = none;
        }

        OnDraw = RenderGameMenu;
    }
}

final function ChangeScorePage(int GameChange, optional int OffsetChange) {
    local int i;

    if (GameChange != 0) {
        for (i = 0; i < AvailableGames.Length; ++i) {
            if (AvailableGames[i] == CurrentSong)    break;
        }

        i += GameChange;

        if (i < 0) {
            i = AvailableGames.Length - 1;
        } else if (i >= AvailableGames.Length) {
            i = 0;
        }

        WindowRefOwner.CurrentScorePage = 0;
        bScoresRequested = false;
    } else if (OffsetChange != 0)
    {
        i = WindowRefOwner.CurrentScorePage;
        WindowRefOwner.CurrentScorePage += OffsetChange;

        if (WindowRefOwner.CurrentScorePage < 0) {
            WindowRefOwner.CurrentScorePage = 0;
        }

        if (WindowRefOwner.CurrentScorePage != i) {
            bScoresRequested = false;
        }
    }
}

final function float DrawCenteredText(Canvas C, string S, float YPos) {
    local float XS, YS;

    C.TextSize(S, XS, YS);
    C.SetPos((C.ClipX - XS) * 0.5f, YPos);

    if (C.CurX < 0) {
        C.CurX = 0;
        YS *= 2.f;
    }

    C.DrawText(S);

    return YS;
}

final function bool DrawCenteredButton(Canvas C, string S, float YPos) {
    local float XS, YS, MX, MY;

    C.TextSize(S, XS, YS);
    C.SetPos((C.ClipX - XS) * 0.5f, YPos);
    MX = Controller.MouseX - C.OrgX;
    MY = Controller.MouseY - C.OrgY;

    if (MX >= C.CurX && MY >= C.CurY && MX <= (C.CurX + XS) && MY <= (C.CurY + YS)) {
        C.DrawColor = class'HUD'.default.GoldColor;
        C.DrawTextClipped(S);

        if (bMakingHitCheck) {
            bMakingHitCheck = false;
            return true;
        }
    } else {
        C.DrawColor = class'HUD'.default.WhiteColor;
        C.DrawTextClipped(S);
    }

    return false;
}

final function bool DrawButtonAt(Canvas C, string S, float XPos, float YPos) {
    local float XS, YS, MX, MY;

    C.TextSize(S, XS, YS);
    C.SetPos(XPos, YPos);
    MX = Controller.MouseX - C.OrgX;
    MY = Controller.MouseY - C.OrgY;

    if (MX >= C.CurX && MY >= C.CurY && MX <= (C.CurX + XS) && MY <= (C.CurY + YS)) {
        C.DrawColor = class'HUD'.default.GoldColor;
        C.DrawTextClipped(S);

        if (bMakingHitCheck) {
            bMakingHitCheck = false;
            return true;
        }
    } else {
        C.DrawColor = class'HUD'.default.WhiteColor;
        C.DrawTextClipped(S);
    }

    return false;
}

function bool RenderGameMenu(canvas C) {
    local float CX, CY, XS, YS, DeltaTime, YPos;
    local int i;

    // Update timing.
    DeltaTime = FClamp(PlayerOwner().Level.TimeSeconds - LastSeconds, 0.f, 0.25f) / 1.1f;
    LastSeconds = PlayerOwner().Level.TimeSeconds;

    CX = C.ClipX;
    CY = C.ClipY;
    C.OrgX = ActualLeft(WinLeft);
    C.OrgY = ActualTop(WinTop);
    C.ClipX = ActualWidth(WinWidth);
    C.ClipY = ActualHeight(WinHeight);

    // Draw background.
    C.Style = 1;
    C.SetPos(0, 0);
    C.SetDrawColor(0, 0, 0, 255);
    C.DrawTile(Texture'WhiteTexture', C.ClipX, C.ClipY, 0, 0, 1, 1);

    // Draw buttons
    C.Font = Font'DefaultFont';
    C.FontScaleX = C.ClipY / 130.f;
    C.FontScaleY = C.FontScaleX;
    C.TextSize("ABC", XS, YS);

    switch (CurrentGameMenu) {
        case MENU_MainMenu:
            C.SetDrawColor(255, 50, 255, 255);
            DrawCenteredText(C,"BIT.TRIP CORE", 10);

            YPos = YS * 1.5;
            for (i = 0; i < AvailableGames.Length; ++i) {
                if (DrawCenteredButton(C, "[Start " $ AvailableGames[i].default.StageName $ "]", YPos)) {
                    SwitchToMenu(MENU_InGame);
                    CurrentSong = AvailableGames[i];
                }

                YPos += YS;
                // if (!AvailableGames[i].default.bCompleted)
                //    break;
            }

            YPos += YS;

            if (DrawCenteredButton(C, "[High scores]", YPos)) {
                SwitchToMenu(MENU_HiScores);
            }

            if (DrawCenteredButton(C,"[Spectate]", YPos + YS)) {
                SwitchToMenu(MENU_Spectate);
            }

            C.SetDrawColor(255, 50, 255, 255);
            DrawCenteredText(C, "Use arrow keys to fire laser", C.ClipY - (YS * 3));
            DrawCenteredText(C, "At beats as they pass by", C.ClipY - (YS * 2));
            break;

        case MENU_EndGame:
            C.DrawColor = class'HUD'.default.CyanColor;
            YPos = YS * 1.5;
            DrawCenteredText(C, CurrentSong.default.StageName, YPos);
            YPos += YS * 1.5;

            if (CompletedPrct <= 100) {
                C.DrawColor = class'HUD'.default.RedColor;
                DrawCenteredText(C,"GAME OVER", YPos);
                DrawCenteredText(C,"SONG PROGRESS: " $ Min(CompletedPrct, 99) $ "%", YPos + YS);
            } else {
                C.DrawColor = class'HUD'.default.GreenColor;
                DrawCenteredText(C, "COMPLETED!", YPos);
            }

            C.DrawColor = class'HUD'.default.CyanColor;
            YPos = C.ClipY * 0.5;
            DrawCenteredText(C, "Your final score was:", YPos);
            DrawCenteredText(C, string(PlayerScore), YPos + YS);

            if (WindowRefOwner.ClientRank != 0) {
                C.DrawColor = class'HUD'.default.GoldColor;
                C.SetPos(0, YPos + YS * 2);

                if (WindowRefOwner.ClientRank == -1) {
                    DrawCenteredText(C, "You didn't even rank with that score!", YPos + YS * 2);
                } else if (WindowRefOwner.ClientRank == -2) {
                    DrawCenteredText(C, "Your old record still stands!", YPos + YS * 2);
                } else {
                    DrawCenteredText(C, "Your rank is: #" $ WindowRefOwner.ClientRank, YPos + YS * 2);
                }
            }

            C.DrawColor = class'HUD'.default.WhiteColor;
            C.SetPos(0, C.ClipY * 0.8);
            DrawCenteredText(C, "Click to continue.", C.ClipY * 0.8);

            if (bMakingHitCheck) {
                SwitchToMenu(MENU_HiScores);
            }
            break;

        case MENU_HiScores:
            if (!bScoresRequested) {
                bScoresRequested = true;
                WindowRefOwner.HiScores.Length = 0;
                WindowRefOwner.bHighScoresReceived = false;

                if (CurrentSong == none) {
                    CurrentSong = AvailableGames[0];
                }

                if (WindowRefOwner.RepActor != none) {
                    WindowRefOwner.RepActor.ClientCheckScores(CurrentSong, WindowRefOwner.CurrentScorePage);
                }
            }
            C.FontScaleX *= 0.75;
            C.FontScaleY = C.FontScaleX;
            YS *= 0.75;
            C.DrawColor = class'HUD'.default.CyanColor;
            YPos = YS * 0.5;
            DrawCenteredText(C, "High scores:", YPos);
            YPos += YS;
            DrawCenteredText(C, CurrentSong.default.StageName, YPos);

            // Next/Prev game buttons.
            // Prev game.
            if (DrawButtonAt(C, "<<", 20, YPos)) {
                ChangeScorePage(-1);
            }

            C.TextSize(">>", XS, YS);
            // Next game.
            if (DrawButtonAt(C, ">>", C.ClipX - 20 - XS, YPos)) {
                ChangeScorePage(1);
            }

            YPos += YS * 2;
            C.DrawColor = class'HUD'.default.CyanColor;

            // Draw scores.
            C.FontScaleX *= 0.5;
            C.FontScaleY = C.FontScaleX;
            WindowRefOwner.RenderHiScores(C, YPos, YS * 0.5f);
            C.FontScaleX *= 2.f;
            C.FontScaleY = C.FontScaleX;

            // Next/Prev scores page buttons.
            YPos = C.ClipY - (YS * 2);
            // Prev page.
            if (DrawButtonAt(C, "<<", 20, YPos)) {
                ChangeScorePage(0, -20);
            }

            // Next page.
            if (DrawButtonAt(C, ">>", C.ClipX - 20 - XS, YPos)) {
                ChangeScorePage(0, 20);
            }

            // Exit menu button.
            if (DrawCenteredButton(C, "[Exit to main menu]", YPos)) {
                SwitchToMenu(MENU_MainMenu);
            }
            break;

        case MENU_Spectate:
            if (!bScoresRequested || (SectionDuration -= DeltaTime) <= 0.f) {
                bScoresRequested = true;
                SectionDuration = 5.f;
                WindowRefOwner.SpecClients.Length = 0;

                if (WindowRefOwner.RepActor != none) {
                    WindowRefOwner.RepActor.ClientCheckSpec();
                }
            }

            C.FontScaleX *= 0.75;
            C.FontScaleY = C.FontScaleX;
            YS *= 0.75;
            C.DrawColor = class'HUD'.default.CyanColor;
            YPos = YS * 0.5;
            DrawCenteredText(C, "Spectate another player:", YPos);
            YPos += (YS * 3);

            // Draw scores.
            C.FontScaleX *= 0.5;
            C.FontScaleY = C.FontScaleX;
            RenderSpecList(C, YPos, XS * 0.5f);
            C.FontScaleX *= 2.f;
            C.FontScaleY = C.FontScaleX;

            // Exit menu button.
            YPos = C.ClipY - (YS * 2);
            if (DrawCenteredButton(C, "[Exit to main menu]", YPos)) {
                SwitchToMenu(MENU_MainMenu);
            }
            break;
    }

    if (bFadeOutMenu) {
        MenuFadeTime -= DeltaTime;

        if (MenuFadeTime <= 0.f) {
            OpenUpMenu(PendingMenu);
        }

        // Fade screen to black here.
        C.Style = 5; // Alpha
        C.SetPos(0, 0);
        C.SetDrawColor(0, 0, 0, Clamp(255 - (MenuFadeTime * 255.f), 0, 255));
        C.DrawTile(Texture'WhiteTexture', C.ClipX, C.ClipY, 0, 0, 1, 1);
    }

    bMakingHitCheck = false;
    C.OrgX = 0;
    C.OrgY = 0;
    C.ClipX = CX;
    C.ClipY = CY;
    C.FontScaleX = 1;
    C.FontScaleY = 1;

    return false;
}

final function RenderSpecList(Canvas C, float YPos, float YS) {
    local int i;
    local float NameXPos, GameXPos, MX, MY;

    NameXPos = C.ClipX * 0.1;
    GameXPos = C.ClipX * 0.6;

    MX = Controller.MouseX - C.OrgX;
    MY = Controller.MouseY - C.OrgY;

    // Draw headers.
    C.DrawColor = class'HUD'.default.WhiteColor;
    C.SetPos(NameXPos, YPos);
    C.DrawText("Player:");
    C.SetPos(GameXPos, YPos);
    C.DrawText("Current stage:");

    for (i = 0; i < WindowRefOwner.SpecClients.Length; ++i) {
        YPos += YS;

        if (WindowRefOwner.SpecClients[i].ID >= 0 && MX >= 0 && MX <= C.ClipX && MY >= YPos && MY <= (YPos + YS))
        {
            C.DrawColor = class'HUD'.default.GoldColor;

            if (bMakingHitCheck) {
                WindowRefOwner.RepActor.ClientBeginSpectate(WindowRefOwner.SpecClients[i].ID);
                bMakingHitCheck = false;
            }
        } else {
            C.DrawColor = class'HUD'.default.CyanColor;
        }

        C.SetPos(NameXPos, YPos);
        C.DrawText(WindowRefOwner.SpecClients[i].PlayerName);
        C.SetPos(GameXPos, YPos);

        if (WindowRefOwner.SpecClients[i].ID == -1) {
            C.DrawText("<Not playing>");
        } else {
            C.DrawText(WindowRefOwner.SpecClients[i].GameName);
        }
    }
}

delegate OnInitSongInfo(byte MaxFX);
delegate OnSectionChange(int Sec, byte FXNum, float SecSize);
delegate OnSongOffset(float Offset);
delegate OnStartedSong(class<GameSongBase> GameClass);

// Network delegates
delegate OnSectionChangeSpec(byte Index);
delegate OnBeatCombo(byte X, byte Y, int Combo);
delegate OnModeUp(byte NewMode);
delegate OnModeDown(byte NewMode);
delegate OnStatsChange(int Combo, byte Multi, int Score);
delegate OnFireLaser(byte Dir, bool bRelease);

defaultproperties {
    AvailableGames(0)=class'Discovery'
    AvailableGames(1)=class'Control'
    CurrentGameMenu=MENU_MainMenu
    PropagateVisibility=true
    OnDraw=RenderGameMenu
    OnClick=GameMouseClick
    OnKeyType=GameKeyStroke
    OnKeyEvent=GameInputKey
    StyleName="NoBackground"
    bAcceptsInput=true
    SelectedBeatIndex=-1
    EndTravelTime=1
    BeatTravelTime=2
    WaverSize=0.1
    WaverSine=3
    ScoreMultiplier=1
    ChallengeNames(0)="DOUBLE PADDLE"
    ChallengeNames(1)="CHALLENGE"
    ChallengeNames(2)="MEGA PADDLE"
    GreyLineColor=(R=36,G=36,B=36,A=255)
    BeatColors(0)=(G=255,R=255,A=255)
    BeatColors(1)=(B=255,G=255,A=255)
    BeatColors(2)=(R=255,G=231,B=14,A=255)
    BeatColors(3)=(G=255,R=255,A=255)
    BeatColors(4)=(R=10,G=140,B=10,A=255)
    BeatColors(5)=(R=200,G=20,B=170,A=255)
    BeatColors(6)=(G=128,A=255)
    BeatColors(7)=(R=255,A=255)
    BeatColors(8)=(G=255,R=255,A=255)
    BeatColors(9)=(G=170,R=212,A=255)
    BeatColors(10)=(G=170,R=212,A=255)
    BeatColors(11)=(R=255,G=255,B=255,A=255)
    BeatColors(12)=(R=0,G=0,B=150,A=255)
    BeatColors(13)=(R=0,G=150,B=0,A=255)
    HoldingLaserButton=255
}