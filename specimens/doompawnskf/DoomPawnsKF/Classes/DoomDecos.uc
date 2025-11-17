Class DoomDecos extends Decoration
	Abstract
	Placeable;

#exec obj load file=DDecos.utx package=DoomPawnsKF

var DoomDecoDisplay MyRender;

simulated function PostBeginPlay()
{
	if( Level.NetMode==NM_DedicatedServer )
		return;
	MyRender = Spawn(Class'DoomDecoDisplay',Self);
	if( !bMovable )
		MyRender.SetPhysics(PHYS_None);
	MyRender.SetDrawScale3D(DrawScale3D);
	MyRender.SetDrawScale(DrawScale*0.5f);
	MyRender.Skins[0] = Texture;
	MyRender.AmbientGlow = AmbientGlow;
}
simulated function Destroyed()
{
	if( MyRender!=None )
		MyRender.Destroy();
}
function Landed(vector HitNormal);
function HitWall (vector HitNormal, actor Wall);
function TakeDamage( int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, optional int HitIndex);
function Trigger( actor Other, pawn EventInstigator );
function BaseChange();
function Bump( actor Other );

defaultproperties
{
     DrawType=DT_Sprite
     bHidden=True
     bNoDelete=True
     bSkipActorPropertyReplication=True
     RemoteRole=ROLE_None
     NetUpdateFrequency=0.500000
     bMovable=False
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
}
