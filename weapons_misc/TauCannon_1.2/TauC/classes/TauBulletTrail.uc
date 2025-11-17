class TauBulletTrail extends HitFlame;

var float LastFlameSpawnTime;
var () float FlameSpawnInterval;

var Emitter SecondaryFlame;

state Ticking
{
    simulated function Tick( float dt )
    {
       if( LifeSpan < 2.0 )
       {
          mRegenRange[0] *= LifeSpan * 0.5;
          mRegenRange[1] = mRegenRange[0];
          SoundVolume = byte(float(SoundVolume) * (LifeSpan * 0.5));
       }

       if (Level.TimeSeconds - LastFlameSpawnTime > FlameSpawnInterval)
       {
          if( SecondaryFlame != none )
          {
              SecondaryFlame.Kill();
          }
         SecondaryFlame =  Spawn(class'KFMod.FlameThrowerFlameB',self);
       }
    }
}

simulated function Destroyed()
{
    if( SecondaryFlame != none )
    {
       SecondaryFlame.Kill();
    }
}

defaultproperties
{
     AmbientSound=Sound'Amb_Destruction.Kessel_Fire_Small_Barrel'
     bNotOnDedServer=False
     FlameSpawnInterval = 0.5
     mAttenFunc = ATF_None
     mAttenKa = 0
     mAttenKb = 0
     mAttraction = 100
     mGrowthRate = -52
     mLifeRange(0)=1
     mLifeRange(1)=1.5
     mMassRange(0)=0.5
     mMassRange(1)=1
     mParticleType=PT_Stream
     mRandOrient = false
     mRandTextures = true
     mRegenRange(0)=60.000000
     mRegenRange(1)=60.000000
     mSizeRange(0)=4
     mSizeRange(1)=8
     Physics=PHYS_Trailer
     RemoteRole=ROLE_None
     Skins(0)=Texture'KFX.KFFlames'
     SoundVolume = 255
     Style = STY_Additive
     TransientSoundRadius = 50
     TransientSoundVolume = + 50
}
