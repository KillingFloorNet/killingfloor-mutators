class RPGMut extends Mutator config(RPG7DT_v2);

var config bool bGiveToAll;
var config float baseYaw,basePitch,baseRoll,baseX,baseY,baseZ;
struct ExcludedSkinsStruct
{
	var config string cSkin;
	var config float cYaw,cPitch,cRoll,cX,cY,cZ;
	var config bool cHideBag,cHideAll;
};
var config array<ExcludedSkinsStruct> ExcludedSkins;
var array<CRItem> PendingBags;

function ModifyPlayer(Pawn Player)
{
	Super.ModifyPlayer(Player);
	if(bGiveToAll) Player.GiveWeapon("RPG7DT_v2.RPG");
}


function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local RPGBackpackProj Bag;
	local PlayerReplicationInfo PRI;
	local ExcludedSkinsStruct ess;
	//Log("CheckReplacement.0"@Other);
	if(Other.IsA('CRItem'))
	{
		Bag=RPGBackpackProj(CRItem(Other).Owner);
		if(Bag==None) return true;
		PRI=KFHumanPawn(Bag.Taker).PlayerReplicationInfo;
		if(PRI==None) return true;

		if(InList(PRI.CharacterName,ess))
		{
			Bag.bHideBag=ess.cHideBag;
			Bag.bHideAll=ess.cHideAll;
			Bag.cYaw=ess.cYaw;
			Bag.cPitch=ess.cPitch;
			Bag.cRoll=ess.cRoll;
			Bag.cX=ess.cX;
			Bag.cY=ess.cY;
			Bag.cZ=ess.cZ;
		}
		else
		{
			Bag.bHideBag=false;
			Bag.bHideAll=false;
			Bag.cYaw=baseYaw;
			Bag.cPitch=basePitch;
			Bag.cRoll=baseRoll;
			Bag.cX=baseX;
			Bag.cY=baseY;
			Bag.cZ=baseZ;
		}
		
		//PendingBags[PendingBags.Length] = CRItem(Other);
		//SetTimer(0.1,false);
	}
	return true;
}

function bool InList(string CharacterName, out ExcludedSkinsStruct ess)
{
	local int i;
	for(i=0;i<ExcludedSkins.Length;i++)
	{
		if(CharacterName~=ExcludedSkins[i].cSkin)
		{
			ess=ExcludedSkins[i];
			return true;
		}
	}
	return false;
}

defaultproperties
{
	baseYaw=0
	basePitch=0
	baseRoll=1000
	baseX=10
	baseY=0
	baseZ=-10
	bGiveToAll=true
	ExcludedSkins(0)=(cSkin="commando_chicken",cYaw=0,cPitch=0,cRoll=1000,cX=10,cY=6,cZ=-10,cHideBag=False,cHideAll=False)
	bAddToServerPackages=True
	GroupName="KF-RPG7DT_v2"
	FriendlyName="RPG7DT_v2 Mutator"
	Description="Gives RPG7DT_v2 weapon to player."
}