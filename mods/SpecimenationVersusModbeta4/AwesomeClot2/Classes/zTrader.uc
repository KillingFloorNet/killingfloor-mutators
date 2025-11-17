class zTrader extends TimerMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{

		return "Trader Door has Opened";

}

static function int GetFontSize(int Switch, PlayerReplicationInfo RelatedPRI1, PlayerReplicationInfo RelatedPRI2, PlayerReplicationInfo LocalPlayer)
{


	

	return default.FontSize;
}

static function GetPos(int Switch, out EDrawPivot OutDrawPivot, out EStackMode OutStackMode, out float OutPosX, out float OutPosY)
{
	OutDrawPivot = default.DrawPivot;
	OutStackMode = default.StackMode;
	OutPosX = default.PosX;

	switch( Switch )
	{
		case 1:
		case 3:
			OutPosY = 0.45;
			break;
		case 2:
		    OutPosY = 0.4;
		    break;
		case 4:
			OutPosY = 0.7;
		case 5:
			OutPosY = 0.7;
		case 6:
			OutPosY = 0.8;
			break;
	}
}

static function float GetLifeTime(int Switch)
{
	switch( switch )
	{
		case 1:
		case 3:
			return 1;
		case 2:
		    return 3;
		case 4:
			return 4;
		case 5:
			return 1.5;
		case 6:
			return 5;
	}
}

static function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	super(CriticalEventPlus).ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	//if ( Switch == 1 )
	  // 	P.QueueAnnouncement(default.WarningMessage[Rand(2)], 1, AP_InstantOrQueueSwitch, 1);
}

static function RenderComplexMessage(
	Canvas Canvas,
	out float XL,
	out float YL,
	optional string MessageString,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local int i;
	local float TempY;

	i = InStr(MessageString, "|");

	TempY = Canvas.CurY;

	Canvas.FontScaleX = Canvas.ClipX / 1024.0;
	Canvas.FontScaleY = Canvas.FontScaleX;

	if ( i < 0 )
	{
		Canvas.TextSize(MessageString, XL, YL);
		Canvas.SetPos((Canvas.ClipX / 2.0) - (XL / 2.0), TempY);
		Canvas.DrawTextClipped(MessageString, false);
	}
	else
	{
		Canvas.TextSize(Left(MessageString, i), XL, YL);
		Canvas.SetPos((Canvas.ClipX / 2.0) - (XL / 2.0), TempY);
		Canvas.DrawTextClipped(Left(MessageString, i), false);

		Canvas.TextSize(Mid(MessageString, i + 1), XL, YL);
		Canvas.SetPos((Canvas.ClipX / 2.0) - (XL / 2.0), TempY + YL);
		Canvas.DrawTextClipped(Mid(MessageString, i + 1), false);
	}

	Canvas.FontScaleX = 1.0;
	Canvas.FontScaleY = 1.0;
}

defaultproperties
{
     bComplexString=True
     DrawColor=(G=0)
     FontSize=5
}
