class TauCannon extends KFWeapon;
// class TauCannon extends HuskGun;

#exec obj load file="TC_R.ukx"

var float DesiredChamberSpeed;
var float ChamberSpeed;
var int ChamberSpin;

//Copied from ZEDMKIIWeapon to allow dry-firing with the alt-fire mode
simulated function AltFire(float F)
{
	if( !bIsReloading &&
		 FireMode[1].NextFireTime <= Level.TimeSeconds )
	{
		// We're dry, ask the server to autoreload
		if( MagAmmoRemaining < 1 )
		{
            ServerRequestAutoReload();
            PlayOwnedSound(FireMode[1].NoAmmoSound,SLOT_None,2.0,,,,false);
        }
        else if( MagAmmoRemaining < FireMode[1].AmmoPerFire )
        {
        	PlayOwnedSound(FireMode[1].NoAmmoSound,SLOT_None,2.0,,,,false);
        }
	}

	super.AltFire(F);
}

simulated event WeaponTick(float dt)
{
	local Rotator ChamberBn;

	if (FireMode[0].IsFiring())
			DesiredChamberSpeed = 0.15;
	if (FireMode[1].IsFiring())
			DesiredChamberSpeed = 0.60;			
	//Here, Yaw spins sideways, Roll spins forward
	ChamberBn.Pitch = -1 * ChamberSpin; //The -1 is to make it spin the opposite direction
	SetBoneRotation('Chamber', ChamberBn);
	
	super.WeaponTick(dt);
}

simulated event Tick(float dt)
{
	local float OldChamberSpin;

	super.Tick(dt);
	
	//Commenting this out. Otherwise the firing anim doesn't play after firing, instead it cancels
	//ReloadMeNow(); //Keeps the 'magazine' reloaded even if ammo was just bought or picked up
	
	if(FireMode[0].IsFiring() || FireMode[1].IsFiring())
	{
		ChamberSpeed = ChamberSpeed + FClamp(DesiredChamberSpeed - ChamberSpeed, -0.20 * dt, 0.40 * dt);
		ChamberSpin += int(ChamberSpeed * float(655360) * dt);
		//TauCannonFireAlt(FireMode[0]).HoldTime > ###;
	}
	else
	{
		if(ChamberSpeed > float(0))
		{
			ChamberSpeed = FMax(ChamberSpeed - 0.10 * dt, 0.01);
			OldChamberSpin = float(ChamberSpin);
			ChamberSpin += int(ChamberSpeed * float(655360) * dt);
			if(ChamberSpeed <= 0.01 && (int(OldChamberSpin / 6553.60) < int(float(ChamberSpin) / 6553.60)))
			{
				ChamberSpin = int(float(int(float(ChamberSpin) / 6553.60)) * 6553.60);
				ChamberSpeed = 0.00;
			}
		}
	}
	if(ThirdPersonActor != none)
	{
		TauCannonAttachment(ThirdPersonActor).ChamberSpeed = ChamberSpeed;
	}
}

