class KFRandMut extends Mutator
	config(KFRandMut);

const NUM_Monsters = 10;

struct SRandMonster {
	var class<KFMonster> ZedClass;
	var class<KFMonster> RandClass;
	var MeshAnimation MeshAnim;
};

var SRandMonster RandMonsters[NUM_Monsters];
var config array<string> EventSuffixes;
var config bool bRegular, bCircus, bHalloween, bXmas;

/* ======================================
 * Mutator's config page.
 ======================================== */

static function FillPlayInfo(PlayInfo PlayInfo) {
	Super.FillPlayInfo(PlayInfo);
	
	PlayInfo.AddSetting("Random Models", "bRegular", "Regular zeds", 0, 0, "Check");
	PlayInfo.AddSetting("Random Models", "bCircus", "Summer zeds", 0, 1, "Check");
	PlayInfo.AddSetting("Random Models", "bHalloween", "Halloween zeds", 0, 2, "Check");
	PlayInfo.AddSetting("Random Models", "bXmas", "Christmas zeds", 0, 3, "Check");
}

static event string GetDescriptionText(string Property) {
	switch (Property) {
		case "bRegular":
			return "Use regular zeds.";
		case "bCircus":
			return "Use Summer zeds.";
		case "bHalloween":
			return "Use Halloween zeds.";
		case "bXmas":
			return "Use Christmas zeds.";
		default:
			return Super.GetDescriptionText(Property);
	}
}

/* ======================================
 * Replace squads and precache materials.
 ======================================== */

function PostBeginPlay() {
	local KFGameType GT;
	local class<KFRandMonstersCollection> MColl;
	local byte i;

	Super.PostBeginPlay();
	
	GT = KFGameType(Level.Game);
	if (GT != None) {
		MColl = class'KFRandMonstersCollection';
		for (i = 0; i < MColl.default.MonsterClasses.length; i++) {
			ReplaceClassName(MColl.default.MonsterClasses[i].MClassName);
		}
		
		ReplaceSquadArray(MColl.default.SpecialSquads);
		ReplaceSquadArray(MColl.default.ShortSpecialSquads);
		ReplaceSquadArray(MColl.default.NormalSpecialSquads);
		ReplaceSquadArray(MColl.default.LongSpecialSquads);
		ReplaceSquadArray(MColl.default.FinalSquads);
		
		ReplaceClassName(MColl.default.FallbackMonsterClass);
		ReplaceClassName(MColl.default.EndGameBossClass);
				
		GT.MonsterCollection = MColl;
		for (i = 0; i < GT.SpecialEventMonsterCollections.length; i++) {
			GT.SpecialEventMonsterCollections[i]= MColl;
		}
		
		UpdateEventSuffixes();
	}
}

static function class<KFMonster> GetReplaceClass(class<KFMonster> MC) {
	local byte i;
	
	for (i = 0; i < NUM_Monsters; i++) {
		if (ClassIsChildOf(MC, default.RandMonsters[i].ZedClass)) {
			return default.RandMonsters[i].RandClass;
		}
	}
	
	return MC;
}

function ReplaceClassName(out string ClassName) {
	local class<KFMonster> OldClass, NewClass;
	
	OldClass = class<KFMonster>(DynamicLoadObject(ClassName, class'Class'));
	if (OldClass != None) {
		NewClass = GetReplaceClass(OldClass);
		if (NewClass != None) {
			ClassName = string(NewClass);
		}
	}
}

function ReplaceSquadArray(out array<KFMonstersCollection.SpecialSquad> SquadArray) {
	local int i, j;
	
	for(i = 0; i < SquadArray.length; i++) {
		for(j = 0; j < SquadArray[i].ZedClass.length; j++) {
			ReplaceClassName(SquadArray[i].ZedClass[j]);
		}
	}
}

