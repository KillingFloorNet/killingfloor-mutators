class WTFEquipFireAxeProj extends FlameNade;

function PostNetBeginPlay()
{
	if( !bHidden )
		Explode(Location, vect(0,0,1));
	else
		Destroy();
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex);

simulated function Explode(vector HitLocation, vector HitNormal)
{
	//local Controller C;
	local PlayerController  LocalPlayer;
	local float ShakeScale;
	bHasExploded = True;
	PlaySound(sound'KF_GrenadeSnd.FlameNade_Explode',,100.5*TransientSoundVolume);
	if ( EffectIsRelevant(Location,false) )
	{
		Spawn(class'KFMod.FlameImpact',,,HitLocation + HitNormal*20,rotator(HitNormal));
		Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
	}
	BlowUp(HitLocation);
	Destroy();
	LocalPlayer = Level.GetLocalPlayerController();
	if	(
			LocalPlayer != none
			&&	LocalPlayer==Pawn(Owner).Controller
		)
	{
		ShakeScale = GetShakeScale(Location, LocalPlayer.ViewTarget.Location);
		if( ShakeScale > 0 )
			LocalPlayer.ShakeView(RotMag * ShakeScale, RotRate, RotTime, OffsetMag * ShakeScale, OffsetRate, OffsetTime);
	}
/* 	for ( C=Level.ControllerList; C!=None; C=C.NextController )
	{
		if ( PlayerController(C) != None && C != LocalPlayer )
		{
			ShakeScale = GetShakeScale(Location, PlayerController(C).ViewTarget.Location);
			if( ShakeScale > 0 )
				C.ShakeView(RotMag * ShakeScale, RotRate, RotTime, OffsetMag * ShakeScale, OffsetRate, OffsetTime);
		}
	} */
}

simulated function float GetShakeScale(vector ViewLocation, vector EventLocation)
{
	local float Dist;
	local float scale;
	Dist = VSize(ViewLocation - EventLocation);
	if (Dist < DamageRadius * 2.0 )
		scale = (DamageRadius * 2.0  - Dist) / (DamageRadius * 2.0);
	return scale;
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dirs;
	local int NumKilled;
	local KFMonster KFMonsterVictim;
	local Pawn P;
	local KFPawn KFP;
	local array<Pawn> CheckedPawns;
	local int i;
	local bool bAlreadyChecked;
	if ( bHurtEntry )
		return;
	bHurtEntry = true;
	foreach CollidingActors (class 'Actor', Victims, DamageRadius, HitLocation)
	{
		if	(
				Victims != self
				&&	Victims != Instigator
				&&	Hurtwall != Victims
				&&	Victims.Role == ROLE_Authority
				&&	!Victims.IsA('FluidSurfaceInfo')
				&&	ExtendedZCollision(Victims)==None
				&&	KFBulletWhipAttachment(Victims)==None
			)
		{
			dirs = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dirs));
			dirs = dirs/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			if ( Instigator == None || Instigator.Controller == None )
				Victims.SetDelayedDamageInstigatorController( InstigatorController );
			if ( Victims == LastTouched )
				LastTouched = None;
			P = Pawn(Victims);
			if( P != none )
			{
				for (i = 0; i < CheckedPawns.Length; i++)
				{
					if (CheckedPawns[i] == P)
					{
						bAlreadyChecked = true;
						break;
					}
				}
				if( bAlreadyChecked )
				{
					bAlreadyChecked = false;
					P = none;
					continue;
				}
				KFMonsterVictim = KFMonster(Victims);
				if( KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
					KFMonsterVictim = none;
				KFP = KFPawn(Victims);
				if( KFMonsterVictim != none )
					damageScale *= KFMonsterVictim.GetExposureTo(HitLocation);
				else if( KFP != none )
					damageScale *= KFP.GetExposureTo(HitLocation);
				CheckedPawns[CheckedPawns.Length] = P;
				if ( damageScale <= 0)
				{
					P = none;
					continue;
				}
				else
					P = none;
			}
			if(KFHumanPawn(Victims)!=none)
				damageScale=0;
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 
					0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dirs,
				damageScale * Momentum * dirs,
				DamageType
			);
			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
			if( Role == ROLE_Authority && KFMonsterVictim != none && KFMonsterVictim.Health <= 0 )
				NumKilled++;
		}
	}
	if	(
			LastTouched != None
			&&	LastTouched != self
			&&	LastTouched != Instigator
			&&	LastTouched.Role == ROLE_Authority
			&& !LastTouched.IsA('FluidSurfaceInfo')
		)
	{
		Victims = LastTouched;
		LastTouched = None;
		dirs = Victims.Location - HitLocation;
		dist = FMax(1,VSize(dirs));
		dirs = dirs/dist;
		damageScale = FMax(Victims.CollisionRadius/(Victims.CollisionRadius + Victims.CollisionHeight),1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius));
		if ( Instigator == None || Instigator.Controller == None )
			Victims.SetDelayedDamageInstigatorController(InstigatorController);
		if(KFHumanPawn(Victims)!=none)
			damageScale=0;
		Victims.TakeDamage
		(
			damageScale * DamageAmount,
			Instigator,
			Victims.Location - 
				0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dirs,
			damageScale * Momentum * dirs,
			DamageType
		);
		if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
			Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
	}
	if( Role == ROLE_Authority )
	{
		if( NumKilled >= 12 )
			KFGameType(Level.Game).DramaticEvent(0.05);
		else if( NumKilled >= 6 )
			KFGameType(Level.Game).DramaticEvent(0.03);
	}
	bHurtEntry = false;
}

simulated singular function Touch(Actor Other)
{
	if ( Other == None || KFBulletWhipAttachment(Other)!=None )
		return;
	super.Touch(Other);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if( ExtendedZCollision(Other) != none )
		return;
	super.ProcessTouch(Other, HitLocation);
}

defaultproperties
{
	ExplodeTimer=0.000000
	Damage=230.000000
	DamageRadius=330.000000
	MyDamageType=Class'KFMod.DamTypeBurned'
	ExplosionDecal=Class'KFMod.FlameThrowerBurnMark'
	LightType=LT_Steady
	LightHue=250
	LightSaturation=230
	LightBrightness=800.000000
	LightRadius=100.000000
	LightCone=47
	StaticMesh=StaticMesh'EffectsSM.Weapons.Ger_Tracer'
	bDynamicLight=True
	AmbientSound=Sound'KF_BaseHusk.Fire.husk_fireball_loop'
	DrawScale=2.000000
	AmbientGlow=254
	bUnlit=True
}
