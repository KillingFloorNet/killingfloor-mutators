
class VDollMut extends Mutator
	hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

function PostBeginPlay()
{
	SetTimer(0.10, false);
}

function Timer()
{
	local KFGameType KF;

	KF = KFGameType(Level.Game);
	// End:0x64 Loop:False
	if(KF != none)
	{
		// End:0x4d Loop:False
		if(KF.KFLRules != none)
		{
			KF.KFLRules.Destroy();
		}
		KF.KFLRules = Spawn(class'VoodooDollLevelRules');
	}
}

function ModifyPlayer(Pawn P)
{
	local VoodooDoll_AnimInfo A;

	super.ModifyPlayer(P);
	A = Spawn(class'VoodooDoll_AnimInfo', P);
	A.LinkAnim(P);
}

defaultproperties
{
	bAddToServerPackages=true
	GroupName="KF_VoodooDoll"
	FriendlyName="Voodoo Doll"
	Description="Voodoo Doll Weapon (originally developed by Monolith in Blood PC Game)"
	bAlwaysRelevant=true
}