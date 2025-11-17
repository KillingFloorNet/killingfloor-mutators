class GiveWeaponByIDMut extends Mutator config(GiveWeaponByIDMut);

struct VipStruct
{
	var config string PlayerID;
	var config string PerkIndex;
	var config string PlayerName;
	var config string SpecialWeapon;
};

var config array<VipStruct> VipList;

function PostBeginPlay()
{
	SaveConfig();
}

function ModifyPlayer(Pawn P)
{
	Super.ModifyPlayer(P);
	TryGiveSpecialWeapon(P);
}

function TryGiveSpecialWeapon(Pawn P)
{
	local KFPlayerReplicationInfo KFPRI;
	local PlayerController PC;
	local string PerkIndex;
	local string Hash;
	local int i;
	if(P==None) return;
	KFPRI=KFPlayerReplicationInfo(P.PlayerReplicationInfo);
	PC=PlayerController(P.Controller);
	if(PC==None) return;
	Hash=PC.GetPlayerIDHash();
	if(KFPRI!=None)
	{
		PerkIndex=string(KFPRI.ClientVeteranSkill.default.PerkIndex);
	}
	for(i=0;i<VipList.Length;i++)
	{
		if(VipList[i].PlayerID~=Hash && VipList[i].PerkIndex~=PerkIndex)
		{
			P.GiveWeapon(VipList[i].SpecialWeapon);
		}
	}
}

defaultproperties
{
     VipList(0)=(PlayerID="76561198051378",PlayerName="Flame",PerkIndex="4",SpecialWeapon="KFMod.Katana")
     bAddToServerPackages=True
     GroupName="KF-GiveWeaponByIDMut"
     FriendlyName="GiveWeaponByIDMut"
     Description="Give Weapon By ID"
}