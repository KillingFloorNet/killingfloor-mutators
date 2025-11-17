// Red Team player.
Class KFRedTDMPlayer extends KFDMHumanPawn;

#exec obj load file="TeamSkins.utx" package="KFDeathMatch"

var Material TeamSkinX;

simulated function PostBeginPlay()
{
	Super(UnrealPawn).PostBeginPlay();
	AssignInitialPose();

	if( bActorShadows && bPlayerShadows && (Level.NetMode!=NM_DedicatedServer) )
	{
		if( bDetailedShadows )
			PlayerShadow = Spawn(class'KFShadowProject',Self,'',Location);
		else PlayerShadow = Spawn(class'ShadowProjector',Self,'',Location);
		PlayerShadow.ShadowActor = self;
		PlayerShadow.bBlobShadow = bBlobShadow;
		PlayerShadow.LightDirection = Normal(vect(1,1,3));
		PlayerShadow.InitShadow();
	}
	Skins[0] = TeamSkinX;
}
simulated function Setup(xUtil.PlayerRecord rec, optional bool bLoadNow)
{
	if( rec.Species==None || Class<SPECIES_KFMaleHuman>(rec.Species)==None )
		rec = class'xUtil'.static.FindPlayerRecord(GetDefaultCharacter());
	Species = rec.Species;
	RagdollOverride = rec.Ragdoll;
	if ( Species!=None && !Species.static.Setup(self,rec) )
	{
		rec = class'xUtil'.static.FindPlayerRecord(GetDefaultCharacter());
		Species = rec.Species;
		RagdollOverride = rec.Ragdoll;
		if ( !Species.static.Setup(self,rec) )
			return;
	}
	if( Class<SPECIES_KFMaleHuman>(Species) != none )
	{
		DetachedArmClass = Class<SPECIES_KFMaleHuman>(Species).default.DetachedArmClass;
		DetachedLegClass = Class<SPECIES_KFMaleHuman>(Species).default.DetachedLegClass;
	}
	Skins[0] = TeamSkinX;
	ResetPhysicsBasedAnim();
}
function bool CanBuyNow()
{
	local TDMShopTrigger Sh;

	if( PlayerReplicationInfo==None || PlayerReplicationInfo.Team==None )
		return False;
	foreach TouchingActors(Class'TDMShopTrigger',Sh)
		if( Sh.Team==PlayerReplicationInfo.Team.TeamIndex )
			Return True;
	Return False;
}

defaultproperties
{
     TeamSkinX=ConstantColor'KFDeathMatch.TeamSkins.RedConstColor'
     bNoTeamBeacon=False
     bScriptPostRender=True
}
