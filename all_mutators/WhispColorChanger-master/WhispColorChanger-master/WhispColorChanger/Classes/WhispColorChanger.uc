//=============================================================================
// Base Mutator by Vel-San - Contact on Steam using the following Profile Link
// for more information, feedback, questions or requests
// https://steamcommunity.com/id/Vel-San/
//=============================================================================

class WhispColorChanger extends Mutator Config(WhispColorChanger);

//// Config Vars
var config bool bRandomColor;

// Struct of Whisp Colors declared in Config File
// TODO: Add More Varibales, when needed ;p (And support for custom textures instead of smoke only)
struct WhispColors
{
  var config Color cWhispColorHead, cWhispColorTail;
  var config int iHeadSize, iTailSize;
};

// Colors Count
const COLORS_COUNT = 2;

// Colors List to be loaded from Config File
var config WhispColors aColors[COLORS_COUNT];

// Mut Vars
var KFGameType KFGT;
var WhispColorChanger Mut;
var RedWhisp RW;
var WhispColors Colors[COLORS_COUNT];
var bool bChangeColor;

replication
{
  unreliable if (Role == ROLE_Authority)
                aColors, Colors,
                bRandomColor,
                bChangeColor;
}

simulated function PostBeginPlay()
{
  if (Level.NetMode != NM_Client)
  {
    // Var init
    KFGT = KFGameType(Level.Game);
  }

  // Basic Logging
  MutLog("-----|| Random Whisp Color Enabled? " $bRandomColor$ " ||-----");

  // Get server vars
  GetServerVars();

  // Enable Timer
  bChangeColor=false;
  SetTimer(0.5, true);
}

simulated function Timer()
{
  if (Level.NetMode != NM_Client)
  {
    if (!KFGT.bWaveInProgress && !KFGT.IsInState('PendingMatch') && !KFGT.IsInState('GameEnded')) bChangeColor=true;
    else bChangeColor=false;
  }

  // Check later on if this eventually fixes the 'Slight' lag on wave start
  if (Level.NetMode != NM_DedicatedServer)
  {
    if(bChangeColor) ChangeWhispColor();
  }
}

// TODO: Need to find a way to replace foreach, and do the color change just once?
simulated function ChangeWhispColor()
{
  // MutLog("-----|| Whisp Color Changer Spawned & Activated ||-----");

  if (bRandomColor)
  {
    // MutLog("-----|| Random-Colored Whisp is active ||-----");
    foreach DynamicActors(class'KFMod.RedWhisp', RW)
    {
      RW.default.mColorRange[0] = class'Canvas'.static.MakeColor(rand(255),rand(255),rand(255),255);
      RW.default.mColorRange[1] = class'Canvas'.static.MakeColor(rand(255),rand(255),rand(255),255);
      RW.default.mSizeRange[0] = Colors[0].iHeadSize;
      RW.default.mSizeRange[1] = Colors[0].iTailSize;
    }
  }
  else
  {
    // MutLog("-----|| Single-Colored Whisp is active ||-----");
    foreach DynamicActors(class'KFMod.RedWhisp', RW)
    {
      RW.default.mColorRange[0] = Colors[0].cWhispColorHead;
      RW.default.mColorRange[1] = Colors[0].cWhispColorTail;
      RW.default.mSizeRange[0] = Colors[0].iHeadSize;
      RW.default.mSizeRange[1] = Colors[0].iTailSize;
    }
  }
}

// Any new vars added to the array, will automatically be copied here
simulated function GetServerVars()
{
  MutLog("-----|| Getting Colors from Server ||-----");
  Colors[0] = aColors[0];
  MutLog("-----|| Chosen cWhispColorHead Colors (RGBA): " $Colors[0].cWhispColorHead.R$ "-" $Colors[0].cWhispColorHead.G$ "-" $Colors[0].cWhispColorHead.B$ "-" $Colors[0].cWhispColorHead.A$ " ||-----");
  MutLog("-----|| Chosen cWhispColorTail Colors (RGBA): " $Colors[0].cWhispColorTail.R$ "-" $Colors[0].cWhispColorTail.G$ "-" $Colors[0].cWhispColorTail.B$ "-" $Colors[0].cWhispColorTail.A$ " ||-----");
  MutLog("-----|| Chosen Head Size: " $Colors[0].iHeadSize$ " ||-----");
  MutLog("-----|| Chosen Tail Size: " $Colors[0].iTailSize$ " ||-----");
}

function TimeStampLog(coerce string s)
{
  log("["$Level.TimeSeconds$"s]" @ s, 'WhispColorChanger');
}

function MutLog(string s)
{
  log(s, 'WhispColorChanger');
}

defaultproperties
{
  // Mut Info
  GroupName="KF-WhispColorChanger"
  FriendlyName="Whisp Color Changer - v3.2.2"
  Description="Changes the Color of Trader Path; - By Vel-San"
  bAddToServerPackages=true
  bNetNotify=true
  RemoteRole=ROLE_SimulatedProxy
  bAlwaysRelevant=true
}
