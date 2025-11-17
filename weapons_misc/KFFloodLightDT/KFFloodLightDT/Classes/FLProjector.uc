//class FLProjector extends Effect_TacLightProjector;
class FLProjector extends DynamicProjector;
/*
event PostBeginPlay()
{
	log("FLProjector: Spawned");
}
*/
defaultproperties
{
     MaterialBlendingOp=PB_Modulate
     FrameBufferBlendingOp=PB_Add
     FOV=50
     MaxTraceDistance=2048
     bClipBSP=True
     bProjectOnUnlit=True
     bGradient=True
     bProjectOnAlpha=True
     bProjectOnParallelBSP=True
     bDynamicAttach=True
     bNoProjectOnOwner=True
     CullDistance=2000.000000
     bLightChanged=True
     bStatic=False
     bDetailAttachment=True
     DrawScale=0.650000
     bHardAttach=True
}
