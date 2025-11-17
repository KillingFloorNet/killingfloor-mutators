Class Kf2Boss_karma extends Object Config(Kf2Boss) PerObjectConfig;

var config bool bRagdolls;
var bool bHasInit,bRagdoll;

static final function InitConfig()
{
	local Kf2Boss_karma D;

	Default.bHasInit = true;
	D = New(None,"KFCharactersKA") Class'Kf2Boss_karma';
	Default.bRagdoll = D.bRagdolls;
	D.SaveConfig();
}
static final function bool UseRagdoll()
{
	if( !Default.bHasInit )
		InitConfig();
	return Default.bRagdoll;
}

defaultproperties
{
}
