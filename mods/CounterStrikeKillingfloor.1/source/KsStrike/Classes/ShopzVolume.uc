//-----------------------------------------------------------
//
//-----------------------------------------------------------
class ShopzVolume extends Volume;

var() string URL;
var() float EnabledProbability; // How big chance is it that I get selected to be open on wave start?
var() bool bAlwaysEnabled; // Should the trader always be open (even when its not my turn)?
var array<Teleporter> TelList;
var bool bTelsInit,bHasTeles,bInitTriggerActs,bCurrentlyOpen,bAlwaysClosed;
var array<Actor> TriggeringActors;
var NavigationPoint BotPoint;
var WeaponLocker MyTrader;



function UsedBy( Pawn user )
{
    
    User.SetAnimAction(User.IdleWeaponAnim);

	if( PlayerController(user.Controller)!=None  )
		KFPlayerController(user.Controller).ShowBuyMenu("Weaponlocker",KFHumanPawn(user).MaxCarryWeight);
}

defaultproperties
{
     EnabledProbability=1.000000
}
