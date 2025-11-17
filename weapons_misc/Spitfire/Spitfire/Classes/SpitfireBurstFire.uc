class SpitfireBurstFire extends CrossbowFire;

var byte FlockIndex;
var int MaxLoad;
var Sound FireEndSound;
var float AmbientFireSoundRadius;
var Sound AmbientFireSound;
var byte AmbientFireVolume;

function StartFiring()
{
    GotoState('FireLoop');
    //return;    
}

function PlayAmbientSound(Sound ASound)
{
    local WeaponAttachment WA;

    WA = WeaponAttachment(Weapon.ThirdPersonActor);
    // End:0x33
    if((Weapon == none) || WA == none)
    {
        return;
    }
    // End:0x7B
    if(ASound == none)
    {
        WA.SoundVolume = WA.default.SoundVolume;
        WA.SoundRadius = WA.default.SoundRadius;
    }
    // End:0xA3
    else
    {
        WA.SoundVolume = AmbientFireVolume;
        WA.SoundRadius = AmbientFireSoundRadius;
    }
    WA.AmbientSound = ASound;
    //return;    
}

event ModeDoFire()
{
    // End:0x1C
    if((AllowFire()) && IsInState('FireLoop'))
    {
        super(KFShotgunFire).ModeDoFire();
    }
    //return;    
}

simulated function bool AllowFire()

{

	return (Weapon.AmmoAmount(ThisModeNum) >= AmmoPerFire);

}

function DoFireEffect()
{
    local Vector StartProj, StartTrace, X, Y, Z;

    local Rotator Aim;
    local Vector HitLocation, HitNormal, FireLocation;
    local Actor Other;
    local int P, SpawnCount;
    local SpitfireTendril FiredRockets[4];

    // End:0x28
    if((SpreadStyle == 2) || load < float(2))
    {
        super.DoFireEffect();
        return;
    }
    Instigator.MakeNoise(1.0);
    Weapon.GetViewAxes(X, Y, Z);
    StartTrace = Instigator.Location + Instigator.EyePosition();
    StartProj = (StartTrace + (X * ProjSpawnOffset.X)) + (Z * ProjSpawnOffset.Z);
    // End:0xEF
    if(!Weapon.WeaponCentered())
    {
        StartProj = StartProj + ((Weapon.hand * Y) * ProjSpawnOffset.Y);
    }
    Other = Weapon.Trace(HitLocation, HitNormal, StartProj, StartTrace, false);
    // End:0x12C
    if(Other != none)
    {
        StartProj = HitLocation;
    }
    Aim = AdjustAim(StartProj, aimerror);
    SpawnCount = Max(1, int(load));
    P = 0;
    J0x159:
    // End:0x219 [Loop If]
    if(P < SpawnCount)
    {
        FireLocation = (StartProj - (float(2) * ((((Sin((float(P * 2) * 3.1415930) / float(MaxLoad)) * float(8)) - float(7)) * Y) - (((Cos((float(P * 2) * 3.1415930) / float(MaxLoad)) * float(8)) - float(7)) * Z)))) - ((X * float(8)) * FRand());
        FiredRockets[P] = SpitfireTendril(SpawnProjectile(FireLocation, Aim));
        ++ P;
        // [Loop Continue]
        goto J0x159;
    }
    //return;    
}

function float MaxRange()
{
    return 1500.0;
    //return;    
}

state FireLoop
{
    function BeginState()
    {
        NextFireTime = Level.TimeSeconds - 0.10;
        Weapon.LoopAnim(FireLoopAnim, FireLoopAnimRate, TweenTime);
        PlayAmbientSound(AmbientFireSound);
        //return;        
    }

    function PlayFiring()
    {
        //return;        
    }

    function ServerPlayFiring()
    {
        //return;        
    }

    function EndState()
    {
        Weapon.AnimStopLooping();
        PlayAmbientSound(none);
        Weapon.PlayOwnedSound(FireEndSound,SLOT_None,AmbientFireVolume/127,,AmbientFireSoundRadius);
        Weapon.StopFire(ThisModeNum);
        //return;        
    }

    function StopFiring()
    {
        GotoState('None');
        //return;        
    }

    function ModeTick(float dt)
    {
        super(WeaponFire).ModeTick(dt);
        // End:0x2C
        if(!bIsFiring || !AllowFire())
        {
            GotoState('None');
            return;
        }
        //return;        
    }
    stop;    
}


defaultproperties
{
     MaxLoad=3
     FireEndSound=SoundGroup'KF_FlamethrowerSnd.FT_Fire1Shot'
     AmbientFireSoundRadius=500.000000
     AmbientFireSound=Sound'KF_FlamethrowerSnd.FireBase.FireLoop'
     AmbientFireVolume=255
     EffectiveRange=1500.000000
     maxVerticalRecoilAngle=200
     maxHorizontalRecoilAngle=100
     ProjSpawnOffset=(X=65.000000,Y=9.000000,Z=-18.000000)
     bSplashDamage=True
     bRecommendSplashDamage=True
     bWaitForRelease=false 
     bAttachSmokeEmitter=True
     TransientSoundVolume=1.000000
     TransientSoundRadius=500.000000
     FireAnim="Fire"
     FireLoopAnim="Fire"
     FireEndAnim="Idle"
     NoAmmoSound=None
     FireRate=0.070000
     AmmoClass=Class'Spitfire.SpitfireAmmo'
     ShakeRotMag=(X=0.000000,Y=0.000000,Z=0.000000)
     ShakeRotRate=(X=0.000000,Y=0.000000,Z=0.000000)
     ShakeOffsetMag=(X=0.000000,Y=0.000000,Z=0.000000)
     ProjectileClass=Class'Spitfire.SpitfireTendril'
     BotRefireRate=0.070000
     aimerror=0.000000
     Spread=0.000000
     SpreadStyle=SS_Random
}
