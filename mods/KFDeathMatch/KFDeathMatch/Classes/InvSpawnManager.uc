Class InvSpawnManager extends Info;

var KFLevelRules InvList;
var class<Pickup> PickupClass;

var float DisableTime;

var NavigationPoint LastPoint;
var Pickup ActivePickup;
var array<NavigationPoint> Candiantes;

final function InitDests()
{
	local NavigationPoint N;

	for( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
	{
		if( PathNode(N)!=None )
			Candiantes[Candiantes.Length] = N;
	}
}
final function bool PickRandomPoint()
{
	local byte i;
	local NavigationPoint N;

	if( Candiantes.Length==0 )
	{
		InitDests();
		if( Candiantes.Length==0 )
			return false;
	}
	if( Candiantes.Length==1 )
		LastPoint = Candiantes[0];
	else
	{
		while( ++i<20 )
		{
			N = Candiantes[Rand(Candiantes.Length)];
			if( N!=LastPoint )
				break;
		}
		LastPoint = N;
	}
	return true;
}
final function bool TryToSpawn()
{
	local rotator R;
	local int i;
	local KFGameType KF;

	R.Yaw = Rand(65536);
	if( PickupClass!=None )
	{
		ActivePickup = Spawn(PickupClass,,,LastPoint.Location,R);
		if( ActivePickup==None )
			return false;
		ActivePickup.RespawnTime = 0;
		if( KFAmmoPickup(ActivePickup)!=None )
		{
			KF = KFGameType(Level.Game);
			for( i=0; i<KF.AmmoPickups.Length; i++ )
			{
				if( KF.AmmoPickups[i]==None || KF.AmmoPickups[i]==ActivePickup )
				{
					KF.AmmoPickups.Remove(i--,1);
					break;
				}
			}
			ActivePickup.GoToState('Pickup');
		}
		return true;
	}
	else if( InvList!=None )
	{
		ActivePickup = Spawn(PickRandomGun(),,,LastPoint.Location,R);
		if( ActivePickup==None )
			return false;
		ActivePickup.RespawnTime = 0;
		return true;
	}
	return false;
}
final function class<Pickup> PickRandomGun()
{
	local int i,c;

	for( i=0; i<24; i++ )
		if( InvList.ItemForSale[i]!=None )
			c++;
	if( c==0 )
		return None;
	c = Rand(c);
	for( i=0; i<24; i++ )
		if( InvList.ItemForSale[i]!=None && --c<0 )
			return InvList.ItemForSale[i];
}

Auto state AddingPickup
{
Begin:
	Sleep(DisableTime+DisableTime*FRand());
	if( !PickRandomPoint() )
		Destroy();
	while( !TryToSpawn() )
	{
		Sleep(2.f);
		PickRandomPoint();
	}
	GoToState('PickupActive');
}
state PickupActive
{
	final function bool PlayerSeesMe()
	{
		local Controller C;

		if( ActivePickup==None || ActivePickup.bDeleteMe )
			return false;
		for( C=Level.ControllerList; C!=None; C=C.nextController )
			if( PlayerController(C)!=None && C.Pawn!=None && C.Pawn.Health>0 && VSizeSquared(ActivePickup.Location-C.Pawn.Location)<4000000.f
			 && FastTrace(ActivePickup.Location,C.Pawn.Location) )
				return true;
		return false;
	}
	function EndState()
	{
		if( ActivePickup!=None )
			ActivePickup.Destroy();
		ActivePickup = None;
	}
Begin:
	Sleep(30.f+FRand()*60.f);
	while( PlayerSeesMe() )
		Sleep(5.f);
	GoToState('AddingPickup');
}

defaultproperties
{
     DisableTime=30.000000
}
