//================
//Code fixes and balancing by Skell*.
//Original content by Alex Quick and David Hensley.
//================
//Puppet Ventriloquist Knife
//================
class PuppetKnifeFix extends PuppetKnife;

var name BigKnifeBones[8];

simulated state OnWall
{
    Ignores HitWall;

    //These shouldn't be able to be picked up by players with crossbows...
    function ProcessTouch (Actor Other, vector HitLocation);

    simulated function Tick( float Delta )
    {
        if( Base==None )
        {
            if(Level.NetMode==NM_Client)
                bHidden = True;
            else Destroy();
        }

        if(GetAnimName() != 'idle')
        {
            LoopAnim('idle', 1.0);

            BoneRefresh();
        }

        if(Trail!=None)
            Trail.mRegen = False;
    }
    simulated function BeginState()
    {

        bCollideWorld = False;

        if(Level.NetMode!=NM_DedicatedServer)
            AmbientSound = None;

        if(Trail!=None)
            Trail.mRegen = False;

        if(GetAnimName() != 'idle')
            LoopAnim('idle', 1.0);

        Enable('Tick');

        SetCollisionSize(25,25);
    }
}

simulated function ProcessTouch(Actor Other, vector HitLocation)
{
    if (Other == none)
        return;

    //Ignore anything but a player.
    if(KFBulletWhipAttachment(Other) != None || KFHumanPawn(Other) != None)
    {
        Super.ProcessTouch(Other, HitLocation);

        LoopAnim('idle', 1.0);

        Stick(Other, HitLocation);

        if(CheckPlayerDistance(Other))
        {
            if(Trail!=None)
                Trail.mRegen = False;
            Destroy();
            return;
        }

        BoneRefresh();

        Other.BoneRefresh();

        GoToState('OnWall');
    }
}

//Uses modified Seal Squeal projectile code. Playing into the crazy theme going on in this mod.
simulated function Stick(actor HitActor, vector HitLocation)
{
    local name NearestBone;
    local Pawn HitPawn;
    local float Dist, NewKnifeScale;
    local vector HitDirection;
    local string BoneString;
    local rotator AttachedRotation;
    local int RandomPitch, RandomYaw, RandomRoll;
    local int BaseYawRotation;

    if( HitActor.IsA('KFBulletWhipAttachment') && HitActor.Base != none && KFHumanPawn(HitActor.Base) != none )
    {
        HitPawn = Pawn(HitActor.Base);
    }
    else
    {
        HitPawn = Pawn(HitActor);
    }

    NewKnifeScale = 1.0;

    HitDirection = Normal(Velocity);

    if( Velocity == vect(0,0,0) )
    {
        HitDirection = Vector(Rotation);
    }

    Velocity = vect(0,0,0);
    SetPhysics(PHYS_None);

    if (HitPawn != none)
    {
        NearestBone = HitPawn.GetClosestBone(HitLocation, HitDirection, Dist);

        BoneString = Caps(NearestBone);

        //Move knives around to look a little nicer.
        if(InStr(BoneString, "LARMD") != -1)
            NearestBone='CHR_LArmForeArm';
        else if(InStr(BoneString, "RARMD") != -1)
            NearestBone='CHR_RArmForeArm';
        else if(NearestBone == 'CHR_LAnkle' || NearestBone == 'CHR_LToe1' || NearestBone == 'lfoot')
            NearestBone='CHR_LCalf';
        else if(NearestBone == 'CHR_RAnkle' || NearestBone == 'CHR_RToe1' || NearestBone == 'rfoot')
            NearestBone='CHR_RCalf';
        else if(InStr(BoneString, "NECK") != -1)
            NearestBone='CHR_Head';
        else if(InStr(BoneString, "COLLAR") != -1 || InStr(BoneString, "SHOULDER") != -1)
            NearestBone='CHR_Spine3';
        
        //Update the BoneString to reflect the changes above (if any happened).
        BoneString = Caps(NearestBone);

        //Scaling so the knives don't look too weird.
        //Head
        if(InStr(BoneString, "HEAD") != -1)
            NewKnifeScale = 1.1;
        //Body
        else if(InStr(BoneString, "SPINE") != -1 || NearestBone == 'CHR_Pelvis'
            || NearestBone == 'CHR_Ribcage')
            NewKnifeScale = 1.2;
        //Upper limbs
        else if(InStr(BoneString, "UPPER") != -1 || InStr(BoneString, "THIGH") != -1)
            NewKnifeScale = 1.0;
        //Everywhere else
        else
            NewKnifeScale = 0.85;

        SetBoneScale(0, NewKnifeScale, 'tip');
        SetBoneScale(1, NewKnifeScale, 'root');

        //Is this coming from behind or in front?
        if((Normal(HitActor.Location - Location) dot vector(HitActor.Rotation))>0)
            BaseYawRotation = -16384;
        else
            BaseYawRotation = 16384;

        HitPawn.AttachToBone(self,NearestBone);

        //Set our rotation to nothing and plug directly into relative rotation.
        SetRotation(Rotator(vect(0,0,0)));

        RandomPitch = int((FRand() - 0.5) * 8192.0 * 1.5);
        RandomYaw = BaseYawRotation + int((FRand() - 0.5) * 4096.0 * 1.25);
        RandomRoll = int((FRand() - 0.5) * 8192.0 * 1.5);

        AttachedRotation = Rotator(vect(0,0,0));
        AttachedRotation.Pitch = RandomPitch;
        AttachedRotation.Yaw = RandomYaw;
        AttachedRotation.Roll = RandomRoll;

        SetRelativeRotation(AttachedRotation);
    }
    else
    {
        SetRotation(Rotator(HitDirection));

        SetBoneScale(0, 1.0, 'tip');
        SetBoneScale(1, 1.0, 'root');

        SetBase(HitActor);
    }
}

simulated function name GetAnimName()
{
    local float f;

    local name AnimName;
    
    GetAnimParams(0, AnimName, f, f);

    return AnimName;
}

//Used to get rid of floating knives
simulated function bool CheckPlayerDistance(actor ConnectedPawn)
{
    local float XDist, YDist, ZDist, HDist;

    //Quick distance calculation.
    XDist = abs(Location.X - ConnectedPawn.Location.X);
    YDist = abs(Location.Y - ConnectedPawn.Location.Y);
    ZDist = abs(Location.Z - ConnectedPawn.Location.Z);
    HDist = Sqrt(Square(XDist) + Square(YDist));

    if(HDist >= 65.0 || ZDist >= 80.0)
    {
        return true;
    }

    return false;
}

defaultproperties
{
     KnifeTrailClass=Class'KFCharPuppetsFixV3.KnifeTrailFix'
     HeadShotDamageMult=1.500000
     Speed=650.000000
     MaxSpeed=750.000000
}
