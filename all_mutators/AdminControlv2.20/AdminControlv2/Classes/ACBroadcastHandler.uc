class ACBroadcastHandler extends BroadcastHandler;

var AdminControlMut MutatorOwner;

function BroadcastText( PlayerReplicationInfo SenderPRI, PlayerController Receiver, coerce string Msg, optional name Type )
{
	local ACLinkedReplicationInfo ACLRI;
	
	ACLRI = class'AdminControlMut'.Static.GetACLRI(SenderPRI);
	
	if ( ACLRI.bShutUp ) // если на нашем Sender'е висит мут, броадкаст не пропускает сообщение
	{ // В случае если CorLogMut запустит свой броадкаст раньше этого, сообщение всё равно пойдёт в лог
		if ( SenderPRI == Receiver.PlayerReplicationInfo )
		{
			Msg = "You were muted.";
		}
		else
		{
			return;
		}
	}
	
	if ( NextBroadcastHandler != None )
	{
		NextBroadcastHandler.BroadcastText( SenderPRI, Receiver, Msg, Type );
	}
	else
	{
		Receiver.TeamMessage( SenderPRI, Msg, Type );
	}
}

defaultproperties
{
}