function float GetAIRating()
{
	local AIController B;

	B = AIController(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	return (AIRating + 0.0003 * FClamp(1500 - VSize(B.Enemy.Location - Instigator.Location),0,1000));
}

function byte BestMode()
{
	return 0;
}

function bool RecommendRangedAttack()
{
	return true;
}

function bool RecommendLongRangedAttack()
{
	return true;
}

function float SuggestAttackStyle()
{
	return -1.0;
}

simulated function AnimEnd(int channel)
{
    if (FireMode[1].bIsFiring)
    {
    	if( bAimingRifle )
    	{
    		LoopAnim('ChargeLoop_Iron_NR');
    	}
    	else
    	{
    		LoopAnim('ChargeLoop_NR');
    	}
    }
    else
    {
        Super.AnimEnd(channel);
    }
}

simulated event OnZoomOutFinished()
{
	local name anim;
	local float frame, rate;

	GetAnimParams(0, anim, frame, rate);

	if (ClientState == WS_ReadyToFire)
	{
		if (anim == IdleAimAnim)
		{
            PlayIdle();
		}
		else if(anim == 'ChargeLoop_Iron')
		{
            LoopAnim('ChargeLoop');
		}
	}
}

simulated event OnZoomInFinished()
{
	local name anim;
	local float frame, rate;

	GetAnimParams(0, anim, frame, rate);

	if (ClientState == WS_ReadyToFire)
	{
		if (anim == IdleAnim)
		{
		   PlayIdle();
		}
		else if( anim == 'ChargeLoop' )
		{
            LoopAnim('ChargeLoop_Iron');
		}
	}
}

simulated function bool ConsumeAmmo( int Mode, float Load, optional bool bAmountNeededIsMax )
{
	local Inventory Inv;
	local bool bOutOfAmmo;
	local KFWeapon KFWeap;

	if ( Super(Weapon).ConsumeAmmo(Mode, Load, bAmountNeededIsMax) )
	{
		if ( Load > 0 && (Mode == 0 || bReduceMagAmmoOnSecondaryFire) )
			MagAmmoRemaining -= Load;

		NetUpdateTime = Level.TimeSeconds - 1;

		if ( FireMode[Mode].AmmoPerFire > 0 && InventoryGroup > 0 && !bMeleeWeapon && bConsumesPhysicalAmmo &&
			 (Ammo[0] == none || FireMode[0] == none || FireMode[0].AmmoPerFire <= 0 || Ammo[0].AmmoAmount < FireMode[0].AmmoPerFire) &&
			 (Ammo[1] == none || FireMode[1] == none || FireMode[1].AmmoPerFire <= 0 || Ammo[1].AmmoAmount < FireMode[1].AmmoPerFire) )
		{
			bOutOfAmmo = true;

			for ( Inv = Instigator.Inventory; Inv != none; Inv = Inv.Inventory )
			{
				KFWeap = KFWeapon(Inv);

				if ( Inv.InventoryGroup > 0 && KFWeap != none && !KFWeap.bMeleeWeapon && KFWeap.bConsumesPhysicalAmmo &&
					 ((KFWeap.Ammo[0] != none && KFWeap.FireMode[0] != none && KFWeap.FireMode[0].AmmoPerFire > 0 &&KFWeap.Ammo[0].AmmoAmount >= KFWeap.FireMode[0].AmmoPerFire) ||
					 (KFWeap.Ammo[1] != none && KFWeap.FireMode[1] != none && KFWeap.FireMode[1].AmmoPerFire > 0 && KFWeap.Ammo[1].AmmoAmount >= KFWeap.FireMode[1].AmmoPerFire)) )
				{
					bOutOfAmmo = false;
					break;
				}
			}

			if ( bOutOfAmmo )
			{
				PlayerController(Instigator.Controller).Speech('AUTO', 3, "");
			}
		}

		return true;
	}
	return false;
}

function GiveAmmo(int m, WeaponPickup WP, bool bJustSpawned)
{
	local bool bJustSpawnedAmmo;
	local int addAmount, InitialAmount;
	local float AddMultiplier;

	UpdateMagCapacity(Instigator.PlayerReplicationInfo);

	if ( FireMode[m] != None && FireMode[m].AmmoClass != None )
	{
		Ammo[m] = Ammunition(Instigator.FindInventoryType(FireMode[m].AmmoClass));
		bJustSpawnedAmmo = false;

		if ( bNoAmmoInstances )
		{
			if ( (FireMode[m].AmmoClass == None) || ((m != 0) && (FireMode[m].AmmoClass == FireMode[0].AmmoClass)) )
				return;

			InitialAmount = FireMode[m].AmmoClass.Default.InitialAmount;

			if(WP!=none && WP.bThrown==true)
				InitialAmount = WP.AmmoAmount[m];
			else
			{
				MagAmmoRemaining = MagCapacity;
			}

			if ( Ammo[m] != None )
			{
				addamount = InitialAmount + Ammo[m].AmmoAmount;
				Ammo[m].Destroy();
			}
			else
				addAmount = InitialAmount;

			AddAmmo(addAmount,m);
		}
		else
		{
			if ( (Ammo[m] == None) && (FireMode[m].AmmoClass != None) )
			{
				Ammo[m] = Spawn(FireMode[m].AmmoClass, Instigator);
				Instigator.AddInventory(Ammo[m]);
				bJustSpawnedAmmo = true;
			}
			else if ( (m == 0) || (FireMode[m].AmmoClass != FireMode[0].AmmoClass) )
				bJustSpawnedAmmo = ( bJustSpawned || ((WP != None) && !WP.bWeaponStay) );

			if(WP!=none && WP.bThrown==true)
			{
				addAmount = WP.AmmoAmount[m];
			}
			else if ( bJustSpawnedAmmo )
			{
        		if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
        		{
        			AddMultiplier = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.static.AddExtraAmmoFor(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), FireMode[m].AmmoClass);
        		}
        		else
        		{
                    AddMultiplier = 1.0;
        		}

				if (default.MagCapacity == 0)
					addAmount = 0;
				else
					addAmount = Ammo[m].InitialAmount * (float(MagCapacity) / float(default.MagCapacity)) * AddMultiplier;
			}

			if ( WP != none && WP.Class == class'BoomstickPickup' && m > 0 )
			{
				return;
			}

			Ammo[m].AddAmmo(addAmount);
			Ammo[m].GotoState('');
		}
	}
}

