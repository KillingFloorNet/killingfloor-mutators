

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         FadeOutStartTime=0.300000
         FadeInEndTime=0.200000
         CoordinateSystem=PTCS_Relative
         MaxParticles=8
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Max=8.000000)
         SpinsPerSecondRange=(X=(Max=0.250000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeTime=0.500000,RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=15.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'kf_fx_trip_t.Gore.bloat_explode_blood'
         LifetimeRange=(Min=0.500000,Max=0.600000)
     End Object
     Emitters(0)=SpriteEmitter'AliensKFXenos.SpitFX.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         UseDirectionAs=PTDU_Up
         FadeOut=True
         ScaleSizeYByVelocity=True
         BlendBetweenSubdivisions=True
         AddVelocityFromOwner=True
         Acceleration=(Z=-600.000000)
         FadeOutStartTime=0.500000
         MaxParticles=5
         StartSizeRange=(X=(Min=5.000000,Max=10.000000),Y=(Min=4.000000,Max=7.000000))
         ScaleSizeByVelocityMultiplier=(Y=0.020000)
         ScaleSizeByVelocityMax=0.250000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'kf_fx_trip_t.Gore.bloat_vomit_spray_anim'
         TextureUSubdivisions=8
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.600000,Max=0.900000)
         StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-100.000000,Max=400.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000))
     End Object
     Emitters(1)=SpriteEmitter'AliensKFXenos.SpitFX.SpriteEmitter1'

     Begin Object Class=TrailEmitter Name=TrailEmitter0
         TrailShadeType=PTTST_Linear
         TrailLocation=PTTL_FollowEmitter
         MaxPointsPerTrail=10
         DistanceThreshold=25.000000
         FadeOut=True
         FadeIn=True
         FadeOutStartTime=0.250000
         FadeInEndTime=0.100000
         StartSizeRange=(X=(Min=10.000000,Max=15.000000))
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'kf_fx_trip_t.Gore.bloat_explode_blood_alt'
         LifetimeRange=(Min=0.250000,Max=0.250000)
     End Object
     Emitters(2)=TrailEmitter'AliensKFXenos.SpitFX.TrailEmitter0'

     bNoDelete=False
     Physics=PHYS_Trailer
     LifeSpan=30.000000
}
