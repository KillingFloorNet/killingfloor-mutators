class RpgExplosion extends Emitter;

defaultproperties
{
	Begin Object Class=SpriteEmitter Name=SpriteEmitter95
		UseColorScale=True
		FadeOut=True
		FadeIn=True
		RespawnDeadParticles=False
		UseSizeScale=True
		UseRegularSizeScale=False
		UniformSize=True
		AutomaticInitialSpawning=False
		ColorScale(0)=(Color=(B=174,G=228,R=255,A=255))
		ColorScale(1)=(RelativeTime=0.200000,Color=(B=255,G=255,R=255,A=255))
		ColorScale(2)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
		ColorScale(3)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
		ColorScale(4)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
		FadeOutStartTime=0.102500
		FadeInEndTime=0.050000
		MaxParticles=4
		SizeScale(1)=(RelativeTime=0.250000,RelativeSize=1.000000)
		SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.000000)
		InitialParticlesPerSecond=30.000000
		DrawStyle=PTDS_AlphaBlend
		Texture=Texture'Effects_Tex.explosions.radialexplosion_1frame'
		LifetimeRange=(Min=0.250000,Max=0.250000)
	End Object
	Emitters(0)=SpriteEmitter'RPG7DT_v2.RpgExplosion.SpriteEmitter95'

	Begin Object Class=SpriteEmitter Name=SpriteEmitter96
		UseColorScale=True
		FadeOut=True
		RespawnDeadParticles=False
		SpinParticles=True
		UseSizeScale=True
		UseRegularSizeScale=False
		UniformSize=True
		AutomaticInitialSpawning=False
		BlendBetweenSubdivisions=True
		Acceleration=(X=50.000000,Y=50.000000,Z=0.500000)
		ColorScale(0)=(Color=(B=128,G=128,R=128,A=255))
		ColorScale(1)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128,A=255))
		FadeOutStartTime=0.990000
		Opacity=0.300000
		MaxParticles=5
		StartLocationRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000))
		StartLocationShape=PTLS_Sphere
		SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000))
		StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
		SizeScale(0)=(RelativeTime=1.000000,RelativeSize=10.000000)
		StartSizeRange=(X=(Min=10.000000,Max=50.000000),Y=(Min=10.000000,Max=50.000000),Z=(Min=20.000000,Max=20.000000))
		InitialParticlesPerSecond=500.000000
		DrawStyle=PTDS_AlphaBlend
		Texture=Texture'kf_fx_trip_t.Misc.smoke_animated'
		TextureUSubdivisions=8
		TextureVSubdivisions=8
		SecondsBeforeInactive=0.000000
		LifetimeRange=(Min=3.000000)
		StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000))
		VelocityLossRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
	End Object
	Emitters(1)=SpriteEmitter'RPG7DT_v2.RpgExplosion.SpriteEmitter96'

	/// Добавлено*************

	Begin Object Class=SpriteEmitter Name=SpriteEmitterDT24
		FadeOut=True
		FadeIn=True
		RespawnDeadParticles=False
		SpinParticles=True
		UseSizeScale=True
		UseRegularSizeScale=False
		UseRandomSubdivision=True
		UniformSize=True
		AutomaticInitialSpawning=False
		ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
		ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
		ColorMultiplierRange=(X=(Min=0.900000),Y=(Min=0.760000,Max=0.760000),Z=(Min=0.400000,Max=0.400000))
		Opacity=0.320000
		FadeOutStartTime=0.090000
		FadeInEndTime=0.044000
		MaxParticles=3
		StartLocationRange=(X=(Min=-40.000000,Max=40.000000),Y=(Min=-40.000000,Max=40.000000),Z=(Min=-40.000000,Max=40.000000))
		StartLocationShape=PTLS_Polar
		SpinsPerSecondRange=(X=(Max=2.000000))
		StartSpinRange=(X=(Max=1.000000))
		SizeScale(0)=(RelativeSize=0.100000)
		SizeScale(1)=(RelativeTime=0.280000,RelativeSize=2.000000)
		SizeScale(2)=(RelativeTime=1.000000,RelativeSize=4.000000)
		StartSizeRange=(X=(Min=50.000000,Max=80.000000),Y=(Min=50.000000,Max=80.000000),Z=(Min=50.000000,Max=80.000000))
		InitialParticlesPerSecond=500.000000
		Texture=Texture'RPG7DTv2_A.Effects.explo_trans_ani02'
		TextureUSubdivisions=2
		TextureVSubdivisions=2
		SecondsBeforeInactive=0.000000
		LifetimeRange=(Min=0.400000,Max=0.400000)
		StartVelocityRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000))
	End Object
	Emitters(2)=SpriteEmitter'RPG7DT_v2.RpgExplosion.SpriteEmitterDT24'

	Begin Object Class=SpriteEmitter Name=SpriteEmitterDT3
		FadeOut=True
		RespawnDeadParticles=False
		SpinParticles=True
		UseSizeScale=True
		UseRegularSizeScale=False
		UniformSize=True
		AutomaticInitialSpawning=False
		UseRandomSubdivision=True
		ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
		ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
		FadeOutStartTime=0.100000
		MaxParticles=1
		StartSpinRange=(X=(Max=1.000000))
		SizeScale(1)=(RelativeTime=1.000000,RelativeSize=5.000000)
		InitialParticlesPerSecond=50000.000000
		DrawStyle=PTDS_AlphaBlend
		Texture=Texture'RPG7DTv2_A.Effects.smoke_hitwall_k'
		TextureUSubdivisions=2
		TextureVSubdivisions=2
		SecondsBeforeInactive=0.000000
		LifetimeRange=(Min=0.500000,Max=0.500000)
	End Object
	Emitters(3)=SpriteEmitter'RPG7DT_v2.RpgExplosion.SpriteEmitterDT3'
	
	Begin Object Class=SpriteEmitter Name=SpriteEmitterDT1
		UseCollision=True
		RespawnDeadParticles=False
		SpinParticles=True
		UniformSize=True
		AutomaticInitialSpawning=False
		ExtentMultiplier=(X=0.300000,Y=0.300000,Z=0.300000)
		DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.700000,Max=0.700000))
		ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
		ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
		ColorMultiplierRange=(X=(Min=0.800000),Y=(Min=0.700000,Max=0.800000),Z=(Min=0.100000,Max=0.200000))
		Opacity=0.630000
		FadeOutStartTime=0.050000
		MaxParticles=9
		AddLocationFromOtherEmitter=5
		AlphaRef=128
		SpinsPerSecondRange=(X=(Max=2.000000))
		StartSizeRange=(X=(Min=20.000000,Max=30.000000),Y=(Min=20.000000,Max=30.000000),Z=(Min=20.000000,Max=30.000000))
		InitialParticlesPerSecond=50000.000000
		Texture=Texture'RPG7DTv2_A.Effects.FlareB1'
		SecondsBeforeInactive=0.000000
		LifetimeRange=(Min=0.050000,Max=0.050000)
		StartVelocityRange=(Z=(Min=-100.000000))
		VelocityLossRange=(X=(Min=0.400000,Max=0.400000),Y=(Min=0.400000,Max=0.400000),Z=(Min=0.300000,Max=0.400000))
		AddVelocityFromOtherEmitter=5
	End Object
	Emitters(4)=SpriteEmitter'RPG7DT_v2.RpgExplosion.SpriteEmitterDT1'
	///************************
	
	Begin Object Class=SpriteEmitter Name=SpriteEmitter98
		UseCollision=True
		UseColorScale=True
		FadeOut=True
		RespawnDeadParticles=False
		UseRevolution=True
		SpinParticles=False
		UseSizeScale=False
		UseRegularSizeScale=False
		UniformSize=True
		AutomaticInitialSpawning=False
		UseRandomSubdivision=True
		Acceleration=(Z=-1200.000000)
		DampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
		ColorScale(0)=(Color=(B=9,G=169,R=255,A=255))
		ColorScale(1)=(RelativeTime=0.050000,Color=(B=128,G=128,R=128,A=255))
		ColorScale(2)=(RelativeTime=1.000000,Color=(B=128,G=128,R=128,A=255))
		FadeOutStartTime=1.400000
		MaxParticles=90
		//UseRotationFrom=PTRS_Actor
		//SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000))
		//StartSpinRange=(X=(Min=0.500000,Max=0.500000))
		SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
		StartSizeRange=(X=(Min=1.000000,Max=3.000000),Y=(Min=1.000000,Max=3.000000),Z=(Min=3.000000,Max=5.000000))
		InitialParticlesPerSecond=500.000000
		DrawStyle=PTDS_AlphaBlend
		Texture=Texture'RPG7DTv2_A.Effects.Concrete_Debris'
		TextureUSubdivisions=2
		TextureVSubdivisions=2
		LifetimeRange=(Min=5.000000,Max=5.000000)
		StartVelocityRange=(X=(Min=-800.000000,Max=1000.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=500.000000,Max=1000.000000))
	End Object
	Emitters(5)=SpriteEmitter'RPG7DT_v2.RpgExplosion.SpriteEmitter98'
	
	Begin Object Class=SpriteEmitter Name=SpriteEmitter9
		FadeOut=True
		RespawnDeadParticles=False
		SpinParticles=True
		UseSizeScale=True
		UseRegularSizeScale=False
		UniformSize=True
		AutomaticInitialSpawning=False
		ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
		ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
		Opacity=0.140000
		FadeOutStartTime=0.010000
		MaxParticles=1
		SpinsPerSecondRange=(X=(Min=0.050000,Max=0.100000),Y=(Min=0.050000,Max=0.100000),Z=(Min=0.050000,Max=0.100000))
		SizeScale(1)=(RelativeTime=1.000000,RelativeSize=500.000000)
		StartSizeRange=(X=(Min=0.000000,Max=50.000000),Y=(Min=0.000000,Max=50.000000),Z=(Min=0.000000,Max=50.000000))
		InitialParticlesPerSecond=50000.000000
		Texture=Texture'RPG7DTv2_A.Effects.Alien_effect_010'
		LifetimeRange=(Min=0.500000,Max=0.500000)
	End Object
	Emitters(6)=SpriteEmitter'RPG7DT_v2.RpgExplosion.SpriteEmitter9'

	AutoDestroy=True
	bNoDelete=False
	LifeSpan=5.000000
	bHardAttach=True
	bDirectional=True
}