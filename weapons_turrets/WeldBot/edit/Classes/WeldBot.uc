class WeldBot extends Pawn
  Config(chippoSentryConfig);
#exec OBJ LOAD FILE=KF_LAWSnd.uax
#exec OBJ LOAD FILE="chippo.ukx" package="chippo"
var WeldBotSetupIcon WeldBotSetupIcon;

var() config int WeldSpeed;
var() config int SentryHealth;
var(Sounds) array<Sound> SndFootStep;
var(Sounds) array<Sound> SndPain;
var(Sounds) array<Sound> SndFire;
var(Sounds) array<Sound> SndOther;

// for temporary match operations
var Rotator	rotator1,rotator2,rotator3;
var vector	vector1,vector2,vector3;
var float	float1,float2,float3;
var int		int1,int2,int3;

var Pawn OwnerPawn;

var WeldBotUseActor WeldBotUseActor;

var vector HitEmitterLocation;
var WeldBotLazor Lazor;
var vector WeldBoneLocation;
var bool bWelding, bWeldingClient;
var vector wPStart, wPEnd, wPCur, wPNext, wPCurClient; // weld points
var object.box DoorBox;
var bool bWeldOffset;
var float WeldSoundLoopTime;
var array<vector> DebugPoint1, DebugPoint2;
var(Debug) config float TransformerVol, SparkVolMin, SparkVolMax, LazorWeldVolume;
var(Debug) vector UsedByTraceWidth;
var float NextWeldEffectTime;

var transient float NextVoiceTimer;
var WeldBotGun WeaponOwner;
var transient Font HUDFontz[2];
var() string BotName;
var localized string OwnerText, MSG_ModeStay, MSG_ModeWeldDoors, DefaultBotName;
var WeldBotMut WMut;
var bool bLangChecked, bLangCheckedClient;

var() Actor HomeActor;
var() Actor WeldTarget, WeldTargetClient;
var	vector WeldTargetLocation;
var() float MaxDistanceToOwner, MaxShootDistance;

var int ServerHealth, ClientHealth;
var enum EState
{
	Stay,
	Follow,
	WeldDoors,
} BotState, BotStateClient;

var enum EAnim
{
	Idle,
	Spawned,
	Left,
	Right,
	Twich,
	Walk,
	Fire,
	Stop,
	TurnLeft,
	TurnRight,
	TurnStop,
} CurAnim, RepAnim;

var array<KFDoorMover> NearDoors;
var vector DebugLineStart, DebugLineEnd;
var bool bDebug;

