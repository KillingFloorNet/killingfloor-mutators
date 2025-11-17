/**
 * Author:      Marco
 * Home repo:   https://github.com/InsultingPros/BitCore
 */
class BitGameWindow extends FloatingWindow;

struct FHighScoreEntry {
    var int Index, Score;
    var byte Progress;
    var string PlayerName;
};
var transient array<FHighScoreEntry> HiScores;
var int CurrentScorePage, ClientRank;

struct FSpectateEntry {
    var string PlayerName;
    var int ID;
    var string GameName;
    var class<GameSongBase> CurrentGame;
};
var transient array<FSpectateEntry> SpecClients;

var transient BitGameWindow NewMenu;
var BitGameRep RepActor;

var automated GameControls GC_Main;
var automated GUIButton B_EnterDevMode, B_Stop, B_Play, B_Save;
var automated moNumericEdit N_SectionSelector, N_MusicFXSelect;
var automated moSlider S_SectionSlider;
var automated moFloatEdit F_SectionSlider;
var automated moCheckBox C_Autofire;

var bool bInDevMode, bReadyToEdit, bHighScoresReceived;

function Opened(GUIComponent Sender) {
    HiScores.Length = 0;
    SpecClients.Length = 0;
    bHighScoresReceived = false;
    class'BitGameWindow'.default.NewMenu = self;

    super.Opened(Sender);
}

function InitComponent(GUIController pMyController, GUIComponent MyOwner) {
    super.InitComponent(pMyController, MyOwner);

    if (PlayerOwner().Level.NetMode != NM_StandAlone) {
        RemoveComponent(B_EnterDevMode);
        RemoveComponent(N_SectionSelector);
        RemoveComponent(N_MusicFXSelect);
        RemoveComponent(S_SectionSlider);
        RemoveComponent(B_Stop);
        RemoveComponent(B_Play);
        RemoveComponent(B_Save);
        RemoveComponent(C_Autofire);
        RemoveComponent(F_SectionSlider);
    } else {
        F_SectionSlider.SetValue(0.25);
        C_Autofire.Checked(true);
        SetComponentsStatus(false);
    }

    GC_Main.WindowRefOwner = self;
    bReadyToEdit = true;
}

function Closed(GUIComponent Sender, bool bCancelled) {
    class'BitGameWindow'.default.NewMenu = none;

    if (RepActor != none) {
        RepActor.ActiveWindow = none; // To prevent game from opening main menu.
        RepActor.ServerClosedMenu();
    }

    RepActor = none;
    super.Closed(Sender, bCancelled);
}

final function SetComponentsStatus(bool bEnable) {
    if (bEnable) {
        EnableComponent(N_SectionSelector);
        EnableComponent(N_MusicFXSelect);
        EnableComponent(S_SectionSlider);
        EnableComponent(B_Stop);
        EnableComponent(B_Play);
        EnableComponent(B_Save);
        EnableComponent(C_Autofire);
        EnableComponent(F_SectionSlider);
    } else {
        DisableComponent(N_SectionSelector);
        DisableComponent(N_MusicFXSelect);
        DisableComponent(S_SectionSlider);
        DisableComponent(B_Stop);
        DisableComponent(B_Play);
        DisableComponent(B_Save);
        DisableComponent(C_Autofire);
        DisableComponent(F_SectionSlider);
    }
}

function bool InternalOnClick(GUIComponent Sender) {
    if (bReadyToEdit) {
        switch (Sender) {
            case B_EnterDevMode:
                ToggleDevMode();
                break;
            case B_Stop:
                GC_Main.SetPaused(true);
                break;
            case B_Play:
                GC_Main.SetPaused(false);
                break;
            case B_Save:
                GC_Main.SaveFile();
                break;
        }
    }

    return true;
}

function InternalOnChange(GUIComponent Sender) {
    if (bReadyToEdit) {
        switch (Sender) {
            case N_SectionSelector:
                GC_Main.ModifySongSection(N_SectionSelector.GetValue());
                break;
            case N_MusicFXSelect:
                GC_Main.ModifySongOrder(N_MusicFXSelect.GetValue());
                break;
            case S_SectionSlider:
                SetOffset(S_SectionSlider.MySlider.Value);
                break;
            case B_Save:
                GC_Main.SaveFile();
                break;
            case C_Autofire:
                GC_Main.bAutoFireMode = C_Autofire.IsChecked();
                break;
        }
    }
}

