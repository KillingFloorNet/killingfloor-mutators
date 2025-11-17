class RPGAttachment extends KFWeaponAttachment;

#exec OBJ LOAD FILE="..\Animations\RPG7DTv2_A.ukx"

var int RocketSize,ClientRocketSize;

replication
{
	reliable if ( Role == ROLE_Authority )
		RocketSize;
}

simulated function PostBeginPlay()
{
	local Pawn P;
	//Flame. Чот на клиенте Instigator равен None. поэтому для клиента получаем по-другому Pawn
	if(Role<ROLE_Authority)
		P=Level.GetLocalPlayerController().Pawn;
	else
		P=Instigator;
	//Flame
	Super.PostBeginPlay();
	SetTimer(0.2,true);
	if (P!=None && P.Weapon!=None && P.Weapon.AmmoAmount(0) < 1)
		SizeRocket(0);
}

simulated function PostNetReceive()
{
	Super.PostNetReceive();
	if ( ClientRocketSize != RocketSize )
	{
		ClientRocketSize = RocketSize;
		//Level.GetLocalPlayerController().ClientMessage("ClientRocketSize = " $ ClientRocketSize $ " RocketSize = " $ RocketSize);
		SetBoneScale(0,float(ClientRocketSize),'Grenade');
	}
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
}

simulated function Timer()
{
	if(Instigator!=None)
	{
		if(Instigator.PlayerReplicationInfo!=None && !Instigator.HasAnim('Reload_RPG_Y'))
		{
			Log("3 person animation applied"@Instigator.PlayerReplicationInfo.PlayerName);
			Instigator.LinkSkelAnim(MeshAnimation'RPG7DTv2_A.Soldier_RPG7DT_anims');
			Instigator.PlayAnim('Idle_RPG_Y',0.1,0.1);
			SetTimer(1.0,true);
		}
	}
	Super.Timer();
}
//Flame. Виновник пятна света после выстрела
simulated event ThirdPersonEffects()
{

	if( FiringMode==1 )
		return;
	Super.ThirdPersonEffects();

}

function SizeRocket(int Size)
{
	if ( Role < ROLE_Authority )
		return;
	if ( Level.NetMode == NM_Standalone )
		SetBoneScale(0,float(Size),'Grenade');
	else
	{
		RocketSize = Size;
		NetUpdateTime = Level.TimeSeconds - 1;
	}
}

defaultproperties
{
	bNetNotify = true
	RocketSize = 1
	ClientRocketSize = 1

	MovementAnims(0)="JogF_RPG_Y"
	MovementAnims(1)="JogB_RPG_Y"
	MovementAnims(2)="JogL_RPG_Y"
	MovementAnims(3)="JogR_RPG_Y"
	TurnLeftAnim="TurnL_RPG_Y"
	TurnRightAnim="TurnR_RPG_Y"
	CrouchAnims(0)="CHwalkF_RPG_Y"
	CrouchAnims(1)="CHwalkB_RPG_Y"
	CrouchAnims(2)="CHwalkL_RPG_Y"
	CrouchAnims(3)="CHwalkR_RPG_Y"
	WalkAnims(0)="WalkF_RPG_Y"
	WalkAnims(1)="WalkB_RPG_Y"
	WalkAnims(2)="WalkL_RPG_Y"
	WalkAnims(3)="WalkR_RPG_Y"
	CrouchTurnRightAnim="CH_TurnR_RPG_Y"
	CrouchTurnLeftAnim="CH_TurnL_RPG_Y"
	IdleCrouchAnim="CHIdle_RPG_Y"
	IdleWeaponAnim="Idle_RPG_Y"
	IdleRestAnim="Idle_RPG_Y"
	IdleChatAnim="Idle_RPG_Y"
	IdleHeavyAnim="Idle_RPG_Y"
	IdleRifleAnim="Idle_RPG_Y"
	FireAnims(0)="Fire_RPG_Y"
	FireAnims(1)="Fire_RPG_Y"
	FireAnims(2)="Fire_RPG_Y"
	FireAnims(3)="Fire_RPG_Y"
	FireAltAnims(0)="Fire_RPG_Y"
	FireAltAnims(1)="Fire_RPG_Y"
	FireAltAnims(2)="Fire_RPG_Y"
	FireAltAnims(3)="Fire_RPG_Y"
	FireCrouchAnims(0)="CHFire_RPG_Y"
	FireCrouchAnims(1)="CHFire_RPG_Y"
	FireCrouchAnims(2)="CHFire_RPG_Y"
	FireCrouchAnims(3)="CHFire_RPG_Y"
	FireCrouchAltAnims(0)="CHFire_RPG_Y"
	FireCrouchAltAnims(1)="CHFire_RPG_Y"
	FireCrouchAltAnims(2)="CHFire_RPG_Y"
	FireCrouchAltAnims(3)="CHFire_RPG_Y"
	HitAnims(0)="HitF_RPG_Y"
	HitAnims(1)="HitB_RPG_Y"
	HitAnims(2)="HitL_RPG_Y"
	HitAnims(3)="HitR_RPG_Y"
	PostFireBlendStandAnim="Blend_RPG_Y"
	PostFireBlendCrouchAnim="CH_Blend_RPG_Y"
	// 
     AirAnims(0)="JumpF_Mid_RPG_Y"
     AirAnims(1)="JumpF_Mid_RPG_Y"
     AirAnims(2)="JumpL_Mid_RPG_Y"
     AirAnims(3)="JumpR_Mid_RPG_Y"
     TakeoffAnims(0)="JumpF_Takeoff_RPG_Y"
     TakeoffAnims(1)="JumpF_Takeoff_RPG_Y"
     TakeoffAnims(2)="JumpL_Takeoff_RPG_Y"
     TakeoffAnims(3)="JumpR_Takeoff_RPG_Y"
     LandAnims(0)="JumpF_Land_RPG_Y"
     LandAnims(1)="JumpF_Land_RPG_Y"
     LandAnims(2)="JumpL_Land_RPG_Y"
     LandAnims(3)="JumpR_Land_RPG_Y"
     DodgeAnims(0)="JumpF_Takeoff_RPG_Y"
     DodgeAnims(1)="JumpF_Takeoff_RPG_Y"
     DodgeAnims(2)="JumpL_Takeoff_RPG_Y"
     DodgeAnims(3)="JumpR_Takeoff_RPG_Y"
     AirStillAnim="JumpF_Mid_RPG_Y"
     TakeoffStillAnim="JumpF_Takeoff_RPG_Y"
	//
	bHeavy=True

	Mesh=SkeletalMesh'RPG7DTv2_A.RPG7_3rd'

	// mTracerClass=Class'RPG7DT.RPGTracer'
	// mTracerClass=Class'kfmod.KFNewTracer'
	// mMuzFlashClass=Class'RPG7DT.RGPFlashEmitter'
	// mMuzFlashClass=Class'RPG7DT.KFRpgMuzzFlash'
	mMuzFlashClass=Class'RPG7DT_v2.RPGBackFlashEmitter'
}
