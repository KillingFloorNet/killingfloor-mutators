class MHHumanPawn extends KFHumanPawn;

var sound spawnSound;

#exec OBJ LOAD FILE=KFDMMayhem.uax

exec function TossCash( int Amount )
{
	if(!MHPlayerController( controller ).bRandomItemSpawnMechanism)
		super.tossCash( amount );
}

function PlayTeleportEffect(bool bOut, bool bSound)
{
	playSound(spawnSound,SLOT_Misc,10.0,,200,,true);
}

function died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local float rating;
	local Inventory oldItem,newItem;

//	Passing inventory to controller (see also KFDMMayhem.addDefaultInventory).
	if(!MHPlayerController(controller).bRandomItemSpawnMechanism)
	{
		weapon = none;
		while(inventory != none)
		{
			oldItem = inventory;
			inventory = oldItem.inventory;
			oldItem.inventory = none;
			if(MHPlayerController(controller).lastPawnsInventory == None)
				MHPlayerController(controller).lastPawnsInventory = oldItem;
			else
				for (newItem = MHPlayerController(controller).lastPawnsInventory;newItem != none;newItem = newItem.Inventory)
					if(newItem.Inventory == None)
					{
						newItem.Inventory = oldItem;
						break;
					}
		}
	}
	else
		if(inventory != none)
			weapon = inventory.RecommendWeapon(rating);
	super.died(killer,damageType,hitLocation);
}

defaultproperties
{
     SpawnSound=Sound'KFDMMayhem.Misc.doomTeleport'
     RequiredEquipment(2)="KFDMMayhem.MHFrag"
}
