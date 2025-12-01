//=============================================================================
// GrenadeExplosion
//=============================================================================
// Grenade explosion effect
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Tripwire Interactive LLC
// - David Hensley & John "Ramm-Jaeger" Gibson
//=============================================================================

class PuppetExplosion extends FleshHitEmitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
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
         LifetimeRange=(Min=0.250000,Max=0.250000)
         StartVelocityRange=(Z=(Min=10.000000,Max=10.000000))
     End Object
     Emitters(0)=SpriteEmitter'KFCharPuppets.PuppetExplosion.SpriteEmitter0'

     bNetTemporary=True
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=8.000000
     Style=STY_Masked
     bHardAttach=True
     bDirectional=True
}
