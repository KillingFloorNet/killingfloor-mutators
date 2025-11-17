class PFAmmoPickup extends KFAmmoPickup;
state Pickup
{
// When touched by an actor.
function Touch(Actor Other)
{
  local Inventory CurInv;
  local bool bPickedUp;
  local Boomstick DBShotty;
  local bool bResuppliedBoomstick;
  if ( Pawn(Other) != none && Pawn(Other).bCanPickupInventory && Pawn(Other).Controller != none &&
	FastTrace(Other.Location, Location) )
  {
   for ( CurInv = Other.Inventory; CurInv != none; CurInv = CurInv.Inventory )
   {
	if( Boomstick(CurInv) != none )
	{
		DBShotty = Boomstick(CurInv);
	}
  
	bPickedUp = bPickedUp || PickupAmmo(KFAmmunition(CurInv),Pawn(Other));
				if( DBShotgunAmmo(CurInv) != none )
	{
	 bResuppliedBoomstick = true;
	}
   }
   if ( bPickedUp )
   {
				if( bResuppliedBoomstick && DBShotty != none )
				{
					DBShotty.AmmoPickedUp();
				}
				AnnouncePickup(Pawn(Other));
	GotoState('Sleeping', 'Begin');
	if ( KFGameType(Level.Game) != none )
	{
	 KFGameType(Level.Game).AmmoPickedUp(self);
	}
   }
  }
}
}
function bool PickupAmmo(KFAmmunition KFA, Pawn P)
{
local KFPlayerReplicationInfo KFPRI;
local class<KFVeterancyTypes> KFV;
local int CurrentMaxAmmo;
local int AmmoPickupAmount;
if ( KFA == none || P == none || !KFA.bAcceptsAmmoPickups )
{
  return false;
}

KFPRI = KFPlayerReplicationInfo(P.PlayerReplicationInfo);

if ( KFPRI != none )
{
  KFV = KFPRI.ClientVeteranSkill;
}

CurrentMaxAmmo = KFA.default.MaxAmmo;

if ( KFV != none )
{
  CurrentMaxAmmo = float(CurrentMaxAmmo) * KFV.Static.AddExtraAmmoFor(KFPRI,KFA.Class);
}

if ( KFA.AmmoAmount < CurrentMaxAmmo )
{
  AmmoPickupAmount = KFA.AmmoPickupAmount;

  if ( KFV != none )
  {
   AmmoPickupAmount = float(AmmoPickupAmount) * KFV.Static.GetAmmoPickupMod(KFPRI,KFA);
  }

  KFA.AmmoAmount = Min(CurrentMaxAmmo,KFA.AmmoAmount+AmmoPickupAmount);

  return true;
}

return false;
}
defaultproperties
{
}