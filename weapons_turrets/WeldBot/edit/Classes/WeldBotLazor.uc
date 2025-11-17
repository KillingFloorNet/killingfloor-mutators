class WeldBotLazor extends Emitter
    transient;

var WeldBot WeldBot;
var BeamEmitter BM;


simulated function BeginPlay()
{
	AmbientSound = Sound'chippo.WeldLooped';
	SoundVolume = 255; // Volume of ambient sound. Ranges from 0 to 255. 255 is maximum volume.
	SoundRadius = 20; // Radius of ambient sound. When a viewport in UnrealEd is set to radii view, a blue circle will surround the actor when there is something in the AmbientSound field. Within this radius, the sound in the AmbientSound field can be heard.
	
	WeldBot = WeldBot(Owner);
	BM = BeamEmitter(Emitters[0]);
	Tick(0);
}

simulated function Tick( float Delta )
{
	if( WeldBot==None || WeldBot.Health==0 || WeldBot.bWelding==false )
		Destroy();
}

defaultproperties
{
     Begin Object Class=BeamEmitter Name=BeamEmitter0
         BeamEndPoints(0)=(offset=(X=(Min=800.000000,Max=800.000000)))
         DetermineEndPointBy=PTEP_Offset
         BeamTextureVScale=0.500000
         RotatingSheets=1
         FadeOut=True
         FadeIn=True
         ColorMultiplierRange=(Y=(Min=0.700000,Max=0.700000),Z=(Min=0.700000,Max=0.700000))
         FadeOutStartTime=0.050000
         FadeInEndTime=0.050000
         CoordinateSystem=PTCS_Relative
         MaxParticles=3
         StartSizeRange=(X=(Min=2.000000,Max=2.000000))
         Texture=Texture'KFX.TransTrailT'
         LifetimeRange=(Min=0.100000,Max=0.100000)
     End Object
     Emitters(0)=BeamEmitter'chippo.WeldBotLazor.BeamEmitter0'

     bNoDelete=False
}
