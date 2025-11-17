class ZombieStalker_RAND extends KFChar.ZombieStalker_STANDARD;

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

simulated function CloakStalker();
simulated function UnCloakStalker();

simulated function Tick(float deltaTime) {
	Super(KFMonster).Tick(deltaTime);
}

simulated function SetZappedBehavior() {
    Super(KFMonster).SetZappedBehavior();
}

simulated function UnSetZappedBehavior() {
    Super(KFMonster).UnSetZappedBehavior();
}

function SetZapped(float ZapAmount, Pawn Instigator) {
	Super(KFMonster).SetZapped(ZapAmount, Instigator);
}

function RemoveHead() {
	Super(KFMonster).RemoveHead();
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc) {
	Super(KFMonster).PlayDying(DamageType,HitLoc);
}