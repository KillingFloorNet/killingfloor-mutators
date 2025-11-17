//-----------------------------------------------------------
//
//-----------------------------------------------------------
class KatanaM extends KFMeleeGun;

var float DmgHeal;
var localized   string  SuccessfulHealMessage;

replication
{
    // Variables the server should send to the client.
    reliable if( Role==ROLE_Authority && bNetOwner )
        DmgHeal;
		
	reliable if( Role == ROLE_Authority )
		ClientSuccessfulHeal;
}

function SumeAmmoe()
{
  DmgHeal +=1;
  
     if (GetAmmoe() > 9 && KFHumanPawn(Instigator).Health < (KFHumanPawn(Instigator).HealthMax*0.95) )
    {
	   KFHumanPawn(Instigator).GiveHealth(10, (KFHumanPawn(Instigator).HealthMax));
	   SetAmmoe(36);
       Spawn(Class'KatanaMedic.HPAlia', KFHumanPawn(Instigator) );
	}
	
}

function int GetAmmoe()
{

  Return DmgHeal/6;
}

function SetAmmoe(float Med)
{
   DmgHeal -= Med;
}


simulated event RenderOverlays( Canvas Canvas )
{

	local int m;

    Canvas.Font = Canvas.MedFont;

	if (Instigator == None)
		return;

	if ( Instigator.Controller != None )
		Hand = Instigator.Controller.Handedness;

	if ((Hand < -1.0) || (Hand > 1.0))
		return;

	// draw muzzleflashes/smoke for all fire modes so idle state won't
	// cause emitters to just disappear
	for (m = 0; m < NUM_FIRE_MODES; m++)
	{
		if (FireMode[m] != None)
		{
			FireMode[m].DrawMuzzleFlash(Canvas);
		}
	}

	SetLocation( Instigator.Location + Instigator.CalcDrawOffset(self) );
	SetRotation( Instigator.GetViewRotation() + ZoomRotInterp);

	//PreDrawFPWeapon();	// Laurent -- Hook to override things before render (like rotation if using a staticmesh)
   	//Canvas.Font = Canvas.MedFont;

	Canvas.SetDrawColor(12,0,205,255);
	
	  Canvas.SetPos(Canvas.ClipX*0.10,Canvas.ClipY*0.12);
	  Canvas.DrawText("Dmg To Heal(min 10): "$int(DmgHeal/6),false);
   
	bDrawingFirstPerson = true;
	Canvas.DrawActor(self, false, false, DisplayFOV);
	bDrawingFirstPerson = false;
}

function AdjustPlayerDamage(out int Damage, Pawn instigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
    if (GetAmmoe() > 9 && KFHumanPawn(Instigator).Health < (KFHumanPawn(Instigator).HealthMax*0.95) )
    {
	   KFHumanPawn(Instigator).GiveHealth(10, (KFHumanPawn(Instigator).HealthMax));
	   SetAmmoe(36);
       Spawn(Class'KatanaMedic.HPAlia', KFHumanPawn(Instigator) );
	}
}

simulated function ClientSuccessfulHeal(String HealedName)
{
    if( PlayerController(Instigator.Controller) != none )
    {
        PlayerController(Instigator.controller).ClientMessage(SuccessfulHealMessage$HealedName, 'CriticalEvent');
    }
}

defaultproperties
{
     SuccessfulHealMessage="You healed "
     weaponRange=90.000000
     BloodyMaterial=Shader'KatanaMedicT.KatanaMedic_Cmb'
     BloodSkinSwitchArray=0
     BloodyMaterialRef="KatanaMedicT.KatanaMedic_Cmb"
     bSpeedMeUp=True
     HudImage=Texture'KatanaMedicT.Katana_UnSelect'
     SelectedHudImage=Texture'KatanaMedicT.Katana_Select'
     Weight=2.000000
     StandardDisplayFOV=75.000000
     TraderInfoTexture=Texture'KatanaMedicT.Katana_Select'
     bIsTier2Weapon=True
     SelectSoundRef="KF_KatanaSnd.Katana_Select"
     FireModeClass(0)=Class'KatanaMedic.KatanaMFire'
     FireModeClass(1)=Class'KatanaMedic.KatanaMFireB'
     AIRating=0.400000
     CurrentRating=0.600000
     Description="An incredibly katana Medic."
     DisplayFOV=75.000000
     Priority=80
     GroupOffset=4
     PickupClass=Class'KatanaMedic.KatanaMPickup'
     BobDamping=8.000000
     AttachmentClass=Class'KatanaMedic.KatanaMAttachment'
     IconCoords=(X1=246,Y1=80,X2=332,Y2=106)
     ItemName="Katana Medic"
     Mesh=SkeletalMesh'KF_Weapons2_Trip.katana_Trip'
     Skins(0)=Shader'KatanaMedicT.KatanaMedic_Cmb'
}
