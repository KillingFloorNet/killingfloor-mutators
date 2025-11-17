class WTFEquipMP7M2Fire extends MP7MFire;

event ModeDoFire()
{
	local float Rec;
	
	if (!AllowFire())
		return;
		
	//following 2 lines from regular mp7's fire code
	if( !IsInState('FireLoop'))
	    return;

	if( Instigator==None || Instigator.Controller==none )
		return;

    Spread = GetSpread();

	Rec = GetFireSpeed();
	FireRate = default.FireRate/Rec;
	FireAnimRate = default.FireAnimRate*Rec;
	ReloadAnimRate = default.ReloadAnimRate*Rec;
	Rec = 1;

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		Spread *= KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.ModifyRecoilSpread(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self, Rec);
	}

	LastFireTime = Level.TimeSeconds;
	Super(InstantFire).ModeDoFire();

    // client
    if (Instigator.IsLocallyControlled())
    {
        if( bDoClientRagdollShotFX && Weapon.Level.NetMode == NM_Client )
        {
            DoClientOnlyFireEffect();
        }
        HandleRecoil(Rec);
    }
}

defaultproperties
{
     MaxSpread=0.066000
     AmmoClass=Class'WTFEquipMP7M2Ammo'
     aimerror=15.000000
     Spread=0.006000
}
