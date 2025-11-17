class ZombieBastard extends ZombieBastardBase
	hidecategories(AnimTweaks,DeRes,Force,Gib,Karma,UDamage,UnrealPawn)
	config(User);

simulated function PostNetReceive()
{
	if(bRunning)
	{
		MovementAnims[0] = 'RunF';
	}
	else
	{
		MovementAnims[0] = default.MovementAnims[0];
	}
}

function SetMindControlled(bool bNewMindControlled)
{
	if(bNewMindControlled)
	{
		++ NumZCDHits;
		if(NumZCDHits > 1)
		{
			if(!IsInState('RunningToMarker'))
			{
				GotoState('RunningToMarker');
			}
			else
			{
				NumZCDHits = 1;
				if(IsInState('RunningToMarker'))
				{
					GotoState('None');
				}
			}
		}
		else
		{
			if(IsInState('RunningToMarker'))
			{
				GotoState('None');
			}
		}
		if(bNewMindControlled != bZedUnderControl)
		{
			GroundSpeed = OriginalGroundSpeed * 1.25;
			Health *= 1.25;
			HealthMax *= 1.25;
		}
	}
	else
	{
		NumZCDHits = 0;
	}
	bZedUnderControl = bNewMindControlled;
}

function GivenNewMarker()
{
	if(bRunning && (NumZCDHits > 1))
	{
		GotoState('RunningToMarker');
	}
	else
	{
		GotoState('None');
	}
}

function RangedAttack(Actor A)
{
	super(KFMonster).RangedAttack(A);
	if(!bShotAnim && (!bDecapitated) && (VSize(A.Location - Location) <= float(700)))
	{
		GotoState('RunningState');
	}
}

simulated event SetAnimAction(name NewAction)
{
	local int meleeAnimIndex;
	local bool bWantsToAttackAndMove;

	if(NewAction == 'None')
	{
		return;
	}
	bWantsToAttackAndMove = NewAction == 'ClawAndMove';
	if(NewAction == 'Claw')
	{
		meleeAnimIndex = Rand(3);
		NewAction = MeleeAnims[meleeAnimIndex];
		CurrentDamType = ZombieDamType[meleeAnimIndex];
	}
	if(bWantsToAttackAndMove)
	{
		ExpectingChannel = AttackAndMoveDoAnimAction(NewAction);
	}
	else
	{
		ExpectingChannel = DoAnimAction(NewAction);
	}
	if(!bWantsToAttackAndMove && (AnimNeedsWait(NewAction)))
	{
		bWaitForAnim = true;
	}
	else
	{
		bWaitForAnim = false;
	}
	if(Level.NetMode != 3)
	{
		AnimAction = NewAction;
		bResetAnimAct = true;
		ResetAnimActTime = Level.TimeSeconds + 0.30;
	}
}

simulated function int AttackAndMoveDoAnimAction(name AnimName)
{
	local int meleeAnimIndex;

	if(AnimName == 'ClawAndMove')
	{
		meleeAnimIndex = Rand(3);
		AnimName = MeleeAnims[meleeAnimIndex];
		CurrentDamType = ZombieDamType[meleeAnimIndex];
	}
	if(AnimName == 'Claw' || (AnimName == 'Claw2') || (AnimName == 'Claw3'))
	{
		AnimBlendParams(1, 1.00, 0.00,, FireRootBone);
		PlayAnim(AnimName,, 0.10, 1);
		return 1;
	}
	return DoAnimAction(AnimName);
}

simulated function HideBone(name BoneName)
{
	local int BoneScaleSlot;
	local Coords boneCoords;
	local bool bValidBoneToHide;

	if(BoneName == LeftThighBone)
	{
		BoneScaleSlot = 0;
		bValidBoneToHide = true;
		if(SeveredLeftLeg == none)
		{
			SeveredLeftLeg = Spawn(SeveredLegAttachClass, self);
			SeveredLeftLeg.SetDrawScale(SeveredLegAttachScale);
			boneCoords = GetBoneCoords('lleg');
			AttachEmitterEffect(LimbSpurtEmitterClass, 'lleg', boneCoords.Origin, rot(0, 0, 0));
			AttachToBone(SeveredLeftLeg, 'lleg');
		}
	}
	else
	{
		if(BoneName == RightThighBone)
		{
			BoneScaleSlot = 1;
			bValidBoneToHide = true;
			if(SeveredRightLeg == none)
			{
				SeveredRightLeg = Spawn(SeveredLegAttachClass, self);
				SeveredRightLeg.SetDrawScale(SeveredLegAttachScale);
				boneCoords = GetBoneCoords('rleg');
				AttachEmitterEffect(LimbSpurtEmitterClass, 'rleg', boneCoords.Origin, rot(0, 0, 0));
				AttachToBone(SeveredRightLeg, 'rleg');
			}
		}
		else
		{
			if(BoneName == RightFArmBone)
			{
				BoneScaleSlot = 2;
				bValidBoneToHide = true;
				if(SeveredRightArm == none)
				{
					SeveredRightArm = Spawn(SeveredArmAttachClass, self);
					SeveredRightArm.SetDrawScale(SeveredArmAttachScale);
					boneCoords = GetBoneCoords('rarm');
					AttachEmitterEffect(LimbSpurtEmitterClass, 'rarm', boneCoords.Origin, rot(0, 0, 0));
					AttachToBone(SeveredRightArm, 'rarm');
				}
			}
			else
			{
				if(BoneName == LeftFArmBone)
				{
					return;
				}
				else
				{
					if(BoneName == HeadBone)
					{
						if(SeveredHead == none)
						{
							bValidBoneToHide = true;
							BoneScaleSlot = 4;
							SeveredHead = Spawn(SeveredHeadAttachClass, self);
							SeveredHead.SetDrawScale(SeveredHeadAttachScale);
							boneCoords = GetBoneCoords('neck');
							AttachEmitterEffect(NeckSpurtEmitterClass, 'neck', boneCoords.Origin, rot(0, 0, 0));
							AttachToBone(SeveredHead, 'neck');
						}
						else
						{
							return;
						}
					}
					else
					{
						if(BoneName == 'spine')
						{
							bValidBoneToHide = true;
							BoneScaleSlot = 5;
						}
					}
				}
			}
		}
	}
	if(bValidBoneToHide)
	{
		SetBoneScale(BoneScaleSlot, 0.00, BoneName);
	}
}