var WeldBotReplicationInfo RepInfo;
replication
{
	// Things the server should send to the client.
	reliable if ( Role == ROLE_Authority )
		RepInfo, CheckLanguage, bLangChecked, SentryHealth, RepAnim, BotName, BotState, MaxDistanceToOwner, HomeActor, StopWeld, bWelding;
	
	reliable if (Role == ROLE_Authority && bWelding)
		wPStart, wPCur, wPNext, wPEnd, WeldTarget//, GetWeldPathPoints
		//, wPCur, 
		//ServerHealth, CoordMove, WeldTarget,StopWeld, 
		//Weld, StartWeld, GetWeldPathPoints, wPCur, SetOwningPlayer
		;

	/*reliable if ( Role == ROLE_Authority && bWelding==false && bWeldingClient==true)
		bWeldingClient;*/
}
//--------------------------------------------------------------------------------------------------
function float DoorHP(Actor D)
{
	local KFDoorMover Door;
	Door = KFDoorMover(D);
	if (Door==none)
		return 4000;
	return (Door.WeldStrength / Door.MaxWeld) * 100.f;
}
//--------------------------------------------------------------------------------------------------
function KFDoorMover DoorToRepairFirst()
{
	local int i;
	local float MinHP, tHP;
	local KFDoorMover Door;
	MinHP=3000;
	if (NearDoors.Length==0) return none;
	for (i=0; i<NearDoors.Length; i++)
	{
		tHP = DoorHP(NearDoors[i]);
		if (tHP<MinHP)
		{
			MinHP=tHP;
			Door=NearDoors[i];
		}
	}
	return Door;
}
//--------------------------------------------------------------------------------------------------
/*function bool WeldDoor(Actor D)
{
	local KFDoorMover Door;

	local vector StartTrace, EndTrace, HitLocation, HitNormal;
	local rotator PointRot;
	local KFDoorMover HitActor;

	Door = KFDoorMover(D);
	if (Door==none || bDoorValid(Door)==false)
	{
		StopWeld();
		return false;
	}
	//Weld();
	if ( Level.NetMode != 1 )
	{
		WeldBoneLocation = GetBoneCoords('tip').Origin;
		PointRot = Controller.GetViewRotation();
		StartTrace = WeldBoneLocation;
		EndTrace = StartTrace + vector(PointRot)*(MaxShootDistance*1.5);
		DebugLineStart	= StartTrace;
		DebugLineEnd	= EndTrace;
		//HitActor = Trace( HitLocation, HitNormal, EndTrace, StartTrace, true);
		foreach TraceActors(class'KFDoorMover', HitActor, HitLocation, HitNormal, EndTrace, StartTrace)
		{
			if (HitActor!=none)
				break;
		}
		HitEmitterLocation=HitLocation;
		if (bWelding==false)
			StartWeld(D);
	}
	Door.TakeDamage(4.0, OwnerPawn, HitLocation , vector(PointRot), class'KFMod.DamTypeWelder');
	return true;
}*/
//--------------------------------------------------------------------------------------------------
function NavigationPoint GetNearestDoorNavigationPoint(KFDoorMover Door)
{
	local NavigationPoint nav, nearest;
	local float tD, tDn;
	foreach Door.RadiusActors(class'NavigationPoint', nav, 100.0)
	{
		tD = VSizeSquared(Location - nav.Location);
		if (tDn==0 && tD < tDn)
		{
			tDn=tD;
			nearest=nav;
		}
	}
	return nav;
}
//--------------------------------------------------------------------------------------------------
// Calculates current WeldBone (for Lazor) and HitEmitter location
simulated function bool Weld(Actor A)
{
	local KFDoorMover	Door;
	local KFHumanPawn	Pawn;
	local vector HitLocation;
	local rotator PointRot;

	Door = KFDoorMover(A);
	Pawn = KFHumanPawn(A);
	if (Door==none && Pawn==none || (Door!=none && bDoorValid(Door)==false))
	{
		StopWeld();
		return false;
	}
	
	StartWeld(A);

	if (Door!=none)
		Door.TakeDamage(WeldSpeed, OwnerPawn, HitLocation , vector(PointRot), class'KFMod.DamTypeWelder');

	else if (Pawn!=none) {
		log(default.Class.Name$", 00_Weld, ShieldStrengthMax is"@xPawn(OwnerPawn).ShieldStrengthMax$", ShieldStrength is"@OwnerPawn.ShieldStrength);
		log(default.Class.Name$", 00_Weld, WeldSpeed is"@WeldSpeed$", KFSteamStatsAndAchievements is"@KFSteamStatsAndAchievements(PlayerController(OwnerPawn.Controller).SteamStatsAndAchievements));

		/// Прокачка кол-ва сварки хозяина бота при ремонте брони игроков, включая себя. Sir Arthur
		if(xPawn(OwnerPawn).ShieldStrengthMax - int(OwnerPawn.ShieldStrength) > WeldSpeed) {  /// Если оставшееся до максимально возможного кол-во брони игрока всё ещё больше скорости сварки (WeldSpeed) бота, то в статистику прокачки записываем стандартное кол-во единиц сварки (WeldSpeed). Sir Arthur
			KFSteamStatsAndAchievements(PlayerController(OwnerPawn.Controller).SteamStatsAndAchievements).AddWeldingPoints(WeldSpeed);
			log(default.Class.Name$", 01_Weld, ShieldStrengthMax is"@xPawn(OwnerPawn).ShieldStrengthMax$", ShieldStrength is"@OwnerPawn.ShieldStrength);
		}

		else {  /// В противном случае в статистику прокачки будет записано только необходимое до достижения максимального уровня сварки брони кол-во единиц прокачки. Sir Arthur
			KFSteamStatsAndAchievements(PlayerController(OwnerPawn.Controller).SteamStatsAndAchievements).AddWeldingPoints(xPawn(OwnerPawn).ShieldStrengthMax - int(OwnerPawn.ShieldStrength));
			log(default.Class.Name$", 02_Weld, ShieldStrengthMax is"@xPawn(OwnerPawn).ShieldStrengthMax$", ShieldStrength is"@OwnerPawn.ShieldStrength);
		}

		Pawn.AddShieldStrength(WeldSpeed);

		log(default.Class.Name$", 03_Weld, ShieldStrengthMax is"@xPawn(OwnerPawn).ShieldStrengthMax$", ShieldStrength is"@OwnerPawn.ShieldStrength);
		log(default.Class.Name$", 03_Weld, WeldSpeed is"@WeldSpeed$", KFSteamStatsAndAchievements is"@KFSteamStatsAndAchievements(PlayerController(OwnerPawn.Controller).SteamStatsAndAchievements));
		///
	}

	else return false; //unreal situation

	return true;
}
//--------------------------------------------------------------------------------------------------
simulated function Object.Box GetDoorBox(KFDoorMover Door)
{
	local object.box DBox;
	if (Door!=none)
	{
		if (Door.MyTrigger.DoorOwners.Length>1)
		{
			//PlayerController(OwnerPawn.Controller).ClientMessage("Current door have "@Door.MyTrigger.DoorOwners.Length@"sections");
			DBox.Max = Door.MyTrigger.DoorOwners[0].OctreeBox.Max;
			DBox.Min = Door.MyTrigger.DoorOwners[1].OctreeBox.Min;
		}
		else
		{
			DBox.Max = Door.OctreeBox.Max;
			DBox.Min = Door.OctreeBox.Min;
		}
	}
	return DBox;
}
//--------------------------------------------------------------------------------------------------
simulated function vector GetDoorCenter(KFDoorMover Door)
{
	local object.box DBox;
	DBox = GetDoorBox(Door);
	return (DBox.Max+DBox.Min)*0.5f;
}
//--------------------------------------------------------------------------------------------------
simulated function vector GetDoorBottomCenter(KFDoorMover Door)
{
	local object.box DBox;
	local vector bottomCenter;
	DBox = GetDoorBox(Door);
	bottomCenter = (DBox.Max+DBox.Min)*0.5f;
	bottomCenter.Z = FMin(DBox.Max.Z, DBox.Min.Z);
	return bottomCenter;
}
//--------------------------------------------------------------------------------------------------
simulated function GetWeldPathPoints(optional bool bNext)
{
	local KFDoorMover Door;
	local KFHumanPawn Pawn, tPawn;
	local vector	StartTrace, EndTrace, HitLocation, HitNormal, tVector;
	local rotator	Rot;
	local float		Dist;
	local Actor		HitActor;
	local int		i;
	local bool		bFound;
	
	Door = KFDoorMover(WeldTarget);
	Pawn = KFHumanPawn(WeldTarget);
	
	if (Door!=none && Door.MyTrigger!=none)
	{
		DoorBox = GetDoorBox(Door);
		tVector = (DoorBox.Max+DoorBox.Min)*0.5f;
		wPStart	= tVector;
		wPStart.Z = DoorBox.Max.Z;
		// ограничиваем максимум 30 градусов вверх
		StartTrace = WeldBoneLocation;
		Rot = GetBoneRotation('tip');
		Rot.Pitch+=7500; // 41 degrees max       //5461 +30 degrees max
		Dist = VSize(wPStart - StartTrace);
		EndTrace = StartTrace + vector(Rot)*(Dist*1.1f);
		HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);
		if (KFDoorMover(HitActor)!=none && KFDoorMover(HitActor)!=none && KFDoorMover(HitActor).Tag == Door.Tag)
			if (HitLocation.Z < wPStart.Z)
				wPStart.Z = HitLocation.Z;
		//----
		// ограничиваем максимум 20 градусов вниз
		wPEnd	= tVector;
		wPEnd.Z	= DoorBox.Min.Z;
		// ограничиваем максимум 20 градусов вниз
		StartTrace = WeldBoneLocation;
		Rot = GetBoneRotation('tip');
		Rot.Pitch-=3640; // -20 degrees max
		Dist = VSize(wPEnd - StartTrace);
		EndTrace = StartTrace + vector(Rot)*(Dist*1.1f);
		HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);
		if (KFDoorMover(HitActor)!=none && KFDoorMover(HitActor)!=none && KFDoorMover(HitActor).Tag == Door.Tag)
			if (HitLocation.Z > wPEnd.Z)
				wPEnd.Z = HitLocation.Z;		
		
		
		// ищем верхнюю видимую точку двери (т.к. часто границы дверей уходят глубоко в землю)
		WeldBoneLocation = GetBoneCoords('tip').Origin;
		StartTrace = WeldBoneLocation;
		EndTrace = wPStart;
		
		DebugPoint1.Remove(0,DebugPoint1.Length);
		while (i<100)
		{

			EndTrace.Z = EndTrace.Z - i*3;
			Rot = rotator(EndTrace - StartTrace);
			Dist = VSize(EndTrace - StartTrace);
			EndTrace = StartTrace + vector(Rot)*(Dist*1.1f);
			
			DebugPoint1.Insert(0,1);
			DebugPoint1[0] = EndTrace;
			
			HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);
			if (KFDoorMover(HitActor)!=none && KFDoorMover(HitActor)!=none && KFDoorMover(HitActor).Tag == Door.Tag)
			{
				//M("Found upper visible door bound i"@i);
				wPStart.Z = HitLocation.Z;
				break;
			}
			i++;
		}
		
		// ищем нижний видимый центр двери
		i=0;
		EndTrace = wPEnd;
		DebugPoint2.Remove(0,DebugPoint2.Length);
		while (i<100)
		{

			EndTrace.Z = EndTrace.Z + i*3;
			Rot = rotator(EndTrace - StartTrace);
			Dist = VSize(EndTrace - StartTrace);
			EndTrace = StartTrace + vector(Rot)*(Dist*1.1f);
			
			DebugPoint2.Insert(0,1);
			DebugPoint2[0] = EndTrace;
			
			HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);
			if (KFDoorMover(HitActor)!=none && KFDoorMover(HitActor)!=none && KFDoorMover(HitActor).Tag == Door.Tag)
			{
				//M("Found bottom visible door bound i"@i);
				wPEnd.Z = HitLocation.Z;
				break;
			}
			i++;
		}
		
		wPCur=wPStart;
		wPNext=wPCur;
	}
	else if (Pawn!=none)
	{
		if (bNext==false)
		{
			StartTrace	= WeldBoneLocation;
			EndTrace	= Pawn.Location;
			foreach TraceActors(class'KFHumanPawn', tPawn, HitLocation, HitNormal, EndTrace, StartTrace)
			{
				if (Pawn==tPawn)
					break;
			}
			vector1 = WeldBoneLocation;
			rotator1 = rotator(Normal(WeldBoneLocation - HitLocation));
			rotator2 = GetBoneRotation('tip');
			int1	 = rotator1.Pitch - rotator2.Pitch;
			if (int1 > 7500)
			{
				rotator1.Pitch = rotator2.Pitch + Rand(7500);
				float1 = VSize(WeldBoneLocation - Pawn.Location) * 1.2f;
				EndTrace = WeldBoneLocation + vector(rotator1)*float1;
				foreach TraceActors(class'KFHumanPawn', tPawn, HitLocation, HitNormal, EndTrace, StartTrace)
				{
					if (Pawn==tPawn)
						break;
				}
				wPCur = HitLocation;
			}
			else
				wPCur = HitLocation;
		}
			
		while (i<100)
		{
			rotator1 = GetBoneRotation('tip');
			rotator1.Pitch += Rand(7500); // + upto 40 degrees
			rotator1.Yaw += Rand(1820)-910; // +- 5 degrees
			float1 = VSize(WeldBoneLocation - Pawn.Location) * 1.2f;
			EndTrace = WeldBoneLocation + vector(rotator1)*float1; 
			foreach TraceActors(class'KFHumanPawn', tPawn, HitLocation, HitNormal, EndTrace, StartTrace)
			{
				if (Pawn==tPawn)
				{
					wPNext = HitLocation;
					bFound=true;
					break;
				}
			}
			if (bFound)
				break;
			i++;
		}
	}
}
//--------------------------------------------------------------------------------------------------
simulated function StartWeld(Actor A)
{
	WeldTarget=A;
	WeldTargetLocation = WeldTarget.Location;
	GetWeldPathPoints();
	bWelding=true;
	
	// Transformer sound
	AmbientSound = SndFire[0];
	SoundVolume = 161; // Volume of ambient sound. Ranges from 0 to 255. 255 is maximum volume.
	AmbientSoundScaling = 2.0;
	SoundRadius = 20; // Radius of ambient sound. When a viewport in UnrealEd is set to radii view, a blue circle will surround the actor when there is something in the AmbientSound field. Within this radius, the sound in the AmbientSound field can be heard.
	
	SetTimer(FClamp(FRand(),0.1f,0.4f),false);
}
//--------------------------------------------------------------------------------------------------
simulated function StopWeld()
{
	bWelding=false;
	if (Lazor!=none)
		Lazor.Destroy();
	AmbientSound = none;
	SetTimer(0.0,false);
}
//--------------------------------------------------------------------------------------------------
simulated function DrawDebugLines()
{
	local int i;
	/*	if (Controller.Target!=none && KFDoorMover(Controller.Target)!=none)
	{
		DrawStayingDebugLine( Location, DoorBox.Max, 10, 255, 255);
		DrawStayingDebugLine( Location, DoorBox.Min, 10, 255, 255);
		
		DrawStayingDebugLine( Location, (DoorBox.Max+DoorBox.Min)*0.5f, 10, 255, 255);
	}
	*/
	for (i=0; i<DebugPoint1.Length; i++)
		DrawStayingDebugLine( WeldBoneLocation, DebugPoint1[i], 0, 255, 0);
	for (i=0; i<DebugPoint2.Length; i++)
		DrawStayingDebugLine( WeldBoneLocation, DebugPoint2[i], 0, 0, 255);
	DrawStayingDebugLine( WeldBoneLocation, wPStart, 255, 0, 0);
	DrawStayingDebugLine( WeldBoneLocation, wPEnd, 255, 0, 0);
/*	DrawStayingDebugLine( DebugLineStart, DebugLineEnd, 10, 255, 255);
	
	DrawStayingDebugLine( HomeActor.Location, Location, 10, 255, 10);
	if (Controller!=none)
	{
		DrawStayingDebugLine( WeldBotController(Controller).repDot, Location, 255, 255, 10);
		
		if (Controller.Target!=none)
			DrawStayingDebugLine( Controller.Target.Location, Location, 255, 10, 10);
		if (Controller.Enemy!=none)
			DrawStayingDebugLine( Controller.Enemy.Location, Location, 255, 10, 10);
		if (Controller.MoveTarget!=none)
			DrawStayingDebugLine( Controller.MoveTarget.Location, Location, 10, 10, 255);
	}
*/
}
//--------------------------------------------------------------------------------------------------
simulated function float CoordMove(float x1, float x2, float step)
{
	if (abs(x1-x2)<=step)
		return x2;
	else
	{
		if (x1 < x2)
			return x1+step;
		else
			return x1-step;
	}
}
//--------------------------------------------------------------------------------------------------
simulated function Tick( float dt )
{
	local float wPStep;
	local float dist;
	local vector tVector;
	local rotator Rot;
	local vector	StartTrace, EndTrace, HitLocation, HitNormal;
	local Actor		HitActor;
	local Pawn		Pawn;
	local KFDoorMover	Door;
	
	if (Level.NetMode==NM_Standalone)
		PostNetReceive();
	
	// very unefficient method
	if (WeldBotUseActor!=none)
		WeldBotUseActor.SetLocation(GetBoneCoords('Neck01').Origin);

	Pawn = KFHumanPawn(WeldTarget);
	Door = KFDoorMover(WeldTarget);
	WeldBoneLocation = GetBoneCoords('tip').Origin;
	wPStep = FRand()*0.1f; // скорость перемещения лазера
	
	if (bDebug)
		DrawDebugLines();
	
	if (bWeldingClient)
	{
		if (NextWeldEffectTime < Level.TimeSeconds)
		{
			//class'WeldBotHitEmitter'.default.VolMin = SparkVolMin;
			//class'WeldBotHitEmitter'.default.VolMax = SparkVolMax;
			Spawn(class'WeldBotHitEmitter',self,, wPCurClient, RotRand());
			//SetTimer(FClamp(FRand(),0.1f,0.4f),false);
			NextWeldEffectTime = Level.TimeSeconds + FClamp(FRand(),0.1f,0.4f);
		}
		if (Door!=none)
		{
			if (wPCurClient==wPNext)
			{	// ищем следующую точку, к которой двигать лазер
				if (wPNext.Z==wPEnd.Z)
				{
					tVector=wPEnd;
					wPEnd=wPStart;
					wPStart=tVector;
				}
				
				// покачиваем лазер влево-вправо
				tVector = wPStart;
				tVector.z = wPNext.Z;
				Rot = rotator(tVector - WeldBoneLocation);
				if (bWeldOffset)
					Rot.Yaw += Rand(1500);
				else
					Rot.Yaw -= Rand(1500);
				bWeldOffset=!bWeldOffset;
				
				StartTrace = WeldBoneLocation;
				dist = VSize(wPCur - StartTrace);
				EndTrace = StartTrace + vector(Rot)*(dist*1.1f);
				HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);
				if (KFDoorMover(HitActor)!=none && KFDoorMover(HitActor)!=none && KFDoorMover(WeldTarget).Tag == KFDoorMover(HitActor).Tag)
					wPNext = HitLocation;
				
				wPNext.z = CoordMove(wPNext.z, wPEnd.z, abs(wPStart.z-wPEnd.z)*0.1 );
			}		
		}
		else if (Pawn!=none)
		{
			if (WeldTargetLocation!=WeldTarget.Location) // если позиция игрока изменилась
			{
				WeldTargetLocation = WeldTarget.Location;
				GetWeldPathPoints(false);
			}
			if (wPCurClient==wPNext)
				GetWeldPathPoints(true); // get new wPNext
		}

		// Плавно двигаем лазер к следующей точке wPNext
		wPCurClient.x = CoordMove(wPCurClient.x, wPNext.x, wPStep);
		wPCurClient.y = CoordMove(wPCurClient.y, wPNext.y, wPStep);
		wPCurClient.z = CoordMove(wPCurClient.z, wPNext.z, wPStep);

		if (Lazor==none)
			Lazor=Spawn(Class'WeldBotLazor',Self,,WeldBoneLocation, rotator(wPCurClient-WeldBoneLocation));
		Lazor.SetLocation(WeldBoneLocation);
		Lazor.SetRotation(rotator(wPCurClient-WeldBoneLocation));
		dist = VSize(wPCurClient-WeldBoneLocation);
		Lazor.BM.BeamEndPoints[0].Offset.X.Min = dist;
		Lazor.BM.BeamEndPoints[0].Offset.X.Max = dist;
	}
}

