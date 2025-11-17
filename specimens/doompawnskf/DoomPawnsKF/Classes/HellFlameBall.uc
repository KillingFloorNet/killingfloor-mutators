//=============================================================================
// HellFlameBall.
//=============================================================================
class HellFlameBall extends DoomProjectile;

var() texture MyFrames[5];

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
simulated function Update3DScale( out vector D3D, byte Rot )
{
	if( rot==2 || rot==6 )
		D3D.X*=2;
}
simulated function bool MirrorMe( byte rot )
{
	if( rot==2 ) Return False;
	else if( rot==6 ) Return True;
	Return !(rot<=3 && rot>=1);
}
simulated function Explode(vector HitLocation, vector HitNormal)
{
	local DoomExplosionKni s;

	s = spawn(class'DoomExplosionKni',,,HitLocation + HitNormal*16);	
 	s.RemoteRole = ROLE_None;
	MakeNoise(2.0);

 	Destroy();
}
simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if( KFBulletWhipAttachment(Other)==None && Other!=Instigator && DoomProjectile(Other)==None )
	{
		if ( Role == ROLE_Authority )
			Other.TakeDamage( Damage, instigator, HitLocation, MomentumTransfer*Vector(Rotation), Class'KniExploded');
		Explode(HitLocation,Normal(HitLocation-Other.Location));
	}
}

defaultproperties
{
     MyFrames(0)=Texture'DoomPawnsKF.HellKnight.BAL7A1A5'
     MyFrames(1)=Texture'DoomPawnsKF.HellKnight.BAL7A2A8'
     MyFrames(2)=Texture'DoomPawnsKF.HellKnight.BAL7A3A7'
     MyFrames(3)=Texture'DoomPawnsKF.HellKnight.BAL7A4A6'
     MyFrames(4)=Texture'DoomPawnsKF.HellKnight.BAL7A1A5'
     Speed=700.000000
     MaxSpeed=6000.000000
     Damage=64.000000
     ImpactSound=Sound'DoomPawnsKF.Imp.DSFIRXPL'
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightHue=83
     LightSaturation=50
     LightBrightness=155.000000
     LightRadius=5.000000
     Texture=Texture'DoomPawnsKF.HellKnight.BAL7A1A5'
     DrawScale=1.500000
}
