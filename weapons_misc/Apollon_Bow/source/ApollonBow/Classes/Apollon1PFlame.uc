//=============================================================================
// ROTankROPanzerfaustTrail
//=============================================================================
// Emitter Panzerfaust to leave smoke trail
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2005 Martin "Doh" Behrend
// Copyright (C) 2005 David Hensley
// Copyright (C) 2005 Jon Giblson
//=============================================================================

class Apollon1PFlame extends Emitter;

simulated function HandleOwnerDestroyed()
{
    Emitters[0].ParticlesPerSecond = 0;
    Emitters[0].InitialParticlesPerSecond = 0;
    Emitters[0].RespawnDeadParticles=false;
	
	Emitters[1].ParticlesPerSecond = 0;
    Emitters[1].InitialParticlesPerSecond = 0;
    Emitters[1].RespawnDeadParticles=false;

    AutoDestroy=true;
}

defaultproperties
{

    Begin Object Class=SpriteEmitter Name=SpriteEmitter0
        UseColorScale=False
        FadeOut=True
        AutoReset=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        Acceleration=(X=70.000000,Z=0.000000)
        ColorScale(0)=(Color=(B=60,G=60,R=60,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=117,G=117,R=117,A=255))
		ColorMultiplierRange=(X=(Max=1.0,Min=1.0),Y=(Max=1.0,Min=1.0),Z=(Max=1.0,Min=1.0))
        FadeOutStartTime=1.200000
        MaxParticles=50
		Opacity=0.015
        AutoResetTimeRange=(Min=5.000000,Max=10.000000)
        Name="SpriteEmitter4"
        UseRotationFrom=PTRS_Actor
        //SpinsPerSecondRange=(X=(Min=-0.075000,Max=0.075000))
		StartSpinRange=(X=(Max=16384,Min=0.0))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.070000,RelativeSize=0.700000)
        SizeScale(2)=(RelativeTime=0.100000,RelativeSize=0.800000)
        SizeScale(3)=(RelativeTime=0.200000,RelativeSize=1.000000)
        StartSizeRange=(X=(Min=15.000000,Max=20.000000))
        ParticlesPerSecond=200.000000
        InitialParticlesPerSecond=200.000000
        DrawStyle=PTDS_Brighten
        Texture=Texture'bow_flare'
		TextureUSubdivisions=4
		TextureVSubdivisions=4
		SubdivisionStart=0
		SubdivisionEnd=15
        LifetimeRange=(Max=4.000000)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-10.000000,Max=100.000000))
        VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.100000,RelativeVelocity=(X=0.150000,Y=0.150000,Z=1.000000))
        VelocityScale(2)=(RelativeTime=0.200000,RelativeVelocity=(Y=0.400000,Z=0.400000))
    End Object
    Emitters(0)=SpriteEmitter'SpriteEmitter0'
	
	Begin Object Class=SpriteEmitter Name=SpriteEmitter1
        UseColorScale=False
        FadeOut=True
        AutoReset=True
        SpinParticles=True
        UseSizeScale=True
        UseRegularSizeScale=False
        UniformSize=True
        AutomaticInitialSpawning=False
        UseVelocityScale=True
        Acceleration=(X=70.000000,Z=0.000000)
        ColorScale(0)=(Color=(B=60,G=60,R=60,A=255))
        ColorScale(1)=(RelativeTime=1.000000,Color=(B=117,G=117,R=117,A=255))
		ColorMultiplierRange=(X=(Max=1.0,Min=1.0),Y=(Max=1.0,Min=1.0),Z=(Max=1.0,Min=1.0))
        FadeOutStartTime=0.010000
        MaxParticles=50
		Opacity=0.25
		SpinsPerSecondRange=(X=(Max=1.0,Min=-0.075))
        AutoResetTimeRange=(Min=5.000000,Max=10.000000)
        Name="SpriteEmitter4"
        UseRotationFrom=PTRS_Actor
        //SpinsPerSecondRange=(X=(Min=-0.075000,Max=0.075000))
		StartSpinRange=(X=(Max=16384,Min=0.0))
        SizeScale(0)=(RelativeSize=1.000000)
        SizeScale(1)=(RelativeTime=0.070000,RelativeSize=0.700000)
        SizeScale(2)=(RelativeTime=0.100000,RelativeSize=0.800000)
        SizeScale(3)=(RelativeTime=0.200000,RelativeSize=1.000000)
		StartLocationRange=(Y=(Max=10.0,Min=-10.0))
        StartSizeRange=(X=(Min=5.000000,Max=10.000000))
        ParticlesPerSecond=10.000000
        InitialParticlesPerSecond=10.000000
        DrawStyle=PTDS_Brighten
        Texture=Texture'bow_flare'
		TextureUSubdivisions=1
		TextureVSubdivisions=1
        LifetimeRange=(Max=1.000000,Min=1.0)
        StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-60.000000,Max=60.000000),Z=(Min=-10.000000,Max=200.000000))
        VelocityLossRange=(X=(Min=2.000000,Max=2.000000),Y=(Min=2.000000,Max=2.000000),Z=(Min=2.000000,Max=2.000000))
        VelocityScale(0)=(RelativeVelocity=(X=1.000000,Y=1.000000,Z=1.000000))
        VelocityScale(1)=(RelativeTime=0.100000,RelativeVelocity=(X=0.150000,Y=0.150000,Z=1.000000))
        VelocityScale(2)=(RelativeTime=0.200000,RelativeVelocity=(Y=0.400000,Z=0.400000))
    End Object
    Emitters(1)=SpriteEmitter'SpriteEmitter1'

	bNoDelete=false
	AutoDestroy=False
}
