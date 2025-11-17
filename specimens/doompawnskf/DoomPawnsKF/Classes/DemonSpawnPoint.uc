Class DemonSpawnPoint extends KeyPoint;

var() Class<DoomPawns> TheMonsterClass;
var() bool bPissOffAtTriggerer,bTriggerOnceOnly;
var() float SpawnDelay;
var bool bDisabled;

event Trigger( Actor Other, Pawn EventInstigator )
{
	if( bDisabled )
		Return;
	if( bTriggerOnceOnly )
		bDisabled = True;
	Instigator = EventInstigator;
	if( SpawnDelay==0 )
		Timer();
	else SetTimer(SpawnDelay,False);
}
function Timer()
{
	local DoomPawns D;

	if( TheMonsterClass!=None )
	{
		D = Spawn(TheMonsterClass);
		if( D==None )
			Return;
		Spawn(class'TeleportEffects');
		if( bPissOffAtTriggerer && D.Controller!=None )
			D.Controller.SeePlayer(Instigator);
	}
}
function Reset()
{
	SetTimer(0,False);
	bDisabled = False;
}

defaultproperties
{
     bPissOffAtTriggerer=True
     bTriggerOnceOnly=True
     bStatic=False
     bNoDelete=True
     Style=STY_Modulated
     bDirectional=True
}
