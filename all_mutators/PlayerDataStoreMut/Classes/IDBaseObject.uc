Class IDBaseObject extends Object PerObjectConfig Config(PlayerDataStoreID);

var private transient IDBaseObject Ref;
struct IDBaseObjectStruct
{
	var config string PlayerName,PlayerIP,FirstEntry;
};
var config array<IDBaseObjectStruct> IDBaseObjectList;

static final function IDBaseObject GetSettings(string Hash)
{
	Default.Ref = New(None,Hash)Class'IDBaseObject';
	return Default.Ref;
}

static final function int GetLength(string Hash)
{
	local IDBaseObject S;
	S = GetSettings(Hash);
	return S.IDBaseObjectList.Length;
}

static final function IDBaseObjectStruct Get(string Hash, int N)
{
	local IDBaseObject S;
	S = GetSettings(Hash);
	return S.IDBaseObjectList[N];
}

static final function Set(string Hash, IDBaseObjectStruct nos)
{
	local IDBaseObject S;
	S = GetSettings(Hash);
	S.IDBaseObjectList[S.IDBaseObjectList.Length]=nos;
	S.SaveConfig();
}
