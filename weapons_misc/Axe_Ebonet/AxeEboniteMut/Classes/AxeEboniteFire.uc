class AxeEboniteFire extends KFMeleeFire;

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
     FireAnims(0)="Fire"
     FireAnims(1)="Fire2"
     FireAnims(2)="fire3"
     FireAnims(3)="Fire4"
     FireAnims(4)="Fire5"     
     FireAnims(5)="Fire6"	 
     FireAnimRate=1.0 	 
	 MeleeDamage=260
     ProxySize=0.150000
     weaponRange=105.000000
     DamagedelayMin=0.650000
     DamagedelayMax=0.650000
     hitDamageClass=Class'AxeEboniteMut.DamTypeAxeEbonite'
     MeleeHitSounds(0)=SoundGroup'KF_AxeSnd.Axe_HitFlesh'
     HitEffectClass=Class'AxeEboniteMut.AxeEboniteHitEffect'
     FireRate=1.20000
     BotRefireRate=0.850000
     WideDamageMinHitAngle=0.65
}
