class UberKnifeFireB extends KnifeFireB;

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local LawProj g;
	local vector X, Y, Z;
	local float pawnSpeed;
	local float Speed;

	g = Weapon.Spawn(class'KFMod.LAWProj', instigator,, Start, Dir);

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
	DamagedelayMin=0.5
	FireSound=Sound'KF_LAWSnd.LAW_Fire'
	FireAnimRate=10
	weaponRange=5000
	damageConst=500
	FireRate=0.5
}