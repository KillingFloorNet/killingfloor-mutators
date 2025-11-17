Class DoomWeaponAttachment extends KFWeaponAttachment
	Abstract;

simulated event ThirdPersonEffects()
{
	if ( (Level.NetMode == NM_DedicatedServer) || (Instigator == None) )
		return;

  	if ( FlashCount>0 )
	{
		if( KFPawn(Instigator)!=None )
		{
			if (FiringMode == 0)
				KFPawn(Instigator).StartFiringX(false,bRapidFire);
			else KFPawn(Instigator).StartFiringX(true,bRapidFire);
		}
	}
	else
	{
		GotoState('');
		if( KFPawn(Instigator)!=None )
			KFPawn(Instigator).StopFiring();
	}
}

defaultproperties
{
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'DoomPawnsKF.Weapon3rdMesh'
     bActorShadows=False
     DrawScale=0.100000
     Style=STY_Masked
}
