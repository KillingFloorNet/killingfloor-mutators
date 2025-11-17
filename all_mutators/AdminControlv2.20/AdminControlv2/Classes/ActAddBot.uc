class ActAddBot extends AdminCommand
	abstract;
	
static function Perform(string CommandString, AdminRecord Sender)
{
	local string Answer;
	local string BotClassName;
	local class<ACBot> BotClass;
	
	BotClassName = GetStringParam(CommandString);
	BotClass = class<ACBot>(DynamicLoadObject(BotClassName,class'Class'));
	if ( BotClass != none )
	Sender.MutatorOwner.AddBot(BotClass);
	Answer = Sender.Controller.PlayerReplicationInfo.PlayerName @ "added" @ BotClassName @ "bot.";
	CommandMessage(Sender,Answer);
}

defaultproperties
{
     HelpString(0)="addbot classname - adds a bot"
     CommandName(0)="addbot"
}
