//======================================================================
// John Romero, or in other words brains of "Icon of Sin"
//======================================================================
class Romero extends Pawn;

#exec obj load file=SinS.uax package=DoomPawnsKF
#exec obj load file=SinT.utx package=DoomPawnsKF

var(Sounds) sound GotTriggered,PainNoise,DeathNoise,SpawnNoise;
var bool bFirstTimer;
struct PwnClssT
{
	var() class<DoomPawns> C;
};
var() Array<PwnClssT> EnemyTypes;
var() vector SpawnLocation;
var() texture PainAnimation;

function float GetExposureTo(vector TestLocation)
{
	if( FastTrace(Location,TestLocation) )
		return 1.f;
	return 0.f;
}
event Trigger( Actor Other, Pawn EventInstigator )
{
	SetTimer(5,True);
	PlaySound(GotTriggered);
	if( SpawnLocation==vect(0,0,0) )
		SpawnLocation = Location+vector(Rotation)*55;
}
function Timer()
{
	local EnemyCreator E;
	
	if( !bFirstTimer )
	{
		Disable('Trigger');
		bFirstTimer = True;
	}
	Instigator = Self;
	E = Spawn(class'EnemyCreator',,,SpawnLocation,Rotation);
	E.SpawnType = EnemyTypes[Rand(EnemyTypes.Length)].C;
	PlaySound(SpawnNoise);
}
State PainTimes
{
Ignores PlayHit;
	
Begin:
	Sleep(2);
	Texture = Default.Texture;
	GoToState('');
}
function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	PlaySound(DeathNoise);
	level.game.Killed(Killer, Controller, Self, damageType);
	//log(class$" dying");
	if( Killer!=None )
		TriggerEvent(Event, self, Killer.Pawn);
	else TriggerEvent(Event, self, Self);
	Level.Game.DiscardInventory(self);
	Destroy();
}
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, optional int HitIndex )
{
	Health-=Damage;
	if( Health<=0 )
	{
		Died(instigatedBy.Controller,damageType,HitLocation);
		Return;
	}
	if( !IsInState('PainTimes') )
	{
		PlaySound(PainNoise);
		Texture = PainAnimation;
		GoToState('PainTimes');
	}
}
event Falling()
{
	SetPhysics(PHYS_None);
}
function bool DoJump( bool bUpdating );
function DropToGround();
function AddVelocity( vector NewVelocity);
function bool IsHeadShot(vector loc, vector ray, float AdditionalScale);
function JumpOffPawn();

defaultproperties
{
     GotTriggered=Sound'DoomPawnsKF.Sin.DSBOSSIT'
     PainNoise=Sound'DoomPawnsKF.Sin.DSBOSPN'
     DeathNoise=Sound'DoomPawnsKF.Sin.DSBOSDTH'
     SpawnNoise=Sound'DoomPawnsKF.Sin.DSBOSPIT'
     EnemyTypes(0)=(C=Class'DoomPawnsKF.Imp')
     EnemyTypes(1)=(C=Class'DoomPawnsKF.Demon')
     EnemyTypes(2)=(C=Class'DoomPawnsKF.Skull')
     EnemyTypes(3)=(C=Class'DoomPawnsKF.Caco')
     EnemyTypes(4)=(C=Class'DoomPawnsKF.Mancub')
     EnemyTypes(5)=(C=Class'DoomPawnsKF.Knight')
     EnemyTypes(6)=(C=Class'DoomPawnsKF.PainHead')
     EnemyTypes(7)=(C=Class'DoomPawnsKF.Spider')
     EnemyTypes(8)=(C=Class'DoomPawnsKF.Baron')
     EnemyTypes(9)=(C=Class'DoomPawnsKF.Skeleton')
     EnemyTypes(10)=(C=Class'DoomPawnsKF.Vile')
     PainAnimation=Texture'DoomPawnsKF.Sin.BBRNB0'
     Health=750
     MenuName="John Romero"
     DrawType=DT_Sprite
     bStasis=False
     Tag="IconOfSin"
     Texture=Texture'DoomPawnsKF.Sin.BBRNA0'
     DrawScale=2.000000
     DrawScale3D=(Y=2.000000)
     Style=STY_Masked
     bMovable=False
     TransientSoundVolume=2.000000
     TransientSoundRadius=8000.000000
     CollisionRadius=30.000000
     CollisionHeight=50.000000
}
