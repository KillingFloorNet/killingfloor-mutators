class HeldWeapon extends Actor;

var Weapon Weapon;

function postbeginplay()
{
	settimer(2.0,true);
}
function timer()
{

	if(weapon == none)
		destroy();
}

defaultproperties
{
     DrawType=DT_Mesh
     Physics=PHYS_Projectile
     bOwnerNoSee=True
}
