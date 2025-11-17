class FlareAttachment extends KFWeaponAttachment;

// No muzzle flash for this
simulated function WeaponLight(){}
simulated function DoFlashEmitter(){}

defaultproperties
{
	MovementAnims(0)="JogF_Axe"
	MovementAnims(1)="JogB_Axe"
	MovementAnims(2)="JogL_Axe"
	MovementAnims(3)="JogR_Axe"
	TurnLeftAnim="TurnL_Axe"
	TurnRightAnim="TurnR_Axe"
	CrouchAnims(0)="CHwalkF_Axe"
	CrouchAnims(1)="CHwalkB_Axe"
	CrouchAnims(2)="CHwalkL_Axe"
	CrouchAnims(3)="CHwalkR_Axe"
	CrouchTurnRightAnim="CH_TurnR_Axe"
	CrouchTurnLeftAnim="CH_TurnL_Axe"
	IdleCrouchAnim="CHIdle_Axe"
	IdleWeaponAnim="Idle_Axe"
	IdleRestAnim="Idle_Axe"
	IdleChatAnim="Idle_Axe"
	IdleHeavyAnim="Idle_Axe"
	IdleRifleAnim="Idle_Axe"
	FireAnims(0)="Frag_Axe"
	FireAnims(1)="Frag_Axe"
	FireAnims(2)="Frag_Axe"
	FireAnims(3)="Frag_Axe"
	FireAltAnims(0)="Frag_Axe"
	FireAltAnims(1)="Frag_Axe"
	FireAltAnims(2)="Frag_Axe"
	FireAltAnims(3)="Frag_Axe"
	FireCrouchAnims(0)="CHAttack1_Axe"
	FireCrouchAnims(1)="CHAttack2_Axe"
	FireCrouchAnims(2)="CHAttack3_Axe"
	FireCrouchAnims(3)="CHAttack3_Axe"
	FireCrouchAltAnims(0)="CHAttack1_Axe"
	FireCrouchAltAnims(1)="CHAttack2_Axe"
	FireCrouchAltAnims(2)="CHAttack3_Axe"
	FireCrouchAltAnims(3)="CHAttack3_Axe"
	HitAnims(0)="HitF_Axe"
	HitAnims(1)="HitB_Axe"
	HitAnims(2)="HitL_Axe"
	HitAnims(3)="HitR_Axe"
	PostFireBlendStandAnim="Blend_Axe"
	PostFireBlendCrouchAnim="CHBlend_Axe"
	Mesh=SkeletalMesh'Flare_R.FlareMesh3rd'
}