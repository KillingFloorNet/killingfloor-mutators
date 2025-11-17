class AA12DWAttachment extends DualiesAttachment;

simulated function UpdateTacBeam( float Dist );
simulated function TacBeamGone();

simulated function DoFlashEmitter()
{
	if(bIsOffHand)
		return;
	if( FiringMode==1 )
	{
		brother.ActuallyFlash();
		ActuallyFlash();	
	}
	else
	{	
		if(bMyFlashTurn)
			ActuallyFlash();
		else if(brother != None)
			brother.ActuallyFlash();
		bMyFlashTurn = !bMyFlashTurn;
	}
}

//Muzzle flash for both primary and alternate fire
simulated event ThirdPersonEffects()
{
	if( FiringMode==1 )
	{
		DoFlashEmitter();
	}
	Super.ThirdPersonEffects();
}

defaultproperties
{
     BrotherMesh=SkeletalMesh'AA12DW_R.Mesh3rd'
     mMuzFlashClass=Class'ROEffects.MuzzleFlash3rdKar'
     mTracerClass=None
     mShellCaseEmitterClass=Class'KFMod.KFShotgunShellSpewer'
     MeshRef="AA12DW_R.Mesh3rd"
     Mesh=SkeletalMesh'AA12DW_R.Mesh3rd'
}