simulated function UpdateEventSuffixes() {
	local class<KFMonster> MC;

	ClearConfig("EventSuffixes");
	
	if (bCircus) {
		MC = class<KFMonster>(DynamicLoadObject("KFChar.ZombieClot_CIRCUS", class'Class', true));
		if (MC != None) {
			EventSuffixes[EventSuffixes.length] = "_CIRCUS";
		}
	}
	
	if (bHalloween) {
		MC = class<KFMonster>(DynamicLoadObject("KFChar.ZombieClot_HALLOWEEN", class'Class', true));
		if (MC != None) {
			EventSuffixes[EventSuffixes.length] = "_HALLOWEEN";
		}
	}
	
	if (bXmas) {
		MC = class<KFMonster>(DynamicLoadObject("KFChar.ZombieClot_XMAS", class'Class', true));
		if (MC != None) {
			EventSuffixes[EventSuffixes.length] = "_XMAS";
		}
	}
	
	if (bRegular || EventSuffixes.length == 0) {
		EventSuffixes[EventSuffixes.length] = "_STANDARD";
	}
	
	SaveConfig();
}

simulated function UpdatePrecacheMaterials() {
	local class<KFMonster> MC;
	local string S;
	local byte i, j;
	
	for (i = 0; i < EventSuffixes.length; i++) {
		for (j = 0; j < NUM_Monsters - 1; j++) {
			S = string(RandMonsters[j].ZedClass) $ EventSuffixes[i];
			MC = class<KFMonster>(DynamicLoadObject(S, class'Class', true));
			if (MC != None) {
				MC.static.PreCacheAssets(Level);
			}
		}
	}
}

/* ======================================
 * Static functions called in zed classes.
 ======================================== */

static function class<KFMonster> GetRandClass(class<KFMonster> MC) {
	local class<KFMonster> RC;
	local string S;
	local byte i, j;
	
	j = NUM_Monsters - 1;
	i = Rand(j);
	if (ClassIsChildOf(MC, default.RandMonsters[i].ZedClass)) {
		i = ++i % j;
	}
	
	if (ClassIsChildOf(MC, class'KFChar.ZombieBoss') && default.RandMonsters[i].ZedClass.default.bLeftArmGibbed) {
		i = ++i % j;
	}

	j = Rand(default.EventSuffixes.length);	
	S = string(default.RandMonsters[i].ZedClass) $ default.EventSuffixes[j];
	RC = class<KFMonster>(DynamicLoadObject(S, class'Class', true));
	if (RC != None) {
		return RC;
	}
	
	return default.RandMonsters[i].ZedClass;
}

static function MeshAnimation GetMeshAnimation(class<KFMonster> MC) {
	local byte i;
	
	for (i = 0; i < NUM_Monsters; i++) {
		if (ClassIsChildOf(MC, default.RandMonsters[i].ZedClass)) {
			return default.RandMonsters[i].MeshAnim;
		}
	}
	
	return None;
}

static function Material GetSkinMaterial(class<KFMonster> MC, byte skinIndex) {
	if (skinIndex >= MC.default.Skins.length) {
		return None;
	}
	
	if (ClassIsChildOf(MC, class'KFChar.ZombieStalker')) {
		if (string(MC) ~= "KFChar.ZombieStalker_CIRCUS") {
			if (skinIndex == 0) {
				return Combiner(DynamicLoadObject("KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_CIRCUS_CMB", class'Combiner', true));
			}
			else {
				return FinalBlend(DynamicLoadObject("KF_Specimens_Trip_CIRCUS_T.stalker_CIRCUS.stalker_CIRCUS_fb", class'FinalBlend', true));
			}
		}
		else if (string(MC) ~= "KFChar.ZombieStalker_HALLOWEEN") {
			return Combiner(DynamicLoadObject("KF_Specimens_Trip_HALLOWEEN_T.stalker.stalker_RedneckZombie_CMB", class'Combiner', true));
		}
		else if (string(MC) ~= "KFChar.ZombieStalker_XMAS") {
			if (skinIndex == 0) {
				return Combiner(DynamicLoadObject("KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_cmb", class'Combiner', true));
			}
			else {
				return FinalBlend(DynamicLoadObject("KF_Specimens_Trip_XMAS_T.StalkerClause.StalkerClause_fb", class'FinalBlend', true));
			}
		}
		
		if (skinIndex == 0) {
			return Combiner(DynamicLoadObject("KF_Specimens_Trip_T.stalker_cmb", class'Combiner', true));
		}
		else {
			return FinalBlend(DynamicLoadObject("KF_Specimens_Trip_T.stalker_fb", class'FinalBlend', true));
		}
	}
	
	
	return MC.default.Skins[skinIndex];
}

