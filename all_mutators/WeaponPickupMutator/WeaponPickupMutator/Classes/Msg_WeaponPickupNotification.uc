class Msg_WeaponPickupNotification extends WaitingMessage;

var localized string WeaponPickupMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local string WeaponName;
	WeaponName = KFWeaponPickup(OptionalObject).InventoryType.default.ItemName;

	switch(Switch)
	{
		case 1:
			return default.WeaponPickupMessage@WeaponName$".";
	}
}

static function int GetFontSize(int Switch, PlayerReplicationInfo RelatedPRI1, PlayerReplicationInfo RelatedPRI2, PlayerReplicationInfo LocalPlayer)
{
	return 0;
}

static function GetPos(int Switch, out EDrawPivot OutDrawPivot, out EStackMode OutStackMode, out float OutPosX, out float OutPosY)
{
	OutDrawPivot = default.DrawPivot;
	OutStackMode = default.StackMode;
	OutPosX = default.PosX;

	switch( Switch )
	{
		case 1:
			OutPosY = 0.8;
			break;
	}
}

static function float GetLifeTime(int Switch)
{
	switch( switch )
	{
		case 1:
		    return 4;
	}
}

defaultproperties
{
     WeaponPickupMessage="Press '%Use%' to pick up"
}
