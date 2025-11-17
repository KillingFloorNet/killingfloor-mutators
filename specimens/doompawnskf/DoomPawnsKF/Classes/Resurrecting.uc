//=============================================================================
// Resurrecting.
//=============================================================================
class Resurrecting extends DoomCarcass;

var bool bHasBeenInited;
var array<Texture> AnimationF;
var int CurSkinNum;
var bool bIsRessurrecting;

simulated function Initfor( class<DoomPawns> MonsterType )
{
	if( MonsterType==None || bHasBeenInited ) Return;
	bHasBeenInited = True;
	DeadEnemy = MonsterType;
	if( Level.NetMode!=NM_DedicatedServer )
	{
		SetDrawScale(DeadEnemy.Default.DrawScale);
		ScaleGlow = DeadEnemy.Default.ScaleGlow;
		SetStaticMesh(DeadEnemy.Default.RenderingClass.Default.StaticMesh);
		SetDrawScale3D(DeadEnemy.Default.RenderingClass.Default.DrawScale3D);
		AnimationF = Class'DRendering'.Static.GetAnimation(DeadEnemy.Default.DieTexture);
		CurSkinNum = AnimationF.Length-1;
		Skins[0] = AnimationF[CurSkinNum];
		SetTimer(LifeSpan/float(CurSkinNum+1),True);
	}
	bIgnoreThisScan = True;
}
function SetType( DoomCarcass ToGetFrom )
{
	if( ToGetFrom.DeadEnemy==None )
		Destroy();
	else Initfor(ToGetFrom.DeadEnemy);
}
simulated function Timer()
{
	if( --CurSkinNum<0 )
		Destroy();
	else Skins[0] = AnimationF[CurSkinNum];
}
function Destroyed()
{
	local DoomPawns DD;

	if( DeadEnemy!=None )
	{
		Class'Resurrecting'.Default.bIsRessurrecting = true; // Stop telefragging.
		DD = Spawn(DeadEnemy);
		Class'Resurrecting'.Default.bIsRessurrecting = false;
		if( DD!=None && Level.Game.IsA('Invasion') )
			Invasion(Level.Game).NumMonsters++;
	}
}

defaultproperties
{
     bNetTemporary=True
     Physics=PHYS_None
     LifeSpan=1.000000
}
