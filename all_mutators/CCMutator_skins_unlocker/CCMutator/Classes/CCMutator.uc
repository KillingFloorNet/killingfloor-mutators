class CCMutator extends Mutator
	Config(CCMutator);

var() globalconfig array<string> CharacterName;
var() globalconfig array<name> AddPackageMap;

function PostBeginPlay()
{
	local array<name> ServerPcks;
	local int i,j;

	if( Level.Game.PlayerControllerClass==Class'KFPlayerController' )
	{
		Level.Game.PlayerControllerClass = Class'CCPlayerController';
		Level.Game.PlayerControllerClassName = string(Class'CCPlayerController');
	}
	
	Log("CCMUTATOR: Adding"@(AddPackageMap.Length+1)@"additional serverpackages for characters",Class.Outer.Name);
	for( i=0; i<AddPackageMap.Length; i++ )
	AddToPackageMap(string(AddPackageMap[i]));
	
	if( CharacterName.Length==0 )
	{
		CharacterName.Length = 1;
		CharacterName[0] = "All";
	}
}

static function string GetCharacterList( string S )
{
	local int i,l;

	l = Default.CharacterName.Length;
	if( S!="" )
	{
		for( i=0; i<l; i++ )
		{
			if( Default.CharacterName[i]~=S )
				Return Default.CharacterName[i];
		}
	}
	Return Default.CharacterName[Rand(l)];
}


static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting(default.GameGroup,"CharacterName","Character List",1,1,"Text","42",,,True);
	PlayInfo.AddSetting(default.GameGroup,"AddPackageMap","Character Resources",1,1,"Text","42",,,True);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "CharacterName":	return "Character Names";
		case "AddPackageMap":	return "Character Resources";
	}
	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     CharacterName(0)="Corporal_Lewis"
     CharacterName(1)="Lieutenant_Masterson"
     CharacterName(2)="Police_Constable_Briar"
     CharacterName(3)="Private_Schnieder"
     CharacterName(4)="Sergeant_Powers"
     CharacterName(5)="Police_Sergeant_Davin"
     CharacterName(6)="Dr_Gary_Glover"
     CharacterName(7)="DJ_Scully"
     CharacterName(8)="FoundryWorker_Aldridge"
     CharacterName(9)="Agent_Wilkes"
     CharacterName(10)="Mr_Foster"
     CharacterName(11)="LanceCorporal_Lee_Baron"
     CharacterName(12)="Mike_Noble"
     CharacterName(13)="Security_Officer_Thorne"
     CharacterName(14)="Harold_Hunt"
     CharacterName(15)="Kerry_Fitzpatrick"
     CharacterName(16)="Paramedic_Alfred_Anderson"
     CharacterName(17)="Trooper_Clive_Jenkins"
     CharacterName(18)="Harchier_Spebbington"
     CharacterName(19)="Captian_Wiggins"
     CharacterName(20)="Chopper_Harris"
     CharacterName(21)="Kevo_Chav"
     CharacterName(22)="Reverend_Alberts"
     CharacterName(23)="Baddest_Santa"
     CharacterName(24)="Pyro_Blue"
     CharacterName(25)="Pyro_Red"
     CharacterName(26)="Steampunk_Berserker"
     CharacterName(27)="Steampunk_Firebug"
     CharacterName(28)="Steampunk_Medic"
     CharacterName(29)="Steampunk_Sharpshooter"
     CharacterName(30)="Steampunk_MrFoster"
     CharacterName(31)="KF_Soviet"
     CharacterName(32)="KF_German"
     CharacterName(33)="Commando_Chicken"
     bAddToServerPackages=True
     GroupName="KFCustChar"
     FriendlyName="Custom Character Enabler"
     Description="Custom Character Enabler Made by FluX - www.fluxiserver.co.uk"
     bAlwaysRelevant=True
}
