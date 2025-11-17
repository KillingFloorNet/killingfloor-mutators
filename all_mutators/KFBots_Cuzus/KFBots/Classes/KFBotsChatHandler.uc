Class KFBotsChatHandler extends BroadcastHandler;

function PostBeginPlay()
{
	NextBroadcastHandler = Level.Game.BroadcastHandler;
	Level.Game.BroadcastHandler = Self;
}

final function ProcessCommand(string CallSgn, PlayerController Sender, byte OrderID)
{
	local bool bAll;
	local int L;
	local Controller C;

	if(Sender.PlayerReplicationInfo==None || Sender.PlayerReplicationInfo.bOnlySpectator) // Spectators can't give orders.
		return;
	
	if(OrderID == 2 && (Sender.Pawn==None || Sender.Pawn.Health<=0)) // Can't give hold position order while player is dead.
		return;

	bAll = (CallSgn ~= "ALL");
	L = Len(CallSgn);

	for(C=Level.ControllerList; C!=None; C=C.nextController)
	{
		if(C.bIsPlayer && C.Class==Class'KFInvBots' 
		&& (bAll || Left(C.PlayerReplicationInfo.PlayerName,L) ~= CallSgn || C.PlayerReplicationInfo.GetCallSign() ~= CallSgn))
		{
			KFInvBots(C).OrderBot(Sender,OrderID);
			if(!bAll)
				break;
		}
	}
}

function UpdateSentText()
{
	NextBroadcastHandler.UpdateSentText();
}

function bool AllowsBroadcast( actor broadcaster, int Len )
{
	return NextBroadcastHandler.AllowsBroadcast(broadcaster,Len);
}

function BroadcastText( PlayerReplicationInfo SenderPRI, PlayerController Receiver, coerce string Msg, optional name Type )
{
	NextBroadcastHandler.BroadcastText( SenderPRI, Receiver, Msg, Type );
}

function BroadcastLocalized( Actor Sender, PlayerController Receiver, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	NextBroadcastHandler.BroadcastLocalized( Sender, Receiver, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

function Broadcast( Actor Sender, coerce string Msg, optional name Type )
{
	if( Type=='Say' && PlayerController(Sender)!=None )
	{
		if( Left(Msg,7)~="FOLLOW " )
			ProcessCommand(Mid(Msg,7),PlayerController(Sender),1);
		else if( Left(Msg,5)~="HOLD " )
			ProcessCommand(Mid(Msg,5),PlayerController(Sender),2);
		else if( Left(Msg,5)~="FREE " )
			ProcessCommand(Mid(Msg,5),PlayerController(Sender),3);
	}

	NextBroadcastHandler.Broadcast(Sender,Msg,Type);
}

function BroadcastTeam( Controller Sender, coerce string Msg, optional name Type )
{
	if( Type=='TeamSay' && PlayerController(Sender)!=None )
	{
		if( Left(Msg,7)~="FOLLOW " )
			ProcessCommand(Mid(Msg,7),PlayerController(Sender),1);
		else if( Left(Msg,5)~="HOLD " )
			ProcessCommand(Mid(Msg,5),PlayerController(Sender),2);
		else if( Left(Msg,5)~="FREE " )
			ProcessCommand(Mid(Msg,5),PlayerController(Sender),3);
	}

	NextBroadcastHandler.BroadcastTeam(Sender,Msg,Type);
}

function AllowBroadcastLocalized( actor Sender, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	NextBroadcastHandler.AllowBroadcastLocalized(Sender,Message,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
}

function RegisterBroadcastHandler(BroadcastHandler NewBH)
{
	NextBroadcastHandler.RegisterBroadcastHandler(NewBH);
}

function Destroyed();

defaultproperties
{
}