//------------------------------Добавленно мной---------------------------------------------

//--------------------------------------------------------------------------------------------------
/*simulated function Timer()
{
	if (bWelding)
	{
		class'WeldBotHitEmitter'.default.VolMin = SparkVolMin;
		class'WeldBotHitEmitter'.default.VolMax = SparkVolMax;
		Spawn(class'WeldBotHitEmitter',self,,wPCur, RotRand() );
		SetTimer(FClamp(FRand(),0.1f,0.4f),false);
	}
}*/
//--------------------------------------------------------------------------------------------------
function bool bDoorValid(KFDoorMover Door)
{
	return (Door.bClosed==true
			&& Door.bSealed==true
			&& Door.WeldStrength < Door.MaxWeld
			&& Door.MyTrigger!=none
			&& Door.bDisallowWeld==false
			&& Door.bDoorIsDead==false);
}
//--------------------------------------------------------------------------------------------------
simulated function bool TraceDoor(KFDoorMover Door)
{
	local vector	StartTrace, EndTrace, HitLocation, HitNormal;
	local Actor HitActor;
	StartTrace = Location;
	EndTrace = GetDoorCenter(Door);
	HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);
	if (KFDoorMover(HitActor)!=none && KFDoorMover(HitActor).tag == Door.tag)
		return true;
	else
		return false;
}
//--------------------------------------------------------------------------------------------------
function AddDoor(KFDoorMover Door)
{
	local vector L;
	if (bDoorValid(Door)==false)
		return;

	if (TraceDoor(Door)==false)
		return;

	L=WeldBotController(Controller).NearestDoorPoint(Door);
	if (WeldBotController(Controller).bTooFar(L,true))
		return;

	NearDoors.Insert(0,1);
	NearDoors[0]=Door;
}
//--------------------------------------------------------------------------------------------------
function BadDoor(KFDoorMover Door)
{
	local int i;
	for (i=0; i<NearDoors.Length; i++)
		if (NearDoors[i]==Door)
			NearDoors.Remove(i,1);
}
//--------------------------------------------------------------------------------------------------
function bool FindDoors(optional float Distance)
{
	local KFDoorMover Door;
	local Actor RelActor;
	// Clear old doors and find new
	if (NearDoors.Length != 0)
		NearDoors.Remove(0,NearDoors.Length);

	// ищем их заново
	if (BotState==Stay || BotState==WeldDoors)
		RelActor=HomeActor;
	else
		RelActor=self;

	foreach RelActor.CollidingActors(class'KFDoorMover',Door,sqrt(MaxDistanceToOwner))
		AddDoor(Door);

	return (NearDoors.Length != 0);
}
//--------------------------------------------------------------------------------------------------
function Message(Controller C, int message_switch)
{
	if (KFPlayerController(C)!=none)
		KFPlayerController(C).ReceiveLocalizedMessage(class'WeldBotMessage', message_switch);
}
//--------------------------------------------------------------------------------------------------
function SetHomeLocation(vector loc)
{
	if (HomeActor==none || HomeActor==OwnerPawn)
		HomeActor=spawn(class'WeldBotHomeActor');
	if (HomeActor==none || HomeActor==OwnerPawn)
	{
		log("WeldBot: SetHomeLocation - Error: cant spawn WeldBotHomeActor");
		return;
	}
	HomeActor.SetLocation(loc);
}
//--------------------------------------------------------------------------------------------------
static function EState StringToState(string input)
{
	if (caps(input)=="FOLLOW") return Follow;
	if (caps(input)=="STAY") return Stay;
	if (caps(input)=="WELDDOORS") return WeldDoors;
	return Stay;
}
//--------------------------------------------------------------------------------------------------
static function string StateToString(EState input)
{
	if (input==Follow) return "FOLLOW";
	if (input==Stay) return "STAY";
	if (input==WeldDoors) return "WELDDOORS";
	return "STAY";
}
//--------------------------------------------------------------------------------------------------
// Set localized (client-side) BotName
simulated function ClientSetBotName()
{
	if (Level.NetMode==NM_Client)
		BotName=Default.BotName;
	else
		BotName=Default.BotName;
	//PlayerController(OwnerPawn.Controller).ConsoleCommand("mutate WELDBOTNAME"@DefaultBotName,false);
}
//--------------------------------------------------------------------------------------------------
function SetBotName(string S)
{
	if (Len(S) > 0)
	{
		BotName=S;
		RepInfo.BotName = S;
	}
}
//--------------------------------------------------------------------------------------------------
function SetBotState(EState S)
{
	BotState = S;
	WeaponOwner.SetBotState(S);
	RepInfo.BotState = S;
}
//--------------------------------------------------------------------------------------------------
function SetDistance(float D)
{
	if (D > 0.f)
	{
		MaxDistanceToOwner = D;
		RepInfo.Distance = D;
	}
}
//--------------------------------------------------------------------------------------------------
function SetHealth(optional float F, optional bool bInitial)
{
	local int H;
	if (bInitial)
		Health = F;
	H = GetHealth();
//	RepInfo.Health = H;
	WeaponOwner.SetHealth(H);
}
//--------------------------------------------------------------------------------------------------
function SetParams(EState inState, optional float Dist, optional string inBotName)
{
	if (WeldBotSetupIcon!=none)
	{
		WeldBotSetupIcon.Destroy();
		WeldBotSetupIcon=none;
	}
	if (BotState!=inState)
	{
		SetBotState(inState);
		switch (BotState)
		{
			case Stay:
				SetHomeLocation(Location);
				Message(OwnerPawn.Controller, 4);
				Controller.GotoState('FollowOwner');
				break;
			case WeldDoors:
				SetHomeLocation(Location);
				Message(OwnerPawn.Controller, 5);
				FindDoors(); // Fill NearDoors array
				Controller.GotoState('WeldDoors');
				break;
			case Follow:
			default:
				if (HomeActor!=none && HomeActor!=OwnerPawn)
					HomeActor.Destroy();
				HomeActor=OwnerPawn;
				Message(OwnerPawn.Controller, 3);
				Controller.GotoState('FollowOwner');
		}
		SetAnim(Twich);
	}
	SetDistance(Dist);
	SetBotName(inBotName);
}
//--------------------------------------------------------------------------------------------------
function UsedBy(Pawn user)
{
	local KFPlayerController PC;
	local vector TraceStart,TraceEnd, TraceLocation, TraceNormal;
	local bool bTraceActors;
	local Actor TraceActor;
	PC = KFPlayerController(user.Controller);
	if (PC==none) return;

	TraceStart	= user.Location + user.EyePosition();
	TraceEnd	= TraceStart + vector(user.Controller.GetViewRotation()) * 250.f;
	bTraceActors=true;
	TraceActor = user.Controller.Trace(TraceLocation, TraceNormal, TraceEnd, TraceStart, bTraceActors,UsedByTraceWidth);
	if (WeldBot(TraceActor)!=self || PC.CanSee(self)==false)
	{
		if (bDebug) M("You don't see me, so why use?");
		return;
	}
	if (OwnerPawn!=user)
	{
		Message(user.controller,6); // "You are not my owner!"
		return;
	}
	
	if (WeldBotSetupIcon==none)
		WeldBotSetupIcon = Spawn(Class'WeldBotSetupIcon', self);
	if (WeldBotSetupIcon!=none)
		AttachToBone(WeldBotSetupIcon,'TopHeadClaw_Base');

	PC.StopForceFeedback();
	PC.ClientOpenMenu(string(Class'WeldBotMenu'),,StateToString(BotState),string(MaxDistanceToOwner));
	return;
}
//--------------------------------------------------------------------------------------------------
simulated function float GetHealth()
{
  return ((float(Health)/ float(SentryHealth)) * 100.f);
}
//--------------------------------------------------------------------------------------------------
simulated function SetOwningPlayer(Pawn Other, WeldBotGun W, optional bool bNotifyNewOwner)
{
	WeaponOwner	= W; // must be first
	OwnerPawn	= Other;
	RepInfo.SetOwnerPC(PlayerController(Other.Controller));
	HomeActor	= OwnerPawn;
	PlayerReplicationInfo = Other.PlayerReplicationInfo;

	
	SetBotState(Follow);
	SetDistance(default.MaxDistanceToOwner);
	SetHealth(SentryHealth, true);
	if (bNotifyNewOwner)
		Message(Other.Controller,7);

	// Set localized (client-side) BotName
	//BotName=GetBotName(PlayerReplicationInfo);
	if (Len(BotName)==0)
		ClientSetBotName();
	
	WeldBotController(Controller).Restart();
}
//--------------------------------------------------------------------------------------------------
/*function string GetBotName(PlayerReplicationInfo PRI)
{
	local KFPlayerController PC;
	local WeldBotNickMut nMut;

	PC = KFPlayerController(PRI.Owner);
	if (PC==none) {return "";}

	foreach DynamicActors(class'WeldBotNickMut',nMut)
		return nMut.GetBotNameByPC(PC);
	return "";
}*/
//--------------------------------------------------------------------------------------------------
event PostBeginPlay()
{
	local Mutator M;
	
	Super.PostBeginPlay();
	
	if ( ControllerClass != None && Controller == None )
		Controller = Spawn(ControllerClass);

	/* Controllers take control of a pawn using their Possess() method,
	 * and relinquish control of the pawn by calling UnPossess(). */
	if (Controller != None)
		Controller.Possess(self);

	bBlockActors=false;		

	CheckLanguage();
	bLangChecked=true; //bLangCheckedClient=true;
	
	//if (Level.NetMode!=NM_Client || Level.NetMode==NM_Standalone)
	//{
		WeldBotUseActor = spawn(class'WeldBotUseActor', self);
		WeldBotUseActor.WeldBot = self;
		AttachToBone(WeldBotUseActor,'Neck01');
	//}
	
	if (RepInfo == none)
	{
		RepInfo = Spawn(class'WeldBotReplicationInfo');
		RepInfo.WeldBot = self;
	}

	// Spawn Mutator. Will listen mutate messages for Client2Server replication
	if (Level.NetMode != NM_Client)
	{
		if (WMut==none)
		{
			for (M = Level.Game.BaseMutator; M != None; M = M.NextMutator)
			{
				if (M.Class == class'WeldBotMut')
				{
					WMut=WeldBotMut(M);
					break;
				}
			}
			if (WMut==none)
				Level.Game.AddMutator("chippo.WeldBotMut");

			for (M = Level.Game.BaseMutator; M != None; M = M.NextMutator)
			{
				if (M.Class == class'WeldBotMut')
				{
					WMut=WeldBotMut(M);
					break;
				}
			}
		}
		if (WMut==none)
			log("Error: WeldBotMut not loaded");
	}
}
//--------------------------------------------------------------------------------------------------
simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	//if ( Level.NetMode == 3 )
	//{
		bNetNotify = true;
		PostNetReceive();
	//}
}
//--------------------------------------------------------------------------------------------------
simulated function CheckLanguage()
{
	if (Level.NetMode!=NM_DedicatedServer)
	{
		if (class'WeldBotLangSetup'.static.IsRussia())
		{
			class'WeldBotLangSetup'.static.InitRussia();
			MSG_ModeStay		= class'WeldBotLangSetup'.default.MSG_ModeStay;
			MSG_ModeWeldDoors	= class'WeldBotLangSetup'.default.MSG_ModeWeldDoors;
			OwnerText			= class'WeldBotLangSetup'.default.OwnerText;
			if (DefaultBotName==default.DefaultBotName)
				DefaultBotName		= class'WeldBotLangSetup'.default.DefaultBotName;
		}
	}
}
//--------------------------------------------------------------------------------------------------			
simulated function PostNetReceive()
{
	Super.PostNetReceive();
	if ( CurAnim != RepAnim )
	{
		//Level.GetLocalPlayerController().ClientMessage("Anim Changed");
		CurAnim=RepAnim;
		SetAnim(RepAnim);
	}
	if (bLangChecked!=bLangCheckedClient && bLangChecked==true)
	{
		bLangCheckedClient=bLangChecked;
		CheckLanguage();
	}
			
	if (bWelding==true && (bWelding!=bWeldingClient || WeldTargetClient!=WeldTarget) && wPCurClient!=wPCur)
	{
		bWeldingClient=bWelding;
		WeldTargetClient=WeldTarget;
		wPCurClient=wPCur;
		StartWeld(WeldTargetClient);
	}
	if (bWelding==true && KFHumanPawn(WeldTarget)!=none && wPCurClient==vect(0,0,0) && wPCurClient!=wPCur)
	{
		wPCurClient=wPCur;
	}
	if (bWeldingClient!=bWelding && bWelding==false)
	{
		bWeldingClient=false;
		wPCurClient = vect(0,0,0);
		StopWeld();
	}
	/*
	if ( BotStateClient != BotState )
	{
		BotStateClient = BotState;
		WeaponOwner.BotState = BotState;
		WeaponOwner.SetBotState(BotState);
	}
	if (ClientHealth != Health)
	{
		ClientHealth = Health;
		WeaponOwner.Health = Health;
	}
	*/
}
//--------------------------------------------------------------------------------------------------
simulated function SetAnim(EAnim Anim, optional int Channel)
{
	local bool bDbg;
	bDbg = false;
	if (Anim!=Fire)
	{
		SetTimer(0.0,False);
	}
	
	switch (Anim)
	{
		case TurnLeft:
			if (bDbg) Level.GetLocalPlayerController().ClientMessage("Anim TurnLeft");
			LoopAnim('Turn', 0.5, 0.2);
			break;
		case TurnRight:
			if (bDbg) Level.GetLocalPlayerController().ClientMessage("Anim TurnRight");
			LoopAnim('Turn', 0.5, 0.2);
			break;
		case TurnStop:
			if (bDbg) Level.GetLocalPlayerController().ClientMessage("Anim StopTurnAnimLooping");
			AnimStopLooping(0);
			break;
		case Stop:
			if (bDbg) Level.GetLocalPlayerController().ClientMessage("Anim Stop");
			PlayAnim('Idle2');
			StopAnimating();
			break;
		case Fire:
			if (bDbg) Level.GetLocalPlayerController().ClientMessage("Anim Fire");
			PlayAnim('Idle2');
			StopAnimating(); // у бота нет анимации стрельбы, поэтому останавливаем всю анимацию
			break;
		case Idle:
			if (bDbg) Level.GetLocalPlayerController().ClientMessage("Anim Idle");
			/*if (CurAnim!=Idle)
				Speech(SndOther[0]);*/
			LoopAnim('Idle2',0.8, 0.2);
			break;
		case Twich:
			if (bDbg) Level.GetLocalPlayerController().ClientMessage("Anim Twich");
			PlayAnim('CB_Twich',1.0,0.5);
			break;
		case Walk:
			if (bDbg) Level.GetLocalPlayerController().ClientMessage("Anim WalkNorth");
			LoopAnim('CB_WalkNorth', 1.0, 0.2);
			break;
		case Spawned:
			if (bDbg) Level.GetLocalPlayerController().ClientMessage("Anim SpawnedOpen");
			PlayAnim('CB_Spawned_Open');
			break;
	}
	CurAnim = Anim;
	RepAnim = Anim;
	bPhysicsAnimUpdate = False;
}
//--------------------------------------------------------------------------------------------------
final simulated function name GetCurrentAnim()
{
  local name Anim;
  local float frame;
  local float Rate;

  GetAnimParams(0,Anim,frame,Rate);
  return Anim;
}
//--------------------------------------------------------------------------------------------------
simulated function AnimEnd(int Channel)
{
	/*if (bPhysicsAnimUpdate )
		return;
	bPhysicsAnimUpdate = true;*/
	bPhysicsAnimUpdate = false;
	if (Controller != None)
		Controller.AnimEnd(Channel);
}
//--------------------------------------------------------------------------------------------------
simulated function RunStep()
{
	PlaySound(SndFootStep[Rand(SndFootStep.Length)],SLOT_Misc,1.5,,350.0);
}
//--------------------------------------------------------------------------------------------------
function TakeDamage(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, Class<DamageType> DamageType, optional int HitIndex)
{
  if ( KFHumanPawn(instigatedBy) != None )
  {
    return;
  }
	Super.TakeDamage(Damage,instigatedBy,HitLocation,Momentum,DamageType,HitIndex);
	SetHealth();
	Speech(SndPain[Rand(SndPain.Length)]);
}
//--------------------------------------------------------------------------------------------------
function Speech(Sound SND)
{
	PlaySound(SND,SLOT_Talk,2.5,,450.0);
}
//--------------------------------------------------------------------------------------------------
/*final function Speech(byte Num)
{
	local Sound S;

	if ( NextVoiceTimer > Level.TimeSeconds )
		return;
	NextVoiceTimer = Level.TimeSeconds + 1.0 + FRand() * 2.0;
	switch (Num)
	{
		case 0:
			S = VoicesList[0];
			break;
		case 1:
			S = VoicesList[1 + Rand(2)];
			break;
		case 2:
			S = VoicesList[4 + Rand(2)];
			break;
		case 3:
			S = VoicesList[6];
			break;
		case 4:
			S = VoicesList[7 + Rand(4)];
			break;
		case 5:
			S = VoicesList[11];
			break;
		case 6:
			S = VoicesList[12];
			break;
		case 7:
			S = VoicesList[13 + Rand(3)];
			break;
		default:
	}
	PlaySound(S,SLOT_Talk,2.5f,,450.f);

}
*/
//--------------------------------------------------------------------------------------------------
// используется в стейте Dying для взрыва
simulated function HurtRadius(float DamageAmount, float DamageRadius, Class<DamageType> DamageType, float Momentum, Vector HitLocation)
{
	local Actor Victims;
	local float damageScale;
	local float dist;
	local Vector Dir;
	local int NumKilled;
	local KFMonster KFMonsterVictim;
	local Pawn P;

	if ( bHurtEntry )
		return;
	bHurtEntry = True;
	if ( OwnerPawn != None )
		P = OwnerPawn;
	else
		P = self;
	foreach CollidingActors(Class'Actor',Victims,DamageRadius,HitLocation)
	{
		if ( (Victims != self) && (Victims.Role == 4) &&  !Victims.IsA('FluidSurfaceInfo') && (ExtendedZCollision(Victims) == None) && (KFPawn(Victims) == None) && (WeldBot(Victims) == None) )
		{
			Dir = Victims.Location - HitLocation;
			dist = FMax(1.0,VSize(Dir));
			Dir = Dir / dist;
			damageScale = 1.0 - FMax(0.0,(dist - Victims.CollisionRadius) / DamageRadius);
			KFMonsterVictim = KFMonster(Victims);
			if ( (KFMonsterVictim != None) && (KFMonsterVictim.Health <= 0) )
				KFMonsterVictim = None;
			if ( KFMonsterVictim != None )
				damageScale *= KFMonsterVictim.GetExposureTo(HitLocation);
			if ( damageScale <= 0 )
				continue;
			else
			{
				Victims.TakeDamage(int(damageScale * DamageAmount),P,Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * Dir,damageScale * Momentum * Dir,DamageType);
				if ( (Role == 4) && (KFMonsterVictim != None) && (KFMonsterVictim.Health <= 0) )
					NumKilled++;
			}
		}
	}
	if ( Role == 4 )
	{
		if ( NumKilled >= 4 )
			KFGameType(Level.Game).DramaticEvent(0.05);
		else
		{
			if ( NumKilled >= 2 )
				KFGameType(Level.Game).DramaticEvent(0.03);
		}
	}
	bHurtEntry = False;
}
//--------------------------------------------------------------------------------------------------
// 1 WeldBot: Died()
// 2 WeldBot: PlayDying()
// 3 WeldBot: Dying - Begin state
// 4 WeldBot: Dying - End state
// 5 WeldBot: Destroyed()
//--------------------------------------------------------------------------------------------------
simulated function Destroyed()
{
	if (HomeActor!=none && HomeActor!=OwnerPawn)
		HomeActor.Destroy();

	if ( Controller != None )
	{
		Controller.bIsPlayer = False;
		Controller.Destroy();
	}
	/*
	if (WeaponOwner!=none)
		WeaponOwner.Destroy();
	*/
	if (WeaponOwner != none)
	{
		if ( (OwnerPawn != None) && (PlayerController(OwnerPawn.Controller) != None) )
			PlayerController(OwnerPawn.Controller).ReceiveLocalizedMessage(Class'WeldBotMessage',2);

		if (OwnerPawn!=none && OwnerPawn.Weapon.Class == WeaponOwner.Class)
			WeaponOwner.BotDestroyed();
		else 
		{
			WeaponOwner.CurrentWeldBot = None;
			WeaponOwner.DetachFromPawn(OwnerPawn);
			WeaponOwner.Destroy();
			WeaponOwner = None;
		}
	}
}
//--------------------------------------------------------------------------------------------------
function Died (Controller Killer, Class<DamageType> DamageType, Vector HitLocation)
{
	PlayerReplicationInfo = None;
	if ( Controller != None )
		Controller.bIsPlayer = False;
	Speech(SndOther[1]);
	Super.Died(Killer,DamageType,HitLocation);
}
//--------------------------------------------------------------------------------------------------
simulated event PlayDying(Class<DamageType> DamageType, Vector HitLoc)
{
	AmbientSound = None;
	GotoState('Dying');
	bReplicateMovement = False;
	bTearOff = True;
	Velocity += TearOffMomentum;
	SetPhysics(PHYS_Falling);
	bPlayedDeath = true;
	PlayAnim('Idle2');
}
//--------------------------------------------------------------------------------------------------
state Dying
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, TakeDamage, Landed, SetAnim, Timer;

	simulated function EndState ()
	{
		local Emitter E;
		if( Level.NetMode!=NM_DedicatedServer )
		{
			E = Spawn(Class'PanzerfaustHitConcrete_simple');
			if ( E != None )
				E.RemoteRole = ROLE_None;
			PlaySound(SoundGroup'KF_LAWSnd.Rocket_Explode',SLOT_Pain,2.5,,800.0);
		}
		HurtRadius(400.0,500.0,Class'DamTypeFrag',100000.0,Location);
	}

	simulated function BeginState()
	{
		local int i;
		StopWeld();
		LifeSpan = 1.75;
		SetPhysics(PHYS_Falling);
		SetCollision(False);
		if ( Controller != None )
			Controller.Destroy();
		if ( Controller != None )
			Controller.Destroy();
		for (i = 0; i < Attached.length; i++)
			if (Attached[i] != None)
				Attached[i].PawnBaseDied();
	}
