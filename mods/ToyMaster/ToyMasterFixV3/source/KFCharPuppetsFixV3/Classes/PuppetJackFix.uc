//================
//Code fixes and balancing by Skell*.
//Original content by Alex Quick and David Hensley.
//================
//Puppet Jack in the Box
//================
class PuppetJackFix extends KF_StoryNPC_Jack;

#exec obj load file="KFPuppetsFixV3_T.utx"
#exec obj load file="KFPuppetsFixV3_SM.usx"

var () const class<Projectile> SecondaryProjectileClass;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

    if(KnifeProjectileClass == class'KFCharPuppetsFixV3.JackSawBladeFix')
    {
        class 'KFCharPuppetsFixV3.JackSawBladeFix'.static.PreloadAssets();
    }
    if(BombProjectileClass == class'KFCharPuppetsFixV3.ToyBombFix')
    {
        class 'KFCharPuppetsFixV3.ToyBombFix'.static.PreloadAssets();
    }
    if(SecondaryProjectileClass == class'KFCharPuppetsFixV3.ToyBombFixMulti')
    {  
        class 'KFCharPuppetsFixV3.ToyBombFixMulti'.static.PreloadAssets();
    }
}

simulated function Touch(Actor Other)
{
    //Shouldn't be colliding when it's not on...
    if(!bActive)
        return;

    if(Other == None || !(Other.IsA('Projectile')))
    {
        Super(KF_StoryNPC_Static).Touch(Other);
        return;
    }

    //Do impact-based projectile damage
    if(ZEDGunProjectile(Other) != None)
        DoMissedProjectileDamage(Class'ZEDGunProjectile'.default.Damage);
    else if(ZEDMKIIPrimaryProjectile(Other) != None)
        DoMissedProjectileDamage(Class'ZEDMKIIPrimaryProjectile'.default.Damage);
    else if(M32GrenadeProjectile(Other) != None)
        DoMissedProjectileDamage(Class'M32GrenadeProjectile'.default.ImpactDamage);
    else if(M203GrenadeProjectile(Other) != None)
        DoMissedProjectileDamage(Class'M203GrenadeProjectile'.default.ImpactDamage);
    else if(M79GrenadeProjectile(Other) != None)
        DoMissedProjectileDamage(Class'M79GrenadeProjectile'.default.ImpactDamage);
    else if(LAWProj(Other) != None)
        DoMissedProjectileDamage(Class'LAWProj'.default.ImpactDamage);

    if(Other.Instigator != none && Other.Instigator != self)
    {
        Projectile(Other).Explode(Other.Location,Normal(Location-Other.Location));
    }

    Super(KF_StoryNPC_Static).Touch(Other);
}

//Just subtract that damage from our health.
function DoMissedProjectileDamage(float MissedDamage)
{
    Health -= MissedDamage;
}

//Throw a bunch of bombs in a fan formation around the jack.
simulated function ThrowLotsOfBombs()
{
    local Rotator TargetDir;
    local float SpacingIncrement;
    local int i;

    // Start with wherever he's facing.
    TargetDir = Rotation;
    SpacingIncrement = 65536.f / NumHidingBombs;

    for(i = 0 ; i < NumHidingBombs; i ++)
    {
        //Uses ThrowBombMulti() to use a different bomb type.
        ThrowBombMulti(Normal(Vector(TargetDir)),RandRange(250.f,1000.f)) ;
        TargetDir.Yaw += SpacingIncrement;
    }
}

