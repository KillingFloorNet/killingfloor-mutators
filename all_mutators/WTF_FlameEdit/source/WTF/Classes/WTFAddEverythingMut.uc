class WTFAddEverythingMut extends Mutator;

function ModifyPlayer(Pawn Player)
{
	Super.ModifyPlayer(Player);
	Player.GiveWeapon("WTF.WTFEquipAFS12a");
	Player.GiveWeapon("WTF.WTFEquipAK48S");
	Player.GiveWeapon("WTF.WTFEquipBanHammer");
	Player.GiveWeapon("WTF.WTFEquipBoomStick");
	Player.GiveWeapon("WTF.WTFEquipBulldog");
	Player.GiveWeapon("WTF.WTFEquipChainsaw");
	Player.GiveWeapon("WTF.WTFEquipCrossbow");
	Player.GiveWeapon("WTF.WTFEquipFT");
	Player.GiveWeapon("WTF.WTFEquipFireAxe");
	Player.GiveWeapon("WTF.WTFEquipFlaregun");
	Player.GiveWeapon("WTF.WTFEquipGlowstick");
	Player.GiveWeapon("WTF.WTFEquipKatana");
	Player.GiveWeapon("WTF.WTFEquipLethalInjection");
	Player.GiveWeapon("WTF.WTFEquipM79CF");
	Player.GiveWeapon("WTF.WTFEquipMP7M2a");
	Player.GiveWeapon("WTF.WTFEquipMachineDualies");
	Player.GiveWeapon("WTF.WTFEquipPipeBomb");
	Player.GiveWeapon("WTF.WTFEquipRocketLauncher");
	Player.GiveWeapon("WTF.WTFEquipSA80a");
	Player.GiveWeapon("WTF.WTFEquipSCAR19a");
	Player.GiveWeapon("WTF.WTFEquipSawedOffShotgun");
	Player.GiveWeapon("WTF.WTFEquipSelfDestruct");
	Player.GiveWeapon("WTF.WTFEquipShotgun");
	Player.GiveWeapon("WTF.WTFEquipUM32a");
	Player.GiveWeapon("WTF.WTFEquipWelda");
}

defaultproperties
{
	bAddToServerPackages=True
	GroupName="KF-WTFAddEverything"
	FriendlyName="WTFAddEverythingMut"
	Description="WTFAddEverythingMut"
}
