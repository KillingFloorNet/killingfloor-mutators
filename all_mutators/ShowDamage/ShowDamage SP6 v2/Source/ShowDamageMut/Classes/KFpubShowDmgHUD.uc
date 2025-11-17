//=============================================================================
// KFpubShowDmgHUD
//=============================================================================
// Created by r1v3t
// © 2011, KFpub :: www.kfpub.com
//=============================================================================
class KFpubShowDmgHUD extends SRHUDKillingFloor;
//	config(User);

struct SHitInfo
{
	var string Text;
	var float LastHit;
};

struct Damage
{
	var int Damage;
	var float LastHit;
};

var SHitInfo SHitText[4];
var byte SHitInt;
var float RY[20];
var float RX[20];
var Damage Dam[20];
var int Dint;
var byte secondViewed;

simulated function ShowDamage(int D, float LH)
{
	RX[Dint] = 0.40 + 0.20 * FRand();
	RY[Dint] = 0.10 + 0.20 * FRand();
	Dam[Dint].damage = D;
	Dam[Dint].LastHit = LH;

	Dint++;

	if(Dint > 20)
		Dint=0;
}

simulated function HandleSHit(Canvas C)
{
	local int i;
	local int RColor, GColor, BColor;
	local byte FontSize;
	local float XPos, YPos, fadetimeB, fadetimeG, fadetimeR;

	C.Font = GetConsoleFont(C);
	for( i=0;i<3;i++)
	{
		XPos = 0.70 * C.ClipX;
		YPos = (0.90 - ((Level.TimeSeconds - SHitText[i].LastHit) / 20)) * C.ClipY;
		if(YPos <= 0.60)
			YPos = 0.60;

		if(i < 2 && 0.90 - ((Level.TimeSeconds - SHitText[i + 1].LastHit) / 20) <= 0.60 && SHitText[i + 1].Text != "" || i == 2 && 0.90 - ((Level.TimeSeconds - SHitText[0].LastHit) / 20) <= 0.60 && SHitText[0].Text != "")
			SHitText[i].Text = "";

		if(5 < Level.TimeSeconds - SHitText[i].LastHit)
			{
				SHitText[i].LastHit = 0;
				SHitText[i].Text = "";
			}
			else if(SHitText[i].Text != "")
			{
				C.SetPos(Xpos, Ypos);
				C.DrawText(SHitText[i].Text);
			}
	}

	if(C.ClipX <= float(640))
	{
		FontSize = 7;
	}
	else
	{
		if(C.ClipX <= float(800))
		{
			FontSize = 6;
		}
		else
		{
			if(C.ClipX <= float(1024))
			{
				FontSize = 5;
			}
			else
			{
				if(C.ClipX <= float(1280))
				{
					FontSize = 4;
				}
				else
				{
					FontSize = 3;
				}
			}
		}
	}

	C.Font = LoadFont(FontSize);
	for(i=0;i<20;i++)
	{

		if(5 < Level.TimeSeconds - Dam[i].LastHit)
			continue;

		C.Style = ERenderStyle.STY_Translucent;//STY_Normal
//		TWI: FF4040
        RColor = Class'KFpubShowDmg'.Default.DamageColorR;
        GColor = Class'KFpubShowDmg'.Default.DamageColorG;
        BColor = Class'KFpubShowDmg'.Default.DamageColorB;

		fadetimeR = (Level.TimeSeconds - Dam[i].LastHit) * (RColor / 5);
		fadetimeG = (Level.TimeSeconds - Dam[i].LastHit) * (GColor / 5);
		fadetimeB = (Level.TimeSeconds - Dam[i].LastHit) * (BColor / 5);

		C.SetPos( RX[i]* c.clipx, RY[i]* c.clipy);

		C.DrawColor.R = RColor - fadetimeR;
		C.DrawColor.G = GColor - fadetimeG;
		C.DrawColor.B = BColor - fadetimeB;

		C.DrawText(Dam[i].damage);
	}
}

simulated event PostRender(Canvas Canvas)
{
	super.PostRender(Canvas);
	HandleSHit(Canvas);
}
