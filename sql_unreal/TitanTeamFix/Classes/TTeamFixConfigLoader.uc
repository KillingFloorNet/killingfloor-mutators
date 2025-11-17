//============================================================
// TTeamFixConfigLoader.uc		- Used for loading multiple configuration profiles from the same server install
//============================================================
//	TitanTeamFix
//		+ Coded by Shambler (Shambler@OldUnreal.com or Shambler__@Hotmail.com)
//		- A modular team balancing mutator initially coded for the Titan servers
//			http://ut2004.titaninternet.co.uk/
//
//============================================================
//
// This class allows a serveradmin to specify what config
// preset he wants TitanTeamFix to load.
// This allows an admin to run multiple servers from the same
// UT2004 installation while allowing each server to use a
// completely different TitanTeamFix configuration
//
//============================================================
Class TTeamFixConfigLoader extends Object
	config;

var config string ActiveConfiguration;

defaultproperties
{
	ActiveConfiguration="default"
}