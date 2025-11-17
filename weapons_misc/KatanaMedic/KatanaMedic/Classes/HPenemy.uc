class HPenemy extends PanzerfaustTrail;
simulated function HandleOwnerDestroyed()
{
    Emitters[0].ParticlesPerSecond = 0;
    Emitters[0].InitialParticlesPerSecond = 0;
    Emitters[0].RespawnDeadParticles=false;

    Emitters[1].ParticlesPerSecond = 0;
    Emitters[1].InitialParticlesPerSecond = 0;
    Emitters[1].RespawnDeadParticles=false;

}

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UniformSize=True
         Acceleration=(X=0.445001,Y=0.445001,Z=0.890001)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=1.000000,Color=(B=255,G=255,R=255,A=255))
         MaxParticles=0
         StartSizeRange=(X=(Min=1.000000,Max=3.000000),Y=(Min=1.000000,Max=3.000000),Z=(Min=1.000000,Max=3.000000))
         InitialParticlesPerSecond=1.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'KatanaMedicT.hp_enemy'
         LifetimeRange=(Min=1.000000,Max=2.500000)
         StartVelocityRange=(X=(Min=1.689000,Max=25.335001),Y=(Min=1.689000,Max=25.335001),Z=(Min=27.560005,Max=27.560005))
     End Object
     Emitters(0)=SpriteEmitter'KatanaMedic.HPenemy.SpriteEmitter0'

     Begin Object Class=SpriteEmitter Name=SpriteEmitter1
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         Acceleration=(X=-0.645001,Y=0.645001,Z=12.290001)
         ColorScale(0)=(Color=(B=255,G=255,R=255,A=255))
         ColorScale(1)=(RelativeTime=0.100000,Color=(B=255,G=255,R=255,A=255))
         MaxParticles=1
         SizeScale(0)=(RelativeSize=1.250000)
         StartSizeRange=(X=(Min=12.000000,Max=12.000000),Y=(Min=12.000000,Max=12.000000),Z=(Min=12.000000,Max=12.000000))
         InitialParticlesPerSecond=1.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'KatanaMedicT.hp_enemy'
         LifetimeRange=(Min=0.500000,Max=0.500000)
         StartVelocityRange=(X=(Min=-2.289000,Max=-8.335001),Y=(Min=5.689000,Max=9.335001),Z=(Min=15.560005,Max=30.560005))
     End Object
     Emitters(1)=SpriteEmitter'KatanaMedic.HPenemy.SpriteEmitter1'

     RemoteRole=ROLE_SimulatedProxy
}
