//=============================================================================
// KFHumanPawn2. //Thanks Red-Frog
//=============================================================================
class KFHumanPawnt extends KFHumanPawn;

#exec obj load file=..\animations\KF_Soldier_Trip.ukx
#exec obj load file=..\animations\traders.ukx

var bool bbuy2,bistrader;

exec function TossCash( int Amount )
{}

simulated function tick(float DeltaTime)
{
local weapon w;

	super.Tick(deltaTime);

CrouchRadius=25.000000;

if(WEAPON!=NONE&&weapon.isa('kfmeleegun'))
groundspeed=330;
else
groundspeed=240;


      if(Controller != None && KFPlayerController(Controller) != None)
      KFPlayerController(Controller).bWantsTraderPath = false;

w=kfweapon(findinventorytype(class'pistolwhip'));
if(w!=none){linkmesh(skeletalmesh'traderS.trader');skins[0]=Texture'KF_Soldier_Trip_T.Uniforms.shopkeeper_diff';
skins[1]=none;



}
else if(playerreplicationinfo!=none&&playerreplicationinfo.team.teamindex==0)
{linkmesh(skeletalmesh'british_soldier1');skins[0]=Combiner'KF_Soldier_Trip_T.Uniforms.brit_soldier_I_cmb';
}
else if(playerreplicationinfo!=none&&playerreplicationinfo.team.teamindex==1){linkmesh(skeletalmesh'british_riot_police_I');skins[0]=Combiner'KF_Soldier_Trip_T.Uniforms.british_riot_police_cmb';
skins[1]=FinalBlend'KF_Soldier_Trip_T.Uniforms.british_riot_police_fb';}


}

function bool CanBuyNow()
{
		Return True;

}
function ServerBuyWeapon( Class<Weapon> WClass )
{
	local Inventory I, J;
	local float Price;


	//if( !CanBuyNow() || Class<KFWeapon>(WClass)==None || Class<KFWeaponPickup>(WClass.Default.PickupClass)==None )
	//{
	//	Return;
	//}

	Price = class<KFWeaponPickup>(WClass.Default.PickupClass).Default.Cost;

	if ( KFPlayerController(Controller).SelectedVeterancy != none )
	{
		Price *= KFPlayerController(Controller).SelectedVeterancy.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), WClass.Default.PickupClass);
	}

	for ( I=Inventory; I!=None; I=I.Inventory )
	{
		if( I.Class==WClass )
		{
			Return; // Already has weapon.
		}
	}


if(zombieplayercontroller(controller).boughtweapon1==none)
{zombieplayercontroller(controller).boughtweapon1=wclass;zombieplayercontroller(controller).bbuy2=true;}
else if(zombieplayercontroller(controller).boughtweapon2==none)
{zombieplayercontroller(controller).boughtweapon2=wclass;zombieplayercontroller(controller).bbuy2=false;}


	if ( WClass == class'DualDeagle' )
	{
		for ( J = Inventory; J != None; J = J.Inventory )
		{
			if ( J.class == class'Deagle' )
			{
				Price = Price / 2;
				bHasDeagle = true;

				break;
			}
		}
	}

	if ( !bHasDeagle && !CanCarry(Class<KFWeapon>(WClass).Default.Weight) )
	{
		bHasDeagle = false;
		Return;
	}

    if ( PlayerReplicationInfo.Score < Price )
	{
		bHasDeagle = false;
		Return; // Not enough CASH.
	}

	I = Spawn(WClass);

	if ( I != none )
	{
		KFWeapon(I).UpdateMagCapacity(PlayerReplicationInfo);
		KFWeapon(I).FillToInitialAmmo();
		I.GiveTo(self);
		PlayerReplicationInfo.Score -= Price;
    }

	bHasDeagle = false;

	SetTraderUpdate();
}
//removed groundspeed modifier
simulated event ModifyVelocity(float DeltaTime, vector OldVelocity)
{
    local float WeightMod, HealthMod;
    local float EncumbrancePercentage;

    super(KFPawn).ModifyVelocity(DeltaTime, OldVelocity);

	if (Controller != none)
	{
        // Calculate encumbrance, but cap it to the maxcarryweight so when we use dev weapon cheats we don't move mega slow
        EncumbrancePercentage = (FMin(CurrentWeight, MaxCarryWeight)/MaxCarryWeight);
        // Calculate the weight modifier to speed
        WeightMod = (1.0 - (EncumbrancePercentage * WeightSpeedModifier));
        // Calculate the health modifier to speed
        HealthMod = ((Health/HealthMax) * HealthSpeedModifier) + (1.0 - HealthSpeedModifier);

        // Apply all the modifiers
//        GroundSpeed = default.GroundSpeed * HealthMod;
//        GroundSpeed *= WeightMod;
//        GroundSpeed += InventorySpeedModifier;

		if ( KFPlayerReplicationInfo(PlayerReplicationInfo) != none && KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill != none )
		{
//			GroundSpeed *= KFPlayerReplicationInfo(PlayerReplicationInfo).ClientVeteranSkill.static.GetMovementSpeedModifier(KFPlayerReplicationInfo(PlayerReplicationInfo));
		}
	}
}



function ServerSellWeapon( Class<Weapon> WClass )
{
	local Inventory I;
	local Single NewSingle;
	local Deagle NewDeagle;
	local float Price;

	if( !CanBuyNow() || Class<KFWeapon>(WClass)==None || Class<KFWeaponPickup>(WClass.Default.PickupClass)==None )
	{
		SetTraderUpdate();
		Return;
	}

	For( I=Inventory; I!=None; I=I.Inventory )
	{
		if( I.Class==WClass )
		{
			Price = int(Class<KFWeaponPickup>(WClass.Default.PickupClass).Default.Cost * 0.75);

			if ( KFPlayerController(Controller).SelectedVeterancy != none )
			{
				Price *= KFPlayerController(Controller).SelectedVeterancy.static.GetCostScaling(KFPlayerReplicationInfo(PlayerReplicationInfo), WClass.Default.PickupClass);
			}

			if ( Dualies(I) != None && DualDeagle(I) == none)
			{
				NewSingle = Spawn(Class'Single');
				NewSingle.GiveTo(Self);
			}

			if ( DualDeagle(I) != none )
			{
				NewDeagle = Spawn(Class'Deagle');
				NewDeagle.GiveTo(Self);
				Price = Price / 2;
			}

			if ( I == Weapon || I == PendingWeapon )
			{
				ClientCurrentWeaponSold();
			}

			PlayerReplicationInfo.Score += Price;

if(zombieplayercontroller(controller).boughtweapon1==wclass)
   zombieplayercontroller(controller).boughtweapon1=none;
else if(zombieplayercontroller(controller).boughtweapon2==wclass)
   zombieplayercontroller(controller).boughtweapon2=none;

			I.Destroyed();
			I.Destroy();

			SetTraderUpdate();

			Return;
		}
	}
}

defaultproperties
{
     GroundSpeed=240.000000
     JumpZ=350.000000
     Mass=100.000000
}
