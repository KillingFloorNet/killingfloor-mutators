class FlashProjector extends Effect_TacLightProjector;

// setup the pawn and controller variables, spawn the dynamic light
simulated function PostBeginPlay()
{
	SetCollision(True, False, False);
	/*if (Owner != None)
	{
		LightPawn = Pawn(Owner);
		ValidWeapon = LightPawn.Weapon;
	}*/
	if( Level.NetMode==NM_DedicatedServer )
		Return;
	if( TacLightGlow==None )
		TacLightGlow = spawn(class'Effect_TacLightGlow',);

	TacLightGlow.setowner(lightpawn);
	TacLightGlow.bonlyownersee=true;

	if( Class'KFPawn'.Default.bDetailedShadows )
	{
		AssignedPC = KFPlayerController(Level.GetLocalPlayerController());
		if( AssignedPC!=None )
			AddProjecting();
		LightRadius = 1300;
	}
}
simulated function AddProjecting()
{
	bIsAssigned = True;
	AssignedPC.LightSources[AssignedPC.LightSources.Length] = Self;
}
simulated function RemoveProjecting()
{

}
simulated function Destroyed()
{
	Super.Destroyed();
	if( TacLightGlow!=None )
		TacLightGlow.Destroy();
	if( KFWeaponAttachment(AssignedAttach)!=None )
	{
		KFWeaponAttachment(AssignedAttach).TacBeamGone();
		AssignedAttach = None;
	}
	if( bIsAssigned )
	{
		RemoveProjecting();
		AssignedPC = None;
	}


}

// updates the taclight projector and dynamic light positions
simulated function Tick(float DeltaTime)
{
	local vector StartTrace,EndTrace,X,HitLocation,HitNormal,AdjustedLocation;
	local float BeamLength;
	local rotator R;

	if( Level.NetMode==NM_DedicatedServer )
	{
		if( LightPawn==none  )
		{
			Destroy();
			return;
		}
		SetLocation(LightPawn.Location);
		
		LightRot[0] = LightPawn.Controller.Rotation.Yaw/256;
		LightRot[1] = LightPawn.Controller.Rotation.Pitch/256;
		Return;
	}
	if (TacLightGlow == None)
		return;

	if( Level.NetMode!=NM_Client && LightPawn == none )
	{
		DetachProjector();
		Destroy();
		return;
	}

	// we're changing its location and rotation, so detach it
	DetachProjector();

	// fallback
	if( LightPawn==None  )
	{
		LightPawn = Pawn(Owner);
		TacLightGlow.setowner(lightpawn);
		/*if (TacLightGlow != None)
			TacLightGlow.bDynamicLight = false;
		if( AssignedAttach!=None )
		{
			if( KFWeaponAttachment(AssignedAttach)!=None )
				KFWeaponAttachment(AssignedAttach).TacBeamGone();
			AssignedAttach = None;
		}
		if( bIsAssigned )
			RemoveProjecting();
		return;*/
	}

	if( Level.NetMode!=NM_Client || PlayerController(LightPawn.Controller)!=None )
	{
		R = LightPawn.Controller.Rotation;
		if( PlayerController(LightPawn.Controller)==None || PlayerController(LightPawn.Controller).bBehindView || LightPawn.Weapon==None )
		{
			if( XPawn(LightPawn)!=None )
				StartTrace = LightPawn.Location+LightPawn.EyePosition()+20*Vector(R);
		}
		if( Level.NetMode!=NM_Client )
		{
			LightRot[0] = R.Yaw/256;
			LightRot[1] = R.Pitch/256;
		}
		X = vector(R);
	}
	else
	{
		R.Yaw = LightRot[0]*256;
		R.Pitch = LightRot[1]*256;
		if( XPawn(LightPawn)!=None)
			StartTrace = LightPawn.Location+LightPawn.EyePosition()+20*Vector(R);
		X = vector(R);
	}

	// not too far out, we don't want a flashlight that can shine across the map
	EndTrace = StartTrace + 1800*X;

	if( Trace(HitLocation,HitNormal,EndTrace,StartTrace,true)==None )
		HitLocation = EndTrace;

	// find out how far the first hit was
	BeamLength = VSize(StartTrace-HitLocation);

	// this makes a neat focus effect when you get close to a wall
	if (BeamLength <= 90)
		SetDrawScale(FMax(0.02,(BeamLength/90))*Default.DrawScale);
	else SetDrawScale(Default.DrawScale);
	SetLocation(StartTrace);
	SetRotation(R);

	// reattach it
	AttachProjector();

	// turns the dynamic light on if it's off
	if (!TacLightGlow.bDynamicLight)
		TacLightGlow.bDynamicLight = true;

	// again, neat focus effect up close, starts earlier than the dynamic projector
	if (BeamLength <= 100)
	{
		TacLightGlow.LightBrightness = TacLightGlow.Default.LightBrightness * (1.0 + (1.0 - (BeamLength/100)));
		TaclightGlow.LightRadius = TacLightGlow.Default.LightRadius * FMax(0.3,(BeamLength/100));
	} // else we scale its radius and brightness depending on distance from the material
	else
	{
		// fades the lightsource out as it moves farther away
		if (BeamLength >= 1300)
			TacLightGlow.LightBrightness = TacLightGlow.Default.LightBrightness * ((1800-BeamLength)/500);
		else // else normal brightness
			TacLightGlow.LightBrightness = TacLightGlow.Default.LightBrightness;

		// this makes the light act more like a spotlight, resizing depending on distance
		TacLightGlow.LightRadius = TacLightGlow.Default.LightRadius + (4.5 * (BeamLength/1900));
	}
	AdjustedLocation = HitLocation;
	AdjustedLocation.Z += 0.5 * LightPawn.CollisionHeight;
	TacLightGlow.SetLocation(AdjustedLocation - 50*X );
	if( XPawn(LightPawn)!=None && XPawn(LightPawn).WeaponAttachment!=AssignedAttach )
	{
		if( KFWeaponAttachment(AssignedAttach)!=None )
			KFWeaponAttachment(AssignedAttach).TacBeamGone();
		AssignedAttach = XPawn(LightPawn).WeaponAttachment;
	}
	if( KFWeaponAttachment(AssignedAttach)!=None )
		KFWeaponAttachment(AssignedAttach).UpdateTacBeam(BeamLength);
	if( !bIsAssigned && AssignedPC!=None )
		AddProjecting();
}

defaultproperties
{
     bOnlyOwnerSee=True
}
