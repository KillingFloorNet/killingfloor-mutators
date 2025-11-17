class WTFEquipAK48S extends AK47AssaultRifle
	config(user);

replication
{
	reliable if(Role < ROLE_Authority)
		ServerChangeAutoMode;
}

simulated function DoToggle ()
{
	local PlayerController Player;
	local WTFEquipAK48SFire FM;
	local KFPlayerReplicationInfo KFPRI;
	local int MyAutoMode;
	local bool bIsCommando;
	
	if (Instigator == None)
		return;
	
	Player = Level.GetLocalPlayerController();
	if ( Player==None )
		return;

	FM = WTFEquipAK48SFire(FireMode[0]);
	MyAutoMode = FM.AutoMode;
	MyAutoMode++;
	
	KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
	bIsCommando = true;
	FM.SetAutoMode(MyAutoMode, bIsCommando); //2nd param means YES/NO we are a commando: Super Auto will be available if we are a commando
	
	ServerChangeAutoMode(FM.AutoMode, FM.bWaitForRelease);
	PlayOwnedSound(ToggleSound,SLOT_None,2.0,,,,false);
	Player.ReceiveLocalizedMessage(Class'WTFEquipBulldogSwitchMessage',FM.AutoMode);
}

// Set the new fire mode on the server
function ServerChangeAutoMode(int NewMode, bool bSemiAuto)
{
	WTFEquipAK48SFire(FireMode[0]).AutoMode = NewMode;
	WTFEquipAK48SFire(FireMode[0]).bWaitForRelease = bSemiAuto;
}

defaultproperties
{
     FireModeClass(0)=Class'WTFEquipAK48SFire'
     Description="A deadly weapon"
     PickupClass=Class'WTFEquipAK48SPickup'
     ItemName="AK48S profession"
}
