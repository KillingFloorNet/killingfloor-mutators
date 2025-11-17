class MutServerAds extends Mutator config(MutServerAds);

var bool bInitialized;
var int iCurPos;

var config string sMessage[64];
var config int iMessagesTotal;

var config bool bEnabled;
var config float fDelay;			// delay between a message (seconds)
var config int iGroupSize;			// number of lines to show at one
var config int iAdType;				// the way to display lines
var config bool bWrapAround;		// at the end of the list, start at the beginning

var config int iAdminMsgDuration;	// seconds that an "admin" message will stay visible
var config color cAdminMsgColor;	// color of the admin messages

//  iAdType - description
//  0	display iGroupSize number at the time
//  1	display iGroupSize number of _random_ lines, bWrapAround has no effect
//  2	display iGroupSize number at the time, start at a random position

function PostBeginPlay()
{
	if (!bInitialized)
	{
		bInitialized = true;
		iCurPos = 0;
		SetTimer(fDelay, true);
	}
}

function UpdateTimer()
{
	SetTimer(fDelay, true);
}

event Timer()
{
	local int i;
	
	if (!bEnabled)
		return;
	
	if ((iCurPos >= iMessagesTotal) && (bWrapAround == false))
		return;
	
	switch (iAdType)
	{
		case 0: 
			for (i = 0; i < iGroupSize; i++)
			{
				if (iCurPos >= iMessagesTotal)
				{
					if (bWrapAround)
						iCurPos = 0;
					else
						return;
				}
				
				BroadcastAd(sMessage[iCurPos]);
				iCurPos++;
			}
			break;
		case 1: 
			for(i = 0; i < iGroupSize; i++)
			{
				BroadcastAd(sMessage[rand(iMessagesTotal)]);
			}
			iCurPos = 0; // to make sure bWrapAround has no effect
			break;
		case 2: 
			iCurPos = rand(iMessagesTotal); // begin at a random position
			
			for (i = 0; i < iGroupSize; i++)
			{
				if (iCurPos >= iMessagesTotal)
				{
					if (bWrapAround)
						iCurPos = 0;
					else
						return;
				}
				
				BroadcastAd(sMessage[iCurPos]);
				iCurPos++;
			}
			
			iCurPos = 0; // to make sure bWrapAround has no effect
			break;
	}
}

event BroadcastAd(coerce string Msg)
{
	if (Msg != "")
		Level.Game.Broadcast(None, Msg);
}

defaultproperties
{
	bEnabled=True
	
	fDelay=120.000000
	iGroupSize=1
	bWrapAround=True
	sMessage(0)="Hello World!"
	iMessagesTotal=1
	
	GroupName="KF-MutServerAds"
	FriendlyName="MutServerAds"
	Description=""
}