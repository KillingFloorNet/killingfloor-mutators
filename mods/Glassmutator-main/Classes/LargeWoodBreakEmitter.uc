class LargeWoodBreakEmitter extends KFHitEmitter;


#exec OBJ LOAD FILE=KFWeaponSound.uax


defaultproperties
{
  ImpactSounds(0)=Sound'WoodBreakFX.WoodBreak4'
  ImpactSounds(1)=Sound'WoodBreakFX.WoodBreak2'
  Begin Object Class=SpriteEmitter Name=LargeWoodExplosionEmitter
    UseCollision=true
    FadeOut=true
    RespawnDeadParticles=false
    SpinParticles=true
    UniformSize=true
    BlendBetweenSubdivisions=true
    UseRandomSubdivision=true
    Acceleration=(Z=-800.000000)
    DampingFactorRange=(X=(Min=0.000000,Max=0.800000),Y=(Min=0.000000,Max=0.800000),Z=(Min=0.000000,Max=0.400000))
    ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
    ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
    FadeOutStartTime=1.000000
    MaxParticles=50
    DetailMode=DM_High
    StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
    SpinsPerSecondRange=(X=(Max=0.200000))
    StartSpinRange=(X=(Min=1.000000))
    StartSizeRange=(X=(Min=5.000000,Max=7.000000))
    InitialParticlesPerSecond=200.000000
    DrawStyle=PTDS_AlphaBlend
    Texture=Texture'KFMaterials.WoodChips'
    TextureUSubdivisions=4
    TextureVSubdivisions=4
    LifetimeRange=(Min=2.000000)
    StartVelocityRange=(X=(Min=-200.000000,Max=200.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-200.000000,Max=200.000000))
    MaxAbsVelocity=(Z=500.000000)
  End Object
  Emitters(0)=SpriteEmitter'Glassmutator.LargeWoodBreakEmitter.LargeWoodExplosionEmitter'
}