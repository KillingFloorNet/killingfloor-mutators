Class NameBaseObject extends Object PerObjectConfig Config(PlayerDataStoreName);

var private transient NameBaseObject Ref;
struct NameBaseObjectStruct
{
	var config string PlayerID,PlayerIP,FirstEntry;
};
var config array<NameBaseObjectStruct> NameBaseObjectList;

static final function NameBaseObject GetSettings(string PlayerName)
{
	Default.Ref = New(None,PlayerName)Class'NameBaseObject';
	return Default.Ref;
}

static final function int GetLength(string PlayerName)
{
	local NameBaseObject S;
	S = GetSettings(PlayerName);
	return S.NameBaseObjectList.Length;
}

static final function NameBaseObjectStruct Get(string PlayerName, int N)
{
	local NameBaseObject S;
	S = GetSettings(PlayerName);
	return S.NameBaseObjectList[N];
}

static final function Set(string PlayerName, NameBaseObjectStruct nos)
{
	local NameBaseObject S;
	S = GetSettings(PlayerName);
	S.NameBaseObjectList[S.NameBaseObjectList.Length]=nos;
	S.SaveConfig();
}
