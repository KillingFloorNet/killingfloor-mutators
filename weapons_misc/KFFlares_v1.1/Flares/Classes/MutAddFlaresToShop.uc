class MutAddFlaresToShop extends Mutator;

// 
// Template by BadKarMa.
// 


const PERK_NEU		= "NEU";
const PERK_MED		= "MED";
const PERK_SUP		= "SUP";
const PERK_SHA		= "SHA";
const PERK_COM		= "COM";
const PERK_BER		= "BER";
const PERK_FIR		= "FIR";
const PERK_DEM		= "DEM";

var   	array< string >		newweapons; // all new weapons (contains package.pickup)
var   	int 			counttimer; // how many times the timer restarted
var 	string			thisPackageName;

// This mutator is based on a template by BadKarMa

simulated function PostBeginPlay()
{
	local int i;
	Super.PostBeginPlay();
	if ((Level.NetMode != NM_Standalone)&&(Level.NetMode != NM_Client)) { 
		if (thisPackageName!="???")	
		{
			AddToPackageMap(thisPackageName); 
		}
		Log("Adding additional serverpackages",Class.Outer.Name);	
		for (i=0; i<newweapons.Length; i++) 
		{
			if (newweapons[i] != "null") {
				AddToPackageMap(Mid(newweapons[i],0,InStr(newweapons[i],".")));
			}
		}		
	}
	SetTimer(0.1,false);
}

simulated function Timer() 
{ 
	local KFLevelRules KFLR; 

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
	foreach DynamicActors(class'KFLevelRules', KFLR) 
	break; //finds one instance of KFLevelRules

	// If not available, try again in a second 
	if (KFLR == none) 
	{ 
		Log("Could not find KFLevelRules",Class.Outer.Name);
		SetTimer(1.0, false); 
		return; 
	} 
	else
	{
		Log("KFLevelRules found!",Class.Outer.Name);
	}

	// Update the LevelRules		
	UpdateLevelRules(KFLR);
}

simulated function UpdateLevelRules (KFLevelRules KFLR) 	
{
	local int i,L;
	local class<KFWeaponPickup> WeaponPickupClass;
	local string perk;

	Log("Updating LevelRules",Class.Outer.Name);

	for( i=0; i<newweapons.Length; ++i ) 
	{
		if (newweapons[i]!="null") {
			WeaponPickupClass	= class<KFWeaponPickup>(DynamicLoadObject(newweapons[i], class'Class', true));
			if (WeaponPickupClass!=none) 
			{	
				perk	= PerkFromClass(WeaponPickupClass); 
				switch (perk)
				{
					case PERK_NEU:
						L = KFLR.NeutItemForSale.Length;
						KFLR.NeutItemForSale.Length = L+1;
						KFLR.NeutItemForSale[L] = WeaponPickupClass;
						break;
					case PERK_MED:
						L = KFLR.MediItemForSale.Length;
						KFLR.MediItemForSale.Length = L+1;
						KFLR.MediItemForSale[L] = WeaponPickupClass;
						break;
					case PERK_SUP:
						L = KFLR.SuppItemForSale.Length;
						KFLR.SuppItemForSale.Length = L+1;
						KFLR.SuppItemForSale[L] = WeaponPickupClass;
						break;
					case PERK_SHA:
						L = KFLR.ShrpItemForSale.Length;
						KFLR.ShrpItemForSale.Length = L+1;
						KFLR.ShrpItemForSale[L] = WeaponPickupClass;
						break;
					case PERK_COM:
						L = KFLR.CommItemForSale.Length;
						KFLR.CommItemForSale.Length = L+1;
						KFLR.CommItemForSale[L] = WeaponPickupClass;
						break;
					case PERK_BER:
						L = KFLR.BersItemForSale.Length;
						KFLR.BersItemForSale.Length = L+1;
						KFLR.BersItemForSale[L] = WeaponPickupClass;
						break;
					case PERK_FIR:
						L = KFLR.FireItemForSale.Length;
						KFLR.FireItemForSale.Length = L+1;
						KFLR.FireItemForSale[L] = WeaponPickupClass;
						break;
					case PERK_DEM:
						L = KFLR.DemoItemForSale.Length;
						KFLR.DemoItemForSale.Length = L+1;
						KFLR.DemoItemForSale[L] = WeaponPickupClass;
						break;
				}
				Log("Added weapon "$WeaponPickupClass$" for "$perk$"! ",Class.Outer.Name);
			}			
		}
	}
}

function CreateLevelRules () 
{
	local KFGameType KF;

	Log("Checking LevelRules",Class.Outer.Name);

	KF = KFGameType(Level.Game);

	if ( KF!=None )
	{
		if(KF.KFLRules==none)
		{
			Log("Unable to find LevelRules - creating default rules",Class.Outer.Name);
			KF.KFLRules = spawn(class'KFLevelRules');
		}
	}
	else 
	{
		Log("Unable to find KFGameType",Class.Outer.Name);
	}
}

static function string PerkFromClass(class<KFWeaponPickup> wClass)
{
	local byte p;
	p = wClass.default.CorrespondingPerkIndex;
	switch (p)
	{
		case 0:
			return PERK_MED ;
		case 1:
			return PERK_SUP ;
		case 2:
			return PERK_SHA ;
		case 3:
			return PERK_COM ;
		case 4:
			return PERK_BER ;
		case 5:
			return PERK_FIR ;
		case 6:
			return PERK_DEM ;
		case 7:
			return PERK_NEU ;
	}
	return PERK_NEU;
}

defaultproperties
{
     newweapons(0)="Flares.FlarePickup"
     thisPackageName="???"
     bAddToServerPackages=True
     GroupName="KF-FlaresShop"
     FriendlyName="Flares MuTrader"
     Description="This mutator adds the Emergency Flares to the trader menu "
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
