class KatanaMedicShopMut extends Mutator;

var   	array< string >		weeaShop;
var   	int 			counttimer; // how many times the timer restarted
var 	string			thisPackageName;

simulated function PostBeginPlay()
{
	local int i;
	Super.PostBeginPlay();
	
	if ((Level.NetMode != NM_Standalone)&&(Level.NetMode != NM_Client)) { 
		if (thisPackageName!="???")	
		{
			AddToPackageMap(thisPackageName); 
		}

		for (i=0; i<weeaShop.Length; i++) 
		{
			if (weeaShop[i] != "null") {
				AddToPackageMap(Mid(weeaShop[i],0,InStr(weeaShop[i],".")));
			}
		}		
	}
	SetTimer(0.1,false);
}


simulated function Timer() 
{ 
	local KFLevelRules KFLR; 
	 local int i,L;
	local class<KFWeaponPickup> WeaponPickupClass;

	

	// If the timer has restarted too often
	if ( (counttimer>30) && (Level.NetMode != NM_Client) )
	{
		CreateLevelRules();
	}
	else
	{
		counttimer++;
	}
	
	// Get KFLevelRules actor if it's available 
	foreach DynamicActors(class'KFLevelRules', KFLR){
   
   
	// If not available, try again in a second 
	if (KFLR == none) 
	{ 
		SetTimer(1.0, false); 
		return; 
	} 
	
	for( i=0; i<weeaShop.Length; ++i ) 
	{
		if (weeaShop[i]!="null") {
			WeaponPickupClass	= class<KFWeaponPickup>(DynamicLoadObject(weeaShop[i], class'Class', true));
			if (WeaponPickupClass!=none) 
			{	
						L = KFLR.MediItemForSale.Length;
						KFLR.MediItemForSale.Length = L+1;
						KFLR.MediItemForSale[L] = WeaponPickupClass;
					
				
			}			
		}
	}
	
	}
		
	UpdateLevelRules(KFLR);
}


simulated function UpdateLevelRules (KFLevelRules KFLR) 	
{
	local int i,L;
	local class<KFWeaponPickup> WeaponPickupClass;

	for( i=0; i<weeaShop.Length; ++i ) 
	{
		if (weeaShop[i]!="null") {
			WeaponPickupClass	= class<KFWeaponPickup>(DynamicLoadObject(weeaShop[i], class'Class', true));
			if (WeaponPickupClass!=none) 
			{	
						L = KFLR.MediItemForSale.Length;
						KFLR.MediItemForSale.Length = L+1;
						KFLR.MediItemForSale[L] = WeaponPickupClass;
					
				
			}			
		}
	}
}


function CreateLevelRules () 
{
	local KFGameType KF;

	KF = KFGameType(Level.Game);

	if ( KF!=None )
	{
		if(KF.KFLRules==none)
		{
			KF.KFLRules = spawn(class'KFLevelRules');
		}
	}

}

defaultproperties
{
     weeaShop(0)="KatanaMedic.KatanaMPickup"
     thisPackageName="KatanaMedic"
     bAddToServerPackages=True
     GroupName="KF-KatanaMedic"
     FriendlyName="Katana Medic"
     Description="Add KatanaMedic to shop"
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
