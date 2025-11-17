class RPGShell3rd extends Actor;

var Actor Taker;
var bool bSticked,bShowMe;
replication
{
	reliable if ( Role == ROLE_Authority )
		Taker,bShowMe;
}

function TransferActor(Actor A)
{
	Taker=A;
}

simulated function UnStick()
{
	Taker.DetachFromBone(Self);
}
//добавить самоуничтожение дл€ клиентских версий?
simulated function Tick(float delta)
{
	if(!bSticked)
		Stick();
	if(bShowMe)
		bHidden=false;
	else
		bHidden=true;
	Super.Tick(delta);
}

simulated function Stick()
{
	local Rotator rot;
	local Vector loc;
	//Log("RPGShell3rd.Stick"@Taker);
	Taker.AttachToBone(Self,'WeaponL_Bone');
	rot.Yaw=-3000;
	rot.Pitch=10000;
	rot.Roll=0;
	SetRelativeRotation(rot);
	bSticked=true;
	loc.X=0;
	loc.Y=3;
	loc.Z=-2.5;
	SetRelativeLocation(loc);
}

defaultproperties
{
	StaticMesh = StaticMesh'RPG7DTv2_A.GrenadeLoad'
	DrawType = DT_StaticMesh
	Physics = PHYS_None
	DrawScale=0.65

	RemoteRole=ROLE_SimulatedProxy //Flame
	bGameRelevant=True //Flame иначе не работала клиентска€ часть. ¬з€то из Projectile
}