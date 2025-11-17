class zombiePRI extends KFplayerreplicationinfo;

var Pawn ZTarget;
var Material ZPortrait;
var pawn Unseenpawn[32];
var int ClotsKilled;
var int BloatsKilled;
var int GoreFastsKilled;
var int HusksKilled;
var int crawlersKilled;
var int StalkersKilled;
var int SirensKilled;
var int ScrakesKilled;
var int FleshPoundsKilled;
var bool bReadySpecimen,bSeen, bSC, bFP;
var int Damage;

replication
{
	reliable if(bNetDirty && (Role == Role_Authority))
				Drawpawn,ZTarget,ClotsKilled,BloatsKilled
				,GoreFAstsKilled,ScrakesKilled,HusksKilled,Fleshpoundskilled
				,Stalkerskilled,SirensKilled,crawlerskilled,bReadySpecimen, damage,bseen, bSC, bFP;
}

simulated function Drawpawn(Pawn P)
{
	local int i;
	local bool T;

	
	for ( i = 0; i < 32; i++ )
	{
		if ( UnseenPawn[i] == P )
		{
			T = true;
			break;
		} 
		else if( Unseenpawn[i] == none || Unseenpawn[i]!=none && Unseenpawn[i].health <= 0)
			UnseenPawn[i] = none;
	}
	
	if( T == false)
	for ( i = 0; i < 32; i++ )
	{

		if( Unseenpawn[i] == none )
		{	
			UnseenPawn[i] = p;
			break;
		}
	}
}

defaultproperties
{
}
