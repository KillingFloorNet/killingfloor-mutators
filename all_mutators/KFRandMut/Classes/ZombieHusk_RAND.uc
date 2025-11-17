class ZombieHusk_RAND extends KFChar.ZombieHusk_STANDARD;

var class<KFMonster> RandClass;

replication {
	reliable if (bNetInitial && Role == ROLE_Authority)
		RandClass;
}

event PreBeginPlay() {
	RandClass = class'KFRandMut'.static.GetRandClass(Class);
	Prepivot = class'KFRandMut'.static.GetPrepivot(Class) + class'KFRandMut'.static.GetPrepivotDelta(RandClass);
	
	Super.PreBeginPlay();
}

simulated event PostNetBeginPlay() {
	local float scaleRatio;
	
	if (RandClass != None) {
		LinkMesh(RandClass.default.Mesh);
		LinkSkelAnim(class'KFRandMut'.static.GetMeshAnimation(Class));
		SetBoneScale(4, headScale / drawScale, 'head');
		Skins[0] = class'KFRandMut'.static.GetSkinMaterial(RandClass, 0);
		Skins[1] = class'KFRandMut'.static.GetSkinMaterial(RandClass, 1);
		KFRagdollName = RandClass.default.KFRagdollName;
		RagdollOverride = RandClass.default.KFRagdollName;
		DetachedHeadClass = RandClass.default.DetachedHeadClass;
		DetachedArmClass = RandClass.default.DetachedArmClass;
		DetachedLegClass = RandClass.default.DetachedLegClass;
		DetachedSpecialArmClass = RandClass.default.DetachedSpecialArmClass;
		scaleRatio = drawScale / RandClass.default.drawScale;
		severedHeadAttachScale = RandClass.default.severedHeadAttachScale * scaleRatio;
		severedArmAttachScale = RandClass.default.severedArmAttachScale * scaleRatio;
		severedLegAttachScale = RandClass.default.severedLegAttachScale * scaleRatio;
		bLeftArmGibbed = RandClass.default.bLeftArmGibbed;
	}
	
	Super.PostNetBeginPlay();
}

function SpawnTwoShots() {
	local vector X, Y, Z, FireStart;
	local rotator FireRotation;
	local KFMonsterController KFMonstControl;

	if(Controller != None && KFDoorMover(Controller.Target) != None) {
		Controller.Target.TakeDamage(22, Self, Location, vect(0,0,0), class'DamTypeVomit');
		return;
	}

	GetAxes(Rotation,X,Y,Z);
	FireStart = GetBoneCoords('righthand').Origin;
	HuskFireProjClass = class'HuskFireProjectile';
	if (!SavedFireProperties.bInitialized) {
		SavedFireProperties.AmmoClass = class'SkaarjAmmo';
		SavedFireProperties.ProjectileClass = HuskFireProjClass;
		SavedFireProperties.WarnTargetPct = 1;
		SavedFireProperties.MaxRange = 65535;
		SavedFireProperties.bTossed = false;
		SavedFireProperties.bTrySplash = true;
		SavedFireProperties.bLeadTarget = true;
		SavedFireProperties.bInstantHit = false;
		SavedFireProperties.bInitialized = true;
	}

	ToggleAuxCollision(false);

	FireRotation = Controller.AdjustAim(SavedFireProperties, FireStart, 600);

	foreach DynamicActors(class'KFMonsterController', KFMonstControl) {
		if(KFMonstControl != Controller) {
			if(PointDistToLine(KFMonstControl.Pawn.Location, vector(FireRotation), FireStart) < 75) {
				KFMonstControl.GetOutOfTheWayOfShot(vector(FireRotation), FireStart);
			}
		}
	}

	Spawn(HuskFireProjClass,,, FireStart, FireRotation);
	ToggleAuxCollision(true);
}