Class ExpBarrel extends DoomDecos;

var vector DeathVelocity;
var array<Texture> ExpAnim;
var byte AnimIndex;

replication
{
	// Variables the server should send to the client.
	reliable if( bNetDirty && (Role==ROLE_Authority) )
		DeathVelocity;
}

function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, optional int HitIndex)
{
	if( Health<=0 )
		return;
	Health-=NDamage;
	if( Health<=0 )
	{
		DeathVelocity = momentum*0.02f;
		if( VSize(DeathVelocity)<2.f )
			DeathVelocity = vect(0,0,-2);
		else if( VSize(DeathVelocity)>160.f )
			DeathVelocity = Normal(DeathVelocity)*160.f;
		MakeExplosion();
		NetUpdateTime = Level.TimeSeconds - 1;
	}
}
function Trigger( actor Other, pawn EventInstigator )
{
	TakeDamage(5000,EventInstigator,Location,vect(0,0,-2),Class'Crushed');
}
simulated function MakeExplosion()
{
	SetPhysics(PHYS_Projectile);
	Velocity = DeathVelocity;
	PlaySound(Sound'DSBAREXP');
	SetCollision(false);
	if( Level.NetMode!=NM_Client )
		GoToState('DeathToll');
	if( MyRender!=None )
	{
		ExpAnim = Class'DRendering'.Static.GetAnimation(Texture'BEXPB0');
		MyRender.Skins[0] = ExpAnim[0];
		MyRender.SetDrawScale(DrawScale);
		MyRender.PrePivot.Z = -25;
		AnimIndex = 1;
		SetTimer(0.6f/float(ExpAnim.Length-1),true);
	}
}
simulated function Timer()
{
	if( AnimIndex==ExpAnim.Length )
		return;
	AmbientGlow+=35;
	MyRender.Skins[0] = ExpAnim[AnimIndex++];
}
simulated function PostNetReceive()
{
	if( DeathVelocity!=vect(0,0,0) )
	{
		MakeExplosion();
		bNetNotify = false;
	}
}
simulated function HitWall( vector HitNormal, actor HitWall )
{
	Velocity-=((Velocity dot HitNormal) * HitNormal);
}
State DeathToll
{
Begin:
	Sleep(0.2);
	HurtRadius(130.f,200.f,Class'RLBlown',10000.f,Location);
	Sleep(0.4);
	Destroy();
}

defaultproperties
{
     Health=30
     bStatic=False
     bNoDelete=False
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     Texture=Texture'DoomPawnsKF.Decos.BAR1A0'
     DrawScale=0.500000
     bMovable=True
     TransientSoundVolume=2.000000
     TransientSoundRadius=1200.000000
     CollisionRadius=24.000000
     CollisionHeight=32.000000
     bCollideWorld=True
     bNetNotify=True
     bBounce=True
}
