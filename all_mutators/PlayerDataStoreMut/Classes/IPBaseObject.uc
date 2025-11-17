Class IPBaseObject extends Object PerObjectConfig Config(PlayerDataStoreIP);

var private transient IPBaseObject Ref;
struct IPBaseObjectStruct
{
	var config string PlayerName,PlayerID,FirstEntry;
};
var config array<IPBaseObjectStruct> IPBaseObjectList;

static final function IPBaseObject GetSettings(string PlayerIP)
{
	Default.Ref = New(None,PlayerIP)Class'IPBaseObject';
	return Default.Ref;
}

static final function int GetLength(string PlayerIP)
{
	local IPBaseObject S;
	S = GetSettings(PlayerIP);
	return S.IPBaseObjectList.Length;
}

static final function IPBaseObjectStruct Get(string PlayerIP, int N)
{
	local IPBaseObject S;
	S = GetSettings(PlayerIP);
	return S.IPBaseObjectList[N];
}

static final function Set(string PlayerIP, IPBaseObjectStruct nos)
{
	local IPBaseObject S;
	S = GetSettings(PlayerIP);
	S.IPBaseObjectList[S.IPBaseObjectList.Length]=nos;
	S.SaveConfig();
}
