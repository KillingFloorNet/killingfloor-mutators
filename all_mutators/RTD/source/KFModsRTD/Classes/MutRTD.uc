//-----------------------------------------------------------
//
//-----------------------------------------------------------
class MutRTD extends Mutator dependson (KFModsChatter);

#exec OBJ LOAD FILE=SantaHatMesh.usx
#exec OBJ LOAD FILE=../StaticMeshes/SantaHatMesh.usx
#exec OBJ LOAD FILE=KFModsRTD/StaticMeshes/SantaHatMesh.usx
#exec OBJ LOAD FILE=SantaHatMesh.usx

var globalconfig array<class<RTDFaceBase> > Faces; //List of dice 'faces' available by RTD

var RTDListener Listener;
var globalconfig float RerollTime;
var localized string PropsDisplayText[20];
var localized string PropsDescText[20];

var globalconfig float ChanceForVeryGood, ChanceForGood, ChanceForBad, ChanceForVeryBad, ChanceForNeutral, ChanceForGlobalGood, ChanceForGlobalBad;

function PreBeginPlay()
{
    AddToPackageMap("KFModsRTDBase");
    Super.PreBeginPlay();
}
function PostBeginPlay()
{
    local int i;
    local bool a,b,c,d,e, f, g;
    a = false;
    b= false;
    c=false;
    d=false;
    e=false;
    f=false;
    g=false;


    // Check what kind of dice faces we have
    for (i = 0;i < faces.length;i++)
    {

        if (Faces[i].default.FaceType == 0)
        {
            a = true;
            continue;
        }
        if (faces[i].default.FaceType == 1)
        {
            b = true;
            continue;
        }
        if (faces[i].default.FaceType == 2)
        {
            c = true;
            continue;
        }
        if (faces[i].default.FaceType == 3)
        {
            d = true;
            continue;
        }
        if (faces[i].default.FaceType == 4)
        {
            e = true;
            continue;
        }
        if (faces[i].default.FaceType == 5)
        {
            f = true;
            continue;
        }
        if (faces[i].default.FaceType == 6)
        {
            g = true;
            continue;
        }
    }

    if (!a)
        ChanceForVeryGood = 0;
    if (!b)
        ChanceForGood = 0;
    if (!c)
        ChanceForBad = 0;
    if (!d)
        ChanceForVeryBad = 0;
    if (!e)
        ChanceForNeutral = 0;
    if (!f)
        ChanceForGlobalGood = 0;
    if (!g)
        ChanceForGlobalBad = 0;

    SetTimer(1.0, false);
}

function class<RTDFaceBase> GetRandomFaceByType(int type)
{
    local array<class<RTDFaceBase> > theFaces;
    local int i;

    Log("Get:"@type);
    for (i = 0;i < Faces.length;i++)
    {
        if (Faces[i].default.FaceType == type)
        {
            theFaces.length = theFaces.length + 1;
            theFaces[theFaces.length-1] = Faces[i];
        }
    }

    Log("Size :"@theFaces.length);
    return theFaces[Rand(theFaces.length)];
}

function int GetRandomType()
{
    local float total;
    local float rnd;
    local float VeryGood, Good, Bad, VeryBad, Neutral, GlobalGood, GlobalBad;

    VeryGood =  ChanceForVeryGood;
    Good =  ChanceForGood;
    Bad =  ChanceForBad;
    VeryBad =  ChanceForVeryBad;
    Neutral =  ChanceForNeutral;
    GlobalGood =  ChanceForGlobalGood;
    GlobalBad =  ChanceForGlobalBad;

    total = ChanceForVeryGood + ChanceForGood + ChanceForBad + ChanceForVeryBad + ChanceForNeutral + ChanceForGlobalGood + ChanceForGlobalBad;

    Good += VeryGood;
    Bad += Good;
    VeryBad += Bad;
    Neutral += VeryBad;
    GlobalGood += Neutral;
    GlobalBad += GlobalGood;

    rnd = 1+Rand(total);

    if (rnd <= VeryGood)
        return 0;
    if (rnd <= Good)
        return 1;
    if (rnd <= Bad)
        return 2;
    if (rnd <= VeryBad)
        return 3;
    if (rnd <= Neutral)
        return 4;
    if (rnd <= GlobalGood)
        return 5;
    if (rnd <= GlobalBad)
        return 6;

    return 4;
}
function Timer()
{
    // We need to wait until the mutchatter is loaded :)
    if ((class'MutChatter'.static.IsLoaded()) && (Listener == None))
    {
        Listener = Spawn(class'RTDListener', self);
        Listener.Mutator = self;
        class'MutChatter'.static.AddListener(Listener);

        return;
    }
    SetTimer(1.0, false);
}

