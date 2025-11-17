class SecurePairMut extends Mutator config(SecurePairMut);

var array<PlayerController> PendingPlayers;

struct SecurePairStruct
{
	var config string PlayerID;
	var config string PlayerName;
	var config string PlayerIP;
};
var config array<SecurePairStruct> SecurePairList;
var config int ComparedBlocks;
var config string ForumLink;

function PostBeginPlay()
{
	SaveConfig();
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if( PlayerController(Other)!=None )
	{
		PendingPlayers[PendingPlayers.Length] = PlayerController(Other);
		SetTimer(0.1,false);
	}
	return true;
}

function Timer()
{
	local string PlayerID,PlayerIP,PlayerName,tmpString;
	while( PendingPlayers.Length>0 )
	{
		PlayerID=PendingPlayers[0].GetPlayerIDHash();
		Divide(PendingPlayers[0].GetPlayerNetworkAddress(),":",PlayerIP,tmpString);
		PlayerName=PendingPlayers[0].PlayerReplicationInfo.PlayerName;
		if(IPIsDifferent(PlayerID,PlayerIP,ComparedBlocks))
			CallMessageBox(PendingPlayers[0]);
		PendingPlayers.Remove(0,1);
	}
}

function bool IPIsDifferent(string PlayerID, string PlayerIP, int N)
{
	local int i;
	local int counter;
	for(i=0;i<SecurePairList.Length;i++)
	{
		if(SecurePairList[i].PlayerID~=PlayerID)
		{
			if(SimilarIP(SecurePairList[i].PlayerIP,PlayerIP,N))
				return false;
			else
				counter++;
		}
	}
	if(counter>0)
		return true;
	return false;
}

function bool SimilarIP(string PlayerIP1, string PlayerIP2, int N)
{
	local array<string> ip1,ip2;
	local int i;
	Split(PlayerIP1, ".", ip1);
	Split(PlayerIP2, ".", ip2);
	for(i=0;i<N;i++)
	{
		if(ip1[i]!=ip2[i])
			return false;
	}
	return true;
}

function CallMessageBox(PlayerController PC)
{
	KFPlayerController(PC).ClientOpenMenu("SecurePairMut.SecurePairMessage",,ForumLink);
}

defaultproperties
{
	ComparedBlocks=2
	ForumLink="http://killingfloor.ru/forum/index.php?/topic/4119-priviazka-ip-ili-serii-ip-k-odnomu-id-otsekaem-chiterov/"
	SecurePairList(0)=(PlayerName="Flame",PlayerID="76561197960265728",PlayerIP="123.121.126.112")
	bAddToServerPackages=True
	GroupName="KF-SecurePair"
	FriendlyName="SecurePair"
	Description="SecurePair"
}
