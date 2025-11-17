//=============================================================================
// Doom Pawns Display Base. (Client side actor)
//=============================================================================
class DPawnDisplay extends Actor
	Transient;

// This variable is set after postbeginplay.
// Use owner on prebeginplay or postbeginplay.
var DoomPawns Renderer;
var PlayerController RenderObject;
var byte AnimChange,LastCheckB; // Default 255
var bool bChecked,bHasDied,bRenderDisabled;
var int NumFrames,LastFrame,NumFramesToPlay;
var float TimeLeft,AmountTime;
var array<Texture> DeathAnimation;

// Called when ready for initializing...
simulated function Initialized()
{
	Renderer.UpdateSkin(Renderer.Texture);
	SetDrawScale(Renderer.DrawScale);
	Style = Renderer.Style;
	Default.LifeSpan = 0;
	LifeSpan = 0;
	ScaleGlow = Renderer.ScaleGlow;
	bUnlit = Renderer.bUnlit;
}
simulated function SetAnimatedTime( float Length, int Frames )
{
	NumFrames = Frames;
	TimeLeft = Length;
	AmountTime = Length;
}
simulated function Tick( float D )
{
	local byte By;
	local bool bAnimChanged;
	local rotator TheNewRot;
	local int Frame;
	local float F;
	local vector D3;
	
	// Check for render object
	if( !bChecked )
	{
		bChecked = True;
		RenderObject = Level.GetLocalPlayerController();
		if( RenderObject==None ) // Could be an dedicated server... cancel everything.
		{
			Disable('Tick');
			Return;
		}
	}
	// To improve CPU useage.
	if( bRenderDisabled )
	{
		if( (LastRenderTime+1)>Level.TimeSeconds )
		{
			bRenderDisabled = False;
			SetDrawType(DT_StaticMesh);
		}
		else Return;
	}
	else if( (LastRenderTime+1)<Level.TimeSeconds )
	{
		bRenderDisabled = True;
		SetDrawType(DT_None);
		Return;
	}

	// Check for animation change.
	if( Level.NetMode==NM_Client && !Renderer.bDidDied && Renderer.AnimChange!=AnimChange )
	{
		AnimChange = Renderer.AnimChange;
		Renderer.NotifyAnimation(AnimChange);
		bAnimChanged = True;
	}

	// Always face the player.
	TheNewRot = Class'DRendering'.Static.GetMyYaw(Class'DRendering'.Static.GetPlayerCamLoc(RenderObject),Owner.Location);

	if( Renderer.bDidDied )
	{
		if( !bHasDied )
		{
			if( Level.NetMode==NM_Client )
				Renderer.GoToState('Dying');
			bHasDied = True;
			DeathAnimation = Class'DRendering'.Static.GetAnimation(Renderer.DieTexture);
			LifeSpan = Renderer.Default.DeathSpeed;
			Renderer.UpdateSkin(DeathAnimation[0]);
			NumFramesToPlay = DeathAnimation.Length;
			LastFrame = 0;
			SetTimer(LifeSpan/NumFramesToPlay,True);
		}
		//TheNewRot.Yaw+=16384;
		if( Rotation!=TheNewRot )
			SetRotation(TheNewRot);
		if( DrawScale3D!=Default.DrawScale3D )
			SetDrawScale3D(Default.DrawScale3D);
		bUnlit = Renderer.Default.bUnlit;
		Return;
	}
	if( Renderer.Default.bUnlit )
		bUnlit = True;
	else bUnlit = (Renderer.LightType!=LT_None);
	// Update animating
	if( TimeLeft>0 )
	{
		if( Renderer.bFastMonster )
			TimeLeft-=D*2;
		else TimeLeft-=D;
		if( TimeLeft<=0 )
		{
			TimeLeft = 0;
			Frame = NumFrames;
			if( Level.NetMode==NM_Client )
				TimeLeft = AmountTime;
		}
		else
		{
			F = (TimeLeft/AmountTime);
			F *= float(NumFrames);
			Frame = NumFrames-Int(F);
		}
		if( Frame!=LastFrame )
		{
			LastFrame = Frame;
			bAnimChanged = True;
		}
	}
	else LastFrame = -2;
	// Update animation (rotation).
	By = Class'DRendering'.Static.GetAnimRot(Renderer.Rotation.Yaw,TheNewRot.Yaw);
	D3 = Default.DrawScale3D;
	if( !Renderer.MirrorMe(By) )
		D3.Y*=-1;
	if( Rotation!=TheNewRot )
		SetRotation(TheNewRot);
	if( DrawScale3D!=D3 )
		SetDrawScale3D(D3);
	if( By!=LastCheckB || bAnimChanged )
	{
		LastCheckB = By;
		Renderer.bForceUnlit = False;
		Renderer.UpdateAnimation(By,Frame);
	}
	if( Renderer.bForceUnlit )
		bUnlit = True;
}
simulated function Destroyed()
{
	if( Renderer!=None )
	{
		Renderer.ResetShaderSkin();
		if( Level.NetMode!=NM_Client )
			Renderer.NotifyDead();
		Renderer = None;
	}
}
simulated function Timer()
{
	if( Level.NetMode!=NM_Client && !Renderer.bDidDied ) Renderer.TimedReply();
	else
	{
		LastFrame++;
		if( LastFrame>=NumFramesToPlay )
			Return;
		Renderer.UpdateSkin(DeathAnimation[LastFrame]);
	}
}

defaultproperties
{
     AnimChange=255
     LastCheckB=255
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'DoomPawnsKF.NormalMesh'
     bTrailerAllowRotation=True
     Physics=PHYS_Trailer
     RemoteRole=ROLE_None
     AmbientGlow=40
     Style=STY_Masked
     bOwnerNoSee=True
     bAlwaysTick=True
}
