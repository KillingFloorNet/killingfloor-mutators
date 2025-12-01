//================
//Code fixes and balancing by Skell*.
//Original content by Alex Quick and David Hensley.
//================
//Pinwheel Puppet (Uber)
//================
class PuppetPinwheelFixUber extends PuppetPinwheelUber;

//This uber version doesn't seem to be ready to use yet.

#exec obj load file="KFPuppetsFixV3_T.utx"
#exec obj load file="KFPuppetsFixV3_A.ukx"

//Let's make the Uber a little... more uber?
simulated function PostBeginPlay()
{
    //ZED Gun zap stuff
    if (Level.Game != none && !bDiffAdjusted)
    {
        if( Level.Game.GameDifficulty < 2.0 )
        {
            ZapThreshold = default.ZapThreshold * 1.0;
        }
        else if( Level.Game.GameDifficulty < 4.0 )
        {
            ZapThreshold = default.ZapThreshold * 1.25;
        }
        else if( Level.Game.GameDifficulty < 5.0 )
        {
            ZapThreshold = default.ZapThreshold * 1.50;
        }
        else if( Level.Game.GameDifficulty < 7.0 )
        {
            ZapThreshold = default.ZapThreshold * 1.75;
        }
        else
        {
            ZapThreshold = default.ZapThreshold * 2.0;
        }
    }

    super.PostBeginPlay();
}

defaultproperties
{
     HitAnims(0)="HitReactionF"
     HitAnims(1)="HitReactionF"
     HitAnims(2)="HitReactionF"
     ZapThreshold=1.500000
     DetachedArmClass=Class'KFCharPuppets.SeveredArm_Pinwheel'
     DetachedLegClass=Class'KFCharPuppets.SeveredLeg_Pinwheel'
     DetachedHeadClass=Class'KFCharPuppets.SeveredHead_Pinwheel'
     HeadHealth=768.000000
     HealthMax=1280.000000
     Health=1280
}
