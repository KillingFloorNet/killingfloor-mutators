class ffmut extends Mutator config (REvengeFF);

function PostBeginPlay()
{

	local GameRules G;

	// Change the overall speed at which karma is evolved for in the level.

//settimer(10.0,true);

	Super.PostBeginPlay();
	
		G = spawn(class'ffRules');
		if ( Level.Game.GameRulesModifiers == None )
			Level.Game.GameRulesModifiers = G;
		else
			Level.Game.GameRulesModifiers.AddGameRules(G);
	
	

}

defaultproperties
{
     GroupName="KF-Dude"
     FriendlyName="FF REvenge "
     Description="when you shoot somebody on a friendlyfire server you get hurt."
}
