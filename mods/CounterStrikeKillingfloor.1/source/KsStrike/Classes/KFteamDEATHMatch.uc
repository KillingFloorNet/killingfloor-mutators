class KFteamDeathMatch extends xteamgame;

var bool startover, bmenu, btraderbluedead, btraderreddead, thereistrader,
    canvip, bendedgames;
var int Countdownz, traderteam;
var controller trader;

function prebeginplay() {
    local kflevelrules kl;

    foreach
        allactors(class 'kflevelrules', kl) if (kl != none) kl.destroy();

    spawn(class 'zLevelRules');

    super.prebeginplay();
    remainingtime = class 'tdmmutator'.default.timelimit * 60;

    canvip = class 'tdmmutator'.default.canvip;
    friendlyfirescale = class 'tdmmutator'.default.friendlyfirescale / 100;
    minplayers = class 'tdmmutator'.default.minplayers;
}

function AddDefaultInventory(pawn PlayerPawn) {
    PlayerPawn.giveweapon("KFMod.knife");
    PlayerPawn.giveweapon("KFMod.single");
    PlayerPawn.giveweapon("ksstrike.fragz");

    playerpawn.giveweapon(
        string(zombieplayercontroller(playerpawn.controller).boughtweapon1));

    playerpawn.giveweapon(
        string(zombieplayercontroller(playerpawn.controller).boughtweapon2));

    kfhumanpawn(playerpawn).shieldstrength =
        zombieplayercontroller(playerpawn.controller).zshieldstrength;
    SetPlayerDefaults(PlayerPawn);

    if (playerpawn.controller.isa('bot')) {
        switch (rand(4)) {
            case 1:
                PlayerPawn.giveweapon("KFMod.ak47assaultrifle");
                playerpawn.playerreplicationinfo.score -= 1000;
                break;
            case 2:
                PlayerPawn.giveweapon("KFMod.bullpup");
                playerpawn.playerreplicationinfo.score -= 400;
                break;
            case 3:
                PlayerPawn.giveweapon("KFMod.winchester");
                playerpawn.playerreplicationinfo.score -= 200;
                break;
            case 4:
                PlayerPawn.giveweapon("KFMod.law");
                playerpawn.playerreplicationinfo.score -= 1500;
                break;
        }
    }

    if (PlayerPawn.playerreplicationinfo != none &&
        PlayerPawn.playerreplicationinfo.score <= 0)
        PlayerPawn.playerreplicationinfo.score = 500;
}

function scorekill(controller killer, controller other) {
    if (killer.playerreplicationinfo.team.teamindex == 0 &&
        teams[0].score >= goalscore)
        super.scorekill(killer, other);
    else if (killer.playerreplicationinfo.team.teamindex == 1 &&
             teams[1].score >= goalscore)
        super.scorekill(killer, other);

    if (killer != other) {
        kfplayerreplicationinfo(killer.playerreplicationinfo).kills += 1;
        killer.playerreplicationinfo.score += 100;
    }

    if (zombieplayercontroller(other).bistrader &&
        other.playerreplicationinfo.team.teamindex == 0) {
        btraderreddead = true;
        Kbroadcast("Army VIP is Killed", 255, 0, 0, );
    } else if (zombieplayercontroller(other).bistrader &&
               other.playerreplicationinfo.team.teamindex == 1) {
        btraderbluedead = true;
        Kbroadcast("Police VIP is Killed", 0, 0, 255, );
    }

    startover = true;

    if (other.playerreplicationinfo.team.teamindex == 0 &&
        zombieplayercontroller(other).bistrader == false)
        kbroadcast("" $other.playerreplicationinfo.playername$ " IS OUT", 255,
                   0, 0);
    else if (other.playerreplicationinfo.team.teamindex == 1 &&
             zombieplayercontroller(other).bistrader == false)
        kbroadcast("" $other.playerreplicationinfo.playername$ " IS OUT", 0, 0,
                   255);

    if (zombieplayercontroller(other).bistrader)
        zombieplayercontroller(other).bistrader = false;
}
function int GetPlayers() {
    local controller C;
    local int i;

    for (C = Level.ControllerList; C != None; C = C.NextController) {
        if (c.bisplayer == true) {
            i++;
        }
    }

    return i;
}
function int GetbluePlayers() {
    local controller C;
    local int i;

    for (C = Level.ControllerList; C != None; C = C.NextController) {
        if (c.isa('controller') && c.bisplayer == true &&
            c.playerreplicationinfo.team.teamindex == 1 &&
            c.playerreplicationinfo.boutoflives == false && c.pawn != none) {
            i++;
        }
    }
    return i;
}

