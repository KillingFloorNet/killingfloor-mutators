//=============================================================================
// DoomRocket.
//=============================================================================
class DoomRocket extends DoomProjectile;

var() texture MyFrames[5];

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if( (Other != instigator) && (DoomRocket(Other) == none) && KFBulletWhipAttachment(Other)==None ) 
		Explode(HitLocation,Normal(HitLocation-Other.Location));
}
function BlowUp( vector HitLocation )
{
	HurtRadius(Damage-(Damage*0.7*FRand()),300.0, Class'CyberBlown', MomentumTransfer, HitLocation );
	MakeNoise(2.0);
}
simulated function Explode(vector HitLocation, vector HitNormal)
{
	local DoomExplosion s;

	s = spawn(class'DoomExplosion',,,HitLocation + HitNormal*16);	
 	s.RemoteRole = ROLE_None;

	BlowUp(HitLocation);

 	Destroy();
}
simulated function UpdateAnimation( byte Rot, byte Frame )
{
	if( rot==7 )
		Rot = 1;
	else if( rot==6 )
		Rot = 2;
	else if( rot==5 )
		Rot = 3;
	Texture = MyFrames[rot];
}
simulated function bool MirrorMe( byte rot )
{
	Return !(rot<=7 && rot>=5);
}

defaultproperties
{
     MyFrames(0)=Texture'DoomPawnsKF.Cybra.MISLA1'
     MyFrames(1)=Texture'DoomPawnsKF.Cybra.MISLA8'
     MyFrames(2)=Texture'DoomPawnsKF.Cybra.MISLA7'
     MyFrames(3)=Texture'DoomPawnsKF.Cybra.MISLA6'
     MyFrames(4)=Texture'DoomPawnsKF.Cybra.MISLA5'
     Speed=1000.000000
     MaxSpeed=6000.000000
     Damage=160.000000
     MomentumTransfer=80000.000000
     SpawnSound=Sound'DoomPawnsKF.Cyborg.DSRLAUNC'
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightHue=28
     LightSaturation=64
     LightBrightness=150.000000
     LightRadius=8.000000
     Texture=Texture'DoomPawnsKF.Cybra.MISLA1'
     DrawScale=1.750000
     CollisionRadius=20.000000
     CollisionHeight=20.000000
}
