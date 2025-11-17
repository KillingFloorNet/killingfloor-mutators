class AdminRecord extends Object;

var AdminControlMut MutatorOwner;
var AdminRecord NextAdmin;
var	AdminSettings ThisAdminSettings;

var PlayerController Controller;
var AdminGroup AdminGroup;
var string AdminID,AdminName,AdminLogin;

CONST PrivsLength=15;
var array<byte> Privs[PrivsLength];
var array< class<AdminCommand> > Allows;

var string CurrentTarget;
var bool bSilentMode;

var LevelInfo Level;

var int DisarmDuration;

function bool AllowAction(class<AdminCommand> ActionClass)
{
	local int i,n;
	
	if ( ActionClass == class'ActHelp' )
	{
		return true;
	}
	
	n = Allows.Length;

	for(i=0; i<n; i++)
	{
		if ( Allows[i] == ActionClass )
		{
			return true;
		}
	}
	
	return false;
}

function PostInit(AdminControlMut MyMut, AdminSettings InitAdm)
{
	local int i,n;
	local class<AdminCommand> CurPriv;
	
	MutatorOwner = MyMut;
	ThisAdminSettings = InitAdm;
	Level = MyMut.Level;
	
	DisarmDuration = MyMut.DisarmDuration;
	
	AdminID = InitAdm.AdminID;
	AdminName = InitAdm.AdminName;
	AdminLogin = InitAdm.AdminLogin;
	
	/*
	for(i=0; i<PrivsLength; i++)
	{
		Privs[i] = 0;
	}
	*/
	
	n = AdminGroup.Allow.Length;
	
	for(i=0; i<n; i++)
	{
		CurPriv = class'AdminControlMut'.Static.RecognizeCommand(AdminGroup.Allow[i]);
		
		if ( CurPriv != none )
		{
			Allows.Insert(0,1);
			Allows[0] = CurPriv;
		}
		/*
		if ( CurPriv != none )
		{
			Privs[CurPriv.default.Index] = 1;
		}*/
	}
}

defaultproperties
{
}
