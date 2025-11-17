class RPGBackpackProj extends Nade;

#exec OBJ LOAD FILE=kf_generic_sm.usx
#exec OBJ LOAD FILE=Asylum_SM.usx
#exec OBJ LOAD FILE=Asylum_T.utx
var bool bBonesUpdated,bTimeToUpdate,bUpdateTimerSet;//Flame
var int MagAmmount,cMagAmmount,oMagAmmount;//Flame
var Pawn Taker;
var bool bSticked,bTakerReplicated;
var bool bHideBag,bHideAll;
var int cYaw,cPitch,cRoll,cX,cY,cZ;

replication
{
	reliable if ( Role == ROLE_Authority )
		MagAmmount,Taker,bHideBag,cYaw,cPitch,cRoll,cX,cY,cZ,bHideAll;//,ClientUpdateBackpack;
}

simulated function PostNetReceive()
{
	//Log("PostNetReceive.Client.000"@Taker@Taker.Location@self.Location);
	if(Taker!=none && !bTakerReplicated)
	{
		//Log("PostNetReceive.Client.0"@Taker@Taker.PlayerReplicationInfo.PlayerName@Instigator.PlayerReplicationInfo.PlayerName);
		bTakerReplicated=true;
		if(!bSticked)
			Stick();
		UpdateBackpack();
		return;
	}
	if(Role<ROLE_Authority)
	{
		//Log("PostNetReceive.Client.1"@MagAmmount@Taker@Taker.PlayerReplicationInfo.PlayerName@Instigator.PlayerReplicationInfo.PlayerName);
		UpdateBackpack();
	}
}

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	//nope
}

simulated function PostBeginPlay()
{
	Super(Nade).PostBeginPlay();
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	bHasExploded = True;
	Destroy();
}

function PostNetBeginPlay()
{
	Super(Nade).PostNetBeginPlay();
}

function TransferActor(Pawn A)
{
	//Log("TransferActor.0"@A@A.PlayerReplicationInfo.PlayerName);
	Taker=A;
}

simulated function Stick()
{
	local Rotator rot;
	local Vector loc;
	local CRItem cri;
	if(Taker==None) return;
	cri=Spawn(class'CRItem',self,,,);
	//Log("Stick.0"@Taker@Taker.OwnerName@cX@cY@cZ@cYaw@cPitch@cRoll);
	Taker.AttachToBone(self,'CHR_Spine3');
	rot.Yaw=cYaw;
	rot.Pitch=cPitch; //-16384; //looks 99% perfect
	rot.Roll=cRoll; // 6144; //+ is tilt wire towards player's back
	SetRelativeRotation(rot);
	bSticked=true;
	loc.X=cX; //+ is up, - is down
	loc.Y=cY; //+ is back, - is front?
	loc.Z=cZ; //+ is left, - is right
	SetRelativeLocation(loc);
	if(!bHideAll) bHidden=false;
	cri.Destroyed();
	cri.Destroy();
}

simulated function UnStick()
{
	Taker.DetachFromBone(Self);
	Explode(Location,VRand()*0.0); // Уничтожаем объект
}

simulated function Tick(float DeltaTime)
{
	local Weapon W;
	
	if(Taker==None) return;
	if(Role==ROLE_Authority)
	{
		if(!bSticked)
			Stick();
		W=GetWeapon(Taker,'RPG');
		if(W==None) return;
		cMagAmmount=W.AmmoAmount(0);
		//MagAmmount=Taker.Weapon.AmmoAmount(0);
		if(KFWeapon(W).MagAmmoRemaining<cMagAmmount) KFWeapon(W).MagAmmoRemaining=cMagAmmount;
		if(bTimeToUpdate || cMagAmmount>oMagAmmount)
		{
			MagAmmount=W.AmmoAmount(0);
			oMagAmmount=MagAmmount;
			//Log("Tick"@bHidden@MagAmmount);
			UpdateBackpack();
		}
	}
	else
		Disable('Tick');
}

function Weapon GetWeapon(Pawn P, Name weaponName)
{
	local Inventory Inv;
	for( Inv=P.Inventory; Inv!=None; Inv=Inv.Inventory )
		if(Inv.Class.Name==weaponName)
			return Weapon(Inv);
	return Weapon(Inv);
}

/* simulated function Timer()
{
	Log("Timer");
	UpdateBackpack();
	bUpdateTimerSet=false;
}
 */
simulated function UpdateBackpack()
{
	//Log("Bag.UpdateBackpack"@MagAmmount);
	bTimeToUpdate=false;
	if(bHideBag) SetBoneScale (4, 0.0, 'Pack');
	if (MagAmmount == 0)
	{
		SetBoneScale (0, 0.0, 'Rock1');
		SetBoneScale (1, 0.0, 'Rock2');
		SetBoneScale (2, 0.0, 'Rock3');
	}
	else if (MagAmmount == 1)
	{
		SetBoneScale (0, 0.0, 'Rock1');
		SetBoneScale (1, 0.0, 'Rock2');
		SetBoneScale (2, 0.0, 'Rock3');
	}
	else if (MagAmmount == 2)
	{
		SetBoneScale (0, 0.0, 'Rock1');
		SetBoneScale (1, 0.0, 'Rock2');
		SetBoneScale (2, 1.0, 'Rock3');
	}
	else if (MagAmmount == 3)
	{
		SetBoneScale (0, 0.0, 'Rock1');
		SetBoneScale (1, 1.0, 'Rock2');
		SetBoneScale (2, 1.0, 'Rock3');
	}
	else if (MagAmmount > 3)
	{
		SetBoneScale (0, 1.0, 'Rock1');
		SetBoneScale (1, 1.0, 'Rock2');
		SetBoneScale (2, 1.0, 'Rock3');
	}
}


defaultproperties
{
	cYaw=0
	cPitch=0
	cRoll=0
	cX=10
	cY=0
	cZ=-10

	oMagAmmount=-10
//bBonesUpdated=true
	Speed=0.000000
	MaxSpeed=0.000000
	Mesh=SkeletalMesh'RPG7DTv2_A.RPG7DT_BackPack'
	//StaticMesh=StaticMesh'RPG7DTv2_A.RPG7_backpack'
	DrawType=DT_Mesh
	Physics=PHYS_Projectile
	DrawScale=2.00000
	CollisionRadius=0.000000
	CollisionHeight=0.000000
	ExplodeTimer=100000.000000
	LifeSpan=0.0
	//AmbientGlow=50
	bUnlit=False
	Damage=1.000000
	DamageRadius=1.000000
	//bDynamicLight=True
	// bFullVolume=True
	//SoundVolume=255
	//SoundRadius=400.000000
	bCollideActors=False
	bHidden=true
	//bAlwaysRelevant=true
}