final function ToggleDevMode() {
    if (GC_Main.CurrentGameMenu != MENU_InGame) {
        PlayerOwner().ClientMessage("You must enter game before you can go to dev mode.");
        return;
    }

    bReadyToEdit = false;
    bInDevMode = !bInDevMode;

    if (bInDevMode) {
        SetComponentsStatus(true);
        GC_Main.StartDev();
        GC_Main.bAutoFireMode = C_Autofire.IsChecked();
    } else {
        SetComponentsStatus(false);
        GC_Main.EndDev();
        GC_Main.bAutoFireMode = false;
    }

    bReadyToEdit = true;
}

function NotifyInitSong(byte MaxFX) {
    bReadyToEdit = false;
    N_MusicFXSelect.MaxValue = (MaxFX - 1);
    bReadyToEdit = true;
}

function NotifySectionChange(int Sec, byte FXNum, float SecSize)
{
    bReadyToEdit = false;
    N_SectionSelector.SetValue(Sec);
    N_MusicFXSelect.SetValue(FXNum);
    S_SectionSlider.Setup(0.f, SecSize);
    bReadyToEdit = true;
}

function NotifySectionOffset(float Offset) {
    bReadyToEdit = false;
    S_SectionSlider.SetValue(Offset);
    bReadyToEdit = true;
}

function NotifyChangedSong(class<GameSongBase> GameClass) {
    if (RepActor != none) {
        RepActor.ServerStartedGame(GameClass);
    }
}

final function SetOffset(float Offset) {
    local float V;

    V = F_SectionSlider.GetValue();
    if (V > 0.f ) {
        Offset = Round(Offset / V) * V;
    }

    GC_Main.ModifySectionOffset(Offset);
}

function bool NotifyLevelChange() {
    RepActor = none;
    bPersistent = false;

    return true;
}

final function RenderHiScores(Canvas C, float YOffset, float YS) {
    local float RankX, NameX, ScoreX, ProgX;
    local int i;

    if (HiScores.Length == 0 && bHighScoresReceived) {
        C.DrawColor = class'HUD'.default.RedColor;
        C.SetPos(10, YOffset);
        C.DrawText("No highscores available yet on this game.");
    } else if (HiScores.Length > 0) {
        RankX = 5;
        NameX = C.ClipX * 0.2;
        ScoreX = C.ClipX * 0.6;
        ProgX = C.ClipX * 0.87;

        C.DrawColor = class'HUD'.default.WhiteColor;
        C.SetPos(RankX, YOffset);
        C.DrawText("RANK");
        C.SetPos(NameX, YOffset);
        C.DrawText("NAME");
        C.SetPos(ScoreX, YOffset);
        C.DrawText("SCORE");
        C.SetPos(ProgX, YOffset);
        C.DrawText("PROGRESS");
        C.DrawColor = class'HUD'.default.CyanColor;
        YOffset += YS;

        for (i = 0; i < HiScores.Length; ++i) {
            C.SetPos(RankX, YOffset);
            C.DrawText("#" $ HiScores[i].Index);

            C.SetPos(NameX, YOffset);
            C.DrawText(HiScores[i].PlayerName);

            C.SetPos(ScoreX, YOffset);
            C.DrawText(HiScores[i].Score);

            C.SetPos(ProgX, YOffset);
            C.DrawText(HiScores[i].Progress $ "%");
            YOffset += YS;
        }
    }
}

final function bool IsPlayingGame() {
    return (GC_Main.CurrentGameMenu == MENU_InGame && !GC_Main.bIsSpectator);
}

final function bool IsSpectatingGame() {
    return (GC_Main.CurrentGameMenu == MENU_InGame && GC_Main.bIsSpectator);
}

final function NotifySpecCount(byte Num) {
    if (Num > GC_Main.NumSpectators && RepActor != none) {
        RepActor.ServerInitialStats(
            GC_Main.CurrentSection - 1,
            GC_Main.SongSecTimer,
            GC_Main.PlayerModeNum,
            GC_Main.PlayerScore
        );
    }

    GC_Main.NumSpectators = Num;
}

final function StartSpectateSong(class<GameSongBase> GameClass) {
    GC_Main.CurrentSong = GameClass;
    GC_Main.SwitchToMenu(MENU_InGame, true);
    GC_Main.bIsSpectator = true;
}

final function EndSpectateSong() {
    if (IsSpectatingGame()) {
        GC_Main.SwitchToMenu(MENU_MainMenu);
    }
}

// Network callbacks
function NotifySectionChangeSpec(byte Index) {
    if (RepActor != none) {
        RepActor.ServerChangeSec(Index);
    }
}

