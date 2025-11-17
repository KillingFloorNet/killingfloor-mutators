//=============================================================================
// EnemyCreator.
//=============================================================================
class EnemyCreator extends Projectile;

var class<DoomPawns> SpawnType;
var bool bHasSpawned,bHellSpawn;

function PreBeginPlay()
{
	Velocity = vector(Rotation)*Speed;
	Velocity += VRand()*(Speed/3);
}
function HitWall (vector HitNormal, actor Wall)
{
	if( SpawnType!=None )
		SpawnEnemy(Location+HitNormal*SpawnType.Default.CollisionHeight,GetRandrot());
	Destroy();
}
function ProcessTouch(Actor Other, Vector HitLocation)
{
	if( KFBulletWhipAttachment(Other)!=None || Romero(Other)!=None )
		return;
	if( SpawnType==None )
	{
		Destroy();
		return;
	}
	if( bHasSpawned ) Return;
	if( Other.IsA('Pawn') )
	{
		HitLocation = Other.Location;
		SpawnEnemy(HitLocation,GetRandrot());
	}
	else SpawnEnemy(Other.Location-Velocity,GetRandrot());
	Destroy();
}
final function rotator GetRandrot()
{
	local rotator Tmp;
	Tmp.Yaw = Rand(65536);
	Return Tmp;
}
function SpawnEnemy( vector Loc, rotator Rota )
{
	local DoomPawns D;
	
	bHasSpawned = True;
	Class'EnemyCreator'.Default.bHellSpawn = true;
	D = Spawn(SpawnType,,,Loc,Rota);
	Class'EnemyCreator'.Default.bHellSpawn = false;
	if( D==None )
	{
		Spawn(Class'TeleportEffects',,,Location);
		Return;
	}
	if( DoomController(D.Controller)!=None )
		DoomController(D.Controller).bIsWandering = true;
	Spawn(Class'TeleportEffects',,,D.Location);
}

defaultproperties
{
     Speed=800.000000
     DrawType=DT_Sprite
     bNetTemporary=False
     Texture=Texture'DoomPawnsKF.Sin.BOSFA0'
     DrawScale=1.500000
     Style=STY_Masked
     CollisionRadius=10.000000
     CollisionHeight=10.000000
}
