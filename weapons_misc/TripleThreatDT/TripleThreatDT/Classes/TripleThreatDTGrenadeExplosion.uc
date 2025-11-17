class TripleThreatDTGrenadeExplosion extends Emitter;

var bool bFlashed;

simulated function PostBeginPlay()
{
	Super.Postbeginplay();
	NadeLight();
}

simulated function NadeLight()
{
	if ( !Level.bDropDetail && (Instigator != None)
		&& ((Level.TimeSeconds - LastRenderTime < 0.2) || (PlayerController(Instigator.Controller) != None)) )
	{
		bDynamicLight = true;
		SetTimer(0.25, false);
	}
	else Timer();
}

simulated function Timer()
{
	bDynamicLight = false;
}

defaultproperties
{
	Begin Object Class=SpriteEmitter Name=SpriteEmitter22
		UseDirectionAs=PTDU_Normal
		FadeOut=True
		FadeIn=True
		RespawnDeadParticles=False
		SpinParticles=True
		UseSizeScale=True
		UseRegularSizeScale=False
		UniformSize=True
		AutomaticInitialSpawning=False
		BlendBetweenSubdivisions=True
		ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
		ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
		ColorMultiplierRange=(Y=(Min=0.250000,Max=0.250000),Z=(Min=0.000000,Max=0.000000))
		FadeOutStartTime=0.102500
		FadeInEndTime=0.050000
		MaxParticles=1
		SpinsPerSecondRange=(X=(Max=10.000000))
		StartSpinRange=(X=(Max=1.000000))
		SizeScale(1)=(RelativeTime=0.140000,RelativeSize=2.000000)
		SizeScale(2)=(RelativeTime=1.000000,RelativeSize=2.500000)
		InitialParticlesPerSecond=30.000000
		DrawStyle=PTDS_Brighten
		Texture=Texture'KFZED_FX_T.Energy.ZedGun_Energy_A'
		TextureUSubdivisions=1
		TextureVSubdivisions=1
		LifetimeRange=(Min=0.500000,Max=0.500000)
		StartVelocityRange=(Z=(Min=20.000000,Max=20.000000))
	End Object
     Emitters(0)=SpriteEmitter'TripleThreatDTGrenadeExplosion.SpriteEmitter22'

	 Begin Object Class=SpriteEmitter Name=SpriteEmitter21
		FadeOut=True
		FadeIn=True
		RespawnDeadParticles=False
		UseSizeScale=True
		UseRegularSizeScale=False
		UniformSize=True
		AutomaticInitialSpawning=False
		Acceleration=(Z=25.000000)
		ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
		ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
		ColorMultiplierRange=(Z=(Min=0.500000,Max=0.500000))
		FadeOutStartTime=0.102500
		FadeInEndTime=0.050000
		MaxParticles=2
		SpinsPerSecondRange=(X=(Max=10.000000))
		StartSpinRange=(X=(Max=1.000000))
		SizeScale(1)=(RelativeTime=0.140000,RelativeSize=1.000000)
		SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
		StartSizeRange=(X=(Min=25.000000,Max=25.000000),Y=(Min=25.000000,Max=25.000000),Z=(Min=25.000000,Max=25.000000))
		InitialParticlesPerSecond=30.000000
		DrawStyle=PTDS_Brighten
		Texture=Texture'Effects_Tex.explosions.impact_2frame'
		TextureUSubdivisions=2
		TextureVSubdivisions=1
		LifetimeRange=(Min=0.100000,Max=0.100000)
		StartVelocityRange=(Z=(Min=5.000000,Max=5.000000))
	End Object
     Emitters(1)=SpriteEmitter'TripleThreatDTGrenadeExplosion.SpriteEmitter21'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         Acceleration=(Z=50.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         FadeOutStartTime=0.102500
         FadeInEndTime=0.050000
         MaxParticles=1
         SizeScale(1)=(RelativeTime=0.140000,RelativeSize=1.000000)
         SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartSizeRange=(X=(Min=50.000000,Max=50.000000),Y=(Min=50.000000,Max=50.000000),Z=(Min=50.000000,Max=50.000000))
         InitialParticlesPerSecond=30.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'Effects_Tex.explosions.impact_2frame'
         TextureUSubdivisions=2
         TextureVSubdivisions=1
         LifetimeRange=(Min=0.100000,Max=0.100000)
         StartVelocityRange=(Z=(Min=10.000000,Max=10.000000))
     End Object
     Emitters(2)=SpriteEmitter'TripleThreatDTGrenadeExplosion.SpriteEmitter3'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter4
         UseCollision=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ScaleSizeXByVelocity=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-1000.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.500000,Max=0.500000))
         ColorScale(0)=(Color=(B=255,G=255,R=187))
         ColorScale(1)=(RelativeTime=0.214286,Color=(G=103,R=206,A=255))
         ColorScale(2)=(RelativeTime=0.439286,Color=(B=100,G=177,R=255,A=255))
         ColorScale(3)=(RelativeTime=1.000000,Color=(G=103,R=206,A=255))
         ColorScale(4)=(RelativeTime=1.000000,Color=(G=103,R=206,A=255))
         ColorScale(5)=(RelativeTime=1.000000,Color=(R=128,A=255))
         ColorScale(6)=(RelativeTime=1.000000)
         ColorScale(7)=(RelativeTime=1.000000)
         FadeOutStartTime=0.336000
         FadeInEndTime=0.064000
         MaxParticles=20
         StartSpinRange=(X=(Min=-0.500000,Max=0.500000))
         SizeScale(0)=(RelativeSize=0.250000)
         SizeScale(1)=(RelativeTime=1.000000)
         StartSizeRange=(X=(Min=1.000000,Max=1.000000),Y=(Min=1.000000,Max=1.000000),Z=(Min=1.000000,Max=1.000000))
         ScaleSizeByVelocityMultiplier=(X=0.010000,Y=0.010000)
         InitialParticlesPerSecond=5000.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'Effects_Tex.explosions.shrapnel3'
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=100.000000,Max=500.000000))
     End Object
     Emitters(3)=SpriteEmitter'TripleThreatDTGrenadeExplosion.SpriteEmitter4'
	 
     AutoDestroy=True
     LightType=LT_Steady
     LightHue=30
     LightSaturation=100
     LightBrightness=500.000000
     LightRadius=8.000000
     bNoDelete=False
     RemoteRole=ROLE_SimulatedProxy
     bNotOnDedServer=False
}