//Fixed so that AimError is used
function ThrowBomb(optional vector CustomTossDir, optional float CustomTossSpeed)
{
    local Projectile  MyBomb;
    local float ZSpawnOffset;
    local vector SpawnLocation;
    local vector AimError;
    local int i;
    local int NumToSpawn;
    local vector TossDir;

    if(Role < Role_Authority)
    {
        return;
    }

    NumToSpawn = NumBombs;

    ZSpawnOffset = CollisionHeight / 2;
    SpawnLocation = Location + vect(0,0,1) * ZSpawnOffset;

    TossDir = Normal((TargetPlayer.Location) - SpawnLocation) ;
    if(VSize(CustomTossDir) != 0)
    {
        TossDir = CustomTossDir;
    }

    for(i = 0 ; i < NumToSpawn ; i ++)
    {
        MyBomb = Spawn(BombProjectileClass ,,,SpawnLocation, Rotation);
        MyBomb.Instigator = self;

        AimError = ((VRand() - vect(0.5,0.5,0.5)) * 2.0) * BombAimError;
        MyBomb.Velocity = (TossDir - AimError) * CustomTossSpeed  + vect(0,0,250.f);
    }
}

//Custom bomb type for when he throws lots of bombs (also fixes AimError)
function ThrowBombMulti(optional vector CustomTossDir, optional float CustomTossSpeed)
{
    local Projectile MyBomb;
    local float ZSpawnOffset;
    local vector SpawnLocation;
    local vector AimError;
    local vector TossDir;

    if(Role < Role_Authority)
    {
        return;
    }

    ZSpawnOffset = CollisionHeight / 2;
    SpawnLocation = Location + vect(0,0,1) * ZSpawnOffset;

    TossDir = Normal((TargetPlayer.Location) - SpawnLocation) ;
    if(VSize(CustomTossDir) != 0)
    {
        TossDir = CustomTossDir;
    }

    //We're only tossing 1 bomb at a time here so there's no need for the for loop.
    MyBomb = Spawn(SecondaryProjectileClass ,,,SpawnLocation, Rotation);
    MyBomb.Instigator = self;

    AimError = ((VRand() - vect(0.5,0.5,0.5)) * 2.0) * BombAimError;
    MyBomb.Velocity = (TossDir - AimError) * CustomTossSpeed  + vect(0,0,250.f);
}

//Modified to change idle animations depending on what state has been set through AI Script actors.
simulated function PlayScriptedAnim( SScriptedAnimRepInfo  AnimData)
{
    if(AnimData.bLoopAnim)
    {
        LoopAnim(AnimData.BaseAnim, AnimData.AnimRate, AnimData.BlendInTime);
    }
    else
    {
        PlayAnim(AnimData.baseAnim,AnimData.AnimRate,AnimData.BlendInTime);
    }

    if( AnimData.StartFrame > 0.0 )
       SetAnimFrame(AnimData.StartFrame, 0, 1);

    if(AnimData.BaseAnim == 'Closed' || AnimData.BaseAnim == 'Close')
    {
        IdleWeaponAnim='Closed';
        IdleRifleAnim='Closed';
        IdleRestAnim='Closed';
    }
    else if(AnimData.BaseAnim == 'Idle' || AnimData.BaseAnim == 'Open')
    {
        IdleWeaponAnim='Idle';
        IdleRifleAnim='Idle';
        IdleRestAnim='Idle';
    }
}

//Removed this function for now as there's no directional hit animations for this mesh.
simulated function PlayDirectionalHit(Vector HitLoc);

// Set up default blending parameters and pose. Ensures the mesh doesn't have only a T-pose whenever it first springs into view.
simulated function AssignInitialPose();

defaultproperties
{
     SecondaryProjectileClass=Class'KFCharPuppetsFixV3.ToyBombFixMulti'
     PlayerCountHealthScale=1.125000
     BombTossInterval=16.000000
     KnifeTossInterval=8.000000
     TossSpeedUpModifier=0.200000
     KnifeProjectileClass=Class'KFCharPuppetsFixV3.JackSawBladeFix'
     BombProjectileClass=Class'KFCharPuppetsFixV3.ToyBombFix'
     NumBombs=2
     NumHidingBombs=6
     NumKnives=3
     KnifeAimError=200.000000
     BombAimError=150.000000
     IdleRifleAnim="'"
     FireRootBone="BoneD"
     IdleWeaponAnim="'"
     IdleRestAnim="'"
}
