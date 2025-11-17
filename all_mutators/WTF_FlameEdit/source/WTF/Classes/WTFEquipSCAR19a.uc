class WTFEquipSCAR19a extends SCARMK17AssaultRifle
	config(user);

replication
{
	reliable if(Role < ROLE_Authority)
		ServerChangeAutoMode;
}

simulated function DoToggle ()
{
	local PlayerController Player;
	local WTFEquipSCAR19Fire FM;
	local int MyAutoMode;
	local bool bIsCommando;

	if (Instigator == None)
		return;
	
	Player = Level.GetLocalPlayerController();
	if ( Player==None )
		return;

	FM = WTFEquipSCAR19Fire(FireMode[0]);
	MyAutoMode = FM.AutoMode;
	MyAutoMode++;
	
	bIsCommando = true;
	FM.SetAutoMode(MyAutoMode, bIsCommando); //2nd param means YES/NO we are a commando: Super Auto will be available if we are a commando

	ServerChangeAutoMode(FM.AutoMode, FM.bWaitForRelease);
	//Super(KFWeapon).DoToggle(); //just plays a sound
	PlayOwnedSound(ToggleSound,SLOT_None,2.0,,,,false);
	Player.ReceiveLocalizedMessage(Class'WTFEquipBulldogSwitchMessage',FM.AutoMode);
}

// Set the new fire mode on the server
function ServerChangeAutoMode(int NewMode, bool bSemiAuto)
{
	WTFEquipSCAR19Fire(FireMode[0]).AutoMode = NewMode;
	WTFEquipSCAR19Fire(FireMode[0]).bWaitForRelease = bSemiAuto;
}

defaultproperties
{
	FireModeClass(0)=Class'WTFEquipSCAR19Fire'
	Description="A deadly weapon"
	PickupClass=Class'WTFEquipSCAR19Pickup'
	ItemName="SCAR19 profession"
}
