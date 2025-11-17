class KFBleedOut extends Mutator;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SetTimer(1, true);
}

function Timer()
{
	local KFHumanPawn Player;
	
	foreach DynamicActors(class'KFHumanPawn', Player)
	{
		if (Player.Health <= 1)
			SetTimer(1, true);
		else Player.Health -= 1;
	}
}

defaultproperties
{
     GroupName="KFBleedOut"
     FriendlyName="Bleed Out"
     Description="Medic!"
}
