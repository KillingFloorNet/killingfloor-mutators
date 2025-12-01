//================
//Code fixes and balancing by Skell*.
//Original content by Alex Quick and David Hensley.
//================
//Toy Chest
//================
class PuppetToyChestFix extends PuppetToyChest;

//All of these changes are to stop animation-related log spam.

//Overwritten to stop the chest from playing IdleWeaponAnim
simulated function AnimEnd(int Channel)
{
    if (Channel == 1)
    {
        if (FireState == FS_Ready)
        {
            AnimBlendToAlpha(1, 0.0, 0.12);
            FireState = FS_None;
        }
        else if (FireState == FS_PlayOnce)
        {
            //PlayAnim(IdleWeaponAnim,, 0.2, 1);
            FireState = FS_Ready;
            IdleTime = Level.TimeSeconds;
        }
        else
            AnimBlendToAlpha(1, 0.0, 0.12);
    }
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

    if(AnimData.BaseAnim == 'Idle' || AnimData.BaseAnim == 'Close')
    {
        IdleWeaponAnim='Idle';
        IdleRifleAnim='Idle';
        IdleRestAnim='Idle';
    }
    else if(AnimData.BaseAnim == 'openIdle' || AnimData.BaseAnim == 'Open')
    {
        IdleWeaponAnim='openIdle';
        IdleRifleAnim='openIdle';
        IdleRestAnim='openIdle';
    }
}

//Modified to stop anims that try to play through here from getting set.
simulated event SetAnimAction(name NewAction)
{
    if(NewAction!='Idle' && NewAction!='Open' && NewAction!='openIdle' && NewAction!='Close')
        return;
    Super.SetAnimAction(NewAction);
}

defaultproperties
{
     IdleRifleAnim="'"
     IdleWeaponAnim="'"
     IdleRestAnim="'"
}
