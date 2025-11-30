class BossHUDInteraction extends Interaction;

// #exec obj load file=MultiplePatHPBar.utx
#exec obj load file=KF_InterfaceArt_tex.utx

var Texture BarTex, GreenProgTex, RedProgTex, MainTex, WeakTex;

var string DisplayString;
var float XL, YL;

struct BossStats
{
	var int Type;
	var int Health;
	var int HealthMax;
	var int SyringeCount;
	var int HealingLevels[3];
};

var BossStats Patriarchs[3];

event NotifyLevelChange()
{
	Master.RemoveInteraction(self);
}

simulated function SetBossStats(int Type[3], int Health[3], int HealthMax[3], int SyringeCount[3], int HealingLevels[9], string BossString)
{
	local int i, j;

	for( i = 0; i < 3; i++ )
	{	
		Patriarchs[i].Type = Type[i];
		Patriarchs[i].Health = Health[i];
		Patriarchs[i].HealthMax = HealthMax[i];
		Patriarchs[i].SyringeCount = SyringeCount[i];

		for( j = 0; j < 3; j++ )
			Patriarchs[i].HealingLevels[j] = HealingLevels[3 * i + j];
	}

	DisplayString = BossString;
}

function PreRender(Canvas C)
{
	XL = FClamp(C.SizeY, 640, 1080);
	YL = 0.02 * FClamp(C.SizeX, 480, 1920);	
}

simulated function PostRender(Canvas C)
{
	local int i;
	local float PosX, PosY;

	for ( i = 0; i < 3; i++ )
	{
		if ( Patriarchs[i].Health > 0 )
		{
			C.SetDrawColor(255, 255, 255, 255);

			PosX = 0.5 * (C.SizeX - XL);
			PosY = i * (YL + 5);

			C.CurX = PosX;
			C.CurY = PosY + 5;

			C.DrawTileStretched(BarTex, XL, YL);

			if (Patriarchs[i].SyringeCount >= && Patriarchs[i].SyringeCount <= 2)
			{
				DrawHealth(C, Patriarchs[i].Type, Patriarchs[i].Health, Patriarchs[i].HealthMax, Patriarchs[i].HealingLevels[Patriarchs[i].SyringeCount]);
			}
			else
			{
				DrawHealth(C, Patriarchs[i].Type, Patriarchs[i].Health, Patriarchs[i].HealthMax, 0);
			}

			DrawString(C, Patriarchs[i].Health, Patriarchs[i].HealthMax, Patriarchs[i].SyringeCount);
		}
	}
}

function DrawHealth(Canvas C, int Type, int Health, int HealthMax, int HealingLevel)
{
	// if( Health > HealingLevel )
	// {
	// 	C.DrawTileStretched(RedProgTex, XL * float(HealingLevel) / float(HealthMax), YL);
	// 	C.CurX += XL * float(HealingLevel) / float(HealthMax);

	// 	if( Health > HealthMax )
	// 		C.DrawTileStretched(GreenProgTex, XL * float(HealthMax - HealingLevel) / float(HealthMax), YL);
	// 	else
	// 		C.DrawTileStretched(GreenProgTex, XL * float(Health - HealingLevel) / float(HealthMax), YL);
	// }
	// else
	
	if (Type == 1)
	{
		C.DrawTileStretched(WeakTex, XL * float(Health) / float(HealthMax), YL);
	}
	else
	{
		C.DrawTileStretched(MainTex, XL * float(Health) / float(HealthMax), YL);
	}
}

function DrawString(Canvas C, int Health, int HealthMax, int SyringeCount)
{
	local string BossString;
	local float SXL, SYL;

	BossString = GetDisplayString(Health, HealthMax, SyringeCount);

	C.Font = class'HUDKillingFloor'.Static.GetConsoleFont(C);
	C.TextSize(BossString, SXL, SYL);
		
	C.CurX = (C.SizeX - SXL) / 2;
	C.CurY += (YL - SYL) / 2;

	C.DrawTextClipped(BossString);
}

function string GetDisplayString(int Health, int HealthMax, int SyringeCount)
{
	local string S;
	
	S = DisplayString;

	ReplaceText(S, "%t", string());
	
	ReplaceText(S, "%h", string(Health));
	ReplaceText(S, "%m", string(HealthMax));
	ReplaceText(S, "%p", string(100 * Health / HealthMax));
	ReplaceText(S, "%s", string(SyringeCount));

	return S;	
}

defaultproperties
{
	BarTex=Texture'KF_InterfaceArt_tex.Menu.Item_box_box_Disabled' //Texture'MultiplePatHPBar.Background'
	MainTex=Texture'KF_InterfaceArt_tex.Menu.Item_box_bar_Highlighted'
	WeakTex=Texture'KF_InterfaceArt_tex.Menu.button_pressed'
	// GreenProgTex=Texture'MultiplePatHPBar.Green'
	// RedProgTex=Texture'MultiplePatHPBar.Red'
	bVisible=True
}
