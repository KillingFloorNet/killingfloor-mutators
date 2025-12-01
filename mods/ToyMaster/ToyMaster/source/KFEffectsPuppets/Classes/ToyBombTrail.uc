class ToyBombTrail extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseColorScale=True
         FadeOut=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         BlendBetweenSubdivisions=True
         UseSubdivisionScale=True
         UseRandomSubdivision=True
         ColorScale(0)=(Color=(B=64,G=64,R=64))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=64,G=64,R=64,A=255))
         ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128))
         ColorMultiplierRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         FadeOutStartTime=0.501500
         MaxParticles=200
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=1.000000)
         SpinsPerSecondRange=(X=(Max=0.070000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartSizeRange=(X=(Min=1.000000,Max=15.000000),Y=(Min=0.000000,Max=0.000000),Z=(Min=0.000000,Max=0.000000))
         ScaleSizeByVelocityMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         ScaleSizeByVelocityMax=0.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'kf_fx_trip_t.Misc.smoke_animated'
         TextureUSubdivisions=8
         TextureVSubdivisions=8
         SubdivisionEnd=7
         SecondsBeforeInactive=30.000000
         LifetimeRange=(Min=1.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=2.000000,Max=25.000000))
         MaxAbsVelocity=(X=100.000000,Y=100.000000,Z=100.000000)
     End Object
     Emitters(0)=SpriteEmitter'KFEffectsPuppets.ToyBombTrail.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         UseDirectionAs=PTDU_Up
         UseColorScale=True
         FadeOut=True
         UseRegularSizeScale=False
         ScaleSizeYByVelocity=True
         Acceleration=(Z=-500.000000)
         DampingFactorRange=(X=(Min=0.200000),Y=(Min=0.200000),Z=(Min=0.200000,Max=0.500000))
         ColorScale(0)=(Color=(B=100,G=177,R=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(G=89,R=179))
         FadeOutStartTime=0.500000
         MaxParticles=25
         DetailMode=DM_High
         UseRotationFrom=PTRS_Actor
         SizeScale(2)=(RelativeTime=0.070000,RelativeSize=1.000000)
         SizeScale(3)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=0.500000,Max=3.000000),Y=(Min=0.500000,Max=3.000000),Z=(Min=0.500000,Max=3.000000))
         ScaleSizeByVelocityMultiplier=(Y=0.020000)
         DrawStyle=PTDS_Brighten
         Texture=Texture'KFX.KFSparkHead'
         TextureUSubdivisions=1
         TextureVSubdivisions=1
         LifetimeRange=(Min=0.250000,Max=0.500000)
         StartVelocityRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=-150.000000,Max=150.000000))
     End Object
     Emitters(1)=SpriteEmitter'KFEffectsPuppets.ToyBombTrail.SpriteEmitter2'

     bNoDelete=False
     bNetTemporary=True
     Physics=PHYS_Trailer
}
