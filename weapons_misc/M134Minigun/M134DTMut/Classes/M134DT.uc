//--------------------------------------------------
//Weapon import by Exod and sourcecode help by Ripza
// Modification by 3xzet & Flame 
//--------------------------------------------------
class M134DT extends KFWeapon
	config(user);

#exec OBJ LOAD FILE=m134DT_A.ukx

var float HeatLevel;
var M134DTHeater Heater;

var float DesiredSpeed;
var float BarrelSpeed;
var int BarrelTurn;
var() Sound BarrelSpinSound;
var() Sound BarrelStopSound;
var() Sound BarrelStartSound;

replication
{
	reliable if(bNetDirty && Role == Role_Authority)
		HeatLevel;
}

simulated event WeaponTick(float dt)
{
	local Rotator bt;
	super.WeaponTick(dt);
	if (FireMode[0].IsFiring() /*&& KFFire(FireMode[0]).bIgnited*/)
		HeatLevel = FMin(1, HeatLevel + DT/15); //скорость нагрева 
	if (Heater != None)
		Heater.SetHeat(HeatLevel);
	bt.Yaw = BarrelTurn;
	SetBoneRotation('wpn_block', bt);
	DesiredSpeed = 0.50;
	super.WeaponTick(dt);
}

simulated event Tick(float dt)
{
	local float OldBarrelTurn;

	super.Tick(dt);
	if(Heater==none)
	{
		Heater = Spawn(class'M134DTHeater');
		AttachToBone(Heater, 'wpn_block');
		Heater.SetHeat(HeatLevel);
		M134DTFire(FireMode[0]).Heater = Heater;
	}
	
	if(FireMode[0].IsFiring())
	{
		BarrelSpeed = BarrelSpeed + FClamp(DesiredSpeed - BarrelSpeed, -0.20 * dt, 0.40 * dt);
		BarrelTurn += int(BarrelSpeed * float(655360) * dt);
	}
	else
	{
		if(BarrelSpeed > float(0))
		{
			BarrelSpeed = FMax(BarrelSpeed - 0.10 * dt, 0.01);
			OldBarrelTurn = float(BarrelTurn);
			BarrelTurn += int(BarrelSpeed * float(655360) * dt);
			if(BarrelSpeed <= 0.03 && (int(OldBarrelTurn / 10922.67) < int(float(BarrelTurn) / 10922.67)))
			{
				BarrelTurn = int(float(int(float(BarrelTurn) / 10922.67)) * 10922.67);
				BarrelSpeed = 0.00;
				PlaySound(BarrelStopSound, SLOT_None, 0.50,, 32.00, 1.00, true);
				AmbientSound = none;
			}
		}
	}
	if(BarrelSpeed > float(0))
	{
		AmbientSound = BarrelSpinSound;
		SoundPitch = byte(float(32) + float(96) * BarrelSpeed);
	}
	if(ThirdPersonActor != none)
	{
		M134DTAttachment(ThirdPersonActor).BarrelSpeed = BarrelSpeed;
	}
	if (HeatLevel > 0 && KFFire(FireMode[0]).LastFireTime < level.TimeSeconds - 4)
		HeatLevel = FMax(0, HeatLevel - DT/10); //скорость остывания
}

function DropFrom(vector StartLocation)
{
	local int m;
	local Pickup Pickup;
	local vector Direction;

	if (!bCanThrow)
		return;
	ClientWeaponThrown();
	for (m = 0; m < NUM_FIRE_MODES; m++)
	{
		if (FireMode[m].bIsFiring)
			StopFire(m);
	}
	if ( Instigator != None )
	{
		DetachFromPawn(Instigator);
		Direction = vector(Instigator.Rotation);
	}
	else if ( Owner != none )
		Direction = vector(Owner.Rotation);
	Pickup = Spawn(PickupClass,,, StartLocation);
	if(M134DTPickup(Pickup)!=none)
		M134DTPickup(Pickup).StoreHeatLevel=HeatLevel;
	if ( Pickup != None )
	{
		Pickup.InitDroppedPickupFor(self);
		Pickup.Velocity = Velocity + (Direction * 100);
		if (Instigator.Health > 0)
			WeaponPickup(Pickup).bThrown = true;
	}
	Destroyed();
	Destroy();
}

simulated event Destroyed()
{
	if (Heater != None)
		Heater.Destroy();
	super.Destroyed();
}

simulated function bool StartFire(int Mode)
{
	if( Mode == 1 )
		return super.StartFire(Mode);

	if( !super.StartFire(Mode) )  // returns false when mag is empty
	   return false;

	if( AmmoAmount(0) <= 0 )
	{
    	return false;
    }

	AnimStopLooping();

	if( !FireMode[Mode].IsInState('FireLoop') && (AmmoAmount(0) > 0) )
	{
		FireMode[Mode].StartFiring();
		return true;
	}
	else
	{
		return false;
	}

	return true;
}

simulated function AnimEnd(int channel)
{
    local name anim;
    local float frame, rate;

	if(!FireMode[0].IsInState('FireLoop'))
	{
        GetAnimParams(0, anim, frame, rate);

        if (ClientState == WS_ReadyToFire)
        {
             if ((FireMode[0] == None || !FireMode[0].bIsFiring) && (FireMode[1] == None || !FireMode[1].bIsFiring))
            {
                PlayIdle();
            }
        }
	}
}

defaultproperties
{
	BarrelSpinSound=Sound'm134DT_A.minigun_spin'
	BarrelStopSound=Sound'm134DT_A.minigun_end'
	BarrelStartSound=Sound'm134DT_A.minigun_start'
	MagCapacity=200
	ReloadRate=4.650000
	ReloadAnim="Reload"
	ReloadAnimRate=1.000000
	WeaponReloadAnim="Reload_M134_Y"
	Weight=13.000000
	IdleAimAnim="Idle"
	StandardDisplayFOV=55.000000
	bModeZeroCanDryFire=True
	SleeveNum=0	 
	HudImage=Texture'm134DT_A.m134DT_T.m134DT_unselected'
	SelectedHudImage=Texture'm134DT_A.m134DT_T.m134DT_selected'	
	TraderInfoTexture=Texture'm134DT_A.m134DT_T.m134DT_trader'
	SelectSound=Sound'm134DT_A.Select'
	PlayerIronSightFOV=65.000000
	ZoomedDisplayFOV=45.000000
	FireModeClass(0)=Class'M134DTFire'
	FireModeClass(1)=Class'KFMod.NoFire'
	PutDownAnim="Putaway"
	SelectForce="SwitchToAssaultRifle"
	AIRating=0.550000
	CurrentRating=0.550000
	bShowChargingBar=True
	Description="A big gun."
	EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
	DisplayFOV=75.000000
	Priority=95
	InventoryGroup=4
	GroupOffset=5
	PickupClass=Class'M134DTPickup'
	PlayerViewOffset=(X=25.000000,Y=10,Z=0.000000)
	BobDamping=1.000000
	AttachmentClass=Class'M134DTAttachment'
	IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
	ItemName="M134 Minigun"
	Mesh=SkeletalMesh'm134DT_A.M134DT_MeshMirror'
	Skins(1)=Combiner'm134DT_A.m134DT_T.wpn_dshkblack_cmb'
	Skins(2)=Combiner'm134DT_A.m134DT_T.wpn_134Black_cmb'
	TransientSoundVolume=1.250000
}