defaultproperties
{
    IdleAimAnim=Idle_Iron
    SleeveNum=0
	SkinRefs(1)="TC_R.TC1st_shdr"
	Skins(1)=Shader'TC_R.TC1st_shdr'
	SkinRefs(2)="TC_R.TC1st_shdr"
	Skins(2)=Shader'TC_R.TC1st_shdr'
    Weight=10 //8
    MagCapacity=20 //200
    ReloadRate=0.01
	FireModeClass(0)=Class'TauC.TauCannonFire'
    FireModeClass(1)=Class'TauC.TauCannonFireAlt'
	bModeZeroCanDryFire=True
    PutDownAnim="PutDown"
	SelectSoundRef="KF_HuskGunSnd.Husk_Select"
	SelectSound=Sound'KF_HuskGunSnd.Husk_Select'
    SelectForce="SwitchToAssaultRifle"
    AIRating=0.65
    CurrentRating=0.65
    Description="The XVL-1456 is an obviously-prototypical energy weapon with awesome damage-dealing ability, both to targets and the user if they charge the alt-fire for too long! [Original from Black Mesa Source by Crowbar Collective, port by BoF]"
    Priority=180
    InventoryGroup=4
    GroupOffset=7
    PickupClass=Class'TauC.TauCannonPickup'
    //PlayerViewOffset=(X=18.000000,Y=20.000000,Z=-6.000000) //Husk Gun defaults
	//-+ X  back/fore, Y left/right, Z down/up
    PlayerViewOffset=(X=25.000000,Y=45.000000,Z=-20.000000)
    BobDamping=6.000000
    AttachmentClass=Class'TauC.TauCannonAttachment'
    IconCoords=(X1=253,Y1=146,X2=333,Y2=181)
    ItemName="Tau Cannon"
    LightType=LT_None
    LightBrightness=0.000000
    LightRadius=0.000000
    MeshRef="TC_R.TC1stMesh"
    Mesh=SkeletalMesh'TC_R.TC1stMesh'
    DrawScale=1.000000
    AmbientGlow=0

    ZoomTime=0.25
    FastZoomOutTime=0.2
    ZoomInRotation=(Pitch=-910,Yaw=0,Roll=2910)
    bHasAimingMode=true

    DisplayFOV=65.000000
    StandardDisplayFOV=65.0
    PlayerIronSightFOV=70
    ZoomedDisplayFOV=45

	HudImageRef="TC_R.HUD_UnSelected"
	HudImage=Texture'TC_R.HUD_UnSelected'
	SelectedHudImageRef="TC_R.HUD_Selected"
	SelectedHudImage=Texture'TC_R.HUD_Selected'
	TraderInfoTexture=Texture'TC_R.HUD_Trader'

	bIsTier3Weapon=true
}
