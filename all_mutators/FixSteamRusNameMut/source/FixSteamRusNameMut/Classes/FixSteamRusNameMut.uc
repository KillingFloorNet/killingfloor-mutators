class FixSteamRusNameMut extends Mutator;
var array<KFPlayerController> PendingPlayers;

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	if(KFPlayerController(Other)!=None)
	{
		PendingPlayers[PendingPlayers.Length] = KFPlayerController(Other);
		SetTimer(0.1,false);
	}
	return true;
}

function Timer()
{
	local int i;
	for(i=0;i<PendingPlayers.Length;i++)
		CheckAndFixName(PendingPlayers[i]);
	PendingPlayers.Length = 0;
}

function CheckAndFixName(KFPlayerController KFPC)
{
	local PlayerReplicationInfo PRI;
	local string playerName, fixedName;
	if(KFPC==none) return;
	PRI=KFPC.PlayerReplicationInfo;
	if(PRI==none) return;
	playerName=PRI.PlayerName;
	fixedName=ConvertSteamString(playerName);
	if(fixedName!=playerName)
		KFPC.PlayerReplicationInfo.PlayerName=fixedName;
}

function string ConvertSteamString(string msg)
{
	local int i;
	local string tmp;
	local string result;
	local int code;
	tmp=msg;
	for(i=0; i<Len(msg); i++)
	{
		code=Asc(tmp);
		if(code==1056 || code==1057)
		{
			tmp=Mid(tmp,1);
			continue;
		}
		code=FixCode(code);
		if(code>167)
			code+=848;
		if(i==0) result=Chr(code);
		else result=result$Chr(code);
		tmp=Mid(tmp,1);
	}
	return result;
}

function int FixCode(int code)
{
	switch(code)
	{
		case 176:	return 224;
		case 177:	return 225;
		case 1030:	return 226;
		case 1110:	return 227;
		case 1169:	return 228;
		case 181:	return 229;
		case 8216:	return 184;
		case 182:	return 230;
		case 183:	return 231;
		case 1105:	return 232;
		case 8470:	return 233;
		case 1108:	return 234;
		case 187:	return 235;
		case 1112:	return 236;
		case 1029:	return 237;
		case 1109:	return 238;
		case 1111:	return 239;
		case 1026:	return 240;
		case 1027:	return 241;
		case 8218:	return 242;
		case 1107:	return 243;
		case 8222:	return 244;
		case 8230:	return 245;
		case 8224:	return 246;
		case 8225:	return 247;
		case 8364:	return 248;
		case 8240:	return 249;
		case 1033:	return 250;
		case 8249:	return 251;
		case 1034:	return 252;
		case 1036:	return 253;
		case 1035:	return 254;
		case 1039:	return 255;
		case 1106:	return 192;
		case 8216:	return 193;
		case 8217:	return 194;
		case 8220:	return 195;
		case 8221:	return 196;
		case 8226:	return 197;
		case 1027:	return 168;
		case 8211:	return 198;
		case 8212:	return 199;
		case 152:	return 200;
		case 8482:	return 201;
		case 1113:	return 202;
		case 8250:	return 203;
		case 1114:	return 204;
		case 1116:	return 205;
		case 1115:	return 206;
		case 1119:	return 207;
		case 160:	return 208;
		case 1038:	return 209;
		case 1118:	return 210;
		case 1032:	return 211;
		case 164:	return 212;
		case 1168:	return 213;
		case 166:	return 214;
		case 167:	return 215;
		case 1025:	return 216;
		case 169:	return 217;
		case 1028:	return 218;
		case 171:	return 219;
		case 172:	return 220;
		case 173:	return 221;
		case 174:	return 222;
		case 1031:	return 223;
	}
	return code;
}

/*
а	176		224
б	177		225
в	1030	226
г	1110	227
д	1169	228
е	181		229
ё	8216	184
ж	182		230
з	183		231
и	1105	232
й	8470	233
к	1108	234
л	187		235
м	1112	236
н	1029	237
о	1109	238
п	1111	239
р	1026	240
с	1027	241
т	8218	242
у	1107	243
ф	8222	244
х	8230	245
ц	8224	246
ч	8225	247
ш	8364	248
щ	8240	249
ъ	1033	250
ы	8249	251
ь	1034	252
э	1036	253
ю	1035	254
я	1039	255

А	1106	192
Б	8216	193
В	8217	194
Г	8220	195
Д	8221	196
Е	8226	197
Ё	1027	168
Ж	8211	198
З	8212	199
И	152		200
Й	8482	201
К	1113	202
Л	8250	203
М	1114	204
Н	1116	205
О	1115	206
П	1119	207
Р	160		208
С	1038	209
Т	1118	210
У	1032	211
Ф	164		212
Х	1168	213
Ц	166		214
Ч	167		215
Ш	1025	216
Щ	169		217
Ъ	1028	218
Ы	171		219
Ь	172		220
Э	173		221
Ю	174		222
Я	1031	223
*/

defaultproperties
{
	bAddToServerPackages=True
	GroupName="KF-FixSteamRusName"
	FriendlyName="FixSteamRusNameMut"
	Description="FixSteamRusNameMut"
}
