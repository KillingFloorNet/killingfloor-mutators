
class VoodooDoll_AnimInfo extends ReplicationInfo
	hidecategories(Movement,Collision,Lighting,LightColor,Karma,Force);

var bool bInited;

replication
{
	// Replication block:1
	reliable if(Role == 4)
		ClientLinkAnim, bInited;
}

simulated function ClientLinkAnim(Pawn Player)
{
	// End:0x33 Loop:False
	if(!Player.HasAnim('Attack1_VDoll'))
	{
		Player.LinkSkelAnim(class'VoodooDoll'.default.CustomAnim);
	}
	Log("link anim called" @ string(Player));
}

function Timer()
{
	ClientLinkAnim(Pawn(Owner));
}

function LinkAnim(Pawn Player)
{
	SetTimer(0.10, false);
}