function int GetredPlayers() {
    local controller C;
    local int i;

    for (C = Level.ControllerList; C != None; C = C.NextController) {
        if (c.isa('controller') && c.bisplayer == true &&
            c.playerreplicationinfo.team.teamindex == 0 &&
            c.playerreplicationinfo.boutoflives == false && c.pawn != none) {
            i++;
        }
    }
    return i;
}
Function KBroadcast(string msg, int r, int g, int b, optional sound plays) {
    local controller C;

    for (C = Level.ControllerList; C != None; C = C.NextController) {
        if (c != none && playercontroller(C) != none) {
            PlayerController(C).ClearProgressMessages();
            PlayerController(C).SetProgressTime(6);
            PlayerController(C).SetProgressMessage(
                0, Msg, class 'Canvas'.Static.MakeColor(r, g, b));

            PlayerController(C).clientplaysound(plays, true, 64);
        }
    }
}
function spectateit(controller c) {
    c.gotostate('spectating');
    c.unpossess();
    c.playerreplicationinfo.boutoflives = true;
}

function restartall() {
    local controller c;
    local pawn p;
    local weaponpickup w;

    foreach
        allactors(class 'pawn', p) if (kfhumanpawn(p) != none &&
                                       p.physics != phys_walking) p.destroy();

    startover = false;

    if (traderteam == 0)
        traderteam = 1;
    else
        traderteam = 0;

    thereistrader = false;
    btraderbluedead = false;
    btraderreddead = false;

    for (C = Level.ControllerList; C != None; C = C.NextController) {
        if (c.pawn != none) {
            zombieplayercontroller(c).zshieldstrength =
                kfhumanpawn(c.pawn).shieldstrength;
            if (zombieplayercontroller(c).bistrader)
                zombieplayercontroller(c).bistrader = false;

            p = c.pawn;
        }

        c.unpossess();
        p.destroy();
        if (c.playerreplicationinfo.boutoflives == false)
            c.playerreplicationinfo.score += 200;

        countdownz = 0;

        c.gotostate('playerwaiting');
        c.playerreplicationinfo.boutoflives = false;
        restartplayer(c);
        if (PlayerController(C) != none) {
            PlayerController(C).ClientSetBehindView(false);

            PlayerController(C).bbehindview = false;
        }

        c.pawn.setphysics(phys_projectile);
    }

    foreach
        allactors(class 'weaponpickup', w) if (w != none) w.destroy();
}
function setphysicsp() {
    local controller c;

    kbroadcast("GO,Go,go...", 255, 255, 255, sound 'lockeddoorsound');

    if (CanVIP) MakeTrader();

    for (C = Level.ControllerList; C != None; C = C.NextController) {
        if (c.pawn != none) c.pawn.setphysics(phys_falling);
    }
}

function maketrader() {
    local controller c, cs[32], p;
    local int i;

    for (C = Level.ControllerList; C != None; C = C.NextController) {
        if (c.playerreplicationinfo.team.teamindex == traderteam &&
            c.isa('playercontroller')) {
            cs[i] = c;
            i++;
        }
    }
    p = cs[rand(i)];
    if (thereistrader == false) {
        zombieplayercontroller(p).bistrader = true;
        if (p.pawn != none) p.pawn.giveweapon("ksstrike.pistolwhip");
        Tbroadcast(p);
        thereistrader = true;
        trader = p;
    }
}
Function TBroadcast(controller p) {
    local controller C;
    local sound plays;

    for (C = Level.ControllerList; C != None; C = C.NextController) {
        if (c != none && playercontroller(C) != none &&
            c.playerreplicationinfo.team.teamindex ==
                p.playerreplicationinfo.team.teamindex) {
            PlayerController(C).ClearProgressMessages();
            PlayerController(C).SetProgressTime(6);
            PlayerController(C).SetProgressMessage(
                0, "Protect the VIP: " $p.PLAYERREPLICATIONINFO.playername,
                class 'Canvas'.Static.MakeColor(255, 255, 255));

            switch (rand(4)) {
                case 1:
                    plays = sound 'tenseconds1';
                case 2:
                    plays = sound 'tenseconds6';
                case 3:
                    plays = sound 'thirtyseconds1';
                case 4:
                    plays = sound 'thirtyseconds5';

                    PlayerController(C).clientplaysound(plays, true, 64);
            }

        } else if (c != none && playercontroller(C) != none &&
                   c.playerreplicationinfo.team.teamindex !=
                       p.playerreplicationinfo.team.teamindex) {
            PlayerController(C).ClearProgressMessages();
            PlayerController(C).SetProgressTime(6);
            PlayerController(C).SetProgressMessage(
                0, "Find and Kill the VIP",
                class 'Canvas'.Static.MakeColor(255, 255, 255));
        }
    }
}