static function vector GetPrepivot(class<KFMonster> MC) {
	if (ClassIsChildOf(MC, class'KFChar.ZombieCrawler')) {
		return Vect(0, 0, 26);
	}
	
	return MC.default.Prepivot;
}

static function vector GetPrepivotDelta(class<KFMonster> MC) {
	if (ClassIsChildOf(MC, class'KFChar.ZombieCrawler')) {
		return Vect(0, 0, -26);
	}
	
	return Vect(0, 0, 0);
}

defaultproperties {
	GroupName="KFRandMut"
	FriendlyName="Random Models"
	Description="Gives each specimen a random model."
	bAddToServerPackages=true
	bRegular=true
	RandMonsters(0)=(ZedClass=class'KFChar.ZombieClot',RandClass=class'KFRandMut.ZombieClot_RAND',MeshAnim=MeshAnimation'KF_Freaks_Trip.Clot_Anim')
	RandMonsters(1)=(ZedClass=class'KFChar.ZombieGorefast',RandClass=class'KFRandMut.ZombieGorefast_RAND',MeshAnim=MeshAnimation'KF_Freaks_Trip.GoreFast_Anim')
	RandMonsters(2)=(ZedClass=class'KFChar.ZombieBloat',RandClass=class'KFRandMut.ZombieBloat_RAND',MeshAnim=MeshAnimation'KF_Freaks_Trip.Bloat_Anim')
	RandMonsters(3)=(ZedClass=class'KFChar.ZombieCrawler',RandClass=class'KFRandMut.ZombieCrawler_RAND',MeshAnim=MeshAnimation'KF_Freaks_Trip.Crawler_Anim')
	RandMonsters(4)=(ZedClass=class'KFChar.ZombieStalker',RandClass=class'KFRandMut.ZombieStalker_RAND',MeshAnim=MeshAnimation'KF_Freaks_Trip.Stalker_Anim')
	RandMonsters(5)=(ZedClass=class'KFChar.ZombieSiren',RandClass=class'KFRandMut.ZombieSiren_RAND',MeshAnim=MeshAnimation'KF_Freaks_Trip.Siren_Anim')
	RandMonsters(6)=(ZedClass=class'KFChar.ZombieHusk',RandClass=class'KFRandMut.ZombieHusk_RAND',MeshAnim=MeshAnimation'KF_Freaks2_Trip.Burns_Anim')
	RandMonsters(7)=(ZedClass=class'KFChar.ZombieScrake',RandClass=class'KFRandMut.ZombieScrake_RAND',MeshAnim=MeshAnimation'KF_Freaks_Trip.Scrake_Anim')
	RandMonsters(8)=(ZedClass=class'KFChar.ZombieFleshPound',RandClass=class'KFRandMut.ZombieFleshPound_RAND',MeshAnim=MeshAnimation'KF_Freaks_Trip.FleshPound_Anim')
	RandMonsters(9)=(ZedClass=class'KFChar.ZombieBoss',RandClass=class'KFRandMut.ZombieBoss_RAND',MeshAnim=MeshAnimation'KF_Freaks_Trip.Patriarch_Anim')
}