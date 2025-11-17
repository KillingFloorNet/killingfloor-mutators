//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KatanaSAFire extends KFMeleeFire;
var() array<name> FireAnims;

simulated event ModeDoFire()
{
    local int AnimToPlay;

    if(FireAnims.length > 0)
    {
        AnimToPlay = rand(FireAnims.length);
        FireAnim = FireAnims[AnimToPlay];
    }

    Super.ModeDoFire();

}

defaultproperties
{
     FireAnims(0)="Attack1"
     FireAnims(1)="Attack2"
     FireAnims(2)="Attack2"
     FireAnims(3)="Attack1"
     MeleeDamage=135
     ProxySize=0.150000
     weaponRange=95.000000
     DamagedelayMin=0.320000
     DamagedelayMax=0.320000
     hitDamageClass=Class'KatanaSA.DamTypeKatanaSA'
     HitEffectClass=Class'KFMod.AxeHitEffect'
     MeleeHitSoundRefs(0)="KF_KatanaSnd.Katana_HitFlesh"
     WideDamageMinHitAngle=0.800000
     FireRate=0.670000
     BotRefireRate=0.850000
}
