class WTFEquipBulldog extends Bullpup
	config(user);

replication
{
	reliable if(Role < ROLE_Authority)
		ServerChangeAutoMode;
}

simulated function DoToggle ()
{
	local PlayerController Player;
	local WTFEquipBulldogFire FM;
	local KFPlayerReplicationInfo KFPRI;
	local int MyAutoMode;
	local bool bIsCommando;
	
	if (Instigator == None)
		return;
	
	Player = Level.GetLocalPlayerController();
	if ( Player==None )
		return;

	FM = WTFEquipBulldogFire(FireMode[0]);
	MyAutoMode = FM.AutoMode;
	MyAutoMode++;
	
	KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
	FM.SetAutoMode(MyAutoMode, bIsCommando); //2nd param means YES/NO we are a commando: Super Auto will be available if we are a commando
	
	ServerChangeAutoMode(FM.AutoMode, FM.bWaitForRelease);
	Super(KFWeapon).DoToggle(); //just plays a sound
	Player.ReceiveLocalizedMessage(class'WTF.WTFEquipBulldogSwitchMessage',FM.AutoMode);
}

// Set the new fire mode on the server
function ServerChangeAutoMode(int NewMode, bool bSemiAuto)
{
	WTFEquipBulldogFire(FireMode[0]).AutoMode = NewMode;
	WTFEquipBulldogFire(FireMode[0]).bWaitForRelease = bSemiAuto;
}
	

defaultproperties
{
     FireModeClass(0)=Class'WTF.WTFEquipBulldogFire'
     Description="A deadly weapon"
     PickupClass=Class'WTF.WTFEquipBulldogPickup'
     ItemName="Bulldog"
}
