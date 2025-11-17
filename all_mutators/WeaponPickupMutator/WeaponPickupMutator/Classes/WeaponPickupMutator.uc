class WeaponPickupMutator extends Mutator;

function PostBeginPlay()
{
	local GameRules GR;

	level.Game.PlayerControllerClass = class'WeaponPickupMutator.MyPlayerController';
    level.Game.PlayerControllerClassName = "WeaponPickupMutator.MyPlayerController"; // just in case

	Super.PostBeginPlay();
	GR = Spawn(class'WeaponPickupGameRules');
	if(Level.Game.GameRulesModifiers == none)
	{
		Level.Game.GameRulesModifiers = GR;
	}
	else
	{
		Level.Game.GameRulesModifiers.AddGameRules(GR);
	}
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KFWeaponPickupMutator"
     FriendlyName="Press Use to Pickup Weapon"
     Description="Activate this mutator to press use pickup weapon."
}