static function MessagePlayer( PlayerController C, string Msg)
{
    Msg = right(Msg,len(Msg)-1);
    C.ClearProgressMessages();
	C.SetProgressTime(6);
	C.SetProgressMessage(0, Msg, class'Canvas'.Static.MakeColor(255,255,255));
}
function RollRequested(PlayerReplicationInfo PRI)
{
    local InvRolledRecently RR;
    local KFPlayerReplicationInfo KFPRI;
    local KFHumanPawn HPX;
    local KFHumanPawn HP;
    local class<RTDFaceBase> RTD;
    local int rndType;
    local int seconds;
    if (Faces.Length == 0)
        return;

    KFPRI =  KFPlayerReplicationInfo(PRI);
    if (KFPRI == None)
        return;

	ForEach DynamicActors( class 'KFHumanPawn', HPX )
	{
		if (HPX.PlayerReplicationInfo == KFPRI)
		{
		  HP = HPX;
		  break;
        }
	}

	if (HP == None)
	   return;

    RR = InvRolledRecently(HP.FindInventoryType(class'InvRolledRecently'));

    if (RR == None)
    {
        RR = HP.spawn(class'InvRolledRecently', HP,,,rot(0,0,0));
	    RR.GiveTo(HP);
        RR.InitTimer(RerollTime);

        rndType = GetRandomType();
        RTD = GetRandomFaceByType(rndType);

        RTD.static.ModifyPawn(HP);
        Level.Game.Broadcast(HP, "rolls the dice and ..."@RTD.default.CurrentMessage, 'Say');

        MessagePlayer(PlayerController(HP.Controller), ""@RTD.default.CurrentPersonalMessage);
        return;
    }else{
        seconds = (RR.TTL-RR.TimeLived);
        MessagePlayer(PlayerController(HP.Controller), " You already rolled the dice recently. Please, try again in"@seconds@"second(s)");
    }
}

static function string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "Faces":	            return default.PropsDescText[0];
		case "ChanceForVeryGood":	return default.PropsDescText[1];
		case "ChanceForGood":	    return default.PropsDescText[2];
		case "ChanceForBad":	    return default.PropsDescText[3];
		case "ChanceForVeryBad":	return default.PropsDescText[4];
		case "ChanceForNeutral":	return default.PropsDescText[5];
		case "ChanceForGlobalGood":	return default.PropsDescText[6];
		case "ChanceForGlobalBad":	return default.PropsDescText[7];
		case "RerollTime":        	return default.PropsDescText[8];
	}
}