state RunningState
{
	function bool CanSpeedAdjust()
	{
		return false;
	}

	function BeginState()
	{
		GroundSpeed = OriginalGroundSpeed * 2.00;
		bRunning = true;
		if(Level.NetMode != 1)
		{
			PostNetReceive();
		}
		NetUpdateTime = Level.TimeSeconds - float(1);
	}

	function EndState()
	{
		GroundSpeed = GetOriginalGroundSpeed();
		bRunning = false;
		if(Level.NetMode != 1)
		{
			PostNetReceive();
		}
		RunAttackTimeout = 0.00;
		NetUpdateTime = Level.TimeSeconds - float(1);
	}

	function RemoveHead()
	{
		GotoState('None');
		global.RemoveHead();
	}

	function RangedAttack(Actor A)
	{
		local float ChargeChance;

		if(Level.Game.GameDifficulty < 2.00)
		{
			ChargeChance = 0.10;
		}
		else
		{
			if(Level.Game.GameDifficulty < 4.00)
			{
				ChargeChance = 0.20;
			}
			else
			{
				if(Level.Game.GameDifficulty < 5.00)
				{
					ChargeChance = 0.30;
				}
				else
				{
					ChargeChance = 0.40;
				}
			}
		}
		if(bShotAnim || (Physics == 3))
		{
			return;
		}
		else
		{
			if(CanAttack(A))
			{
				bShotAnim = true;
				if(FRand() < ChargeChance)
				{
					SetAnimAction('ClawAndMove');
					RunAttackTimeout = GetAnimDuration('Claw3', 1.00);
				}
				else
				{
					SetAnimAction('Claw');
					Controller.bPreparingMove = true;
					Acceleration = vect(0.00, 0.00, 0.00);
					GotoState('None');
				}
				return;
			}
		}
	}

	simulated function Tick(float DeltaTime)
	{
		if(RunAttackTimeout > float(0))
		{
			RunAttackTimeout -= DeltaTime;
			if(RunAttackTimeout <= float(0) && (!bZedUnderControl))
			{
				RunAttackTimeout = 0.00;
				GotoState('None');
			}
		}
		if(Role == 4 && (bShotAnim) && (!bWaitForAnim))
		{
			if(LookTarget != none)
			{
				Acceleration = AccelRate * Normal(LookTarget.Location - Location);
			}
		}
		global.Tick(DeltaTime);
	}

Begin:
	goto 'CheckCharge';
CheckCharge:

	if(Controller != none && (Controller.Target != none) && (VSize(Controller.Target.Location - Location) < float(700)))
	{
		Sleep(0.50 + FRand() * 0.50);
		goto 'CheckCharge';
	}
	else
	{
		GotoState('None');
	}
	stop;	
}

state RunningToMarker extends RunningState
{
	simulated function Tick(float DeltaTime)
	{
		if(RunAttackTimeout > float(0))
		{
			RunAttackTimeout -= DeltaTime;
			if(RunAttackTimeout <= float(0) && (!bZedUnderControl))
			{
				RunAttackTimeout = 0.00;
				GotoState('None');
			}
		}
		if(Role == 4 && (bShotAnim) && (!bWaitForAnim))
		{
			if(LookTarget != none)
			{
				Acceleration = AccelRate * Normal(LookTarget.Location - Location);
			}
		}
		global.Tick(DeltaTime);
	}

Begin:
	goto 'CheckCharge';
CheckCharge:

	if(bZedUnderControl || (Controller != none && (Controller.Target != none) && (VSize(Controller.Target.Location - Location) < float(700))))
	{
		Sleep(0.50 + FRand() * 0.50);
		goto 'CheckCharge';
	}
	else
	{
		GotoState('None');
	}
	stop;		
}

defaultproperties
{
     DetachedArmClass=Class'KFChar.SeveredArmPatriarch'
     DetachedLegClass=Class'KFChar.SeveredLegPatriarch'
     DetachedHeadClass=Class'KFChar.SeveredHeadPatriarch'
     ControllerClass=Class'HMBastardMut.BastardController'
}
