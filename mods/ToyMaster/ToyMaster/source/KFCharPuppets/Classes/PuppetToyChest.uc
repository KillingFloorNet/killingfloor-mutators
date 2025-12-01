class PuppetToyChest extends KF_StoryNPC_Static;

function SetMovemetPhysics()
{

}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
 	// Don't allow momentum from a Zed
 	if ( KFMonster(InstigatedBy) != none )
	{
		KFMonster(InstigatedBy).bDamagedAPlayer = true;
		Momentum = vect(0,0,0);
	}
    super.TakeDamage(Damage,InstigatedBy,HitLocation,Momentum,damageType,HitIndex);
}


function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{

}

defaultproperties
{
     bStartActive=False
     BaseAIThreatRating=1.000000
     OnlyThreateningTo(0)=Class'KFCharPuppets.PuppetDummy_Runner'
     OnlyThreateningTo(1)=Class'KFCharPuppets.PuppetPinwheel_Runner'
     OnlyThreateningTo(2)=Class'KFCharPuppets.PuppetBabydoll_Runner'
     FriendlyFireDamageScale=0.000000
     bShowHealthBar=True
     bUseDefaultPhysics=False
     NPCHealth=1000.000000
     ProjectileBloodSplatClass=None
     DetachedArmClass=None
     DetachedLegClass=None
     ObliteratedEffectClass=None
     WallDodgeAnims(0)=
     WallDodgeAnims(1)=
     WallDodgeAnims(2)=
     WallDodgeAnims(3)=
     bCanCrouch=False
     ControllerClass=None
     MovementAnims(0)=
     MovementAnims(1)=
     MovementAnims(2)=
     MovementAnims(3)=
     CrouchAnims(0)=
     CrouchAnims(1)=
     CrouchAnims(2)=
     CrouchAnims(3)=
     WalkAnims(0)=
     WalkAnims(1)=
     WalkAnims(2)=
     WalkAnims(3)=
     AirAnims(0)=
     AirAnims(1)=
     AirAnims(2)=
     AirAnims(3)=
     TakeoffAnims(0)=
     TakeoffAnims(1)=
     TakeoffAnims(2)=
     TakeoffAnims(3)=
     LandAnims(0)=
     LandAnims(1)=
     LandAnims(2)=
     LandAnims(3)=
     DoubleJumpAnims(0)=
     DoubleJumpAnims(1)=
     DoubleJumpAnims(2)=
     DoubleJumpAnims(3)=
     DodgeAnims(0)=
     DodgeAnims(1)=
     DodgeAnims(2)=
     DodgeAnims(3)=
     AirStillAnim=
     TakeoffStillAnim=
     DrawType=DT_Mesh
     StaticMesh=None
     bLightChanged=True
     bAcceptsProjectors=False
     Mesh=SkeletalMesh'KF_Puppets.Toybox_SK'
     PrePivot=(Z=40.000000)
     Skins(0)=Texture'KF_Puppets_T.Gameplay.Toybox_D'
     CollisionRadius=60.000000
     CollisionHeight=40.000000
     bUseCylinderCollision=True
}
