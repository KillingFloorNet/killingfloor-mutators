class PickupReplaceMut extends Mutator config(PickupReplaceMut);

struct PickupInfo
{
	var config string PickupClassName;
	var config int Probability;
};
var config array<PickupInfo> PickupList;
var config array<string> MapExcludeList;
var config bool bApplyToFixedPickups;

function PostBeginPlay()
{
	local string URL;
	URL=GetShortUrl(Level.GetLocalURL());
	Log("PickupReplaceMut.MapNameInfo: Map name is"@URL);
	if(!InMapExcludeList(URL))
		ReplaceItemSpawn();
}

function ReplaceItemSpawn()
{
	local KFRandomItemSpawn KFRIS;
	local KFWeaponPickup KFWP;
	foreach DynamicActors(class'KFRandomItemSpawn',KFRIS)
	{
		if(KFRIS.Class.Name=='KFRandomItemSpawn')
		{
			NewReplaceWith(KFRIS,"PickupReplaceMut.NewKFRandomItemSpawn");
			KFRIS.Destroy();
		}
	}
	if(bApplyToFixedPickups)
	{
		foreach DynamicActors(class'KFWeaponPickup',KFWP)
		{
			NewReplaceWith(KFWP,"PickupReplaceMut.NewKFRandomItemSpawn");
			KFWP.Destroy();
		}
	}
}

function bool NewReplaceWith(actor Other, string aClassName)
{
	local Actor A;
	local class<Actor> aClass;

	if ( aClassName == "" )
		return true;

	aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
	//Flame. заменяем Owner на Self. В базовой версии там Other.Owner
	if ( aClass != None )
		A = Spawn(aClass,self,Other.tag,Other.Location, Other.Rotation);
	//
	if ( Other.IsA('Pickup') )
	{
		if ( Pickup(Other).MyMarker != None )
		{
			Pickup(Other).MyMarker.markedItem = Pickup(A);
			if ( Pickup(A) != None )
			{
				Pickup(A).MyMarker = Pickup(Other).MyMarker;
				A.SetLocation(A.Location
					+ (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
			}
			Pickup(Other).MyMarker = None;
		}
		else if ( A.IsA('Pickup') )
			Pickup(A).Respawntime = 0.0;
	}
	if ( A != None )
	{
		A.event = Other.event;
		A.tag = Other.tag;
		return true;
	}
	return false;
}

function string GetNewWeaponClassName()
{
	local int i, sum;
	local int iRand;
	local string weaponName;
	for(i=0;i<PickupList.Length;i++)
	{
		sum+=PickupList[i].Probability;
	}
	iRand=Rand(sum);
	sum=0;
	for(i=0;i<PickupList.Length;i++)
	{
		sum+=PickupList[i].Probability;
		weaponName=PickupList[i].PickupClassName;
		if(sum>iRand) break;
	}
	return weaponName;
}

function string GetShortUrl(string s)
{
	local int qPos, slashPos, startPos;
	local string result;
	qPos=InStr(s,"?");
	slashPos=InStr(s,"/");
	startPos=Max(slashPos, 0);
	result=Mid(s, startPos+1, qPos-startPos-1);
	return result;
}

function bool InMapExcludeList(string URL)
{
	local int i;
	for(i=0;i<MapExcludeList.Length;i++)
	{
		if(MapExcludeList[i]~=URL)
			return true;
	}
	return false;
}

defaultproperties
{
	bAddToServerPackages=True
	GroupName="KF-PickupReplace"
	FriendlyName="PickupReplaceMut"
	Description="PickupReplaceMut"
}
