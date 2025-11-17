Class CashStayMut extends Mutator config(CashStayMut);

var array<CashPickup> PendingPickups;
var config int TimeToStay;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	
	if( CashPickup(Other)!=None )
	{
		PendingPickups[PendingPickups.Length] = CashPickup(Other);
		SetTimer(0.1,false);
	}
	return true;
}

function Timer()
{
	while( PendingPickups.Length>0 )
	{
		PendingPickups[0].bPreventFadeOut = true; 
		PendingPickups[0].LifeSpan = TimeToStay;
		PendingPickups.Remove(0,1);
	}
}


defaultproperties
{
	TimeToStay=0
	bAddToServerPackages=True
	GroupName="KF-CashStay"
	FriendlyName="CashStayMut"
	Description="CashStayMut"
}
