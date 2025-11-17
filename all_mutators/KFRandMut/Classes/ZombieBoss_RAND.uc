class ZombieBoss_RAND extends KFChar.ZombieBoss_STANDARD;

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
		default.Skins[0] = class'KFRandMut'.static.GetSkinMaterial(RandClass, 0);
		default.Skins[1] = class'KFRandMut'.static.GetSkinMaterial(RandClass, 1);
		Skins[0] = default.Skins[0];
		Skins[1] = default.Skins[1];
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
	}
	
	Super.PostNetBeginPlay();
}

simulated function DropNeedle() {
	if (CurrentNeedle != None) {
		DetachFromBone(CurrentNeedle);
		CurrentNeedle.SetLocation(GetBoneCoords('righthand').Origin);
		CurrentNeedle.DroppedNow();
		CurrentNeedle = None;
	}
}

simulated function NotifySyringeA() {
	if (Level.NetMode != NM_Client) {
		if (SyringeCount < 3)
			SyringeCount++;
		if (Level.NetMode != NM_DedicatedServer)
			 PostNetReceive();
	}
	if (Level.NetMode != NM_DedicatedServer) {
		DropNeedle();
		CurrentNeedle = Spawn(Class'BossHPNeedle');
		AttachToBone(CurrentNeedle, 'righthand');
	}
}

simulated function AddTraceHitFX(vector HitPos) {
	local vector Start,SpawnVel,SpawnDir;
	local float hitDist;

	Start = GetBoneCoords('lefthand').Origin;
	if(mTracer==None)
		mTracer = Spawn(Class'KFMod.KFNewTracer',,,Start);
	else mTracer.SetLocation(Start);
	if(mMuzzleFlash==None) {
		mMuzzleFlash = Spawn(Class'MuzzleFlash3rdMG');
		AttachToBone(mMuzzleFlash, 'lefthand');
	}
	else mMuzzleFlash.SpawnParticle(1);
	hitDist = VSize(HitPos - Start) - 50.f;

	if(hitDist>10) {
		SpawnDir = Normal(HitPos - Start);
		SpawnVel = SpawnDir * 10000.f;
		mTracer.Emitters[0].StartVelocityRange.X.Min = SpawnVel.X;
		mTracer.Emitters[0].StartVelocityRange.X.Max = SpawnVel.X;
		mTracer.Emitters[0].StartVelocityRange.Y.Min = SpawnVel.Y;
		mTracer.Emitters[0].StartVelocityRange.Y.Max = SpawnVel.Y;
		mTracer.Emitters[0].StartVelocityRange.Z.Min = SpawnVel.Z;
		mTracer.Emitters[0].StartVelocityRange.Z.Max = SpawnVel.Z;
		mTracer.Emitters[0].LifetimeRange.Min = hitDist / 10000.f;
		mTracer.Emitters[0].LifetimeRange.Max = mTracer.Emitters[0].LifetimeRange.Min;
		mTracer.SpawnParticle(1);
	}
	Instigator = Self;

	if(HitPos != vect(0,0,0)) {
		Spawn(class'ROBulletHitEffect',,, HitPos, Rotator(Normal(HitPos - Start)));
	}
}

state FireChaingun {
	function AnimEnd(int Channel) {
		if(MGFireCounter <= 0) {
			bShotAnim = true;
			Acceleration = vect(0,0,0);
			SetAnimAction('FireEndMG');
			HandleWaitForAnim('FireEndMG');
			GoToState('');
		}
		else {
			if (Controller.Enemy != None) {
				if (Controller.LineOfSightTo(Controller.Enemy) && FastTrace(GetBoneCoords('lefthand').Origin,Controller.Enemy.Location)) {
					MGLostSightTimeout = 0.0;
					Controller.Focus = Controller.Enemy;
					Controller.FocalPoint = Controller.Enemy.Location;
				}
				else {
					MGLostSightTimeout = Level.TimeSeconds + (0.25 + FRand() * 0.35);
					Controller.Focus = None;
				}

				Controller.Target = Controller.Enemy;
			}
			else {
				MGLostSightTimeout = Level.TimeSeconds + (0.25 + FRand() * 0.35);
				Controller.Focus = None;
			}

			if(!bFireAtWill) {
				MGFireDuration = Level.TimeSeconds + (0.75 + FRand() * 0.5);
			}
			else if (FRand() < 0.03 && Controller.Enemy != None && PlayerController(Controller.Enemy.Controller) != None) {
				PlayerController(Controller.Enemy.Controller).Speech('AUTO', 9, "");
			}

			bFireAtWill = True;
			bShotAnim = true;
			Acceleration = vect(0,0,0);

			SetAnimAction('FireMG');
			bWaitForAnim = true;
		}
	}
	
	function FireMGShot() {
		local vector Start,End,HL,HN,Dir;
		local rotator R;
		local Actor A;

		MGFireCounter--;

		if(AmbientSound != MiniGunFireSound) {
			SoundVolume=255;
			SoundRadius=400;
			AmbientSound = MiniGunFireSound;
		}

		Start = GetBoneCoords('lefthand').Origin;
		if(Controller.Focus!=None)
			R = rotator(Controller.Focus.Location-Start);
		else R = rotator(Controller.FocalPoint-Start);
		if(NeedToTurnFor(R))
			R = Rotation;
		
		Dir = Normal(vector(R)+VRand()*0.06);
		End = Start+Dir*10000;

	
		bBlockHitPointTraces = false;
		A = Trace(HL,HN,End,Start,True);
		bBlockHitPointTraces = true;

		if(A==None)
			Return;
		TraceHitPos = HL;
		if(Level.NetMode!=NM_DedicatedServer)
			AddTraceHitFX(HL);

		if(A!=Level) {
			A.TakeDamage(MGDamage+Rand(3),Self,HL,Dir*500,Class'DamageType');
		}
	}
}

state FireMissile {
	ignores RangedAttack;

	function AnimEnd(int Channel) {
		local vector Start;
		local Rotator R;

		Start = GetBoneCoords('lefthand').Origin;

		if (!SavedFireProperties.bInitialized) {
			SavedFireProperties.AmmoClass = MyAmmo.Class;
			SavedFireProperties.ProjectileClass = MyAmmo.ProjectileClass;
			SavedFireProperties.WarnTargetPct = 0.15;
			SavedFireProperties.MaxRange = 10000;
			SavedFireProperties.bTossed = False;
			SavedFireProperties.bTrySplash = False;
			SavedFireProperties.bLeadTarget = True;
			SavedFireProperties.bInstantHit = True;
			SavedFireProperties.bInitialized = true;
		}

		R = AdjustAim(SavedFireProperties,Start,100);
		PlaySound(RocketFireSound,SLOT_Interact,2.0,,TransientSoundRadius,,false);
		Spawn(Class'BossLAWProj',,,Start,R);

		bShotAnim = true;
		Acceleration = vect(0,0,0);
		SetAnimAction('FireEndMissile');
		HandleWaitForAnim('FireEndMissile');
		
		if (FRand() < 0.05 && Controller.Enemy != None && PlayerController(Controller.Enemy.Controller) != None) {
			PlayerController(Controller.Enemy.Controller).Speech('AUTO', 10, "");
		}

		GoToState('');
	}
}