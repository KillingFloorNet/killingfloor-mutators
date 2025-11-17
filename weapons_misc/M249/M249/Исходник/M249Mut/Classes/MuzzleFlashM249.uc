class MuzzleFlashM249 extends ROMuzzleFlash3rd;

simulated function Trigger(Actor Other, Pawn EventInstigator)
{
	Emitters[0].SpawnParticle(1);
}

defaultproperties
{
     bNoDelete=False
     Style=STY_Additive
     bHardAttach=True
     bDirectional=True
}