function int ReduceDamage(int Damage, pawn injured, pawn instigatedBy,
                          vector HitLocation, out vector Momentum,
                          class<DamageType> DamageType) {
    if (damagetype == class 'damtypecrossbow') {
        damage = 75;

        if (injured.playerreplicationinfo.team.teamindex ==
            instigatedby.playerreplicationinfo.team.teamindex)
            damage = damage * friendlyfirescale;

        return damage;
    }

    if (injured.playerreplicationinfo.team.teamindex ==
        instigatedby.playerreplicationinfo.team.teamindex)
        damage = damage * friendlyfirescale;

    if (instigatedby.controller.isa('bot'))
        return damage * 0.2;
    else
        return damage * 0.7;
}

function Bot SpawnBot(optional string botName) {
    local Bot NewBot;
    local RosterEntry Chosen;
    local UnrealTeamInfo BotTeam;

    BotTeam = GetBotTeam();
    Chosen = BotTeam.ChooseBotClass(botName);

    if (Chosen.PawnClass == None) Chosen.Init();  // amb
    // log("Chose pawn class "$Chosen.PawnClass);
    NewBot = Spawn(class 'kfinvasionbot');

    if (NewBot != None) InitializeBot(NewBot, BotTeam, Chosen);

    newbot.accuracy = 0;
    // restartplayer(newbot);
    return NewBot;
}

