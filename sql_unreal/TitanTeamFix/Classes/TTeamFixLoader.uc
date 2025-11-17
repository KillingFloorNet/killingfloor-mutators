//============================================================
// TTeamFixLoader.uc		- Mutator based initialization of the serveractor
//============================================================
//	TitanTeamFix
//		+ Coded by Shambler (Shambler@OldUnreal.com or Shambler__@Hotmail.com , ICQ: 108730864)
//		- A modular team balancing mutator initially coded for the Titan servers
//			http://ut2004.titaninternet.co.uk/
//
//============================================================
Class TTeamFixLoader extends Mutator
	config(TitanTeamFix);

var config class<TTeamFix> LoadClass;

function PreBeginPlay()
{
	Spawn(LoadClass);
	Destroy();
}

defaultproperties
{
	LoadClass=Class'TTeamFixGeneric'
}