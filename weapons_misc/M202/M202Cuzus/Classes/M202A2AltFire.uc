class M202A2AltFire extends M202A2Fire;

var() float BurstRate;
var bool bBursting;

event ModeDoFire()
{
	if(!bBursting && AllowFire())
	{
		bBursting = true;
		SetTimer(BurstRate, true);
	}
	if(KFWeapon(Weapon).MagAmmoRemaining < 1)
	{
		SetTimer(0, false);
		KFWeapon(Weapon).MagAmmoRemaining = 0;
		bBursting = false;
		return;
	}
	Super.ModeDoFire();
}

simulated function Timer()
{
	if(bBursting)
		ModeDoFire();
	else SetTimer(0,false);
}


defaultproperties
{
     FireAnimIron="Fire_Hard"
     FireAnimSimple="IronFire_Hard"
     BurstRate=0.2
}
