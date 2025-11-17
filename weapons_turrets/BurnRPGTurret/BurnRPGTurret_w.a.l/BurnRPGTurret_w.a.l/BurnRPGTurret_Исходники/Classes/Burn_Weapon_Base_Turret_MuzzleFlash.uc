Class Burn_Weapon_Base_Turret_MuzzleFlash extends Emitter
	Transient;

simulated function BeginPlay()
{
	SetTimer(0.06,false);
}
simulated final function FireFX()
{
	local byte i;

	for( i=0; i<Emitters.Length; ++i )
		Emitters[i].Reset();
	LightType = LT_Strobe;
	SetTimer(0.06,false);
}
simulated function Timer()
{
	LightType = LT_None;
}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(X=1,Z=0)
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         SpinsPerSecondRange=(X=(Max=1))
         StartSpinRange=(X=(Max=1))
         SizeScale(0)=(RelativeTime=0.500000,RelativeSize=3)
         SizeScale(1)=(RelativeTime=1)
         StartSizeRange=(X=(Min=4,Max=6))
         InitialParticlesPerSecond=50
         Texture=Texture'BurnRPGTurret.fx.combinemuzzle1'
         LifetimeRange=(Min=0.080000,Max=0.090000)
     End Object
     Emitters(0)=SpriteEmitter'Burn_Weapon_Base_Turret_MuzzleFlash.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.025000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationRange=(X=(Min=4,Max=6))
         SpinsPerSecondRange=(X=(Max=1))
         StartSpinRange=(X=(Max=1))
         StartSizeRange=(X=(Min=5,Max=8))
         InitialParticlesPerSecond=35
         Texture=Texture'BurnRPGTurret.fx.combinemuzzle2'
         LifetimeRange=(Min=0.060000,Max=0.040000)
     End Object
     Emitters(1)=SpriteEmitter'Burn_Weapon_Base_Turret_MuzzleFlash.SpriteEmitter1'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter2
         FadeOut=True
         RespawnDeadParticles=False
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.030000
         CoordinateSystem=PTCS_Relative
         MaxParticles=2
         StartLocationRange=(X=(Min=8,Max=14))
         StartSizeRange=(X=(Min=4,Max=6))
         InitialParticlesPerSecond=45
         Texture=Texture'BurnRPGTurret.fx.combinemuzzle1'
         LifetimeRange=(Min=0.040000,Max=0.060000)
     End Object
     Emitters(2)=SpriteEmitter'Burn_Weapon_Base_Turret_MuzzleFlash.SpriteEmitter2'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter3
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UniformSize=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.030000
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         StartLocationRange=(X=(Min=14,Max=17))
         SpinsPerSecondRange=(X=(Max=1))
         StartSpinRange=(X=(Max=1))
         StartSizeRange=(X=(Min=3,Max=5))
         InitialParticlesPerSecond=25
         Texture=Texture'BurnRPGTurret.fx.combinemuzzle2'
         LifetimeRange=(Min=0.060000,Max=0.090000)
         StartVelocityRange=(X=(Min=150,Max=200))
     End Object
     Emitters(3)=SpriteEmitter'Burn_Weapon_Base_Turret_MuzzleFlash.SpriteEmitter3'

     LightType=LT_Strobe
     LightHue=42
     LightSaturation=191
     LightBrightness=80
     LightRadius=3
     bNoDelete=False
     bDynamicLight=True
     RelativeRotation=(Pitch=16384)
}
