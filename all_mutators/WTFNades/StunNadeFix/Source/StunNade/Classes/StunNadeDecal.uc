class StunNadeDecal extends ProjectedDecal;

#exec OBJ LOAD FILE=StunNade.utx

simulated function BeginPlay()
{
    if ( !Level.bDropDetail && (FRand() < 0.5) )
        ProjTexture = Texture'StunNade.Misc.StunNade_Stain';
    Super.BeginPlay();
}

defaultproperties
{
     ProjTexture=Texture'StunNade.Misc.StunNade_Stain'
     bClipStaticMesh=True
     CullDistance=7000.000000
     LifeSpan=5.000000
     DrawScale=0.500000
}
