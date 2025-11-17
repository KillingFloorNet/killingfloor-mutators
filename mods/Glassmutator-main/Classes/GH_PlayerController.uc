// --------------------------------------------------------------
// GH_PlayerController
// --------------------------------------------------------------

// Player Controller class for use in 'Glasshouse' maps.
// Created for the sole purpose of fixing a hardcoded reference to 'KFHumanPawn'
// in SetPawnClass().

// Author :  Alex Quick

// --------------------------------------------------------------


class GH_PlayerController extends KFPlayerController;


// disable perk system, restore 2012 state
simulated function SendSelectedVeterancyToServer(optional bool bForceChange);
function SelectVeterancy(class<KFVeterancyTypes> VetSkill, optional bool bForceChange);


function SetPawnClass(string inClass, string inCharacter)
{
  super.SetPawnClass(inClass, inCharacter);
  // @todo - why doesn't GetDefaultPlayerClass() work ?
  // PawnClass = Level.Game.GetDefaultPlayerClass(self);
  // PawnClass = class'KFHumanPawn';
  PawnClass = class'PlayerPawn_GH';
}


simulated function UpdateHintManagement(bool bUseHints)
{
  if (Level.GetLocalPlayerController() == self)
  {
    if (bUseHints && HintManager == none)
    {
      HintManager = spawn(class'GH_HintManager', self);
      if (HintManager == none)
        warn("Unable to spawn hint manager");
    }
    else if (!bUseHints && HintManager != none)
    {
      HintManager.Destroy();
      HintManager = none;
    }

    if (!bUseHints)
    {
      if (HUDKillingFloor(myHUD) != none)
        HUDKillingFloor(myHUD).bDrawHint = false;
    }
  }
}


defaultproperties{}