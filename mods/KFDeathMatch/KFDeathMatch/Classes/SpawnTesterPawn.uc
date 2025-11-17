//=============================================================================
// SpawnTesterPawn
//=============================================================================
class SpawnTesterPawn extends KFHumanPawn;

function PreBeginPlay();
function PostBeginPlay();
function BeginPlay();
function PostNetBeginPlay();
function ModifyVelocity(float DeltaTime, vector OldVelocity)
{
	Velocity = vect(0,0,0);
}
function Tick(float DeltaTime);

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex);

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation);

function bool AddInventory( inventory NewItem )
{
	return false;
}

defaultproperties
{
     bHidden=True
     RemoteRole=ROLE_None
     LifeSpan=1.000000
}