function timer() {
    local controller c;
    local weaponpickup wp;

    foreach
        allactors(class 'weaponpickup', wp) if (wp != none) wp.destroy();

    settimer(1.0, true);
    super.timer();

    if (bendedgames) return;

    countdownz++;

    goalscore = class 'tdmmutator'.default.goalscore;
    default.goalscore = class 'tdmmutator'.default.goalscore;
    bPlayersMustBeReady = false;
    saveconfig();

    for (C = Level.ControllerList; C != None; C = C.NextController) {
        if (kfplayercontroller(c) != none && c.pawn != none) {
            kfplayercontroller(c).bbehindview = false;
            kfplayercontroller(c).setviewtarget(c.pawn);
            kfplayercontroller(c).clientsetbehindview(false);
        }
    }
    if (bmenu == true) {
        for (C = Level.ControllerList; C != None; C = C.NextController) {
            if ((c.playerreplicationinfo != None) &&
                (c.playerreplicationinfo.Team != None) &&
                (c.playerreplicationinfo.Team.Score >= GoalScore) &&
                bendedgames == false) {
                EndGame(c.playerreplicationinfo, "teamscorelimit");
                bendedgames = true;
                return;
            }

            if (kfplayercontroller(c) != none && C.PAWN != NONE) {
                kfplayercontroller(c)
                    .StopForceFeedback();  // jdf - no way to pause feedback

                // Open menu
                kfplayercontroller(c).showbuymenu("Weaponlocker", 15);
            }
        }
        bmenu = false;
    }
    maxplayers = class 'tdmmutator'.default.tdmmaxplayers;

    if (getblueplayers() <= 0 && getredplayers() > 0 && startover == true &&
            getplayers() > 1 ||
        btraderbluedead && getplayers() > 1) {
        teams[0].score += 1;
        restartall();
        bmenu = true;
    } else if (getredplayers() <= 0 && getblueplayers() > 0 &&
                   startover == true && getplayers() > 1 ||
               btraderreddead && getplayers() > 1) {
        teams[1].score += 1;
        restartall();
        bmenu = true;
    } else if (getredplayers() <= 0 && getblueplayers() <= 0 &&
               startover == true) {
        restartall();
        bmenu = true;
    } else if (getblueplayers() <= 0 && getredplayers() > 0 &&
               getplayers() > 1) {
        restartall();
        bmenu = true;
    } else if (getredplayers() <= 0 && getblueplayers() > 0 &&
               getplayers() > 1) {
        restartall();
        bmenu = true;
    } else if (getredplayers() <= 0 && getblueplayers() <= 0 &&
               getplayers() > 1) {
        restartall();
        bmenu = true;
    }

    // if(bmenu&&(teams[0].score>=goalscore||teams[1].score>=goalscore))
    // kbroadcast("Winning team's next kill means goal!",255,255,255);

    if (countdownz == 10) SetphysicsP();
}
function RestartPlayer(Controller aPlayer) {
    local NavigationPoint startSpot;
    local int TeamNum;
    local class<Pawn> DefaultPlayerClass;
    local Vehicle V, Best;
    local vector ViewDir;
    local float BestDist, Dist;

    if (startover == true ||
        getplayers() < 2 && level.netmode != nm_standalone) {
        spectateit(aplayer);

        return;
    }

    if (bRestartLevel && Level.NetMode != NM_DedicatedServer &&
        Level.NetMode != NM_ListenServer)
        return;

    if ((aPlayer.PlayerReplicationInfo == None) ||
        (aPlayer.PlayerReplicationInfo.Team == None))
        TeamNum = 255;
    else
        TeamNum = aPlayer.PlayerReplicationInfo.Team.TeamIndex;

    startSpot = FindPlayerStart(aPlayer, TeamNum);
    if (startSpot == None) {
        log(" Player start not found!!!");
        return;
    }

    if (aPlayer.PreviousPawnClass != None &&
        aPlayer.PawnClass != aPlayer.PreviousPawnClass)
        BaseMutator.PlayerChangedClass(aPlayer);

    if (aPlayer.PawnClass != None && aplayer.pawn == none)
        aPlayer.Pawn = Spawn(class 'kfhumanpawnt', , , StartSpot.Location,
                             StartSpot.Rotation);

    if (aPlayer.Pawn == None) {
        DefaultPlayerClass = GetDefaultPlayerClass(aPlayer);
        aPlayer.Pawn = Spawn(class 'kfhumanpawnt', , , StartSpot.Location,
                             StartSpot.Rotation);
    }
    if (aPlayer.Pawn == None) {
        log("Couldn't spawn player of type " $aPlayer.PawnClass$
            " at " $StartSpot);
        aPlayer.GotoState('Dead');
        if (PlayerController(aPlayer) != None)
            PlayerController(aPlayer).ClientGotoState('Dead', 'Begin');
        return;
    }
    if (PlayerController(aPlayer) != None)
        PlayerController(aPlayer).TimeMargin = -0.1;
    aPlayer.Pawn.Anchor = startSpot;
    aPlayer.Pawn.LastStartSpot = PlayerStart(startSpot);
    aPlayer.Pawn.LastStartTime = Level.TimeSeconds;
    aPlayer.PreviousPawnClass = aPlayer.Pawn.Class;

    aPlayer.Possess(aPlayer.Pawn);
    aPlayer.PawnClass = aPlayer.Pawn.Class;

    aPlayer.Pawn.PlayTeleportEffect(true, true);
    aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);
    AddDefaultInventory(aPlayer.Pawn);
    TriggerEvent(StartSpot.Event, StartSpot, aPlayer.Pawn);

    if (bAllowVehicles && (Level.NetMode == NM_Standalone) &&
        (PlayerController(aPlayer) != None)) {
        // tell bots not to get into nearby vehicles for a little while
        BestDist = 2000;
        ViewDir = vector(aPlayer.Pawn.Rotation);
        for (V = VehicleList; V != None; V = V.NextVehicle)
            if (V.bTeamLocked && (aPlayer.GetTeamNum() == V.Team)) {
                Dist = VSize(V.Location - aPlayer.Pawn.Location);
                if ((ViewDir Dot(V.Location - aPlayer.Pawn.Location)) < 0)
                    Dist *= 2;
                if (Dist < BestDist) {
                    Best = V;
                    BestDist = Dist;
                }
            }

        if (Best != None) Best.PlayerStartTime = Level.TimeSeconds + 8;
    }
}

defaultproperties
{
     bSpawnInTeamArea=True
     DefaultVoiceChannel="Team"
     bWeaponStay=False
     bAllowWeaponThrowing=False
     ScoreBoardType="ksstrike.zboardteamdeathmatch"
     HUDType="ksstrike.dmhud"
     MapListType="ksstrike.kfmaplistdeathmatch"
     GoalScore=15
     PlayerControllerClass=Class'KsStrike.zombiePlayerController'
     PlayerControllerClassName="ksstrike.zombieplayercontroller"
     GameReplicationInfoClass=Class'KFMod.KFGameReplicationInfo'
     GameName="Team Deathmatch"
}
