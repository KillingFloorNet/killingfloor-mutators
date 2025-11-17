class MutAllTradersEnabled extends Mutator;

function PreBeginPlay()
{
	local ShopVolume S;

	foreach AllActors(Class'ShopVolume',S)
    {
		S.bAlwaysClosed = false;
		S.bAlwaysEnabled= true;
	}

	Destroy();
}

defaultproperties
{
     bAddToServerPackages=True
     GroupName="KF-AllTraders"
     FriendlyName="All Traders"
     Description="Opens up all traders inbetween waves."
     bAlwaysRelevant=True
}
