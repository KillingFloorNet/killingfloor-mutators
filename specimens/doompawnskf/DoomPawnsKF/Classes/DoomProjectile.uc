//=============================================================================
// DoomProjectile. Projectile that always face player.
//=============================================================================
class DoomProjectile extends Projectile
	Abstract;

var rotator InitRot;
var bool bChecked,bRenderDisabled;
var PlayerController RenderObject;
var byte LastCheckB;

replication
{
	unreliable if( bNetInitial && Role==ROLE_Authority )
		InitRot;
}

function PreBeginPlay()
{
	InitRot.Yaw = Rotation.Yaw;
	Velocity = vector(Rotation)*Speed;
	if( SpawnSound!=None )
		PlaySound(SpawnSound, SLOT_None, 2.3);
}
simulated function Tick( float D )
{
	local byte By;
	local bool bAnimChanged;
	local int Frame;
	local rotator TheNewRot;
	local vector D3;
	
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
			bRenderDisabled = False;
		else Return;
	}
	else if( (LastRenderTime+1)<Level.TimeSeconds )
	{
		bRenderDisabled = True;
		Return;
	}
	TheNewRot = Class'DRendering'.Static.GetMyYaw(Class'DRendering'.Static.GetPlayerCamLoc(RenderObject),Location);
		
	// Update animation (rotation).
	By = Class'DRendering'.Static.GetAnimRot(InitRot.Yaw,TheNewRot.Yaw);
	if( By!=LastCheckB || bAnimChanged )
	{
		LastCheckB = By;
		UpdateAnimation(By,Frame);
	}
	D3 = Default.DrawScale3D;
	Update3DScale(D3,By);
	if( MirrorMe(By) )
		D3.X*=-1;
	if( DrawScale3D!=D3 )
		SetDrawScale3D(D3);
}
simulated function Update3DScale( out vector D3D, byte Rot );
simulated function bool MirrorMe( byte rot )
{
	Return false;
}
simulated function UpdateAnimation( byte Rot, byte Frame );
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if( KFBulletWhipAttachment(Other)==None && Other!=Instigator )
		Explode(HitLocation,Normal(HitLocation-Other.Location));
}

defaultproperties
{
     Speed=500.000000
     DrawType=DT_Sprite
     bDynamicLight=True
}
