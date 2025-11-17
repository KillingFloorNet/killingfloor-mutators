class Shield extends KFWeapon
    config;

function GiveAmmo(int M, WeaponPickup WP, bool bJustSpawned)
{
    local bool bJustSpawnedAmmo;
    local int addAmount, InitialAmount;

    UpdateMagCapacity(Instigator.PlayerReplicationInfo);

    if((FireMode[M] != none) && FireMode[M].AmmoClass != none)
    {
        Ammo[M] = Ammunition(Instigator.FindInventoryType(FireMode[M].AmmoClass));
        bJustSpawnedAmmo = false;

        if(bNoAmmoInstances)
        {
            if((FireMode[M].AmmoClass == none) || (M != 0) && FireMode[M].AmmoClass == FireMode[0].AmmoClass)
            {
                return;
            }
            InitialAmount = FireMode[M].AmmoClass.default.InitialAmount;
            if((WP != none) && WP.bThrown == true)
            {
                InitialAmount = WP.AmmoAmount[M];
            }
            else
            {
                MagAmmoRemaining = MagCapacity;
            }
            if(Ammo[M] != none)
            {
                addAmount = InitialAmount + Ammo[M].AmmoAmount;
                Ammo[M].Destroy();
            }
            else
            {
                addAmount = InitialAmount;
            }
            AddAmmo(addAmount, M);
        }
        else
        {
            if((Ammo[M] == none) && FireMode[M].AmmoClass != none)
            {
                Ammo[M] = Spawn(FireMode[M].AmmoClass, Instigator);
                Instigator.AddInventory(Ammo[M]);
                bJustSpawnedAmmo = true;
            }
            else
            {
                if((M == 0) || FireMode[M].AmmoClass != FireMode[0].AmmoClass)
                {
                    bJustSpawnedAmmo = bJustSpawned || (WP != none) && !WP.bWeaponStay;
                }
            }
            if((WP != none) && WP.bThrown == true)
            {
                addAmount = WP.AmmoAmount[M];
            }
            else
            {
                if(bJustSpawnedAmmo)
                {
                    if(default.MagCapacity == 0)
                    {
                        addAmount = 0;
                    }
                    else
                    {
                        addAmount = int(float(Ammo[M].InitialAmount) * (float(MagCapacity) / float(default.MagCapacity)));
                    }
                }
            }
            if(((WP != none) && WP.Class == Class'ShieldPickup') && M > 0)
            {
                return;
            }
            Ammo[M].AddAmmo(addAmount);
            Ammo[M].GotoState('None');
        }
    }
}

function AdjustPlayerDamage(out int Damage, Pawn instigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
    if((Ammo[0].AmmoAmount - Damage) <= 0)
    {
        DetachFromPawn(Instigator);
        Destroy();
        Damage = 0;
    }
    else
    {
        Ammo[0].AmmoAmount -= Damage;
        Damage = 0;
    }  
}

defaultproperties
{
    SleeveNum=5
    MagCapacity=1
    HudImage=Texture'ShieldUM.Shield_Unselected'
    SelectedHudImage=Texture'ShieldUM.Shield_Selected'
    TraderInfoTexture=Texture'ShieldUM.Shield_Trader'
    Weight=1.0
    bKFNeverThrow=False
    StandardDisplayFOV=75.0
    FireModeClass[0]=Class'ShieldFire'
    FireModeClass[1]=class'ShieldFireB'
    AIRating=0.30
    Description="Riot shields are lightweight protection devices deployed by police and some military organizations."
    DisplayFOV=65.0
    Priority=5
    InventoryGroup=5
    GroupOffset=4
    PickupClass=Class'ShieldPickup'
    BobDamping=8.0
    AttachmentClass=Class'ShieldAttachment'
    IconCoords=(X1=169,Y1=39,X2=241,Y2=77)
    ItemName="Shield"
    Mesh=SkeletalMesh'ShieldUM.Shield'
    Skins(0)=Texture'ShieldUM.shield_cloth'
    Skins(1)=Texture'ShieldUM.shield_grip'
    Skins(2)=Texture'ShieldUM.riot_metal'
    Skins(3)=Shader'ShieldUM.shield_glass_shdr'
    Skins(4)=Texture'ShieldUM.shield_edges'
}