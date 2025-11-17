class InvRTDHPRegen extends InvRTDTimeBased;

var int RegenAmount; // How many health to regen per 'run'

function Timer()
{
    Instigator.GiveHealth(RegenAmount, Instigator.HealthMax);
    super.Timer();
}

defaultproperties
{
     RegenAmount=5
}