function NotifyBeatCombo(byte X, byte Y, int Combo) {
    if (RepActor != none) {
        RepActor.ServerBeatCombo(X, Y, Combo);
    }
}

function NotifyModeUp(byte NewMode) {
    if (RepActor != none) {
        RepActor.ServerModeChange(NewMode, true);
    }
}

function NotifyModeDown(byte NewMode) {
    if (RepActor != none) {
        RepActor.ServerModeChange(NewMode, false);
    }
}

function NotifyStatsChange(int Combo, byte Multi, int Score) {
    if (RepActor != none) {
        RepActor.ServerStatsChange(Combo, Multi, Score);
    }
}

function NotifyFireLaser(byte Dir, bool bRelease) {
    if (RepActor != none) {
        RepActor.ServerFireLaser(Dir, bRelease);
    }
}

defaultproperties {
    WindowName="BIT Game Window"
    bResizeWidthAllowed=false
    bResizeHeightAllowed=false
    bPersistent=true
    bAllowedAsLast=true
    WinTop=0.1
    WinLeft=0.1
    WinWidth=0.8
    WinHeight=0.8
    DefaultLeft=0.1
    DefaultTop=0.1
    DefaultWidth=0.8
    DefaultHeight=0.8
    bMoveAllowed=false

    Begin Object class=GameControls name=MyGamerWin
        WinTop=0.05
        WinLeft=0.1
        WinWidth=0.800000
        WinHeight=0.800000
        bBoundToParent=true
        OnInitSongInfo=NotifyInitSong
        OnSectionChange=NotifySectionChange
        OnSongOffset=NotifySectionOffset
        OnStartedSong=NotifyChangedSong
        OnSectionChangeSpec=NotifySectionChangeSpec
        OnBeatCombo=NotifyBeatCombo
        OnModeUp=NotifyModeUp
        OnModeDown=NotifyModeDown
        OnStatsChange=NotifyStatsChange
        OnFireLaser=NotifyFireLaser
    End Object
    GC_Main=MyGamerWin

    Begin Object class=GUIButton name=DevButton
        Caption="DevMode"
        WinTop=0.9
        WinLeft=0.012
        WinWidth=0.05
        bBoundToParent=true
        OnClick=InternalOnClick
    End Object
    B_EnterDevMode=DevButton

    Begin Object class=moNumericEdit name=DevSectionSelect
        MinValue=0
        WinTop=0.9
        WinLeft=0.07
        WinWidth=0.07
        bBoundToParent=true
        OnChange=InternalOnChange
    End Object
    N_SectionSelector=DevSectionSelect

    Begin Object class=moNumericEdit name=DevMusicFXSelect
        MinValue=0
        WinTop=0.9
        WinLeft=0.16
        WinWidth=0.07
        bBoundToParent=true
        OnChange=InternalOnChange
    End Object
    N_MusicFXSelect=DevMusicFXSelect

    Begin Object class=moSlider name=DevMusicOffsetSlider
        MinValue=0
        WinTop=0.85
        WinLeft=0.3
        WinWidth=0.65
        bIntSlider=false
        bBoundToParent=true
        OnChange=InternalOnChange
    End Object
    S_SectionSlider=DevMusicOffsetSlider

    Begin Object class=GUIButton name=StopButton
        Caption="Stop"
        WinTop=0.7
        WinLeft=0.005
        WinWidth=0.05
        bBoundToParent=true
        OnClick=InternalOnClick
    End Object
    B_Stop=StopButton

    Begin Object class=GUIButton name=PlayButton
        Caption="Play"
        WinTop=0.8
        WinLeft=0.005
        WinWidth=0.05
        bBoundToParent=true
        OnClick=InternalOnClick
    End Object
    B_Play=PlayButton

    Begin Object class=GUIButton name=SaveButton
        Caption="Save"
        WinTop=0.2
        WinLeft=0.005
        WinWidth=0.05
        bBoundToParent=true
        OnClick=InternalOnClick
    End Object
    B_Save=SaveButton

    Begin Object class=moFloatEdit name=DevMusicOffsetRound
        MinValue=0
        MaxValue=4
        Step=0.25
        WinTop=0.92
        WinLeft=0.6
        WinWidth=0.1
        bBoundToParent=true
    End Object
    F_SectionSlider=DevMusicOffsetRound

    Begin Object class=moCheckBox name=DevModeAutoFire
        Caption="AutoFire"
        WinTop=0.92
        WinLeft=0.24
        WinWidth=0.1
        bBoundToParent=true
        OnChange=InternalOnChange
    End Object
    C_Autofire=DevModeAutoFire
}