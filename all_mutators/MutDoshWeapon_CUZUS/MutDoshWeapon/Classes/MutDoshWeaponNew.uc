class MutDoshWeaponNew extends Mutator;

var config bool bUseDoshAsWeapon;
var() config float DoshWeaponDamageScale;
var config int DoshWeaponMinDropAmount;
var config int DoshWeaponMaxDropAmount;
var Interaction _doshWeaponInteraction;

simulated function Tick(float DeltaTime)
{
    local PlayerController PC;

    PC = Level.GetLocalPlayerController();

    if (PC != none)
	{
		if (default.bUseDoshAsWeapon && _doshWeaponInteraction == none)
		{
			// event Interaction AddInteraction(string InteractionName, optional Player AttachTo)
			// _doshWeaponInteraction = PC.Player.InteractionMaster.AddInteraction("KF15BetaMutators.InteractionDoshWeapon", PC.Player);
		}

		Disable('Tick');
    }
}

function Mutate(string MutateString, PlayerController Sender)
{
    local array<string> parts;
    local int numArg;

    Split(MutateString, " ", parts);

    if (parts[0] ~= "tosscash" && bUseDoshAsWeapon)
	{
        if (parts.Length == 1)
		{
            numArg = 50;
        }
		else
		{
            numArg = int(parts[1]);
            if (numArg <= 0 )
				numArg = 50;
        }

		ThrowDosh(Sender, numArg);
    }
	else
	{
        super.Mutate(MutateString, Sender);
    }
}

function ThrowDosh(PlayerController Sender, int Amount)
{
	local Vector X,Y,Z;
    local CashPickupDoshWeapon CashPickup;
    local Vector TossVel;
	local KFPawn kfPawn;

    kfPawn = KFPawn(Sender.Pawn);

    if (kfPawn != None)
	{
		if (Amount <= 0)
		{
			Amount = 50;
		}

        Sender.PlayerReplicationInfo.Score = int(Sender.PlayerReplicationInfo.Score); // To fix issue with throwing 0 pounds.

        if (Sender.PlayerReplicationInfo.Score > 0 && Amount > 0)
		{
            Amount = Min(Amount, int(Sender.PlayerReplicationInfo.Score));
            kfPawn.GetAxes(Rotation,X,Y,Z);

            TossVel = Vector(kfPawn.GetViewRotation());
            TossVel = TossVel * ((kfPawn.Velocity Dot TossVel) + 500) + Vect(0,0,200);

            CashPickup = Spawn(class'CashPickupDoshWeapon',,,kfPawn.Location + 0.8 * kfPawn.CollisionRadius * X - 0.5 * kfPawn.CollisionRadius * Y);

            if (CashPickup != none)
			{
                CashPickup.damageScale = default.DoshWeaponDamageScale;
                CashPickup.CashAmount = Amount;
                CashPickup.bDroppedCash = true;
                CashPickup.RespawnTime = 0;   // Dropped cash doesnt respawn. For obvious reasons.
                CashPickup.Velocity = TossVel;
                CashPickup.DroppedBy = Sender;
                CashPickup.InitDroppedPickupFor(None);
                Sender.PlayerReplicationInfo.Score -= Amount;

                if (Level.Game.NumPlayers > 1 && Level.TimeSeconds - kfPawn.LastDropCashMessageTime > kfPawn.DropCashMessageDelay)
				{
                    Sender.Speech('AUTO', 4, "");
                }
            }
        }
	}
}

defaultproperties
{
	DoshWeaponDamageScale=0.5
	DoshWeaponMinDropAmount=50
	DoshWeaponMaxDropAmount=50
}
