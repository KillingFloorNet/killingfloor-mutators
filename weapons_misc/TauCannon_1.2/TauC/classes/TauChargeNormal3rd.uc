class TauChargeNormal3rd extends ROMuzzleFlash3rd;

defaultproperties
{
     Begin Object Class=BeamEmitter Name=BeamEmitter0
         LowFrequencyNoiseRange=(X=(Min=-16.0,Max=16.0),Y=(Min=-16.0,Max=16.0),Z=(Min=-16.0,Max=16.0))
         LowFrequencyPoints=4
         HighFrequencyNoiseRange=(X=(Min=-4.0,Max=4.0),Y=(Min=-4.0,Max=4.0),Z=(Min=-4.0,Max=4.0))
         HighFrequencyPoints=8
         LFScaleFactors(0)=(FrequencyScale=(Z=100.0),RelativeLength=1.0)
         HFScaleFactors(0)=(FrequencyScale=(X=50.0,Y=50.0,Z=50.0))
         UseBranching=True
         BranchProbability=(Min=1.0,Max=1.0)
         BranchSpawnAmountRange=(Min=5.0,Max=5.0)
         UseColorScale=True
         UseSizeScale=True
         UseRegularSizeScale=False
         ColorScale(0)=(Color=(B=128,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.0,Color=(B=72,G=132,R=255,A=255))
         CoordinateSystem=PTCS_Relative
         MaxParticles=30
         StartLocationRange=(X=(Min=-18.0,Max=18.0),Y=(Min=-18.0,Max=18.0),Z=(Min=-18.0,Max=18.0))
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=1.0,Max=1.0)
         SizeScale(0)=(RelativeTime=0.500000,RelativeSize=1.0)
         SizeScale(1)=(RelativeTime=1.0)
         StartSizeRange=(X=(Min=0.100000,Max=0.500000),Y=(Min=0.100000,Max=0.500000),Z=(Min=0.100000,Max=0.500000))
         InitialParticlesPerSecond=90.0
         Texture=Texture'kf_fx_trip_t.Misc.healingFX'
         LifetimeRange=(Min=0.200000,Max=0.500000)
         StartVelocityRadialRange=(Min=10.0,Max=10.0)
         GetVelocityDirectionFrom=PTVD_AddRadial
     End Object
     Emitters(0)=BeamEmitter'TauChargeNormal3rd.BeamEmitter0'

}
