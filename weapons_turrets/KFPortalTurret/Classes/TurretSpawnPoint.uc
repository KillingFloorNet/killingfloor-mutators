Class TurretSpawnPoint extends Triggers;

var() bool bTriggerOnceOnly,bEvilTurret,bInvulnerableTurret,bNeverKillTurret;
var() int TurretHealth,HitDamage;
var() class<PortalTurret> TurretClass;

event Trigger( Actor Other, Pawn EventInstigator )
{
	local PortalTurret T;

	T = Spawn(TurretClass);
	if( T!=None )
	{
		T.bNoAutoDestruct = bNeverKillTurret;
		T.bEvilTurret = bEvilTurret;
		T.bHasGodMode = bInvulnerableTurret;
		T.HitDamages = HitDamage;
		T.TurretHealth = TurretHealth;
		T.Health = TurretHealth;
	}
	if( bTriggerOnceOnly )
		Destroy();
}

defaultproperties
{
     bEvilTurret=True
     bInvulnerableTurret=True
     TurretHealth=400
     hitdamage=5
     TurretClass=Class'KFPortalTurret.PortalTurretBad'
     DrawType=DT_Mesh
     Mesh=SkeletalMesh'KFPortalTurret.TurretMesh'
     Skins(0)=Texture'KFPortalTurret.Skins.Turret_01'
     bUnlit=True
     CollisionRadius=23.000000
     CollisionHeight=28.000000
     bCollideActors=False
}