// ChanceForVeryGood, ChanceForGood, ChanceForBad, ChanceForVeryBad, ChanceForNeutral;
static function FillPlayInfo(PlayInfo PlayInfo)
{

	Super.FillPlayInfo(PlayInfo);

	Log("MutRTD::FillPlayInfo()");
	PlayInfo.AddSetting("RollTheDice", "Faces", default.PropsDisplayText[0], 1, 15, "Text",,,, true);

	PlayInfo.AddSetting("RollTheDice", "ChanceForVeryGood", default.PropsDisplayText[1], 3, 10, "Text", "14;0.0:100.0",,, true);
	PlayInfo.AddSetting("RollTheDice", "ChanceForGood", default.PropsDisplayText[2], 4, 10, "Text", "30;0.0:100.0",,, true);
	PlayInfo.AddSetting("RollTheDice", "ChanceForBad", default.PropsDisplayText[3], 5, 10, "Text", "30;0.0:100.0",,, true);
	PlayInfo.AddSetting("RollTheDice", "ChanceForVeryBad", default.PropsDisplayText[4], 6, 10, "Text", "9;0.0:100.0",,, true);
	PlayInfo.AddSetting("RollTheDice", "ChanceForNeutral", default.PropsDisplayText[5], 7, 10, "Text", "10;0.0:100.0",,, true);
	PlayInfo.AddSetting("RollTheDice", "ChanceForGlobalGood", default.PropsDisplayText[6], 7, 10, "Text", "4;0.0:100.0",,, true);
	PlayInfo.AddSetting("RollTheDice", "ChanceForGlobalBad", default.PropsDisplayText[7], 7, 10, "Text", "3;0.0:100.0",,, true);

	PlayInfo.AddSetting("RollTheDice", "RerollTime", default.PropsDisplayText[8], 2, 10, "Text", "90;0:3600",,, true);
}

defaultproperties
{
     Faces(0)=Class'KFModsRTD.RTDAddMoney'
     Faces(1)=Class'KFModsRTD.RTDTakeAllMoney'
     Faces(2)=Class'KFModsRTD.RTDGodMode'
     Faces(3)=Class'KFModsRTD.RTDSpawnClot'
     Faces(4)=Class'KFModsRTD.RTDSpawnFleshPound'
     Faces(5)=Class'KFModsRTD.RTDSpawnFleshPounds'
     Faces(6)=Class'KFModsRTD.RTDAddAmmo'
     Faces(7)=Class'KFModsRTD.RTDRefillAmmo'
     Faces(8)=Class'KFModsRTD.RTDHPRegen'
     Faces(9)=Class'KFModsRTD.RTDSantaHat'
     RerollTime=90.000000
     PropsDisplayText(0)="Dice Faces (Possible specials)"
     PropsDisplayText(1)="Chances - Very Good"
     PropsDisplayText(2)="Chances - Good"
     PropsDisplayText(3)="Chances - Bad"
     PropsDisplayText(4)="Chances - Very Bad"
     PropsDisplayText(5)="Chances - Neutral"
     PropsDisplayText(6)="Chances - Global Good"
     PropsDisplayText(7)="Chances - Global Bad"
     PropsDisplayText(8)="Time between rolls"
     PropsDescText(0)="A list of classes that represent all faces of the dice. This allows mod makers to easily add new mutators!"
     PropsDescText(1)="Chance that the player gains a very good advantage (godmode, ...)"
     PropsDescText(2)="Chance that the player gains a good advantage"
     PropsDescText(3)="Chance that the player gains a bad advantage"
     PropsDescText(4)="Chance that the player gains a very bad advantage (death, lose all money, ...)"
     PropsDescText(5)="Chance that the player gains a neutral advantage/disadvantag (player gets party hats, glows, ...)"
     PropsDescText(6)="Chance that the player gains a good advantage for all (or multiple) players"
     PropsDescText(7)="Chance that the player gains a bad advantage for all (or multiple) players"
     PropsDescText(8)="The time before the player can roll again after rolling before. Be aware: On respawn players can always reroll!"
     ChanceForVeryGood=14.000000
     ChanceForGood=30.000000
     ChanceForBad=30.000000
     ChanceForVeryBad=9.000000
     ChanceForNeutral=10.000000
     ChanceForGlobalGood=4.000000
     ChanceForGlobalBad=3.000000
     bAddToServerPackages=True
     GroupName="KF-RTD"
     FriendlyName="Roll The Dice!"
     Description="Players can say !rtd every x seconds to roll the dice. This could give them a bonus or punishment!"
}
