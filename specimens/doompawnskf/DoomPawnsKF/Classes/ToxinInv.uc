Class ToxinInv extends InvulnInv;

simulated function ClientAddOverlay()
{
	local PlayerController PC;

	if( ClientOverlay!=None || Pawn(Owner)==None || PlayerController(Pawn(Owner).Controller)==None || Viewport(PlayerController(Pawn(Owner).Controller).Player)==None )
		return; // Make sure it is a local client that received this call.
	PC = PlayerController(Pawn(Owner).Controller);
	if( PC.myHUD==None )
		return;
	ClientOverlay = Spawn(Class'ToxinOverlay');
	PC.myHUD.AddHudOverlay(ClientOverlay);
}
state Activated
{
	function int ArmorAbsorbDamage(int Damage, class<DamageType> DamageType, vector HitLocation)
	{
		if( DamageType==Class'Corroded' )
			return 0;
		return Damage;
	}
	function int ArmorPriority(class<DamageType> DamageType)
	{
		if( DamageType==Class'Corroded' )
			return 1000000;
		return 0;
	}
	function Timer()
	{
		if( Charge>115 )
			ClientAddOverlay();
		Charge-=1;
		if( Charge<=6 && Charge>0 )
			ClientFlashOverlay();
		if( Charge<=0 )
			Destroy();
	}
}

defaultproperties
{
     Charge=120
}
