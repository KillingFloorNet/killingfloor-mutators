class PuppetDummyUber extends PuppetDummy;

simulated function ZombieCrispUp()
{
	bAshen = true;
	bCrispified = true;

    SetBurningBehavior();

	if ( Level.NetMode == NM_DedicatedServer || class'GameInfo'.static.UseLowGore() )
	{
		Return;
	}

}

defaultproperties
{
     HitAnims(0)=
     HitAnims(1)=
     HitAnims(2)=
     KFHitFront=
     KFHitBack=
     KFHitLeft=
     KFHitRight=
     StunsRemaining=1
     MeleeDamage=35
     damageForce=15000
     bFatAss=True
     bMeleeStunImmune=True
     CrispUpThreshhold=1
     ColOffset=(Z=60.000000)
     ColRadius=25.000000
     ColHeight=20.000000
     DetachedArmClass=Class'KFCharPuppets.SeveredArm_VentrilliquistUber'
     DetachedLegClass=Class'KFCharPuppets.SeveredLeg_VentrilliquistUber'
     DetachedHeadClass=Class'KFCharPuppets.SeveredHead_VentrilliquistUber'
     HeadHealth=700.000000
     PlayerNumHeadHealthScale=0.300000
     MotionDetectorThreat=10.000000
     ScoringValue=250
     MeleeRange=55.000000
     GroundSpeed=130.000000
     WaterSpeed=105.000000
     HealthMax=1500.000000
     Health=1500
     MenuName="Uber Ventriloquist Dummy"
     DrawScale=2.000000
     PrePivot=(Z=24.000000)
     Skins(0)=Shader'KF_Puppets_T.ventriloquist.ventriloquist_uber_shdr'
     CollisionRadius=40.000000
     CollisionHeight=70.000000
     Mass=650.000000
}
