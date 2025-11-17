Class FPLegsMut extends Mutator;

function PostBeginPlay()
{
	local KFGameType KF;

	KF = KFGameType(Level.Game);

	if (KF == none) 
	{
		Log("ERROR: Wrong GameType (requires KFGameType)", Class.Outer.Name);
		Destroy();
		return;
	}
	
	if ( !ClassIsChildOf(KF.PlayerControllerClass, class'ServerPerks.FPPlayerController') ) 
	{
		KF.PlayerControllerClass = class'ServerPerks.FPPlayerController';
		KF.PlayerControllerClassName = string(Class'ServerPerks.FPPlayerController');
	}
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-FPLegs"
     FriendlyName="FP=Legs Base Mut"
     Description="Adds a nice pair of FPLegs"
}
