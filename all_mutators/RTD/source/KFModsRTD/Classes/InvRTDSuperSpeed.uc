class InvRTDSuperSpeed extends InvRTDTimeBased;

var float SpeedIncrease;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
}

function OnStarted()
{
    Log("Speedincrease"@SpeedIncrease);
    KFHumanPawn(Instigator).GroundSpeed  =   KFHumanPawn(Instigator).default.GroundSpeed*SpeedIncrease;
    KFHumanPawn(Instigator).AirSpeed  =   KFHumanPawn(Instigator).default.AirSpeed*SpeedIncrease;
}

function bool OnFinished()
{
    log("finised") ;
    Instigator.GroundSpeed = Instigator.default.GroundSpeed;
    Instigator.AirSpeed = Instigator.default.AirSpeed;

    return true;
}

function Timer()
{
   // OnStarted();

    super.Timer();
}

defaultproperties
{
     SpeedIncrease=2.000000
     bOnlyRelevantToOwner=False
}
