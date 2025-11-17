//=============================================================================
// MancubRocket.
//=============================================================================
class MancubRocket extends DoomRocket;

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if( KFBulletWhipAttachment(Other)==None && Other!=Instigator && DoomProjectile(Other)==None )
	{
		if ( Role == ROLE_Authority )
			Other.TakeDamage( Damage/3*2, instigator, HitLocation, MomentumTransfer*Vector(Rotation), Class'MancubBlown');
		Explode(HitLocation,Normal(HitLocation-Other.Location));
	}
}
simulated function Explode(vector HitLocation, vector HitNormal)
{
	local FlameExp s;

	s = spawn(class'FlameExp',,,HitLocation + HitNormal*16);	
 	s.RemoteRole = ROLE_None;
	s.SetDrawScale(s.DrawScale*1.75);
	BlowUp(HitLocation);

 	Destroy();
}
simulated function bool MirrorMe( byte rot )
{
	Return (rot<=3 && rot>=1);
}
function BlowUp( vector HitLocation )
{
	HurtRadius(Damage/3,100.0, Class'MancubBlown', MomentumTransfer, HitLocation );
	MakeNoise(2.0);
}
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	Acceleration = Normal(Velocity)*800;
}

defaultproperties
{
     MyFrames(0)=Texture'DoomPawnsKF.Mancub.MANFA1'
     MyFrames(1)=Texture'DoomPawnsKF.Mancub.MANFA8A2'
     MyFrames(2)=Texture'DoomPawnsKF.Mancub.MANFA7A3'
     MyFrames(3)=Texture'DoomPawnsKF.Mancub.MANFA6A4'
     MyFrames(4)=Texture'DoomPawnsKF.Mancub.MANFA5'
     Speed=600.000000
     MaxSpeed=2000.000000
     Damage=60.000000
     MomentumTransfer=8000.000000
     SpawnSound=Sound'DoomPawnsKF.Imp.DSFIRSHT'
     LightHue=5
     LightSaturation=63
     Texture=Texture'DoomPawnsKF.Mancub.MANFA1'
     DrawScale=1.000000
     DrawScale3D=(X=2.000000)
     ScaleGlow=2.000000
     TransientSoundVolume=0.400000
     CollisionRadius=15.000000
     CollisionHeight=15.000000
}
