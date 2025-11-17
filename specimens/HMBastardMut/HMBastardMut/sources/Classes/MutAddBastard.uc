class MutAddBastard extends Mutator
	hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force)
	config(HMBastardMut);

var config string SpecPkgName;

static function FillPlayInfo(PlayInfo PlayInfo)
{
	super(Info).FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.RulesGroup, "SpecPkgName", "HMBastardMut package name", 0, 0, "text");
}

function PostBeginPlay()
{
	local KFGameType kf;
	local string HMBastardMutID;
	local int MonsterSlot, SquadIndex, i;
	local string SquadStr, ThisID;
	local int ThisCount;

	if(Level.NetMode != 0)
	{
		AddToPackageMap(SpecPkgName);
	}
	kf = KFGameType(Level.Game);
	if(kf == none)
	{
		Destroy();
		return;
	}
	MonsterSlot = kf.StandardMonsterClasses.Length;
	kf.StandardMonsterClasses.Length = MonsterSlot + 1;
	HMBastardMutID = Chr(65 + MonsterSlot);
	kf.StandardMonsterClasses[MonsterSlot].MClassName = SpecPkgName $ ".ZombieBastard";
	kf.StandardMonsterClasses[MonsterSlot].Mid = HMBastardMutID;
	SquadIndex = 0;
	J0xe2:

	if(SquadIndex < kf.StandardMonsterSquads.Length)
	{
		SquadStr = kf.StandardMonsterSquads[SquadIndex];
		i = 0;
		J0x11c:

		if(i < Len(SquadStr))
		{
			ThisCount = int(Mid(SquadStr, i, 1));
			ThisID = Mid(SquadStr, i + 1, 1);
			if(ThisID == "B")
			{
				SquadStr = Left(SquadStr, i);
				SquadStr $= string(int(float(ThisCount / 2) + float(ThisCount) % float(2)));
				SquadStr $= ThisID;
				SquadStr $= "1";
				SquadStr $= HMBastardMutID;
				SquadStr $= Right(kf.StandardMonsterSquads[SquadIndex], Len(kf.StandardMonsterSquads[SquadIndex]) - i - 2);
				kf.StandardMonsterSquads[SquadIndex] = SquadStr;
			}
			else
			{
				i += 2;
				// This is an implied JumpToken; Continue!
				goto J0x11c;
			}
		}
		++ SquadIndex;
		// This is an implied JumpToken; Continue!
		goto J0xe2;
	}
	SetTimer(0.10, false);
}

function Timer()
{
	Destroy();
}

defaultproperties
{
     SpecPkgName="HMBastardMut"
     GroupName="KF-AddHMBastardMut"
     FriendlyName="Add Bastard"
     Description="Adds Bastard to spawn list."
}
