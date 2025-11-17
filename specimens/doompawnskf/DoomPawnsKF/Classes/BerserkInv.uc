Class BerserkInv extends Powerups;

var BerserkOverlay ClientOverlay;

replication
{
	// Functions server can call.
	reliable if( Role==ROLE_Authority )
		ClientAddOverlay;
}

function bool HandlePickupQuery( Pickup Item )
{
	if (item.InventoryType == class)
	{
		PickupFunction(Pawn(Owner));
		Item.AnnouncePickup(Pawn(Owner));
		Item.SetRespawn();
		return true;
	}
	if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}
function PickupFunction(Pawn Other)
{
	local Inventory I;

	Other.Controller.ClientSetWeapon(Class'DoomFist');
	for( I=Other.Inventory; I!=None; I=I.Inventory )
		if( DoomFist(I)!=None )
			DoomFist(I).MyBerserk = Self;
	Other.Health = Max(Other.Health,Other.Default.Health);
	GoToState('Activated');
	ClientAddOverlay();
}
simulated function ClientAddOverlay()
{
	local PlayerController PC;

	if( ClientOverlay!=None )
	{
		ClientOverlay.LifeSpan = ClientOverlay.Default.LifeSpan;
		return;
	}
	if( Pawn(Owner)==None || PlayerController(Pawn(Owner).Controller)==None || Viewport(PlayerController(Pawn(Owner).Controller).Player)==None )
		return; // Make sure it is a local client that received this call.
	PC = PlayerController(Pawn(Owner).Controller);
	if( PC.myHUD==None )
		return;
	ClientOverlay = Spawn(Class'BerserkOverlay');
	PC.myHUD.AddHudOverlay(ClientOverlay);
}
simulated function Destroyed()
{
	if( ClientOverlay!=None )
		ClientOverlay.Destroy();
	Super.Destroyed();
}
function float GetDamageMulti( DoomFist Weapon, Actor DamageTarget )
{
	return 10.f;
}
state Activated
{
	function PickupFunction(Pawn Other)
	{
		Other.Health = Max(Other.Health,Other.Default.Health);
		ClientAddOverlay();
	}
	function BeginState()
	{
		SetTimer(1,false);
	}
	function EndState()
	{
	}
	function Timer()
	{
		ClientAddOverlay();
	}
}

defaultproperties
{
     bDisplayableInv=True
     Charge=30
     bTravel=False
}
