class MFWPlayerController extends KFPlayerController;

function SetPawnClass(string inClass, string inCharacter) {
    super.SetPawnClass(inClass, inCharacter);
    PawnClass= Class'MFWHumanPawn';
}

function ShowBuyMenu(string wlTag,float maxweight) {
    StopForceFeedback();  // jdf - no way to pause feedback
    // Open menu
    ClientOpenMenu("MultiFragWeapon.BuyMenu",,wlTag,string(maxweight));
}

