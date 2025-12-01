//================
//Code fixes and balancing by Skell*.
//Original content by Alex Quick and David Hensley.
//================
//Babydoll Puppet (Regular)
//================
class PuppetBabydollFix extends PuppetBabydoll;

#exec obj load file="KFPuppetsFixV3_A.ukx"

defaultproperties
{
     ColOffset=(Z=40.000000)
     ColRadius=18.000000
     ColHeight=18.000000
     BurningWalkFAnims(0)="WalkF_Headless"
     BurningWalkFAnims(1)="WalkF_Headless"
     BurningWalkFAnims(2)="WalkF_Headless"
     BurningWalkAnims(0)="WalkB_Headless"
     BurningWalkAnims(1)="WalkL_Headless"
     BurningWalkAnims(2)="WalkR_Headless"
     OnlineHeadshotOffset=(X=1.250000,Z=42.000000)
     HeadHealth=50.000000
     HealthMax=98.000000
     Health=98
     Mesh=SkeletalMesh'KFPuppetsFixV3_A.puppet_babydoll_fix'
     CollisionHeight=29.000000
}
