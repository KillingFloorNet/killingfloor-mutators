class ZombieClot_RAND extends KFChar.ZombieClot_STANDARD;

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