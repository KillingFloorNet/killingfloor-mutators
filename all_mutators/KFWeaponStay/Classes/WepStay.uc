Class WepStay extends Mutator;

var array<WeaponPickup> PendingPickup;

function MatchStarting()
{
	GoToState('EnabledMut');
}

State EnabledMut
{
	function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
	{
		if( WeaponPickup(Other)!=None && KnifePickup(Other)==None && SyringePickup(Other)==None && WelderPickup(Other)==None )
		{
			PendingPickup[PendingPickup.Length] = WeaponPickup(Other);
			SetTimer(0.1,false);
		}
		return true;
	}
}

function Timer()
{
	local int i;

	for( i=(PendingPickup.Length-1); i>=0; --i )
		if( PendingPickup[i]!=None )
		{
			PendingPickup[i].bDropped = false;
			PendingPickup[i].RespawnTime = 0;
		}
	PendingPickup.Length = 0;
}

defaultproperties
{
     GroupName="KF-WepStayMut"
     FriendlyName="Weapon stay"
     Description="Force weapons stay over waves."
}
