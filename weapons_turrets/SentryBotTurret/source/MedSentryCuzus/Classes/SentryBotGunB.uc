// Armor Sentry Bot
class SentryBotGunB extends SentryBotGun;

event ServerStartFire(byte Mode)
{
	local rotator R;
	local vector Spot;

	if ( (Instigator != None) && (Instigator.Weapon != self) )
	{
		if ( Instigator.Weapon == None )
			Instigator.ServerChangedWeapon(None,self);
		else
			Instigator.Weapon.SynchronizeWeapon(self);
		return;
	}

	if( CurrentSentry==None )
	{
		R.Yaw = Instigator.Rotation.Yaw;
		Spot = vector(R)*(Instigator.CollisionRadius+70.f)+Instigator.Location;
		if( FastTrace(Spot,Instigator.Location) )
		{
      CurrentSentry = Spawn(Class'SentryBotTurret',,,Spot,R);
      CurrentSentry.SentryMode = 1; // Armor

			if( CurrentSentry!=None )
			{
				if( PlayerController(Instigator.Controller)!=None )
					PlayerController(Instigator.Controller).ReceiveLocalizedMessage(Class'SentryBotMessage',1);
				CurrentSentry.SetOwningPlayer(Instigator,Self);
				bSentryDeployed = true;
        SellValue = 10; // No refunds after deployed.
        
				if( ThirdPersonActor!=None )
				{
					InventoryAttachment(ThirdPersonActor).bFastAttachmentReplication = false;
					ThirdPersonActor.bHidden = true;
				}
				return;
			}
		}
		if( PlayerController(Instigator.Controller)!=None )
			PlayerController(Instigator.Controller).ReceiveLocalizedMessage(Class'SentryBotMessage',0);
	}
}

defaultproperties
{
	PickupClass=Class'SentryBotGunPickupB'
	ItemName="Sentry Bot (Armor)"
}
