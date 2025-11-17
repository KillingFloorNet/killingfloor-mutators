//=============================================================================
// DoomCarcass.
//=============================================================================
class DoomCarcass extends Decoration
	NotPlaceable
	Config(DoomPawnsKF);

var PlayerController RenderObject;
var bool bChecked,bRenderDisabled,bIgnoreThisScan;
var class<DoomPawns> DeadEnemy;
var() bool bMirrorView;
var() globalconfig float BodyLifeSpan;

replication
{
	// Things the server should send to the client.
	reliable if( bNetDirty && Role==ROLE_Authority )
		DeadEnemy;
}

simulated function Initfor( class<DoomPawns> MonsterType )
{
	local vector D3;

	if( MonsterType==None )
	{
		Destroy();
		Return;
	}
	if( Level.NetMode!=NM_Client )
		LifeSpan = BodyLifeSpan;
	DeadEnemy = MonsterType;
	if( Level.NetMode!=NM_DedicatedServer )
	{
		Skins[0] = DeadEnemy.Default.DeadEndTexture;
		SetDrawScale(DeadEnemy.Default.DrawScale);
		ScaleGlow = DeadEnemy.Default.ScaleGlow;
		SetStaticMesh(DeadEnemy.Default.RenderingClass.Default.StaticMesh);
		D3 = DeadEnemy.Default.RenderingClass.Default.DrawScale3D;
		if( bMirrorView )
			D3.Y*=-1;
		if( DrawScale3D!=D3 )
			SetDrawScale3D(D3);
	}
	SetCollisionSize(DeadEnemy.Default.CollisionRadius, DeadEnemy.Default.CollisionHeight);
	Mass = DeadEnemy.Default.Mass;
	Buoyancy = 0.9 * Mass;
	bIgnoreThisScan = True;
}
simulated function Tick( float D )
{
	local rotator TheNewRot;
	
	// Check for render object
	if( !bChecked )
	{
		bChecked = True;
		RenderObject = Level.GetLocalPlayerController();
		if( RenderObject==None ) // Could be an dedicated server... cancel everything.
		{
			Disable('Tick');
			Return;
		}
	}
	// To improve CPU useage.
	if( bRenderDisabled )
	{
		if( (LastRenderTime+1)>Level.TimeSeconds )
		{
			bRenderDisabled = False;
			SetDrawType(DT_StaticMesh);
		}
		else Return;
	}
	else if( (LastRenderTime+1)<Level.TimeSeconds )
	{
		if( bIgnoreThisScan )
			bIgnoreThisScan = False;
		else
		{
			bRenderDisabled = True;
			SetDrawType(DT_None);
			Return;
		}
	}
	// No rendering if no actor!
	if( RenderObject==None )
	{
		Disable('Tick');
		Return;
	}
	// Always face the player.
	TheNewRot = Class'DRendering'.Static.GetMyYaw(Class'DRendering'.Static.GetPlayerCamLoc(RenderObject),Location);
	if( Rotation!=TheNewRot )
		SetRotation(TheNewRot);
}
function Destroyed();
singular function BaseChange();
function Landed(vector HitNormal);
function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, optional int HitIndex)
{
	if( damageType==Class'Crushed' )
		Destroy(); // Mover encroach.
}
simulated function PostNetReceive()
{
	if( DeadEnemy!=None )
	{
		bNetNotify = false;
		Initfor(DeadEnemy);
	}
}
simulated function PostNetBeginPlay()
{
	if( Level.NetMode==NM_Client && DeadEnemy!=None )
		Initfor(DeadEnemy);
	else bNetNotify = true;
}
function PhysicsVolumeChange( PhysicsVolume NewVolume );

defaultproperties
{
     BodyLifeSpan=65.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'DoomPawnsKF.NormalMesh'
     bStatic=False
     bStasis=False
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     AmbientGlow=40
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideWorld=True
}
