class WeldBotHitEmitter extends KFHitEmitter;

var     bool    bFlashed;
var float VolMin, VolMax;
var float SpawnedTime, InitialSoundVolume;

var() array<Sound> SndEffects;

replication
{
    // Things the server should send to the client.
    reliable if( bNetDirty && (!bNetOwner || bDemoRecording || bRepClientDemo) && (Role==ROLE_Authority) )
        bFlashed;
}
//--------------------------------------------------------------------------------------------------
simulated function PostBeginPlay()
{
	local int srand;
	Super.Postbeginplay();
	SparkLight();
	if( SndEffects.Length>0 )
	{
		srand = Rand(SndEffects.Length);
		AmbientSound = SndEffects[srand];
		InitialSoundVolume = VolMin+(VolMax-VolMin)*FRand();
		SoundVolume = InitialSoundVolume; // Volume of ambient sound. Ranges from 0 to 255. 255 is maximum volume.
		SoundRadius = 20; // Radius of ambient sound. When a viewport in UnrealEd is set to radii view, a blue circle will surround the actor when there is something in the AmbientSound field. Within this radius, the sound in the AmbientSound field can be heard.
		SpawnedTime = Level.TimeSeconds;
		PlaySound(SndEffects[srand], SLOT_Misc, VolMin+(VolMax-VolMin)*FRand(),/*bNoOverride*/false,/*Radius*/30.0,/*pitch*/,/*Attenuate*/);
	}	
}
//--------------------------------------------------------------------------------------------------
simulated function Tick( float dt )
{
	local float LifeTime;
	LifeTime = Level.TimeSeconds-SpawnedTime;
	SoundVolume = FMax(0, InitialSoundVolume * (1.f-(LifeTime*0.8f)) );
}
//--------------------------------------------------------------------------------------------------
simulated function SparkLight()
{
    if ( !bFlashed && !Level.bDropDetail && (Instigator != None)
        && ((Level.TimeSeconds - LastRenderTime < 0.2) || (PlayerController(Instigator.Controller) != None)) )
    {
        bDynamicLight = true;
        SetTimer(0.15, true);
    }
    else
        Timer();
}


simulated function Timer()
{
	bDynamicLight = false;
}

defaultproperties
{
     VolMin=100.000000
     VolMax=255.000000
     SndEffects(0)=Sound'chippo.Sentry.WeldSparkle01'
     SndEffects(1)=Sound'chippo.Sentry.WeldSparkle02'
     SndEffects(2)=Sound'chippo.Sentry.WeldSparkle03'
     SndEffects(3)=Sound'chippo.Sentry.WeldSparkle04'
     SndEffects(4)=Sound'chippo.Sentry.WeldSparkle05'
     SndEffects(5)=Sound'chippo.Sentry.WeldSparkle06'
     SndEffects(6)=Sound'chippo.Sentry.WeldSparkle07'
     SndEffects(7)=Sound'chippo.Sentry.WeldSparkle08'
     SndEffects(8)=Sound'chippo.Sentry.WeldSparkle09'
     SndEffects(9)=Sound'chippo.Sentry.WeldSparkle10'
     SndEffects(10)=Sound'chippo.Sentry.WeldSparkle11'
     SndEffects(11)=Sound'chippo.Sentry.WeldSparkle12'
     SndEffects(12)=Sound'chippo.Sentry.WeldSparkle13'
     Begin Object Class=SpriteEmitter Name=SpriteEmitter41
         UseDirectionAs=PTDU_UpAndNormal
         UseCollision=True
         UseColorScale=True
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         ScaleSizeXByVelocity=True
         AutomaticInitialSpawning=False
         Acceleration=(Z=-210.000000)
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
         MaxParticles=100
         SizeScale(0)=(RelativeSize=2.000000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=0.300000)
         StartSizeRange=(X=(Min=2.000000,Max=3.000000),Y=(Min=5000.000000,Max=5000.000000),Z=(Min=5000.000000,Max=5000.000000))
         ScaleSizeByVelocityMultiplier=(X=0.010000,Y=0.010000)
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'KFX.KFSparkHead'
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
     End Object
     Emitters(0)=SpriteEmitter'chippo.WeldBotHitEmitter.SpriteEmitter41'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter42
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         UseRandomSubdivision=True
         Acceleration=(Z=10.000000)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.250000,Max=0.350000),Y=(Min=0.250000,Max=0.300000),Z=(Min=0.200000,Max=0.250000))
         FadeOutStartTime=0.500000
         FadeInEndTime=0.100000
         MaxParticles=5
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeSize=0.300000)
         SizeScale(1)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=5.000000,Max=10.000000))
         InitialParticlesPerSecond=5.000000
         DrawStyle=PTDS_Brighten
         Texture=None
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=0.000000,Max=0.000000)
         StartVelocityRange=(X=(Min=-8.000000,Max=8.000000),Y=(Min=-8.000000,Max=8.000000))
     End Object
     Emitters(1)=SpriteEmitter'chippo.WeldBotHitEmitter.SpriteEmitter42'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter43
         RespawnDeadParticles=False
         UniformSize=True
         AutomaticInitialSpawning=False
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         ColorMultiplierRange=(X=(Min=0.700000,Max=0.900000),Y=(Min=0.700000,Max=0.800000),Z=(Min=0.500000,Max=0.600000))
         MaxParticles=1
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000))
         StartSpinRange=(X=(Max=1.000000))
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.000000)
         StartSizeRange=(X=(Min=6.000000,Max=6.000000))
         InitialParticlesPerSecond=5.000000
         DrawStyle=PTDS_Brighten
         Texture=Texture'KFX.MetalHitKF'
         LifetimeRange=(Min=0.010000,Max=0.100000)
     End Object
     Emitters(2)=SpriteEmitter'chippo.WeldBotHitEmitter.SpriteEmitter43'

     LightType=LT_Steady
     LightHue=40
     LightSaturation=150
     LightBrightness=100.000000
     LightRadius=5.000000
}
