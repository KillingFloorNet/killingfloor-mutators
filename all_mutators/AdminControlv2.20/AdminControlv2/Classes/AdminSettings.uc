class AdminSettings extends Object
	PerObjectConfig
	Config(AdminControlv2);

struct DateInfo
{
	var	int	Year,Month,Day,Hour,Minute;
};
	
var	string	ConfigFile;
	
var	config	string		AdminID,AdminName,AdminLogin;
var	config	string		AdminGroup;
var	config	int			GameTime,GameTimeMonth,Kicks,KicksMonth,Bans,BansMonth;
var	config	DateInfo	BeginningTime,LastVisitTime;

var	bool	bAdminActive,bStatsChanged,bLoggedIn;

static function array<string> GetNames()
{
	return GetPerObjectNames(default.ConfigFile);
}

defaultproperties
{
     ConfigFile="AdminControlv2"
}