Begin:
}
//--------------------------------------------------------------------------------------------------
simulated function Explode(Vector HitLocation, Vector HitNormal)
{
	SetPhysics(PHYS_none);
	if ( Level.NetMode != 1 )
		Spawn(Class'ROBulletHitEffect',,,Location,rotator( -HitNormal));
	BlowUp(HitLocation);
	Destroy();
}
//--------------------------------------------------------------------------------------------------
simulated function BlowUp(Vector HitLocation)
{
	if ( Role == 4 )
		MakeNoise(1.0);
}
//--------------------------------------------------------------------------------------------------
function M(string in)  // for debugging
{
	PlayerController(OwnerPawn.Controller).ClientMessage(in);
}
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------

defaultproperties
{
     WeldSpeed=1
     SentryHealth=5000
     SndFootStep(0)=Sound'chippo.Sentry.Sentry_sstep_01'
     SndFootStep(1)=Sound'chippo.Sentry.Sentry_sstep_02'
     SndFootStep(2)=Sound'chippo.Sentry.Sentry_sstep_03'
     SndFootStep(3)=Sound'chippo.Sentry.Sentry_sstep_04'
     SndFootStep(4)=Sound'chippo.Sentry.Sentry_sstep_05'
     SndFootStep(5)=Sound'chippo.Sentry.Sentry_sstep_06'
     SndFootStep(6)=Sound'chippo.Sentry.Sentry_sstep_07'
     SndPain(0)=Sound'chippo.Sentry.Sentry_pain_01'
     SndPain(1)=Sound'chippo.Sentry.Sentry_pain_02'
     SndPain(2)=Sound'chippo.Sentry.Sentry_pain_03'
     SndPain(3)=Sound'chippo.Sentry.Sentry_pain_04'
     SndFire(0)=Sound'chippo.Sentry.WeldTransformerCrop'
     SndOther(0)=Sound'chippo.Sentry.Sentry_shutdown_01'
     SndOther(1)=Sound'chippo.Sentry.Sentry_destroyed_01'
     SndOther(2)=Sound'chippo.Sentry.Sentry_fight_enemy_02'
     SndOther(3)=Sound'chippo.Sentry.Sentry_sight_enemy_01'
     SndOther(4)=Sound'chippo.Sentry.Sentry_activate_01'
     SndOther(5)=Sound'chippo.Sentry.Sentry_wait_for_player_02'
     UsedByTraceWidth=(X=10.000000,Y=10.000000,Z=1.000000)
     OwnerText="Owner"
     MSG_ModeStay="Staying"
     MSG_ModeWeldDoors="Holding doors"
     DefaultBotName="Welding bot"
     MaxDistanceToOwner=360000.000000
     MaxShootDistance=14000.000000
     SightRadius=6500.000000
     PeripheralVision=-1.000000
     GroundSpeed=200.000000
     JumpZ=350.000000
     BaseEyeHeight=0.000000
     EyeHeight=0.000000
     Health=500
     ControllerClass=Class'chippo.WeldBotController'
     bStasis=False
     Physics=PHYS_Falling
     Mesh=SkeletalMesh'chippo.chippoDTMesh'
     PrePivot=(Z=-24.549999)
     CollisionRadius=5.000000
     CollisionHeight=20.000000
     bNetNotify=True
}
