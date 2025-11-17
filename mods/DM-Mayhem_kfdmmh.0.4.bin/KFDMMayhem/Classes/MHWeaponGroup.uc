class MHWeaponGroup extends Object;

var int weight; // The weight of the group when randomly calculating which group to use
var int weightTotal; // Total weight of receiver's pickup classes
var int pickupWeight[8]; // Weight of each pickup class when deciding which one to use
var class<KFWeaponPickup> pickupClasses[8]; // Pickup classes this group is able to spawwn

event Created()
{
	local int index;

	for( index = 0 ; index < ArrayCount( pickupClasses ) ; index++ )
	{
		if( pickupClasses[index] == none ) break;
		weightTotal+=pickupWeight[index];
	}
	log( "RLOG: Group weight = " @ weight );
	log( "RLOG: Group total weapon wieght = " @ weightTotal );
}

function class<KFWeaponPickup> weaponPickupClassToUse()
// Returns the pickup class to spawn
{
	local int randomIndex,tally,index;

	randomIndex = rand( weightTotal + 1 );
	tally = pickupWeight[0];

	while ( tally < randomIndex )
	{
		index++;
		Tally += pickupWeight[index];
	}
	log( "RLOG: pickupClass = " @ pickupClasses[index] );
	return pickupClasses[index];
}

defaultproperties
{
     Weight=3
}
