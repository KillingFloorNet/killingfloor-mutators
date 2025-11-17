class UberKnifeFire extends KnifeFire;

function nade SpawnProjectile(Vector Start, Rotator Dir)
{
	local UberKnifeNade g;
	local vector X, Y, Z;
	local float pawnSpeed;
	local float Speed;

	g = Weapon.Spawn(class'PwnzMut.UberKnifeNade', instigator,, Start, Dir);

	if (g != None)
	{
		Weapon.GetViewAxes(X,Y,Z);
		pawnSpeed = X dot Instigator.Velocity;

		Speed = pawnSpeed + 800;
		g.Velocity = Speed * Vector(Dir);
	}

	return g;
}

function DoFireEffect()
{
	local Vector StartProj, StartTrace, X,Y,Z;
	local Rotator Aim;
	local Vector HitLocation, HitNormal;
	local Actor Other;

	Weapon.GetViewAxes(X,Y,Z);

	StartTrace = Instigator.Location + Instigator.EyePosition();
	StartProj = StartTrace + X;

	Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
	if (Other != None)
		StartProj = HitLocation;

	Aim = AdjustAim(StartProj, AimError);

	SpawnProjectile(StartProj, Aim);

	Super.DoFireEffect();
}

defaultproperties
{
	FireAnimRate=50
	DamagedelayMin=0.01
	weaponRange=5000
	damageConst=50
	FireRate=0.1
}