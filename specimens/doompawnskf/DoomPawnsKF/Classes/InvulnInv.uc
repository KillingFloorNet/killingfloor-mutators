Class InvulnInv extends Armor;

var InvulnOverlay ClientOverlay;

replication
{
	// Functions server can call.
	reliable if( Role==ROLE_Authority )
		ClientAddOverlay,ClientFlashOverlay;
}

function PickupFunction(Pawn Other)
{
	GoToState('Activated');
	ClientAddOverlay();
}
function int ArmorAbsorbDamage(int Damage, class<DamageType> DamageType, vector HitLocation)
{
	return Damage;
}
function int ArmorPriority(class<DamageType> DamageType)
{
	return 0;
}
simulated function ClientAddOverlay()
{
	local PlayerController PC;

	if( ClientOverlay!=None || Pawn(Owner)==None || PlayerController(Pawn(Owner).Controller)==None || Viewport(PlayerController(Pawn(Owner).Controller).Player)==None )
		return; // Make sure it is a local client that received this call.
	PC = PlayerController(Pawn(Owner).Controller);
	if( PC.myHUD==None )
		return;
	ClientOverlay = Spawn(Class'InvulnOverlay');
	PC.myHUD.AddHudOverlay(ClientOverlay);
}
simulated function ClientFlashOverlay()
{
	if( ClientOverlay!=None )
		ClientOverlay.FlashIt();
}
simulated function Destroyed()
{
	if( ClientOverlay!=None )
		ClientOverlay.Destroy();
	Super.Destroyed();
}
state Activated
{
	function PickupFunction(Pawn Other);

	function int ArmorAbsorbDamage(int Damage, class<DamageType> DamageType, vector HitLocation)
	{
		return 0;
	}
	function int ArmorPriority(class<DamageType> DamageType)
	{
		return 1000000;
	}
	function BeginState()
	{
		SetTimer(1,true);
	}
	function EndState()
	{
	}
	function Timer()
	{
		if( Charge>27 )
			ClientAddOverlay();
		Charge-=1;
		if( Charge<=5 && Charge>0 )
			ClientFlashOverlay();
		if( Charge<=0 )
			Destroy();
	}
}

defaultproperties
{
     bDisplayableInv=True
     Charge=30
     bTravel=False
}
