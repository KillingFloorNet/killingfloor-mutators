class KatanaMProjEnemy extends FlameTendril;

var() KFMonster StuckTo;
var Pawn OwnerPawn;
var KatanaM WeaponOwner;
var() Emitter		HPSpri;


simulated function PostBeginPlay();



final function SetOwningPlayer(KatanaM Wep)
{
    WeaponOwner = Wep;
}

simulated singular function HitWall(vector HitNormal, actor Wall)
{
	//Destroy();
}

simulated function Landed( vector HitNormal )
{
	//Destroy();
}

simulated function Explode(vector HitLocation,vector HitNormal)
{
	if (HPSpri != None)
	{
   HPSpri.Destroy();
   }
}

simulated function ProcessTouch (Actor Other, vector HitLocation);

simulated function Destroyed()
{
  if (HPSpri != None)
	{
   HPSpri.Destroy();
   }
}

function Timer()
{
	if (StuckTo != None)
	{
		if (StuckTo.Health <= 0)
			Destroy();
			
		if (ROLE == ROLE_Authority)
		{
			StuckTo.TakeDamage(Damage, Instigator, StuckTo.Location, MomentumTransfer * Normal(Velocity), MyDamageType);

		}
		WeaponOwner.SumeAmmoe();
			HPSpri = Spawn(Class'KatanaMedic.HPenemy',Self);
	HPSpri.SetRelativeLocation( vect(-240,10,-8));
	}
}

simulated function Stick(actor HitActor)
{
    local name NearestBone;
	local float Dist;
	
	StuckTo=KFMonster(HitActor);

	SetPhysics(PHYS_None);
     NearestBone = HitActor.GetClosestBone(HitActor.Location,Vector(Rotation), Dist);
	HitActor.AttachToBone(self,StuckTo.HeadBone);

	SetTimer(0.25,true);
}

defaultproperties
{
     Speed=1.000000
     MaxSpeed=1.000000
     Damage=10.000000
     DamageRadius=1.000000
     MyDamageType=Class'KatanaMedic.DamTypeKatanaMedic'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'KF_pickups2_Trip.Supers.MP7_Dart'
     LifeSpan=7.000000
     DrawScale=0.010000
}
