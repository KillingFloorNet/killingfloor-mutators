class MCMonsterInfo extends MCObject
	ParseConfig
	PerObjectConfig
	config(MonsterConfig);
	
// сколько хп добавлять к мобу за каждого игрока
struct PerPlayerSettings
{
	var int Health;
	var int HeadHealth;
};
// настройки резиста к дамагу
struct ResistSettings
{
	var class<DamageType>	DamType;
	var float				Coeff;
	var bool				bNotCheckChild;
};

// непосредственно то, что будет в конфиге
var config array< class<KFMonster> > MonsterClass;
var config int					Health, HeadHealth;
var config int					HealthMax, HeadHealthMax;
var config int 					Speed;
var config float				SpeedMod;
var config string				MonsterName;//редефайн, чтобы в KillMessages писало по своему
var config PerPlayerSettings	PerPlayer;	//PerPlayerAdd=(Health=10, HeadHealth=2)
var config array<ResistSettings> Resist;	//Resist=(DamType="KFMod.DamTypeChainsaw", coeff=0.9)
var config float				RewardScore;
var config float				RewardScoreCoeff;
var config float				MonsterSize;
var config array<Mesh>			Mesh;
var config array<Material>		Skins;
//--------------------------------------------------------------------------------------------------
simulated function UnSerialize(string S)
{
	local int i,n;
	local Name tName;
	
	tName = StringToName(Get(S));
	
	MonsterClass.Remove(0,MonsterClass.Length);
	GetI(S, n);
	MonsterClass.Insert(0,n);
	for (i=0;i<n;i++)
		MonsterClass[i] = class<KFMonster>(DynamicLoadObject(Get(S), Class'Class'));

	GetI(S, Health);
	GetI(S, HeadHealth);
	GetI(S, HealthMax);
	GetI(S, HeadHealthMax);
	GetI(S, Speed);
	GetF(S, SpeedMod);
	Get(S,	MonsterName);
	GetI(S, PerPlayer.Health);
	GetI(S, PerPlayer.HeadHealth);
	
	Resist.Remove(0,Resist.Length);
	GetI(S, n);
	Resist.Insert(0,n);
	for (i=0;i<n;i++)
	{
		Resist[i].DamType = class<DamageType>(DynamicLoadObject(Get(S), Class'Class'));
		GetF(S, Resist[i].Coeff);
		Resist[i].bNotCheckChild = bool(Get(S));
	}
	GetF(S, RewardScore);
	GetF(S, RewardScoreCoeff);
	GetF(S, MonsterSize);
	
	Mesh.Remove(0,Mesh.Length);
	GetI(S, n);
	Mesh.Insert(0,n);
	for (i=0;i<n;i++)
		Mesh[i] = Mesh(DynamicLoadObject(Get(S), Class'Mesh'));

	Skins.Remove(0,Skins.Length);
	GetI(S, n);
	Skins.Insert(0,n);
	for (i=0;i<n;i++)
		Skins[i] = Material(DynamicLoadObject(Get(S), Class'Material'));
}
//--------------------------------------------------------------------------------------------------
simulated function string Serialize()
{
	local string S;
	local int i;
	Push(S, string(Name));
	
	PushI(S, MonsterClass.Length);
	for (i=0;i<MonsterClass.Length;i++)
		Push(S, string(MonsterClass[i]));

	PushI(S, Health);
	PushI(S, HeadHealth);
	PushI(S, HealthMax);
	PushI(S, HeadHealthMax);
	PushI(S, Speed);
	PushF(S, SpeedMod);
	Push(S,	MonsterName);
	PushI(S, PerPlayer.Health);
	PushI(S, PerPlayer.HeadHealth);
	
	PushI(S, Resist.Length);
	for (i=0;i<Resist.Length;i++)
	{
		Push(S, string(Resist[i].DamType));
		PushF(S, Resist[i].Coeff);
		Push(S, string(Resist[i].bNotCheckChild));
	}
	PushF(S, RewardScore);
	PushF(S, RewardScoreCoeff);
	PushF(S, MonsterSize);
	
	PushI(S, Mesh.Length);
	for (i=0;i<Mesh.Length;i++)
		Push(S, string(Mesh[i]));

	PushI(S, Skins.Length);
	for (i=0;i<Skins.Length;i++)
		Push(S, string(Skins[i]));
	return S;
}
//--------------------------------------------------------------------------------------------------
static function array<string> GetNames()
{
	return GetPerObjectNames(default.ConfigFile);
}
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
defaultproperties
{
	ConfigFile = "MonsterConfig"
	
	// если юзер просто не указал это в конфиге, мы учтем это и не будем присваивать
	Health=-1
	HeadHealth=-1
	HealthMax=-1
	HeadHealthMax=-1
	PerPlayer=(Health=0,HeadHealth=0)
	
	Speed = 0
	SpeedMod = 1.0
	
	RewardScore = -1.0
	RewardScoreCoeff = 1.0
	
	MonsterSize = 1.0
}