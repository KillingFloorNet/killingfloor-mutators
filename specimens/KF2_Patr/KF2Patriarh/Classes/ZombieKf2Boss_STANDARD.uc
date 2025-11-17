class ZombieKf2Boss_STANDARD extends ZombieKf2Boss;

#exec obj load file="Patrick_G.ukx"  Package="KF2Patriarh.Patrick"

defaultproperties
{
	 RocketFireSound=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_FireRocket'
     MiniGunFireSound=Sound'KF2Patriarh.Patrick.snd.fire_mg'
     MiniGunSpinSound=Sound'KF_BasePatriarch.Attack.Kev_MG_TurbineFireLoop'
     MeleeImpaleHitSound=Sound'KF2Patriarh.Patrick.snd.tentakl'
     MoanVoice=SoundGroup'KF2Patriarh.Patrick.snd.DieGr'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_HitPlayer_Fist'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd.Patriarch.Kev_Jump'
     DetachedArmClass=None
     DetachedLegClass=Class'SeveredLegKF2Patriarch'
     DetachedHeadClass=none
     DetachedSpecialArmClass=Class'SeveredArmKF2Patriarch'
     HitSound(0)=Sound'KF2Patriarh.Patrick.snd.Pain'
     DeathSound(0)=none
     AmbientSound=Sound'KF_BasePatriarch.Idle.Kev_IdleLoop'
     Mesh=SkeletalMesh'KF2Patriarh.Patrick.patrik_kf2'
     Skins(0)=Shader'KF2Patriarh.Patrick.txr.Zed_Patriarch_Gun_Shdr'
     Skins(1)=Shader'KF2Patriarh.Patrick.txr.ZED_Patriarch_D_shdr'
	 Skins(2)=Shader'KF2Patriarh.Patrick.txr.ZED_Patriarch_D_shdr'
	 Skins(3)=Combiner'KF2Patriarh.Patrick.txr.ZED_Patriarch_D_cmb'
}
