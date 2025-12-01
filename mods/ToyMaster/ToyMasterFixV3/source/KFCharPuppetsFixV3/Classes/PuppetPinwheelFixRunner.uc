//================
//Code fixes and balancing by Skell*.
//Original content by Alex Quick and David Hensley.
//================
//Pinwheel Puppet (Runner)
//================
class PuppetPinwheelFixRunner extends PuppetPinwheel_Runner;

#exec obj load file="KFPuppetsFixV3_A.ukx"

defaultproperties
{
     HitAnims(0)="HitReactionF"
     HitAnims(1)="HitReactionF"
     HitAnims(2)="HitReactionF"
     MeleeDamage=8
     ColOffset=(Z=42.000000)
     ColRadius=24.000000
     ColHeight=16.000000
     OnlineHeadshotOffset=(X=2.500000,Z=46.000000)
     OnlineHeadshotScale=1.250000
     HeadHealth=550.000000
     HealthMax=720.000000
     Health=720
     Mesh=SkeletalMesh'KFPuppetsFixV3_A.puppet_pinwheel_fix'
     CollisionHeight=30.000000
}
