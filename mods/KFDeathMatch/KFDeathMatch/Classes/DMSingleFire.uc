//=============================================================================
// 9mm Fire
//=============================================================================
class DMSingleFire extends SingleFire;

function DoTrace(Vector Start, Rotator Dir)
{
	DoDMTrace(Self,Start,Dir);
}
static final function DoDMTrace( KFFire Fire, vector Start, rotator Dir )
{
	local Vector X,Y,Z, End, HitLocation, HitNormal, ArcEnd;
	local Actor Other;
	local KFWeaponAttachment WeapAttach;
	local array<int>	HitPoints;

	Fire.MaxRange();

	Fire.Weapon.GetViewAxes(X, Y, Z);
	if ( Fire.Weapon.WeaponCentered() )
		ArcEnd = (Fire.Instigator.Location + Fire.Weapon.EffectOffset.X * X + 1.5 * Fire.Weapon.EffectOffset.Z * Z);
	else ArcEnd = (Fire.Instigator.Location + Fire.Instigator.CalcDrawOffset(Fire.Weapon) + Fire.Weapon.EffectOffset.X * X
			 + Fire.Weapon.Hand * Fire.Weapon.EffectOffset.Y * Y + Fire.Weapon.EffectOffset.Z * Z);

	X = Vector(Dir);
	End = Start + Fire.TraceRange * X;
	Other = Fire.Instigator.HitPointTrace(HitLocation, HitNormal, End, HitPoints, Start,, 1);

	if ( Other != None && Other != Fire.Instigator && Other.Base != Fire.Instigator )
	{
		WeapAttach = KFWeaponAttachment(Fire.Weapon.ThirdPersonActor);

		if ( !Other.bWorldGeometry )
		{
			// Update hit effect except for pawns
			if ( !Other.IsA('Pawn') && !Other.IsA('HitScanBlockingVolume') && !Other.IsA('ExtendedZCollision') )
			{
				if( WeapAttach!=None )
					WeapAttach.UpdateHit(Other, HitLocation, HitNormal);
			}
			Other.TakeDamage(Fire.DamageMax, Fire.Instigator, HitLocation, Fire.Momentum*X,Fire.DamageType);
		}
		else
		{
			HitLocation = HitLocation + 2.0 * HitNormal;
			if ( WeapAttach != None )
				WeapAttach.UpdateHit(Other,HitLocation,HitNormal);
		}
	}
	else
	{
		HitLocation = End;
		HitNormal = Normal(Start - End);
	}
}

defaultproperties
{
     DamageType=Class'KFDeathMatch.DamTypeSingle'
}
