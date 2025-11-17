//=============================================================================
// ImpFlameBall.
//=============================================================================
class ImpFlameBall extends Projectile;

var Class<DamageType> MyDamage;

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local FlameExp s;
	
	if ( (Role == ROLE_Authority) && (FRand() < 0.5) )
		MakeNoise(1.0); //FIXME - set appropriate loudness
	
	s = Spawn(class'FlameExp',,,HitLocation+HitNormal*9);
	s.RemoteRole = ROLE_None;
	Destroy();
}
simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if( KFBulletWhipAttachment(Other)==None && (Other != instigator) )
	{
		if ( Role == ROLE_Authority )
			Other.TakeDamage(Damage-(Damage*0.5*FRand()), instigator,HitLocation,
					15000.0 * Normal(velocity),MyDamage);
		Explode(HitLocation, Vect(0,0,0));
	}
}
function PostBeginPlay()
{
	Velocity = vector(Rotation)*Speed;
}

defaultproperties
{
     MyDamage=Class'DoomPawnsKF.ImpBurned'
     Speed=950.000000
     Damage=24.000000
     LightType=LT_Steady
     LightBrightness=130.000000
     LightRadius=8.000000
     DrawType=DT_Sprite
     bDynamicLight=True
     Texture=Texture'DoomPawnsKF.Imp.BAL1A0'
}
