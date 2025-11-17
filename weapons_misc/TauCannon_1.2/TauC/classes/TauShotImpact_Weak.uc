// Weak Impact Effect for Husk Projectile
class TauShotImpact_Weak extends TauShotImpact;

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=True
        RespawnDeadParticles=False
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        Acceleration=(Z=150)
        ColorScale(0)=(Color=(G=255,R=255,A=128))
        ColorScale(1)=(RelativeTime=0.300000,Color=(B=47,G=80,R=179,A=255))
        ColorScale(2)=(RelativeTime=0.600000,Color=(A=80))
        ColorScale(3)=(RelativeTime=1)
        MaxParticles=6
        Name="SpriteEmitter0"
        StartLocationShape=PTLS_Sphere
        SphereRadiusRange=(Min=20,Max=20)
        SpinsPerSecondRange=(X=(Max=0.100000))
        StartSpinRange=(X=(Max=1))
        SizeScale(0)=(RelativeSize=0.700000)
        SizeScale(1)=(RelativeTime=1,RelativeSize=5)
        StartSizeRange=(X=(Min=5,Max=10),Y=(Min=5,Max=10),Z=(Min=10,Max=10))
        InitialParticlesPerSecond=800
        DrawStyle=PTDS_Brighten
        Texture=Texture'kf_fx_trip_t.Misc.smoke_animated'
        TextureUSubdivisions=8
        TextureVSubdivisions=8
        LifetimeRange=(Min=1,Max=1)
        StartVelocityRange=(X=(Min=-50,Max=50),Y=(Min=-50,Max=50))
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'

    bNoDelete = false
    SoundVolume = 255
    SoundRadius = 100
    bFullVolume = false
    AmbientSound = Sound'Amb_Destruction.Kessel_Fire_Small_Vehicle'
    LightRadius = 1
    LightType = LT_Pulse
    LightBrightness = 50
    LightHue = 30
    LightSaturation = 100
    bDynamicLight = true
    LifeSpan=1
}
