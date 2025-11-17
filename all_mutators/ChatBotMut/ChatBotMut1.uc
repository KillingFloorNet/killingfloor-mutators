class ChatBotMut extends Mutator Config(ChatBotConfig);

// vars
var int CurPos;
var int NumLines;

// config options
var globalconfig array<string> InfoLine; // the information lines
var globalconfig bool bDebug; // logs
var globalconfig float MsgDelay; // delay between a message (seconds)
var globalconfig int GroupSize; // number of lines to show at one
var globalconfig int AdminMsgDuration; // seconds that an "admin" message will stay visible
var globalconfig Color AdminMsgColor; // color of the admin messages

// initialise this mutator
function PostBeginPlay()
{
    Super.PostBeginPlay();
    LoadInformationList();
}

// Load info from config
function LoadInformationList()
{
    local array<string> TempLines;
    local int i;
    if(bDebug) Log("[ChatBotMut] Starting");
    // clean up list
    for(i=0; i<InfoLine.Length; i++)
    {
        if(InfoLine[i]!="")
        {
            TempLines.Insert(NumLines,1);
            TempLines[NumLines]=InfoLine[i];
            NumLines++;
        }
    }
    for(i=0; i<InfoLine.Length; i++) InfoLine[i]=TempLines[i];
    SaveConfig();
    if(bDebug) Log("[ChatBotMut] There are"@NumLines@"lines in the list");
    SetTimer(MsgDelay, True);
}

// broadcast the message
function Timer()
{
    local int i;
    for(i=0; i<GroupSize; i++)
    {
        if(CurPos>=NumLines) CurPos=0;
        SendInfoMsg(InfoLine[CurPos]);
        CurPos++;
    }
}

// send message to players
function SendInfoMsg(coerce string Msg)
{
    local PlayerController PC;
    local Controller C;
    local string TempMsg;
    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(C.IsA('PlayerController'))
        {
            PC=PlayerController(C);
            if(PC!=None)
            {
                // center print admin messages which start with #
                if(Left(Msg,1)=="#")
                {
                    Msg=Right(Msg, Len(Msg)-1);
                    PC.ClearProgressMessages();
                    PC.SetProgressTime(AdminMsgDuration);
                    PC.SetProgressMessage(0, Msg, AdminMsgColor);
                    if(bDebug) Log("[ChatBotMut] Admin Line:"@Msg);
                    Return;
                }
                if(PC.PlayerReplicationInfo!=None)
                {
                    // we don't use color for webadmin
                    if(PC.PlayerReplicationInfo.PlayerID==0)
                    {
                        TempMsg=RemoveColor(Msg);
                        PC.TeamMessage(None, TempMsg, 'Chat Bot'); // we don't use BroadcastHandler, because we don't need spam in server logs
                        if(bDebug) Log("[ChatBotMut] Line:"@TempMsg);
                    }
                    else PC.TeamMessage(None, Msg, 'Chat Bot'); // we don't use BroadcastHandler, because we don't need spam in server logs
                }
            }
        }
    }
}

function string RemoveColor(string S)
{
    local int P;
    P=InStr(S,Chr(27));
    While(P>=0)
    {
        S=Left(S,P)$Mid(S,P+4);
        P=InStr(S,Chr(27));
    }
    Return S;
}

defaultproperties
{
    bDebug=False
    MsgDelay=60.000000
    GroupSize=1
    AdminMsgDuration=5
    AdminMsgColor=(B=0,G=0,R=255,A=128)
    GroupName="KF-ChatBotMut"
    FriendlyName="Chat Bot"
    Description="Chat Bot gives you the ability to display news (or what ever kind of messages you want) on your server. Players will see these messages in their chat console. It's also possible to display so called "Admin messages"."
}